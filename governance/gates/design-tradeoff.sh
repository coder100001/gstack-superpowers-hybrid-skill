#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# design-tradeoff.sh — 检查方案设计是否包含备选方案与权衡说明（软门禁）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ADR_DIR="$PROJECT_ROOT/decision-layer/adr"
source "$SCRIPT_DIR/common-context.sh"

context_adr="$(gate_context_get "adr_file")"
if [[ -n "$context_adr" ]]; then
  target_adr="$(gate_context_path "$context_adr" "$PROJECT_ROOT")"
else
  gate_log_fallback "adr_file not set; selecting newest ADR for tradeoff check"
  target_adr=$(ls -t "$ADR_DIR"/ADR-*.md 2>/dev/null | head -1 || true)
fi

if [[ -z "${target_adr:-}" ]] || [[ ! -f "$target_adr" ]]; then
  echo "✗ design-tradeoff: 未找到 ADR 文件"
  exit 1
fi

options_count=$(grep -ciE "^(##|###).*(Option|方案)" "$target_adr" 2>/dev/null || true)
has_tradeoff=false
has_decision=false

if grep -qiE "(Trade[- ]?off|权衡|Pros?|Cons?|优缺点)" "$target_adr" 2>/dev/null; then
  has_tradeoff=true
fi
if grep -qiE "^(##|###).*(Decision|决策)|^Decision:" "$target_adr" 2>/dev/null; then
  has_decision=true
fi

if [[ "$options_count" -lt 2 ]] || [[ "$has_tradeoff" != "true" ]] || [[ "$has_decision" != "true" ]]; then
  echo "✗ design-tradeoff: 设计权衡信息不完整"
  echo "  文件: $target_adr"
  echo "  期望: 至少 2 个方案 + 权衡说明 + 决策结论"
  exit 1
fi

echo "✓ design-tradeoff 通过"
echo "  文件: $target_adr"
exit 0
