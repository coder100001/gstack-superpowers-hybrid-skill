#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# requirement-lock.sh — 检查 REQUIREMENT_LOCK 是否已通过
# 验证条件：
# - L2/L3: spec 文件存在且包含确认标记
# - L1: 允许通过 workflow-state/context 记录的对话式确认

SPEC_DIR="context-layer/specs"
TODAY=$(date +%Y-%m-%d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/common-context.sh"

context_spec="$(gate_context_get "spec_file" "requirement_spec_file")"
state_file="$(gate_workflow_state_file "$SCRIPT_DIR" "$PROJECT_ROOT")"
level="$(gate_context_level "$PROJECT_ROOT")"
requirements_confirmed="$(gate_context_get "requirements_confirmed")"
approval_mode="$(gate_context_get "approval_mode")"

if [[ -n "$state_file" ]]; then
  if [[ -z "$requirements_confirmed" ]]; then
    requirements_confirmed="$(gate_workflow_state_value "requirements_confirmed" "$state_file")"
  fi
  if [[ -z "$approval_mode" ]]; then
    approval_mode="$(gate_workflow_state_value "approval_mode" "$state_file")"
  fi
fi

if [[ "$level" == "L1" ]] && gate_is_truthy "$requirements_confirmed"; then
  confirmed_at="$(gate_context_get "confirmed_at" "confirmation_timestamp")"
  confirmed_by="$(gate_context_get "confirmed_by" "confirmer")"
  
  # Also try workflow-state fallback
  if [[ -z "$confirmed_at" && -n "$state_file" ]]; then
    confirmed_at="$(gate_workflow_state_value "confirmed_at" "$state_file")"
  fi
  if [[ -z "$confirmed_by" && -n "$state_file" ]]; then
    confirmed_by="$(gate_workflow_state_value "confirmed_by" "$state_file")"
  fi
  
  if [[ -z "$confirmed_at" || "$confirmed_by" != "user" ]]; then
    echo ""
    echo "✗ REQUIREMENT_LOCK 未通过：L1 对话确认缺少完整确认三元组"
    echo ""
    echo "需要以下三项："
    echo "  1. requirements_confirmed: true"
    echo "  2. confirmed_at: <ISO8601 timestamp>"
    echo "  3. confirmed_by: user"
    echo ""
    echo "当前状态:"
    echo "  requirements_confirmed: $requirements_confirmed"
    echo "  confirmed_at: ${confirmed_at:-未设置}"
    echo "  confirmed_by: ${confirmed_by:-未设置}"
    echo ""
    echo "修复: 请与用户口头确认需求后，在 context/workflow-state 中写入完整三元组"
    exit 1
  fi
  
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00")
  if [[ -n "$state_file" ]]; then
    gate_workflow_state_append "$state_file" "Requirement Lock" \
      "- Timestamp: $ts" \
      "- Status: passed" \
      "- Confirmation: ${approval_mode:-conversation}" \
      "- Mode: L1 quick path"
  fi
  echo "✓ REQUIREMENT_LOCK 通过"
  echo "  确认方式: ${approval_mode:-conversation}"
  if [[ -n "$state_file" ]]; then
    echo "  状态文件: $state_file"
  fi
  exit 0
fi

if [[ -n "$context_spec" ]]; then
  latest="$(gate_context_path "$context_spec" "$PROJECT_ROOT")"
else
  gate_log_fallback "spec_file not set; discovering latest spec"
  specs=$(ls "$PROJECT_ROOT/$SPEC_DIR"/"$TODAY"-*-spec.md 2>/dev/null || true)
  if [[ -z "$specs" ]]; then
    specs=$(ls "$PROJECT_ROOT/$SPEC_DIR"/*-spec.md 2>/dev/null | tail -3 || true)
  fi
  latest=$(echo "$specs" | tail -1)
fi

if [[ -z "${latest:-}" ]] || [[ ! -f "$latest" ]]; then
  echo ""
  echo "✗ REQUIREMENT_LOCK 未通过：未找到 spec 文件"
  echo ""
  echo "期望路径: context-layer/specs/YYYY-MM-DD-*-spec.md"
  echo ""
  echo "修复步骤:"
  echo "  1. 运行 /brainstorm 生成需求文档"
  echo "  2. 确认需求后运行 /plan"
  echo "  3. L1 快速通道可在 workflow-state/context 中记录 requirements_confirmed: true"
  echo "  4. 或手动创建 spec 文件并添加 ## Approval 章节"
  echo ""
  echo "示例 spec 文件格式:"
  echo "  ---"
  echo "  title: Feature Name"
  echo "  date: $TODAY"
  echo "  ---"
  echo "  "
  echo "  ## Requirements"
  echo "  - Requirement 1"
  echo "  - Requirement 2"
  echo "  "
  echo "  ## Approval"
  echo "  - [x] User confirmed on $TODAY"
  exit 1
fi

if grep -qi "^##.*确认\|^##.*Approval\|^##.*approved" "$latest" 2>/dev/null; then
  echo "✓ REQUIREMENT_LOCK 通过"
  echo "  确认文件: $latest"
  exit 0
else
  echo ""
  echo "✗ REQUIREMENT_LOCK 未通过：$latest 缺少确认标记"
  echo ""
  echo "修复步骤:"
  echo "  1. 在 spec 文件中添加确认章节:"
  echo ""
  echo "     ## Approval"
  echo "     - [x] User confirmed requirements on $(date +%Y-%m-%d)"
  echo ""
  echo "  2. 或运行 /plan 重新生成带确认的 spec"
  exit 1
fi
