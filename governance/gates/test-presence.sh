#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# test-presence.sh — 检查 SELF_REVIEW 前是否有测试文件
# 验证条件：新增/修改的实现文件有对应的测试文件

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 非 git 环境警告但不阻断
if ! git -C "$PROJECT_ROOT" rev-parse --git-dir &>/dev/null; then
  echo "警告: 非 git 环境，跳过测试存在检查"
  exit 0
fi

MERGE_BASE=$(git -C "$PROJECT_ROOT" merge-base HEAD "origin/main" 2>/dev/null || echo "")
if [[ -z "$MERGE_BASE" ]]; then
  MERGE_BASE=$(git -C "$PROJECT_ROOT" merge-base HEAD "main" 2>/dev/null || echo "")
fi
if [[ -z "$MERGE_BASE" ]]; then
  src_files=$(git -C "$PROJECT_ROOT" diff --name-only --diff-filter=AM HEAD~1 -- \
    '*.py' '*.js' '*.ts' '*.go' '*.rs' '*.sh' 2>/dev/null || true)
  changed_test=$(git -C "$PROJECT_ROOT" diff --name-only --diff-filter=A HEAD~1 -- \
    '*_test*' '*.test.*' 2>/dev/null || true)
else
  src_files=$(git -C "$PROJECT_ROOT" diff --name-only --diff-filter=AM HEAD..."$MERGE_BASE" -- \
    '*.py' '*.js' '*.ts' '*.go' '*.rs' '*.sh' 2>/dev/null || true)
  changed_test=$(git -C "$PROJECT_ROOT" diff --name-only --diff-filter=A HEAD..."$MERGE_BASE" -- \
    '*_test*' '*.test.*' 2>/dev/null || true)
fi

if [[ -z "$src_files" ]]; then
  echo "✓ TEST_PRESENCE 通过（无源文件变更）"
  exit 0
fi

# First check if test files were committed alongside source
if [[ -n "${changed_test:-}" ]]; then
  echo "✓ TEST_PRESENCE 通过"
  echo "  已添加测试文件: $(echo "$changed_test" | head -1)"
  exit 0
fi

missing=()
while IFS= read -r src; do
  [[ -z "$src" ]] && continue
  base="${src%.*}"
  test_found=false

  # Pattern 1: src_test.ext or src.test.ext (same dir)
  for test_ext in py js ts go rs sh; do
    if ls "$PROJECT_ROOT/${base}_test.$test_ext" "$PROJECT_ROOT/${base}.test.$test_ext" 2>/dev/null | grep -q .; then
      test_found=true
      break
    fi
  done

  # Pattern 2: test_src.ext (same dir, prefix)
  if [[ "$test_found" == false ]]; then
    base_name=$(basename "$src" | sed 's/\.[^.]*$//')
    dir_name=$(dirname "$PROJECT_ROOT/$src")
    if ls "$dir_name/test_$base_name"* 2>/dev/null | grep -q .; then
      test_found=true
    fi
  fi

  # Pattern 3: tests/path/to/test_src.ext
  if [[ "$test_found" == false ]]; then
    test_path="$PROJECT_ROOT/tests/$src"
    for test_ext in py js ts go rs sh; do
      if ls "${test_path%.*}_test.$test_ext" "${test_path%.*}.test.$test_ext" "$PROJECT_ROOT/tests/test_${base_name}.${test_ext}" 2>/dev/null | grep -q .; then
        test_found=true
        break
      fi
    done
  fi

  if [[ "$test_found" == false ]]; then
    missing+=("$src")
  fi
done < <(echo "$src_files")

if [[ ${#missing[@]} -gt 0 ]]; then
  echo ""
  echo "✗ TEST_PRESENCE 未通过：以下文件缺少测试："
  printf '  - %s\n' "${missing[@]}"
  echo ""
  echo "修复步骤:"
  echo "  1. 为每个源文件创建对应的测试文件"
  echo ""
  echo "测试文件命名规范:"
  echo "  - Python: tests/test_module.py 或 module_test.py"
  echo "  - JavaScript/TypeScript: module.test.ts 或 module.test.js"
  echo "  - Go: module_test.go"
  echo "  - Rust: module_test.rs"
  echo ""
  echo "  2. 检查 project-config.yml 中的 test_command 配置"
  echo "  3. 运行测试确保通过: \$(test_command)"
  exit 1
fi

echo "✓ TEST_PRESENCE 通过"
echo "  所有源文件都有对应测试"
exit 0
