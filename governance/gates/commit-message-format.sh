#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# commit-message-format.sh — 校验最近 N 条 commit subject 是否符合统一格式（软门禁）
# 格式: type(scope): summary
# 允许 type: feat|fix|refactor|docs|test|chore|perf|ci|build|revert

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/common-context.sh"

MAX_COMMITS="${1:-${GSTACK_COMMIT_MSG_CHECK_COUNT:-20}}"
if ! [[ "$MAX_COMMITS" =~ ^[0-9]+$ ]] || [[ "$MAX_COMMITS" -le 0 ]]; then
  MAX_COMMITS=20
fi

pattern='^(feat|fix|refactor|docs|test|chore|perf|ci|build|revert)(\([a-z0-9._/-]+\))?!?: .+$'

if ! git -C "$PROJECT_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  gate_log_fallback "git repo not detected; skipping commit message format check"
  echo "✓ commit-message-format skipped (no git repo)"
  exit 0
fi

subjects="$(git -C "$PROJECT_ROOT" log -n "$MAX_COMMITS" --pretty=format:%s 2>/dev/null || true)"
if [[ -z "${subjects:-}" ]]; then
  gate_log_fallback "no commit history found; skipping commit message format check"
  echo "✓ commit-message-format skipped (no commits)"
  exit 0
fi

invalid_count=0
total_count=0

while IFS= read -r subject; do
  [[ -n "$subject" ]] || continue
  total_count=$((total_count + 1))
  if ! [[ "$subject" =~ $pattern ]]; then
    if [[ $invalid_count -eq 0 ]]; then
      echo "✗ commit-message-format: 发现不合规提交信息"
    fi
    invalid_count=$((invalid_count + 1))
    echo "  - $subject"
  fi
done <<< "$subjects"

if [[ "$invalid_count" -gt 0 ]]; then
  echo "建议格式: type(scope): summary"
  echo "允许 type: feat|fix|refactor|docs|test|chore|perf|ci|build|revert"
  echo "检查范围: 最近 $total_count 条 commit"
  exit 1
fi

echo "✓ commit-message-format 通过（最近 $total_count 条 commit）"
exit 0

