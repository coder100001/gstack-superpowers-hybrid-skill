#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# transition.sh — 状态跃迁入口
# 用法: ./governance/transition.sh <from> <to> [--level L3] [--reason string]
# 示例: ./governance/transition.sh IDEA DISCOVERY --level L3 --reason "new feature"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINE_FILE="$SCRIPT_DIR/machine.json"
GATES_FILE="$SCRIPT_DIR/gates.json"
JOURNAL_DIR="$SCRIPT_DIR/state-journal"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ $# -lt 2 ]]; then
  echo "用法: transition.sh <from> <to> [--level L1|L2|L3] [--reason <reason>]"
  echo ""
  echo "示例:"
  echo "  transition.sh IDEA DISCOVERY --level L3"
  echo "  transition.sh CONTEXT_HYDRATION IMPLEMENTATION --level L3 --reason plan_confirmed"
  echo "  transition.sh IMPLEMENTATION SELF_REVIEW --level L3"
  exit 1
fi

FROM="$1"; shift
TO="$1"; shift
LEVEL="L3"
REASON=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --level) LEVEL="$2"; shift 2 ;;
    --reason) REASON="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

# 1. 校验跃迁合法性
if [[ ! -f "$MACHINE_FILE" ]]; then
  echo "错误: machine.json 不存在（期望路径: $MACHINE_FILE）"
  exit 1
fi

is_valid=false
if command -v python3 &>/dev/null; then
  while IFS= read -r line; do
    f=$(echo "$line" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('from',''))" 2>/dev/null || echo "")
    t=$(echo "$line" | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d.get('to',''))" 2>/dev/null || echo "")
    if { [[ "$f" == "$FROM" ]] || [[ "$f" == "*" ]]; } && [[ "$t" == "$TO" ]]; then
      is_valid=true
      break
    fi
  done < <(python3 -c "
import json
with open('$MACHINE_FILE') as f:
    m = json.load(f)
for t in m['transitions']:
    print(json.dumps(t))
" 2>/dev/null)
else
  echo "警告: 需要 python3 解析 machine.json"
  exit 1
fi

if [[ "$is_valid" != true ]]; then
  echo "非法跃迁: $FROM → $TO"
  echo ""
  echo "合法跃迁:"
  python3 -c "
import json
with open('$MACHINE_FILE') as f:
    m = json.load(f)
for t in m['transitions']:
    f = t['from'] if t['from'] != '*' else 'ANY'
    r = ' (' + t.get('reason','') + ')' if t.get('reason') else ''
    print(f'  {f} → {t[\"to\"]}{r}')
" 2>/dev/null || echo "  (读取 machine.json 失败)"
  exit 1
fi

# 2. 检查目标状态是否有 gate
gate_name=""
if [[ -f "$GATES_FILE" ]]; then
  gate_name=$(python3 -c "
import json
with open('$GATES_FILE') as f:
    g = json.load(f)
for gate in g['gates']:
    if '$TO' in gate['applies_to']:
        print(gate['name'])
        break
" 2>/dev/null || echo "")
fi

# 3. 如果有 gate，执行对应脚本
gates_passed=""
if [[ -n "$gate_name" ]]; then
  gate_script="$SCRIPT_DIR/gates/$gate_name.sh"
  if [[ -f "$gate_script" ]]; then
    echo "→ 门禁检查: $gate_name"
    if ! bash "$gate_script"; then
      echo ""
      echo "✗ 跃迁被阻断: $FROM → $TO (gate: $gate_name)"
      exit 1
    fi
    echo "  ✓ Gate 通过: $gate_name"
    gates_passed="$gate_name"
  else
    echo "  ! Gate 脚本不存在: $gate_name.sh（跳过）"
  fi
fi

# 4. 写入 journal
mkdir -p "$JOURNAL_DIR"
journal_file="$JOURNAL_DIR/$(date +%Y-%m-%d).json"

epoch=$(date +%s 2>/dev/null || echo 0)
ts=$(date -u -Iseconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00" 2>/dev/null || echo "$(date +%Y-%m-%dT%H:%M:%S)")

gp_json="[]"
if [[ -n "$gates_passed" ]]; then
  gp_json="[\"$gates_passed\"]"
fi

entry="{\"timestamp\":\"$ts\",\"from\":\"$FROM\",\"to\":\"$TO\",\"level\":\"$LEVEL\",\"gates_passed\":$gp_json,\"reason\":\"$REASON\",\"session\":\"agent-enforcement\"}"
echo "$entry" >> "$journal_file"

# 5. 打印摘要
echo ""
echo "✓ 状态跃迁完成"
echo "  $FROM → $TO"
echo "  级别: $LEVEL"
echo "  Gate: ${gates_passed:-无}"
echo "  Journal: $journal_file"
