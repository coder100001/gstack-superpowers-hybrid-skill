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
  echo "错误: machine.json 不存在（期望路径: $MACHINE_FILE）"
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
  exit 1
fi

# 2. 检查目标状态是否有 gate
gate_name=""
if [[ -f "$GATES_FILE" ]]; then
  gate_count=$(json_get "$GATES_FILE" '.gates | length')
  gate_count=${gate_count:-0}
  for ((i=0; i<gate_count; i++)); do
    applies=$(json_get "$GATES_FILE" ".gates[$i].applies_to")
    if [[ "$applies" == *"$TO"* ]]; then
      gate_name=$(json_get "$GATES_FILE" ".gates[$i].name")
      break
    fi
  done
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
      echo ""
      echo "修复步骤:"
      case "$gate_name" in
        requirement-lock)
          echo "  1. 运行 /brainstorm 生成需求文档"
          echo "  2. 确认需求后运行 /plan"
          echo "  3. 或手动创建 spec 文件: context-layer/specs/YYYY-MM-DD-*-spec.md"
          echo "     并添加 ## Approval 章节记录用户确认"
          ;;
        context-hydration)
          echo "  1. 确保以下文件存在:"
          echo "     - context-layer/specs/project-spec.md"
          echo "     - context-layer/specs/architecture-spec.md"
          echo "     - context-layer/specs/constraints-spec.md"
          echo "  2. 检查 ADR 目录: decision-layer/adr/"
          ;;
        decision-freeze)
          echo "  1. 如果需要修改冻结项，请先回退到 Decision Layer"
          echo "  2. 运行: transition.sh IMPLEMENTATION ARCH_REVIEW --reason change_request"
          echo "  3. 或运行: transition.sh IMPLEMENTATION TASK_DECOMPOSITION --reason scope_change"
          echo "  4. 或创建新的 ADR 记录变更决策"
          ;;
        test-presence)
          echo "  1. 确保测试文件存在"
          echo "  2. 检查 project-config.yml 中的 test_command 配置"
          ;;
      esac
      exit 1
    fi
    echo "  ✓ Gate 通过: $gate_name"
    gates_passed="$gate_name"
  else
    echo "  ! Gate 脚本不存在: $gate_name.sh（跳过）"
  fi
fi

# 4. 更新状态持久化文件
STATE_FILE="$PROJECT_ROOT/artifacts/workflow-state.md"
mkdir -p "$(dirname "$STATE_FILE")"

epoch=$(date +%s 2>/dev/null || echo 0)
ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00")

# 读取现有历史
existing_history=""
if [[ -f "$STATE_FILE" ]]; then
  existing_history=$(sed -n '/^| [0-9]/p' "$STATE_FILE" 2>/dev/null | tail -20 || true)
fi

cat > "$STATE_FILE" << EOF
# Workflow State

> **Last Updated**: $ts
> **Session**: agent-enforcement

## Current State

\`\`\`yaml
status: $TO
level: $LEVEL
previous: $FROM
gate_passed: ${gates_passed:-none}
reason: $REASON
\`\`\`

## State History

| Timestamp | From | To | Level | Gate |
|-----------|------|-----|-------|------|
$existing_history
| $ts | $FROM | $TO | $LEVEL | ${gates_passed:-—} |

---
*This file is auto-generated by transition.sh*
EOF

# 5. 写入 journal
mkdir -p "$JOURNAL_DIR"
journal_file="$JOURNAL_DIR/$(date +%Y-%m-%d).json"

gp_json="[]"
if [[ -n "$gates_passed" ]]; then
  gp_json="[\"$gates_passed\"]"
fi

entry="{\"timestamp\":\"$ts\",\"from\":\"$FROM\",\"to\":\"$TO\",\"level\":\"$LEVEL\",\"gates_passed\":$gp_json,\"reason\":\"$REASON\",\"session\":\"agent-enforcement\"}"
echo "$entry" >> "$journal_file"

# 6. 打印摘要
echo ""
echo "✓ 状态跃迁完成"
echo "  $FROM → $TO"
echo "  级别: $LEVEL"
echo "  Gate: ${gates_passed:-无}"
echo "  Journal: $journal_file"
echo "  State: $STATE_FILE"
