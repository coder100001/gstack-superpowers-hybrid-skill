#!/bin/bash
set -euo pipefail

# shared helpers for gate context parsing

gate_context_value() {
  local key="$1"
  local context_file="${GSTACK_GATE_CONTEXT:-}"
  [[ -n "$context_file" && -f "$context_file" ]] || return 0
  grep -iE "^${key}:" "$context_file" 2>/dev/null | head -1 | sed 's/^[^:]*:[[:space:]]*//' | sed 's/^["'\'']//; s/["'\'']$//' || true
}

gate_context_get() {
  local primary="$1"
  shift || true

  local val
  val="$(gate_context_value "$primary")"
  if [[ -n "$val" ]]; then
    printf '%s\n' "$val"
    return 0
  fi

  local alias_key
  for alias_key in "$@"; do
    val="$(gate_context_value "$alias_key")"
    if [[ -n "$val" ]]; then
      printf '%s\n' "$val"
      return 0
    fi
  done
}

gate_context_path() {
  local raw="${1:-}"
  local project_root="$2"
  if [[ -z "$raw" ]]; then
    return 0
  fi
  if [[ "$raw" = /* ]]; then
    printf '%s\n' "$raw"
  else
    printf '%s/%s\n' "$project_root" "$raw"
  fi
}

gate_log_fallback() {
  local reason="$1"
  echo "fallback used: $reason"
}
