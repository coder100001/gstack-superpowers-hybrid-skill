#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# transition.sh — 状态跃迁入口
# 用法: ./governance/transition.sh <from> <to> [--level L0|L1|L2|L3] [--reason string] [--json]
# 示例: ./governance/transition.sh IDEA DISCOVERY --level L3 --reason "new feature" --json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINE_FILE="$SCRIPT_DIR/machine.json"
CHECK_GATES="$SCRIPT_DIR/check-gates.sh"
JOURNAL_DIR="$SCRIPT_DIR/state-journal"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# JSON 解析器选择: jq > python3 > 退出
has_jq=false
has_python3=false
if command -v jq &>/dev/null; then
  has_jq=true
elif command -v python3 &>/dev/null; then
  has_python3=true
fi

json_get() {
  local file="$1"
  local query="$2"
  if $has_jq; then
    jq -r "$query" "$file" 2>/dev/null || echo ""
  elif $has_python3; then
    python3 -c "
import json, sys, re

file_path = sys.argv[1]
query = sys.argv[2]

with open(file_path) as f:
    d = json.load(f)
result = d
parts = re.split(r'\.|\[|\]', query)
for part in parts:
    if not part:
        continue
    if part.isdigit():
        result = result[int(part)] if isinstance(result, list) and int(part) < len(result) else None
    elif isinstance(result, dict) and part in result:
        result = result[part]
    else:
        result = None
        break
if result is None:
    print('')
elif isinstance(result, (list, dict)):
    print(json.dumps(result))
else:
    print(result)
" "$file" "$query" 2>/dev/null || echo ""
  else
    echo ""
  fi
}

output_json_result() {
  local status="$1"
  local from="$2"
  local to="$3"
  local level="$4"
  local reason="$5"
  local gate_result="$6"
  local journal_path="$7"
  local state_file="$8"
  local error_code="$9"
  local error_msg="${10:-}"
  
  local ts
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00")
  
  python3 - "$status" "$from" "$to" "$level" "$reason" "$ts" "$gate_result" "$journal_path" "$state_file" "$error_code" "$error_msg" << 'PY'
import json
import sys

status, from_state, to_state, level, reason, ts, gate_result, journal_path, state_file, error_code, error_msg = sys.argv[1:12]

result = {
    "status": status,
    "from": from_state,
    "to": to_state,
    "level": level,
    "reason": reason,
    "timestamp": ts,
}

if gate_result:
    result["gate_result"] = json.loads(gate_result)
if journal_path:
    result["journal_path"] = journal_path
if state_file:
    result["state_file"] = state_file
if error_code:
    result["error"] = {
        "code": error_code,
        "message": error_msg,
    }

print(json.dumps(result, indent=2))
PY
}

if [[ $# -lt 2 ]]; then
  echo "用法: transition.sh <from> <to> [--level L0|L1|L2|L3] [--reason <reason>] [--json]"
  echo ""
  echo "示例:"
  echo "  transition.sh IDEA DISCOVERY --level L3"
  echo "  transition.sh CONTEXT_HYDRATION IMPLEMENTATION --level L3 --reason plan_confirmed"
  echo "  transition.sh IMPLEMENTATION SELF_REVIEW --level L3 --json"
  exit 1
fi

FROM="$1"; shift
TO="$1"; shift
LEVEL="L3"
REASON=""
OUTPUT_JSON=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --level) LEVEL="$2"; shift 2 ;;
    --reason) REASON="$2"; shift 2 ;;
    --json) OUTPUT_JSON=true; shift ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

# 检查 JSON 解析器
if ! $has_jq && ! $has_python3; then
  echo "错误: 需要 jq 或 python3 来解析 JSON"
  echo ""
  echo "安装建议:"
  echo "  macOS: brew install jq"
  echo "  Ubuntu: sudo apt install jq"
  echo "  或确保 python3 可用"
  exit 1
fi

# 1. 校验跃迁合法性
if [[ ! -f "$MACHINE_FILE" ]]; then
  if $OUTPUT_JSON; then
    output_json_result "error" "$FROM" "$TO" "$LEVEL" "$REASON" "" "" "" "MISSING_MACHINE_FILE" "machine.json 不存在"
  else
    echo "错误: machine.json 不存在（期望路径: $MACHINE_FILE）"
  fi
  exit 1
fi

is_valid=false
transition_count=$(json_get "$MACHINE_FILE" '.transitions | length')
transition_count=${transition_count:-0}

for ((i=0; i<transition_count; i++)); do
  f=$(json_get "$MACHINE_FILE" ".transitions[$i].from")
  t=$(json_get "$MACHINE_FILE" ".transitions[$i].to")
  if { [[ "$f" == "$FROM" ]] || [[ "$f" == "*" ]]; } && [[ "$t" == "$TO" ]]; then
    is_valid=true
    break
  fi
done

