#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# guard-test-presence.sh — CI 软检查
# 在 PR pipeline 中执行，警告无测试的代码变更
# warning 不阻断，仅做记录

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BASE="${1:-main}"

cd "$PROJECT_ROOT"

if ! git rev-parse --git-dir &>/dev/null; then
  echo "✅ 不在 git 仓库中，跳过"
  exit 0
fi

if git rev-parse HEAD &>/dev/null 2>&1; then
  MERGE_BASE=$(git merge-base HEAD "origin/$BASE" 2>/dev/null || "")
  if [[ -z "$MERGE_BASE" ]]; then
    MERGE_BASE=$(git merge-base HEAD "$BASE" 2>/dev/null || echo "")
  fi
  if [[ -z "$MERGE_BASE" ]]; then
    changed_src=$(git diff --name-only --diff-filter=AM HEAD~1 2>/dev/null || true)
    changed_test=$(git diff --name-only --diff-filter=A HEAD~1 2>/dev/null || true)
  else
    changed_src=$(git diff --name-only --diff-filter=AM HEAD..."$MERGE_BASE" 2>/dev/null || true)
    changed_test=$(git diff --name-only --diff-filter=A HEAD..."$MERGE_BASE" 2>/dev/null || true)
  fi
else
  changed_src=$(git diff --name-only --diff-filter=AM HEAD~1 2>/dev/null || true)
  changed_test=$(git diff --name-only --diff-filter=A HEAD~1 2>/dev/null || true)
fi

if [[ -z "$changed_src" ]]; then
  echo "✅ 测试存在检查完成（无变更）"
  exit 0
fi

src_count=$(echo "$changed_src" | grep -cP '\.(py|js|ts|go|rs|sh)$' 2>/dev/null || echo 0)
test_count=$(echo "$changed_test" | grep -cP '_test\.(py|js|ts|go|rs|sh)$' 2>/dev/null || echo 0)

if [[ $src_count -gt 0 && $test_count -eq 0 ]]; then
  echo "⚠️  $src_count 个文件变更但没有新增测试"
  echo "   建议补充测试后再合并"
fi

echo "✅ 测试存在检查完成"
