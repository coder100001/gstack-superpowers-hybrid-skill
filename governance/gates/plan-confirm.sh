#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# plan-confirm.sh — 检查 PLAN_CONFIRM 是否已通过
# 验证条件：存在已确认的 plan（Approval/确认标记）且 workflow-state 记录已确认

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLANS_DIR="$PROJECT_ROOT/specs/plans"
STATE_FILE="$PROJECT_ROOT/artifacts/workflow-state.md"

latest_plan=$(ls -t "$PLANS_DIR"/*.md 2>/dev/null | head -1 || true)
if [[ -z "${latest_plan:-}" ]]; then
  echo "✗ PLAN_CONFIRM 未通过：未找到 plan 文件"
  echo "  期望路径: specs/plans/*.md"
  exit 1
fi

if ! grep -qiE "^##.*(Approval|确认)|\[x\].*(confirmed|确认)" "$latest_plan" 2>/dev/null; then
  echo "✗ PLAN_CONFIRM 未通过：最新 plan 缺少确认标记"
  echo "  文件: $latest_plan"
  echo "  建议: 添加 '## Approval' 与 '[x] User confirmed ...'"
  exit 1
fi

if [[ ! -f "$STATE_FILE" ]]; then
  echo "✗ PLAN_CONFIRM 未通过：缺少 workflow-state"
  echo "  期望文件: artifacts/workflow-state.md"
  exit 1
fi

if ! grep -qiE "plan[._ -]?confirmed:[[:space:]]*(true|yes|1)|\[x\].*(plan|计划).*(confirmed|确认)" "$STATE_FILE" 2>/dev/null; then
  echo "✗ PLAN_CONFIRM 未通过：workflow-state 未记录计划确认"
  echo "  文件: $STATE_FILE"
  echo "  建议: 写入 'plan_confirmed: true' 或明确勾选确认项"
  exit 1
fi

echo "✓ PLAN_CONFIRM 通过"
echo "  Plan: $latest_plan"
echo "  State: $STATE_FILE"
exit 0