if [[ "$is_valid" != true ]]; then
  if $OUTPUT_JSON; then
    output_json_result "invalid" "$FROM" "$TO" "$LEVEL" "$REASON" "" "" "" "INVALID_TRANSITION" "非法跃迁: $FROM → $TO"
  else
    echo "非法跃迁: $FROM → $TO"
    echo ""
    echo "合法跃迁:"
    for ((i=0; i<transition_count; i++)); do
      f=$(json_get "$MACHINE_FILE" ".transitions[$i].from")
      t=$(json_get "$MACHINE_FILE" ".transitions[$i].to")
      r=$(json_get "$MACHINE_FILE" ".transitions[$i].reason")
      f_display=${f:-ANY}
      if [[ -n "$r" ]]; then
        echo "  $f_display → $t ($r)"
      else
        echo "  $f_display → $t"
      fi
    done
  fi
  exit 1
fi

# 2. 执行目标状态 Gate。check-gates.sh 消费 gates.yaml（Gate 真相源）。
gates_passed=""
gate_result_json=""

if [[ ! -x "$CHECK_GATES" ]]; then
  if $OUTPUT_JSON; then
    output_json_result "error" "$FROM" "$TO" "$LEVEL" "$REASON" "" "" "" "MISSING_CHECK_GATES" "check-gates.sh 不存在或不可执行"
  else
    echo "错误: check-gates.sh 不存在或不可执行（期望路径: $CHECK_GATES）"
  fi
  exit 1
fi

gate_check_json=""
if ! gate_check_json=$(bash "$CHECK_GATES" --from "$FROM" --to "$TO" --level "$LEVEL" --json); then
  gate_result_json=$(python3 - "$gate_check_json" << 'PY'
import json
import sys

try:
    data = json.loads(sys.argv[1])
except Exception:
    print(json.dumps({
        "status": "error",
        "gate_id": "G000",
        "gate_name": "check-gates",
        "message": "Gate 检查输出不是有效 JSON",
    }, ensure_ascii=False))
    raise SystemExit(0)

for item in data.get("gate_results", []):
    if item.get("status") in {"block", "error"}:
        print(json.dumps(item, ensure_ascii=False))
        break
else:
    print(json.dumps({
        "status": data.get("status", "block"),
        "gate_id": data.get("gate_id", "G000"),
        "gate_name": data.get("gate_name", "check-gates"),
        "message": data.get("message", "Gate 检查失败"),
    }, ensure_ascii=False))
PY
  )
  if $OUTPUT_JSON; then
    output_json_result "blocked" "$FROM" "$TO" "$LEVEL" "$REASON" "$gate_result_json" "" "" "GATE_BLOCKED" "Gate 阻断跃迁"
  else
    echo "$gate_check_json"
    echo ""
    echo "✗ 跃迁被阻断: $FROM → $TO"
  fi
  exit 1
fi

gate_result_json=$(python3 - "$gate_check_json" << 'PY'
import json
import sys

data = json.loads(sys.argv[1])
for item in data.get("gate_results", []):
    if item.get("status") == "pass":
        print(json.dumps(item, ensure_ascii=False))
        break
PY
)

gates_passed=$(python3 - "$gate_check_json" << 'PY'
import json
import sys

data = json.loads(sys.argv[1])
names = [
    item.get("gate_name", "")
    for item in data.get("gate_results", [])
    if item.get("status") == "pass" and item.get("gate_name")
]
print(",".join(names))
PY
)

if [[ -n "$gates_passed" ]] && ! $OUTPUT_JSON; then
  echo "  ✓ Gate 通过: $gates_passed"
fi

# 3. 解析路由（消费 schema/skill-routes.yaml detect 规则）
ROUTE_RESOLVER="$PROJECT_ROOT/scripts/resolve-skill-routes.sh"
resolved_routes="none"
resolved_routes_json="[]"
route_resolution_status="ok"
route_resolution_error="none"

if [[ -x "$ROUTE_RESOLVER" ]]; then
  route_error_file="$(mktemp /tmp/resolve-routes-status.XXXXXX)"
  changed_files_csv=$(
    {
      git diff --name-only --cached 2>/dev/null || true
      git diff --name-only 2>/dev/null || true
      git ls-files --others --exclude-standard 2>/dev/null || true
    } | awk 'NF' | sort -u | paste -sd, - || true
  )

  collect_route_names() {
    local category="$1"
    local json_out
    local stderr_file
    stderr_file="$(mktemp /tmp/resolve-routes-stderr.XXXXXX)"

    if ! json_out=$(bash "$ROUTE_RESOLVER" --category "$category" --state "$TO" --level "$LEVEL" --files "${changed_files_csv:-}" --text "$REASON" --json 2>"$stderr_file"); then
      printf '%s|%s:%s\n' "degraded" "$category" "$(tr '\n' ' ' <"$stderr_file" | sed 's/[[:space:]]\+/ /g' | sed 's/^ //; s/ $//')" > "$route_error_file"
      rm -f "$stderr_file"
      echo ""
      return
    fi
    rm -f "$stderr_file"

    if [[ -n "$json_out" ]]; then
      local parsed_names
      parsed_names=$(python3 -c '
import json,sys
try:
    data=json.loads(sys.argv[1])
    names=[m.get("name","") for m in data.get("matches",[]) if m.get("name")]
    print(",".join(names))
except Exception:
    raise SystemExit(1)
' "$json_out" 2>/dev/null) || {
        printf '%s|%s:%s\n' "degraded" "$category" "invalid_json" > "$route_error_file"
        echo ""
        return
      }
      echo "$parsed_names"
    fi
  }

  superpowers_routes="$(collect_route_names superpowers)"
  gstack_routes="$(collect_route_names gstack)"

  if [[ -s "$route_error_file" ]]; then
    route_error_line="$(tail -n 1 "$route_error_file" 2>/dev/null || true)"
    route_resolution_status="${route_error_line%%|*}"
    route_resolution_error="${route_error_line#*|}"
  fi
  rm -f "$route_error_file"

  merged_routes=$(
    {
      echo "$superpowers_routes"
      echo "$gstack_routes"
    } | tr ',' '\n' | awk 'NF' | sort -u | paste -sd, - || true
  )

  if [[ -n "$merged_routes" ]]; then
    resolved_routes="$merged_routes"
    resolved_routes_json=$(
      python3 -c '
import json,sys
items=[x for x in sys.argv[1].split(",") if x]
print(json.dumps(items, ensure_ascii=False))
' "$merged_routes" 2>/dev/null || echo "[]"
    )
  fi
