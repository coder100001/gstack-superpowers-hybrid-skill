#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# requirement-lock.sh — 检查 REQUIREMENT_LOCK 是否已通过
# 验证条件：context-layer/specs/ 下最新 spec 文件包含确认标记

SPEC_DIR="context-layer/specs"
TODAY=$(date +%Y-%m-%d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

specs=$(ls "$PROJECT_ROOT/$SPEC_DIR"/"$TODAY"-*-spec.md 2>/dev/null || true)
if [[ -z "$specs" ]]; then
  specs=$(ls "$PROJECT_ROOT/$SPEC_DIR"/*-spec.md 2>/dev/null | tail -3 || true)
fi

if [[ -z "$specs" ]]; then
  echo ""
  echo "✗ REQUIREMENT_LOCK 未通过：未找到 spec 文件"
  echo ""
  echo "期望路径: context-layer/specs/YYYY-MM-DD-*-spec.md"
  echo ""
  echo "修复步骤:"
  echo "  1. 运行 /brainstorm 生成需求文档"
  echo "  2. 确认需求后运行 /plan"
  echo "  3. 或手动创建 spec 文件并添加 ## Approval 章节"
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

latest=$(echo "$specs" | tail -1)
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
