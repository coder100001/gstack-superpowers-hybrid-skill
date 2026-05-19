#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# context-hydration.sh — 检查 CONTEXT_HYDRATION 是否已通过
# 验证条件：所有 P0 上下文契约文件存在

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

required=("project-spec" "architecture-spec" "constraints-spec" "domain-boundaries")
missing=()

for asset in "${required[@]}"; do
  if [[ ! -f "$PROJECT_ROOT/context-layer/specs/$asset.md" ]]; then
    missing+=("context-layer/specs/$asset.md")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "CONTEXT_HYDRATION 未通过：缺少上下文契约文件"
  printf '  - %s\n' "${missing[@]}"
  exit 1
fi

exit 0
