#!/bin/bash
set -euo pipefail

# resolve-skill-routes.sh — 消费 schema/skill-routes.yaml 中 detect 规则
# 用法:
#   ./scripts/resolve-skill-routes.sh --category gstack --state QA --level L3 \
#     --files "src/auth/login.ts,src/ui/button.tsx" --text "fix auth token bug" [--json]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ROUTES_FILE="$PROJECT_ROOT/schema/skill-routes.yaml"

CATEGORY="gstack"
STATE=""
LEVEL="L3"
FILES=""
TEXT=""
OUTPUT_JSON=false

# model_tier support
model_tier="${HYBRID_MODEL_TIER:-capable}"
if [[ -f "${GSTACK_GATE_CONTEXT:-}" ]]; then
  mt=$(grep -iE "^model_tier:" "$GSTACK_GATE_CONTEXT" 2>/dev/null | head -1 | sed 's/^[^:]*:[[:space:]]*//' | tr -d '"'"'"')
  if [[ -n "$mt" ]]; then
    model_tier="$mt"
  fi
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --category) CATEGORY="$2"; shift 2 ;;
    --state) STATE="$2"; shift 2 ;;
    --level) LEVEL="$2"; shift 2 ;;
    --files) FILES="$2"; shift 2 ;;
    --text) TEXT="$2"; shift 2 ;;
    --json) OUTPUT_JSON=true; shift ;;
    --help)
      echo "用法: resolve-skill-routes.sh --category gstack --state <STATE> --level <L0|L1|L2|L3> [--files csv] [--text text] [--json]"
      exit 0
      ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

if [[ -z "$STATE" ]]; then
  echo "✗ 错误: 缺少 --state"
  exit 1
fi

if [[ ! -f "$ROUTES_FILE" ]]; then
  echo "✗ 错误: routes 文件不存在: $ROUTES_FILE"
  exit 1
fi

python3 - "$ROUTES_FILE" "$CATEGORY" "$STATE" "$LEVEL" "$FILES" "$TEXT" "$OUTPUT_JSON" "$model_tier" << 'PYEOF'
import fnmatch
import json
import sys
from pathlib import Path

import yaml

routes_file = Path(sys.argv[1])
category = sys.argv[2]
state = sys.argv[3]
level = sys.argv[4]
files_csv = sys.argv[5]
text = sys.argv[6]
output_json = sys.argv[7].lower() == "true"
model_tier = sys.argv[8] if len(sys.argv) > 8 else "capable"

files = [f.strip() for f in files_csv.split(",") if f.strip()]
text_l = text.casefold()

with routes_file.open("r", encoding="utf-8") as f:
    data = yaml.safe_load(f)

routes = (data.get("routes") or {}).get(category, {})
state_routes = routes.get(state, [])

matches = []

for route in state_routes:
    name = route.get("name")
    trigger = (route.get("trigger") or "").casefold()
    manual = bool(route.get("manual", False))
    auto_trigger = bool(route.get("auto_trigger", False))
    detect = route.get("detect") or {}

    # 手动技能不能被自动路由命中。
    if manual:
        continue

    # model_tier: capable 时跳过 full_subagent_review 路由
    if model_tier == "capable" and "full_subagent_review" in trigger:
        continue

    # 无 detect 的路由使用轻量语义规则兜底。
    if not detect:
        reasons = []
        if auto_trigger:
            reasons.append("auto_trigger")

        if "all tasks" in trigger:
            reasons.append("trigger:all_tasks")
        elif "l2+" in trigger and level in {"L2", "L3"}:
            reasons.append("trigger:l2_plus")
        elif "l3" in trigger and level == "L3":
            reasons.append("trigger:l3")

        if reasons:
            matches.append({"name": name, "reason": reasons})
        continue

    reasons = []

    cplx = detect.get("complexity")
    if cplx:
        if level in cplx:
            reasons.append("complexity")
        else:
            continue

    selector_hits = []

    pats = detect.get("file_patterns") or []
    if pats:
        hit = False
        for f in files:
            for p in pats:
                if fnmatch.fnmatch(f, p):
                    hit = True
                    break
            if hit:
                break
        if hit:
            selector_hits.append("file_patterns")

    kws = detect.get("keywords") or []
    if kws:
        hit = any(k.casefold() in text_l for k in kws)
        if hit:
            selector_hits.append("keywords")

    # 文件模式/关键词存在时，命中其一即可；两者都没命中则不路由。
    if (pats or kws) and not selector_hits:
        continue

    reasons.extend(selector_hits)
    if not reasons:
        # 只有 complexity 等前置条件时，保留一个显式原因。
        if cplx:
            reasons.append("complexity")
        else:
            continue

    matches.append({"name": name, "reason": reasons})

if output_json:
    print(json.dumps({"category": category, "state": state, "level": level, "matches": matches}, ensure_ascii=False, indent=2))
else:
    print("==========================================")
    print("Resolved Skill Routes")
    print("==========================================")
    print(f"category: {category}")
    print(f"state: {state}")
    print(f"level: {level}")
    print("")
    if not matches:
        print("(none)")
    else:
        for m in matches:
            print(f"- {m['name']} [{', '.join(m['reason'])}]")
PYEOF
