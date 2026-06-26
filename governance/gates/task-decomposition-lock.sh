#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# task-decomposition-lock.sh — 检查 TASK_DECOMPOSITION 是否已通过
# 验证条件：
# - L2/L3: plan 文件存在且不含 TBD/TODO/PLACEHOLDER，且已确认
# - L1: 允许通过 workflow-state/context 记录的变更摘要式确认

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLANS_DIR="$PROJECT_ROOT/specs/plans"
STATE_FILE="$PROJECT_ROOT/artifacts/workflow-state.md"
source "$SCRIPT_DIR/common-context.sh"
level="$(gate_context_level "$PROJECT_ROOT")"
plan_confirmed="$(gate_context_get "plan_confirmed")"
plan_summary_confirmed="$(gate_context_get "plan_summary_confirmed")"
approval_mode="$(gate_context_get "approval_mode")"

if [[ -f "$STATE_FILE" ]]; then
  if [[ -z "$plan_confirmed" ]]; then
    plan_confirmed="$(gate_workflow_state_value "plan_confirmed" "$STATE_FILE")"
  fi
  if [[ -z "$plan_summary_confirmed" ]]; then
    plan_summary_confirmed="$(gate_workflow_state_value "plan_summary_confirmed" "$STATE_FILE")"
  fi
  if [[ -z "$approval_mode" ]]; then
    approval_mode="$(gate_workflow_state_value "approval_mode" "$STATE_FILE")"
  fi
fi

if [[ "$level" == "L1" ]] && { gate_is_truthy "$plan_summary_confirmed" || gate_is_truthy "$plan_confirmed"; }; then
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00")
  if [[ -f "$STATE_FILE" ]]; then
    gate_workflow_state_append "$STATE_FILE" "Task Decomposition Lock" \
      "- Timestamp: $ts" \
      "- Status: passed" \
      "- Confirmation: ${approval_mode:-conversation}" \
      "- Mode: L1 quick path"
  fi
  echo "✓ TASK_DECOMPOSITION 通过"
  echo "  确认方式: ${approval_mode:-conversation}"
  [[ -f "$STATE_FILE" ]] && echo "  状态文件: $STATE_FILE"
  exit 0
fi

