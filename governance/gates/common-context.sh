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
  echo "fallback used: $reason" >&2
}

gate_workflow_state_file() {
  local script_dir="${1:-}"
  local project_root="${2:-}"
  if [[ -n "$script_dir" && -f "$project_root/artifacts/workflow-state.md" ]]; then
    printf '%s\n' "$project_root/artifacts/workflow-state.md"
  fi
}

gate_workflow_state_value() {
  local key="$1"
  local state_file="$2"
  [[ -n "$state_file" && -f "$state_file" ]] || return 0
  grep -iE "^${key}:" "$state_file" 2>/dev/null | head -1 | sed 's/^[^:]*:[[:space:]]*//' | sed 's/^["'\'']//; s/["'\'']$//' || true
}

gate_context_level() {
  local project_root="$1"
  local state_file
  local level

  level="$(gate_context_get "level" "complexity")"
  if [[ -n "$level" ]]; then
    printf '%s\n' "$level"
    return 0
  fi

  state_file="$(gate_workflow_state_file "$SCRIPT_DIR" "$project_root")"
  level="$(gate_workflow_state_value "level" "$state_file")"
  if [[ -n "$level" ]]; then
    gate_log_fallback "level not set in context; reading level from workflow-state"
    printf '%s\n' "$level"
  fi
}

gate_is_truthy() {
  local value="${1:-}"
  [[ "$value" =~ ^([Tt][Rr][Uu][Ee]|[Yy][Ee]?[Ss]?|1|confirmed|approved|passed)$ ]]
}

gate_workflow_state_append() {
  local state_file="$1"
  local section="$2"
  shift 2

  mkdir -p "$(dirname "$state_file")"
  if [[ ! -f "$state_file" ]]; then
    cat > "$state_file" <<'EOF'
# Workflow State

> **Auto-updated by gate quick path**
EOF
  fi
  {
    echo ""
    echo "### $section"
    for line in "$@"; do
      echo "$line"
    done
  } >> "$state_file"
}
