#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# task-decomposition-lock.sh — 检查 TASK_DECOMPOSITION 是否已通过
# 验证条件：plan 文件存在且不含 TBD/TODO/PLACEHOLDER
# 记录确认状态到 artifacts/workflow-state.md

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PLANS_DIR="$PROJECT_ROOT/specs/plans"
STATE_FILE="$PROJECT_ROOT/artifacts/workflow-state.md"

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
  exit 1
fi

# 仅检查最近的 plan 文件，避免旧 plan 占位符阻断新任务
# 策略：优先使用 workflow-state.md 中记录的当前 plan，否则使用最新修改的 plan
recent_plans=()

# 尝试从 workflow-state.md 获取当前 plan 文件
if [[ -f "$STATE_FILE" ]]; then
  current_plan=$(grep -i "current.plan\|current_plan\|plan_file" "$STATE_FILE" 2>/dev/null | head -1 | sed 's/.*:[[:space:]]*//' || true)
  if [[ -n "$current_plan" ]] && [[ -f "$PROJECT_ROOT/$current_plan" ]]; then
    recent_plans+=("$PROJECT_ROOT/$current_plan")
  fi
fi

# 如果没有记录，使用最新修改的 plan 文件
if [[ ${#recent_plans[@]} -eq 0 ]]; then
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
  # TODO 单独检查：仅在行首或作为独立标记时才算占位符（避免代码示例中的 TODO 被误判）
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*[-*\[]*[[:space:]]*TODO ]] || [[ "$line" =~ ^[[:space:]]*TODO ]]; then
      echo "  ✗ $(basename "$plan_file") 包含占位符: TODO (行: $line)"
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

# 检查用户确认标记（检查所有 plan 文件，任一有确认即可）
confirmed=false
for plan_file in $plan_files; do
  if grep -qi "^##.*确认\|^##.*Approval\|^##.*approved\|\[x\].*confirmed\|\[x\].*确认" "$plan_file" 2>/dev/null; then
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

# 记录状态
mkdir -p "$(dirname "$STATE_FILE")"
ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00")

if [[ -f "$STATE_FILE" ]]; then
  # 追加确认记录
  echo "" >> "$STATE_FILE"
  echo "### Task Decomposition Lock" >> "$STATE_FILE"
  echo "- Timestamp: $ts" >> "$STATE_FILE"
  echo "- Status: passed" >> "$STATE_FILE"
  echo "- Plans: $(echo "$plan_files" | wc -l | tr -d ' ') file(s)" >> "$STATE_FILE"
else
  cat > "$STATE_FILE" << EOF
# Workflow State

> **Last Updated**: $ts

### Task Decomposition Lock
- Timestamp: $ts
- Status: passed
- Plans: $(echo "$plan_files" | wc -l | tr -d ' ') file(s)
EOF
fi

echo "✓ TASK_DECOMPOSITION 通过"
echo "  Plan 文件: $(echo "$plan_files" | wc -l | tr -d ' ') 个"
echo "  占位符检查: 通过"
echo "  用户确认: 已确认"
exit 0
