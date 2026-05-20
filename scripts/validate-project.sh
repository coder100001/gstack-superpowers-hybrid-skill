#!/usr/bin/env bash
#
# validate-project.sh — CI validation tool
# Checks version consistency, file references, and directory completeness.
#
# Usage: ./scripts/validate-project.sh
# Returns: 0 (pass) / 1 (fail)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ERRORS=0

resolve_path() {
  local file_dir="$1" ref_path="$2"
  if [[ "$ref_path" == /* ]]; then
    echo "$ref_path"
  elif [[ "$ref_path" == ./* || "$ref_path" == ../* ]]; then
    (cd "$file_dir" && cd "$(dirname "$ref_path")" && echo "$(pwd -P)/$(basename "$ref_path")")
  else
    echo "$file_dir/$ref_path"
  fi
}

check_exists() {
  if [[ ! -f "$1" ]]; then
    echo "  [FAIL] $2 → $1"
    return 1
  fi
  return 0
}

# ── Check 1: Version consistency ─────────────────────

check_version_consistency() {
  echo "=== [1/6] 版本一致性检查 ==="
  local e=0

  # 从 project-config.yml 动态读取版本号
  CONFIG_VERSION=""
  if [[ -f "$PROJECT_ROOT/project-config.yml" ]]; then
    CONFIG_VERSION=$(grep -E "^version:" "$PROJECT_ROOT/project-config.yml" 2>/dev/null | head -1 | sed 's/^version:[[:space:]]*//' | tr -d '"' | tr -d "'")
  fi

  if [[ -n "$CONFIG_VERSION" ]]; then
    # 主版本号（v4.1 格式）
    CONFIG_VERSION_SHORT="v${CONFIG_VERSION%.*}"

    if grep -q "$CONFIG_VERSION_SHORT" "$PROJECT_ROOT/README.md"; then
      echo "  [OK] README.md contains $CONFIG_VERSION_SHORT"
    else
      echo "  [FAIL] README.md missing $CONFIG_VERSION_SHORT"; e=$((e + 1))
    fi

    if grep -q "version:.*${CONFIG_VERSION}" "$PROJECT_ROOT/project-config.yml"; then
      echo "  [OK] project-config.yml version is $CONFIG_VERSION"
    else
      echo "  [FAIL] project-config.yml missing $CONFIG_VERSION"; e=$((e + 1))
    fi

    if grep -q "$CONFIG_VERSION_SHORT" "$PROJECT_ROOT/docs/architecture.md"; then
      echo "  [OK] docs/architecture.md contains $CONFIG_VERSION_SHORT"
    else
      echo "  [FAIL] docs/architecture.md missing $CONFIG_VERSION_SHORT"; e=$((e + 1))
    fi
  else
    echo "  [FAIL] Cannot read version from project-config.yml"; e=$((e + 1))
  fi

  [[ $e -eq 0 ]] && echo "  => version consistent" || echo "  => $e failure(s)"
  echo ""
  return $e
}

# ── Check 2: references in bridges/ + execution-layer/ ──

check_refs() {
  echo "=== [2/6] bridges/ + execution-layer/ references ==="
  local e=0 total=0

  for dir in "bridges" "execution-layer"; do
    for file in "$PROJECT_ROOT/$dir"/*.md; do
      [[ -f "$file" ]] || continue
      local d; d="$(dirname "$file")"
      local b; b="$(basename "$file")"

      while IFS= read -r path; do
        [[ -z "$path" || "$path" == \#* || "$path" == http* ]] && continue
        local res; res="$(resolve_path "$d" "$path")"
        total=$((total + 1))
        check_exists "$res" "$dir/$b -> $path" || e=$((e + 1))
      done < <(grep -oE '\([^)]+\.md\)' "$file" | tr -d '()')
    done
  done

  echo "   checked $total references"
  [[ $e -eq 0 ]] && echo "  => all exist" || echo "  => $e missing"
  echo ""
  return $e
}

# ── Check 3: "关联文件" references ────────────────────

check_linked() {
  echo "=== [3/6] linked file references ==="
  local e=0 total=0

  for link_dir in "bridges" "decision-layer" "context-layer" "execution-layer"; do
    while IFS= read -r -d '' file; do
      local d; d="$(dirname "$file")"
      while IFS= read -r line; do
        while IFS= read -r path; do
          [[ -z "$path" || "$path" == \#* || "$path" == http* ]] && continue
          local res; res="$(resolve_path "$d" "$path")"
          total=$((total + 1))
          local rel; rel="$(echo "$file" | sed "s|$PROJECT_ROOT/||")"
          check_exists "$res" "$rel -> $path" || e=$((e + 1))
        done < <(echo "$line" | grep -oE '\([^)]+\.md\)' | tr -d '()')
      done < <(grep -H "关联文件" "$file" 2>/dev/null || true)
    done < <(find "$PROJECT_ROOT/$link_dir" -name "*.md" -type f -print0 2>/dev/null || true)
  done

  echo "   checked $total links"
  [[ $e -eq 0 ]] && echo "  => all exist" || echo "  => $e missing"
  echo ""
  return $e
}

# ── Check 4: bridges count ──────────────────────────

check_bridges() {
  echo "=== [4/6] bridges/ count ==="
  local e=0 files=()
  for f in "$PROJECT_ROOT/bridges"/*.md; do
    [[ -f "$f" ]] && files+=("$(basename "$f")")
  done

  if [[ ${#files[@]} -eq 3 ]]; then
    echo "  [OK] 3 bridge files: ${files[*]}"
  else
    echo "  [FAIL] expected 3, found ${#files[@]}: ${files[*]}"
    e=$((e + 1))
  fi

  for name in "decision-to-context.md" "context-to-execution.md" "execution-to-decision.md"; do
    [[ -f "$PROJECT_ROOT/bridges/$name" ]] || { echo "  [FAIL] missing bridges/$name"; e=$((e + 1)); }
  done

  [[ $e -eq 0 ]] && echo "  => complete" || echo "  => $e failure(s)"
  echo ""
  return $e
}

# ── Check 5: decision-layer/reviews/ ─────────────────

check_reviews() {
  echo "=== [5/6] decision-layer/reviews/ ==="
  local e=0 files=()
  for f in "$PROJECT_ROOT/decision-layer/reviews"/*.md; do
    [[ -f "$f" ]] && files+=("$(basename "$f")")
  done

  if [[ ${#files[@]} -eq 4 ]]; then
    echo "  [OK] 4 review files: ${files[*]}"
  else
    echo "  [FAIL] expected 4, found ${#files[@]}: ${files[*]}"
    e=$((e + 1))
  fi

  for name in "architecture-review.md" "product-review.md" "risk-review.md" "tradeoff-review.md"; do
    [[ -f "$PROJECT_ROOT/decision-layer/reviews/$name" ]] || { echo "  [FAIL] missing reviews/$name"; e=$((e + 1)); }
  done

  [[ $e -eq 0 ]] && echo "  => complete" || echo "  => $e failure(s)"
  echo ""
  return $e
}

# ── Check 6: context-layer/specs/ ───────────────────

check_specs() {
  echo "=== [6/6] context-layer/specs/ ==="
  local e=0 files=()
  for f in "$PROJECT_ROOT/context-layer/specs"/*.md; do
    [[ -f "$f" ]] && files+=("$(basename "$f")")
  done

  if [[ ${#files[@]} -ge 4 ]]; then
    echo "  [OK] ${#files[@]} spec files (>= 4): ${files[*]}"
  else
    echo "  [FAIL] expected >= 4, found ${#files[@]}: ${files[*]}"
    e=$((e + 1))
  fi

  for name in "architecture-spec.md" "constraints-spec.md" "domain-boundaries.md" "project-spec.md"; do
    [[ -f "$PROJECT_ROOT/context-layer/specs/$name" ]] || { echo "  [FAIL] missing specs/$name"; e=$((e + 1)); }
  done

  if [[ -d "$PROJECT_ROOT/context-layer/specs/coding-standards" ]]; then
    local cs=0
    for f in "$PROJECT_ROOT/context-layer/specs/coding-standards"/*.md; do
      [[ -f "$f" ]] && cs=$((cs + 1))
    done
    echo "  [OK] coding-standards/ exists with $cs files"
  else
    echo "  [FAIL] coding-standards/ directory missing"
    e=$((e + 1))
  fi

  [[ $e -eq 0 ]] && echo "  => complete" || echo "  => $e failure(s)"
  echo ""
  return $e
}

# ── Main ────────────────────────────────────────────

echo "=================================================="
echo "  Project Integrity Validation"
echo "=================================================="
echo ""

set +e
check_version_consistency; ERRORS=$((ERRORS + $?))
check_refs;                ERRORS=$((ERRORS + $?))
check_linked;              ERRORS=$((ERRORS + $?))
check_bridges;             ERRORS=$((ERRORS + $?))
check_reviews;             ERRORS=$((ERRORS + $?))
check_specs;               ERRORS=$((ERRORS + $?))
set -e

echo "=================================================="
if [[ $ERRORS -eq 0 ]]; then
  echo "All 6 checks passed"
  exit 0
else
  echo "$ERRORS check(s) failed"
  exit 1
fi