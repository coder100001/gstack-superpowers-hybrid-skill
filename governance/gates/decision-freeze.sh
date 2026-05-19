#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# decision-freeze.sh — 检查 IMPLEMENTATION 期间决策冻结
# 验证条件：ADR 和 specs 在进入 IMPLEMENTATION 后未被修改

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

FROZEN_PATTERNS="^decision-layer/adr/|^context-layer/specs/"

if ! git -C "$PROJECT_ROOT" rev-parse --git-dir &>/dev/null; then
  exit 0
fi

if git -C "$PROJECT_ROOT" diff HEAD~1 --name-only 2>/dev/null | grep -qE "$FROZEN_PATTERNS"; then
  echo "决策冻结违规：IMPLEMENTATION 期间修改了以下冻结文件："
  git -C "$PROJECT_ROOT" diff HEAD~1 --name-only | grep -E "$FROZEN_PATTERNS" | sed 's/^/  - /'
  echo ""
  echo "修复：退回 Decision Layer 重新审议后再修改"
  exit 1
fi

exit 0
