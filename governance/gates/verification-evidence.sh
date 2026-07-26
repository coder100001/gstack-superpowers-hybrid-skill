#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# verification-evidence.sh — 检查 SHIP_REVIEW 前是否有测试证据
# 验证条件：
# - L1: approval_mode=conversation + 非空证据文件
# - L2+: 证据含 pass 信号（exit 0 / tests passed 等）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/common-context.sh"

level="$(gate_context_level "$PROJECT_ROOT")"
approval_mode="$(gate_context_get "approval_mode")"
evidence_dir="$PROJECT_ROOT/artifacts/verification"

# 检查是否存在证据
evidence_found=false
evidence_passed=false

if [[ -d "$evidence_dir" ]]; then
  # 查找最新的证据文件
  latest_evidence=$(ls -t "$evidence_dir"/*.txt "$evidence_dir"/*.md "$evidence_dir"/*.log "$evidence_dir"/*.json 2>/dev/null | head -1 || true)
  if [[ -n "$latest_evidence" ]]; then
    evidence_found=true
    # 检查是否含 pass 信号
    if grep -qiE "(exit 0|tests passed|all tests|✓|passed|success|0 failures)" "$latest_evidence" 2>/dev/null; then
      evidence_passed=true
    fi
  fi
fi

# 也检查 context 中的 test_output key
test_output="$(gate_context_get "test_output" "verification_output")"
if [[ -n "$test_output" ]]; then
  evidence_found=true
  if echo "$test_output" | grep -qiE "(exit 0|tests passed|all tests|✓|passed|success|0 failures)"; then
    evidence_passed=true
  fi
fi

# L1: approval_mode=conversation + 非空证据
if [[ "$level" == "L1" ]] && [[ "$approval_mode" == "conversation" ]] && $evidence_found; then
  echo "✓ VERIFICATION_EVIDENCE 通过 (L1 conversation + evidence)"
  exit 0
fi

# L2+: 证据必须含 pass 信号
if $evidence_found && $evidence_passed; then
  echo "✓ VERIFICATION_EVIDENCE 通过"
  echo "  证据文件: ${latest_evidence:-"context key test_output"}"
  exit 0
fi

# Fallback: 允许用户声明 approval_mode=conversation + 内联确认（L1 快路径）
if [[ "$level" == "L1" ]] && gate_is_truthy "$(gate_context_get "verification_confirmed")"; then
  echo "✓ VERIFICATION_EVIDENCE 通过 (L1 conversation confirmation)"
  exit 0
fi

# 失败
echo ""
echo "✗ VERIFICATION_EVIDENCE 未通过：缺少测试验证证据"
echo ""
echo "当前检查:"
echo "  证据目录: $evidence_dir"
echo "  证据存在: $evidence_found"
echo "  证据通过: $evidence_passed"
echo "  级别: $level"
echo "  approval_mode: ${approval_mode:-未设置}"
echo ""
echo "修复步骤:"
echo "  1. 运行测试并将输出保存到 artifacts/verification/"
echo "  2. 或设置 context test_output 包含测试结果"
echo "  3. L1 快速通道可设置 verification_confirmed: true + approval_mode: conversation"
echo ""
exit 1
