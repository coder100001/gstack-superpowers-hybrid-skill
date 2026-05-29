#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# measurable-acceptance.sh — 验收项可测性检查（软门禁）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPEC_DIR="$PROJECT_ROOT/context-layer/specs"
TODAY="$(date +%Y-%m-%d)"
source "$SCRIPT_DIR/common-context.sh"

context_spec="$(gate_context_get "spec_file" "requirement_spec_file")"
if [[ -n "$context_spec" ]]; then
  target_spec="$(gate_context_path "$context_spec" "$PROJECT_ROOT")"
else
  gate_log_fallback "spec_file not set; selecting latest spec for measurable-acceptance"
  specs=$(ls "$SPEC_DIR"/"$TODAY"-*-spec.md 2>/dev/null || true)
  if [[ -z "$specs" ]]; then
    specs=$(ls "$SPEC_DIR"/*-spec.md 2>/dev/null | tail -3 || true)
  fi
  target_spec="$(echo "$specs" | tail -1)"
fi

if [[ -z "${target_spec:-}" ]] || [[ ! -f "$target_spec" ]]; then
  echo "✗ measurable-acceptance: 未找到需求文档"
  exit 1
fi

acceptance_lines=$(awk '
  BEGIN { in_acc=0 }
  /^##[[:space:]]+/ {
    if ($0 ~ /##[[:space:]]*(Acceptance|验收)/) { in_acc=1; next }
    if (in_acc==1) { exit }
  }
  in_acc==1 && /^[[:space:]]*[-*][[:space:]]+/ { print }
' "$target_spec")

if [[ -z "${acceptance_lines:-}" ]]; then
  echo "✗ measurable-acceptance: 未找到验收项列表"
  echo "  文件: $target_spec"
  exit 1
fi

non_measurable=0
while IFS= read -r line; do
  [[ -n "$line" ]] || continue
  normalized="$(echo "$line" | tr '[:upper:]' '[:lower:]')"
  if echo "$normalized" | grep -qiE '[0-9]'; then
    continue
  fi
  if echo "$normalized" | grep -qiE '(<=|>=|<|>|=|\bms\b|\bsec(ond)?s?\b|\bmin(ute)?s?\b|%|p95|p99|latency|error rate|throughput|qps|rps|成功率|耗时|延迟|错误率)'; then
    continue
  fi
  echo "  ✗ 不可测验收项: $line"
  non_measurable=$((non_measurable + 1))
done <<< "$acceptance_lines"

if [[ "$non_measurable" -gt 0 ]]; then
  echo "✗ measurable-acceptance: 存在不可测验收项（$non_measurable）"
  echo "  建议: 使用可观测指标/阈值表达验收标准"
  exit 1
fi

echo "✓ measurable-acceptance 通过"
echo "  文件: $target_spec"
exit 0
