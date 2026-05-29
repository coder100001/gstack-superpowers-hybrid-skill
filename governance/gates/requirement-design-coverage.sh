#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# requirement-design-coverage.sh — 检查需求是否在设计/计划中被覆盖（软门禁）
# 优先规则: 使用 REQ-ID 显式映射；无 REQ-ID 时降级为弱匹配并告警

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SPEC_DIR="$PROJECT_ROOT/context-layer/specs"
PLAN_DIR="$PROJECT_ROOT/specs/plans"
ADR_DIR="$PROJECT_ROOT/decision-layer/adr"
TODAY="$(date +%Y-%m-%d)"
source "$SCRIPT_DIR/common-context.sh"

context_spec="$(gate_context_get "spec_file" "requirement_spec_file")"
context_plan="$(gate_context_get "plan_file" "current_plan_file")"
context_adr="$(gate_context_get "adr_file")"

if [[ -n "$context_spec" ]]; then
  target_spec="$(gate_context_path "$context_spec" "$PROJECT_ROOT")"
else
  gate_log_fallback "spec_file not set; selecting latest spec for coverage check"
  specs=$(ls "$SPEC_DIR"/"$TODAY"-*-spec.md 2>/dev/null || true)
  if [[ -z "$specs" ]]; then
    specs=$(ls "$SPEC_DIR"/*-spec.md 2>/dev/null | tail -3 || true)
  fi
  target_spec="$(echo "$specs" | tail -1)"
fi

if [[ -n "$context_plan" ]]; then
  target_plan="$(gate_context_path "$context_plan" "$PROJECT_ROOT")"
else
  gate_log_fallback "plan_file not set; selecting newest plan for coverage check"
  target_plan=$(ls -t "$PLAN_DIR"/*.md 2>/dev/null | head -1 || true)
fi

if [[ -n "$context_adr" ]]; then
  target_adr="$(gate_context_path "$context_adr" "$PROJECT_ROOT")"
else
  gate_log_fallback "adr_file not set; selecting newest ADR for coverage check"
  target_adr=$(ls -t "$ADR_DIR"/ADR-*.md 2>/dev/null | head -1 || true)
fi

if [[ -z "${target_spec:-}" ]] || [[ ! -f "$target_spec" ]]; then
  echo "✗ requirement-design-coverage: 未找到需求文档"
  exit 1
fi

if [[ -z "${target_plan:-}" ]] || [[ ! -f "$target_plan" ]]; then
  echo "✗ requirement-design-coverage: 未找到计划文档"
  exit 1
fi

corpus_file="$(mktemp /tmp/gstack-coverage-corpus.XXXXXX)"
trap 'rm -f "$corpus_file"' EXIT
cat "$target_plan" > "$corpus_file"
if [[ -n "${target_adr:-}" ]] && [[ -f "$target_adr" ]]; then
  cat "$target_adr" >> "$corpus_file"
fi

# 提取 Requirements 区块中的条目
req_lines=$(awk '
  BEGIN { in_req=0 }
  /^##[[:space:]]+/ {
    if ($0 ~ /##[[:space:]]*(Requirements?|需求|需求清单)/) { in_req=1; next }
    if (in_req==1) { exit }
  }
  in_req==1 && /^[[:space:]]*[-*][[:space:]]+/ { print }
' "$target_spec")

if [[ -z "${req_lines:-}" ]]; then
  echo "✗ requirement-design-coverage: 需求文档中未找到 Requirements 条目"
  echo "  文件: $target_spec"
  exit 1
fi

req_ids=$(echo "$req_lines" | grep -oE 'REQ-[0-9]+' | sort -u || true)
uncovered=0

if [[ -n "${req_ids:-}" ]]; then
  while IFS= read -r req_id; do
    [[ -n "$req_id" ]] || continue
    if ! grep -q "$req_id" "$corpus_file"; then
      echo "  ✗ 未覆盖需求ID: $req_id"
      uncovered=$((uncovered + 1))
    fi
  done <<< "$req_ids"
else
  gate_log_fallback "REQ-ID not found in spec; falling back to weak keyword coverage"
  while IFS= read -r req; do
    [[ -n "$req" ]] || continue
    normalized=$(echo "$req" | tr '[:upper:]' '[:lower:]' | sed -E 's/^[[:space:]]*[-*][[:space:]]*//')
    covered=false
    for token in $(echo "$normalized" | tr -cs '[:alnum:]' '\n' | awk 'length($0)>=4'); do
      if grep -qiE "(^|[^[:alnum:]])${token}([^[:alnum:]]|$)" "$corpus_file"; then
        covered=true
        break
      fi
    done
    if [[ "$covered" != "true" ]]; then
      echo "  ✗ 未覆盖需求: $normalized"
      uncovered=$((uncovered + 1))
    fi
  done <<< "$req_lines"
fi

if [[ "$uncovered" -gt 0 ]]; then
  echo "✗ requirement-design-coverage: 存在未覆盖需求（$uncovered）"
  echo "  spec: $target_spec"
  echo "  plan: $target_plan"
  [[ -n "${target_adr:-}" ]] && echo "  adr: $target_adr"
  exit 1
fi

echo "✓ requirement-design-coverage 通过"
echo "  spec: $target_spec"
echo "  plan: $target_plan"
[[ -n "${target_adr:-}" ]] && echo "  adr: $target_adr"
exit 0
