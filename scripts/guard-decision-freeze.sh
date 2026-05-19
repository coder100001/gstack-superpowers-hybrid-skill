#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# guard-decision-freeze.sh — CI 硬守卫
# 在 PR pipeline 中执行，检测决策冻结是否被违反
# 违反条件：同一 PR 同时修改 ADR/specs 和实现代码

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE="${1:-main}"

cd "$PROJECT_ROOT"

if ! git rev-parse --git-dir &>/dev/null; then
  echo "✅ 不在 git 仓库中，跳过"
  exit 0
fi

if git rev-parse HEAD &>/dev/null 2>&1; then
  MERGE_BASE=$(git merge-base HEAD "origin/$BASE" 2>/dev/null || echo "")
  if [[ -z "$MERGE_BASE" ]]; then
    MERGE_BASE=$(git merge-base HEAD "$BASE" 2>/dev/null || echo "")
  fi
  if [[ -z "$MERGE_BASE" ]]; then
    echo "⚠️  无法确定 merge base，使用 HEAD~1"
    changed=$(git diff --name-only HEAD~1 2>/dev/null || true)
  else
    changed=$(git diff --name-only HEAD..."$MERGE_BASE" 2>/dev/null || true)
  fi
else
  echo "⚠️  无法获取 HEAD，使用 HEAD~1"
  changed=$(git diff --name-only HEAD~1 2>/dev/null || true)
fi

if [[ -z "$changed" ]]; then
  echo "✅ No changes detected"
  exit 0
fi

adr_count=$(echo "$changed" | grep -cE "^decision-layer/adr/|^context-layer/specs/" 2>/dev/null || echo 0)
impl_count=$(echo "$changed" | grep -cE "^skills/hybrid/|^skills/superpowers/|^scripts/" 2>/dev/null || echo 0)

if [[ $adr_count -gt 0 && $impl_count -gt 0 ]]; then
  echo "❌ 决策冻结违规：同时变更了冻结区和执行区"
  echo ""
  echo "冻结区文件 ($adr_count):"
  echo "$changed" | grep -E "^decision-layer/adr/|^context-layer/specs/" | sed 's/^/  /'
  echo ""
  echo "执行区文件 ($impl_count):"
  echo "$changed" | grep -E "^skills/hybrid/|^skills/superpowers/|^scripts/" | sed 's/^/  /'
  echo ""
  echo "修复方案：将冻结变更拆到独立 PR，或用变更流程退回 Decision Layer"
  exit 1
fi

echo "✅ 决策冻结检查通过"
