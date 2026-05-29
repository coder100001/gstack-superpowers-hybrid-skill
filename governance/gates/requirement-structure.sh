#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# requirement-structure.sh — 检查需求文档结构完整性（软门禁）
# 最小结构: 问题定义/范围/非目标/验收标准 + 多方案对比 + 决策结论

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPEC_DIR="$PROJECT_ROOT/context-layer/specs"
TODAY="$(date +%Y-%m-%d)"
source "$SCRIPT_DIR/common-context.sh"

context_spec="$(gate_context_get "spec_file" "requirement_spec_file")"
if [[ -n "$context_spec" ]]; then
  target_spec="$(gate_context_path "$context_spec" "$PROJECT_ROOT")"
else
  gate_log_fallback "spec_file not set; discovering latest spec for structure check"
  specs=$(ls "$SPEC_DIR"/"$TODAY"-*-spec.md 2>/dev/null || true)
  if [[ -z "$specs" ]]; then
    specs=$(ls "$SPEC_DIR"/*-spec.md 2>/dev/null | tail -3 || true)
  fi
  target_spec="$(echo "$specs" | tail -1)"
fi

if [[ -z "${target_spec:-}" ]] || [[ ! -f "$target_spec" ]]; then
  echo "✗ requirement-structure: 未找到需求文档"
  exit 1
fi

missing=()
check_section() {
  local label="$1" regex="$2"
  if ! grep -qiE "$regex" "$target_spec" 2>/dev/null; then
    missing+=("$label")
  fi
}

check_section "问题定义" "^##.*(Problem|问题|背景)"
check_section "范围" "^##.*(Scope|范围)"
check_section "非目标" "^##.*(Non-Goals?|非目标|不做)"
check_section "验收标准" "^##.*(Acceptance|验收)"
check_section "方案对比" "^##.*(Option Comparison|Options?|方案对比|方案比较)"
check_section "决策结论" "^##.*(Decision|决策)"

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "✗ requirement-structure: 需求结构不完整"
  printf '  - 缺失章节: %s\n' "${missing[@]}"
  echo "  文件: $target_spec"
  exit 1
fi

echo "✓ requirement-structure 通过"
echo "  文件: $target_spec"
exit 0
