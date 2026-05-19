#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# test-presence.sh — 检查 SELF_REVIEW 前是否有测试文件
# 验证条件：新增/修改的实现文件有对应的测试文件

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

if ! git -C "$PROJECT_ROOT" rev-parse --git-dir &>/dev/null; then
  exit 0
fi

src_files=$(git -C "$PROJECT_ROOT" diff --name-only --diff-filter=AM HEAD~1 -- \
  '*.py' '*.js' '*.ts' '*.go' '*.rs' '*.sh' 2>/dev/null || true)

if [[ -z "$src_files" ]]; then
  exit 0
fi

missing=()
while IFS= read -r src; do
  [[ -z "$src" ]] && continue
  base="${src%.*}"
  test_found=false

  for test_ext in py js ts go rs sh; do
    if ls "$PROJECT_ROOT/${base}_test.$test_ext" "$PROJECT_ROOT/${base}.test.$test_ext" 2>/dev/null | grep -q .; then
      test_found=true
      break
    fi
  done

  test_path="$PROJECT_ROOT/tests/$src"
  for test_ext in py js ts go rs sh; do
    if ls "${test_path%.*}_test.$test_ext" "${test_path%.*}.test.$test_ext" 2>/dev/null | grep -q .; then
      test_found=true
      break
    fi
  done

  if [[ "$test_found" == false ]]; then
    missing+=("$src")
  fi
done < <(echo "$src_files")

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "test-presence 未通过：以下文件缺少测试："
  printf '  - %s\n' "${missing[@]}"
  exit 1
fi

exit 0