# 检查 plan 文件是否存在
plan_files=$(ls "$PLANS_DIR"/*.md 2>/dev/null || true)

if [[ -z "$plan_files" ]]; then
  echo ""
  echo "✗ TASK_DECOMPOSITION 未通过：未找到 plan 文件"
  echo ""
  echo "期望路径: specs/plans/*.md"
  echo ""
  echo "修复步骤:"
  echo "  1. 运行 /plan 生成任务分解文档"
  echo "  2. 或手动创建 plan 文件到 specs/plans/ 目录"
  echo "  3. 确保 plan 文件中不包含 TBD/TODO/PLACEHOLDER"
  echo "  4. L1 快速通道可在 workflow-state/context 中记录 plan_summary_confirmed: true"
  exit 1
fi

# 仅检查最近的 plan 文件，避免旧 plan 占位符阻断新任务
# 策略：优先使用 workflow-state.md 中记录的当前 plan，否则使用最新修改的 plan
recent_plans=()

# 优先使用 context 指定 plan
context_plan="$(gate_context_get "plan_file" "current_plan_file")"
if [[ -n "$context_plan" ]]; then
  resolved_context_plan="$(gate_context_path "$context_plan" "$PROJECT_ROOT")"
  if [[ -f "$resolved_context_plan" ]]; then
    recent_plans+=("$resolved_context_plan")
  fi
fi

# 尝试从 workflow-state.md 获取当前 plan 文件
if [[ ${#recent_plans[@]} -eq 0 && -f "$STATE_FILE" ]]; then
  gate_log_fallback "plan_file not set; reading plan from workflow-state"
  current_plan=$(grep -i "current.plan\|current_plan\|plan_file" "$STATE_FILE" 2>/dev/null | head -1 | sed 's/.*:[[:space:]]*//' || true)
  if [[ -n "$current_plan" ]] && [[ -f "$PROJECT_ROOT/$current_plan" ]]; then
    recent_plans+=("$PROJECT_ROOT/$current_plan")
  fi
fi

# 如果没有记录，使用最新修改的 plan 文件
if [[ ${#recent_plans[@]} -eq 0 ]]; then
  gate_log_fallback "workflow-state has no usable plan; selecting newest plan file"
  latest_plan=$(ls -t "$PLANS_DIR"/*.md 2>/dev/null | head -1 || true)
  if [[ -n "$latest_plan" ]]; then
    recent_plans=("$latest_plan")
  fi
fi

# 检查 plan 文件是否包含禁止的占位符（仅检查最近文件）
has_placeholder=false
placeholder_patterns=("TBD" "PLACEHOLDER" "FIXME" "implement later" "待定" "待确认")

for plan_file in "${recent_plans[@]}"; do
  for pattern in "${placeholder_patterns[@]}"; do
    if grep -qi "$pattern" "$plan_file" 2>/dev/null; then
      echo "  ✗ $(basename "$plan_file") 包含占位符: $pattern"
      has_placeholder=true
    fi
  done
  # TODO 单独检查：仅匹配任务/条目语义，避免代码示例误判
  while IFS=: read -r line_no line_text; do
    [[ -n "${line_text:-}" ]] || continue
    if [[ "$line_text" =~ ^[[:space:]]*[-*][[:space:]]*(\[.\][[:space:]]*)?TODO([[:space:]:]|$) ]] || [[ "$line_text" =~ ^[[:space:]]*TODO([[:space:]:]|$) ]]; then
      echo "  ✗ $(basename "$plan_file") 包含占位符: TODO (行 $line_no: $line_text)"
      has_placeholder=true
    fi
  done < <(grep -ni "TODO" "$plan_file" 2>/dev/null || true)
done

if [[ "$has_placeholder" == "true" ]]; then
  echo ""
  echo "✗ TASK_DECOMPOSITION 未通过：plan 文件包含未填充的占位符"
  echo ""
  echo "禁止的占位符: TBD, TODO, PLACEHOLDER, FIXME, implement later, 待定, 待确认"
  echo ""
  echo "修复步骤:"
  echo "  1. 将所有占位符替换为具体内容"
  echo "  2. 如果无法确定具体内容，说明需求不够清晰，应回退到 DISCOVERY"
  exit 1
fi

# 检查用户确认标记（仅检查 recent_plans，与占位符检查范围一致）
confirmed=false
for plan_file in "${recent_plans[@]}"; do
  if [[ -n "$plan_file" ]] && grep -qi "^##.*Approval\|^##.*approved\|\[x\].*confirmed\|\[x\].*确认" "$plan_file" 2>/dev/null; then
    confirmed=true
    break
  fi
done

if [[ "$confirmed" == "false" ]]; then
  echo ""
  echo "✗ TASK_DECOMPOSITION 未通过：plan 文件缺少用户确认标记"
  echo ""
  echo "修复步骤:"
  echo "  1. 在 plan 文件中添加确认章节:"
  echo ""
  echo "     ## Approval"
  echo "     - [x] User confirmed plan on $(date +%Y-%m-%d)"
  echo ""
  echo "  2. 或运行 /plan 重新生成带确认的 plan"
  exit 1
fi

# 记录状态（通过统一状态管理器）
gate_workflow_state_append "$STATE_FILE" "Task Decomposition Lock" \
  "- Status: passed" \
  "- Plans: $(echo "$plan_files" | wc -l | tr -d ' ') file(s)"

echo "✓ TASK_DECOMPOSITION 通过"
echo "  Plan 文件: $(echo "$plan_files" | wc -l | tr -d ' ') 个"
echo "  占位符检查: 通过"
echo "  用户确认: 已确认"
exit 0
