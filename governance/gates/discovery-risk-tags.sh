#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# discovery-risk-tags.sh — DISCOVERY 风险标签结构检查（软门禁）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPEC_DIR="$PROJECT_ROOT/context-layer/specs"
TODAY="$(date +%Y-%m-%d)"
source "$SCRIPT_DIR/common-context.sh"

context_spec="$(gate_context_get "spec_file" "requirement_spec_file")"
if [[ -n "$context_spec" ]]; then
  target_spec="$(gate_context_path "$context_spec" "$PROJECT_ROOT")"
else
  gate_log_fallback "spec_file not set; selecting latest spec for discovery-risk-tags"
  specs=$(ls "$SPEC_DIR"/"$TODAY"-*-spec.md 2>/dev/null || true)
  if [[ -z "$specs" ]]; then
    specs=$(ls "$SPEC_DIR"/*-spec.md 2>/dev/null | tail -3 || true)
  fi
  target_spec="$(echo "$specs" | tail -1)"
fi

if [[ -z "${target_spec:-}" ]] || [[ ! -f "$target_spec" ]]; then
  echo "✗ discovery-risk-tags: 未找到需求文档"
  exit 1
fi

if ! grep -qiE "^##.*(Risk Tags|风险标签|风险)" "$target_spec"; then
  echo "✗ discovery-risk-tags: 缺少 Risk Tags 章节"
  echo "  文件: $target_spec"
  exit 1
fi

risk_lines=$(awk '
  BEGIN { in_risk=0 }
  /^##[[:space:]]+/ {
    if ($0 ~ /##[[:space:]]*(Risk Tags|风险标签|风险)/) { in_risk=1; next }
    if (in_risk==1) { exit }
  }
  in_risk==1 && /^[[:space:]]*[-*][[:space:]]+/ { print }
' "$target_spec")

if [[ -z "${risk_lines:-}" ]]; then
  echo "✗ discovery-risk-tags: Risk Tags 章节为空"
  exit 1
fi

required=("business" "technical" "dependency")
missing=0
for tag in "${required[@]}"; do
  if ! echo "$risk_lines" | grep -qi "$tag"; then
    echo "  ✗ 缺少风险标签: $tag"
    missing=$((missing + 1))
  fi
done

if [[ "$missing" -gt 0 ]]; then
  echo "✗ discovery-risk-tags: 风险标签不完整（缺失 $missing 项）"
  echo "  建议最小集合: business, technical, dependency"
  exit 1
fi

echo "✓ discovery-risk-tags 通过"
echo "  文件: $target_spec"
exit 0
