#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# test_validate-project.sh — 测试 validate-project.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

passed=0
failed=0

test_case() {
  local name="$1" expected="$2"
  shift 2
  if "$@" >/dev/null 2>&1; then
    if [[ "$expected" == "pass" ]]; then
      echo "  ✓ $name"
      passed=$((passed + 1))
    else
      echo "  ✗ $name (expected fail, got pass)"
      failed=$((failed + 1))
    fi
  else
    if [[ "$expected" == "fail" ]]; then
      echo "  ✓ $name"
      passed=$((passed + 1))
    else
      echo "  ✗ $name (expected pass, got fail)"
      failed=$((failed + 1))
    fi
  fi
}

echo "=== validate-project.sh Tests ==="

test_case "运行 validate-project.sh 应通过" pass bash "$PROJECT_ROOT/scripts/validate-project.sh"

echo ""
echo "结果: $passed passed, $failed failed"
[[ $failed -eq 0 ]]
