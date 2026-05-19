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
  echo "REQUIREMENT_LOCK 未通过：未找到 spec 文件"
  exit 1
fi

latest=$(echo "$specs" | tail -1)
if grep -qi "^##.*确认\|^##.*Approval\|^##.*approved" "$latest" 2>/dev/null; then
  exit 0
else
  echo "REQUIREMENT_LOCK 未通过：$latest 缺少确认标记"
  exit 1
fi