else
  route_resolution_status="degraded"
  route_resolution_error="resolver_unavailable"
fi

# 5. 更新状态持久化文件（通过统一状态管理器）
source "$SCRIPT_DIR/lib/state-manager.sh"

STATE_FILE="$PROJECT_ROOT/artifacts/workflow-state.md"
mkdir -p "$(dirname "$STATE_FILE")"

ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00")

# 初始化（仅在文件不存在时创建骨架）
state_manager_init "$STATE_FILE" "agent-enforcement"

# 更新当前状态
state_manager_set_current "$STATE_FILE" \
  "status=$TO" \
  "level=$LEVEL" \
  "previous=$FROM" \
  "gate_passed=${gates_passed:-none}" \
  "route_skills=${resolved_routes}" \
  "route_resolution=${route_resolution_status}" \
  "route_resolution_error=${route_resolution_error}" \
  "reason=$REASON"

# 追加历史记录（幂等：相同 from/to/level/gate 不重复追加）
state_manager_add_history "$STATE_FILE" "$FROM" "$TO" "$LEVEL" "${gates_passed:-—}" "${resolved_routes}"

# 6. 写入 journal
mkdir -p "$JOURNAL_DIR"
journal_file="$JOURNAL_DIR/$(date +%Y-%m-%d).json"

gp_json="[]"
if [[ -n "$gates_passed" ]]; then
  gp_json="[\"$gates_passed\"]"
fi

entry=$(
  python3 -c '
import json
import sys

result = {
    "timestamp": sys.argv[1],
    "from": sys.argv[2],
    "to": sys.argv[3],
    "level": sys.argv[4],
    "gates_passed": json.loads(sys.argv[5]),
    "route_skills": json.loads(sys.argv[6]),
    "route_resolution_status": sys.argv[7],
    "route_resolution_error": sys.argv[8],
    "reason": sys.argv[9],
    "session": "agent-enforcement",
}
print(json.dumps(result, ensure_ascii=False))
' "$ts" "$FROM" "$TO" "$LEVEL" "$gp_json" "$resolved_routes_json" "$route_resolution_status" "$route_resolution_error" "$REASON"
)

journal_should_append=true
if [[ -f "$journal_file" ]]; then
  last_entry=$(tail -n 1 "$journal_file" 2>/dev/null || true)
  if [[ -n "$last_entry" ]]; then
    journal_compare=$(
      python3 -c '
import json
import sys

try:
    last = json.loads(sys.argv[1])
    current = json.loads(sys.argv[2])
except Exception:
    print("append")
    raise SystemExit(0)

keys = ["from", "to", "level", "gates_passed", "route_skills", "route_resolution_status", "route_resolution_error", "reason", "session"]
same = all(last.get(k) == current.get(k) for k in keys)
print("skip" if same else "append")
' "$last_entry" "$entry" 2>/dev/null || echo "append"
    )
    if [[ "$journal_compare" == "skip" ]]; then
      journal_should_append=false
    fi
  fi
fi

if [[ "$journal_should_append" == true ]]; then
  echo "$entry" >> "$journal_file"
fi

# 7. 输出结果
if $OUTPUT_JSON; then
  output_json_result "success" "$FROM" "$TO" "$LEVEL" "$REASON" "$gate_result_json" "$journal_file" "$STATE_FILE" "" ""
else
  echo ""
  echo "✓ 状态跃迁完成"
  echo "  $FROM → $TO"
  echo "  级别: $LEVEL"
  echo "  Gate: ${gates_passed:-无}"
  echo "  Routes: ${resolved_routes}"
  echo "  Route Resolution: ${route_resolution_status}"
  if [[ "$route_resolution_status" != "ok" ]]; then
    echo "  Route Error: ${route_resolution_error}"
  fi
  echo "  Journal: $journal_file"
  echo "  State: $STATE_FILE"
fi
