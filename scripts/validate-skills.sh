#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# validate-skills.sh — 校验所有 SKILL.md 与 schema 和路由表的一致性

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SCHEMA_FILE="$PROJECT_ROOT/schema/skill.schema.json"
ROUTES_FILE="$PROJECT_ROOT/schema/skill-routes.yaml"
FILTER_FILE="$PROJECT_ROOT/.sync-filter.json"

errors=0

log_error() { echo "[ERROR] $*"; }

# ---- 1. All SKILL.md must have name ----
echo "=== [1/4] Checking SKILL.md front-matter ==="
while IFS= read -r skill; do
  rel="${skill#$PROJECT_ROOT/}"
  if grep -q '^---$' <(head -1 "$skill") 2>/dev/null; then
    name=$(sed -n '/^---$/,/^---$/p' "$skill" | grep '^name:' | head -1 | sed 's/^name:[[:space:]]*//; s/"//g')
    if [[ -z "$name" ]]; then
      log_error "$rel has no name in front-matter"
      errors=$((errors + 1))
    fi
  else
    log_error "$rel has no YAML front-matter"
    errors=$((errors + 1))
  fi
done < <(find "$PROJECT_ROOT/skills" -name "SKILL.md" | sort)
total=$(find "$PROJECT_ROOT/skills" -name "SKILL.md" | wc -l)
echo "  Checked $total SKILL.md files"

# ---- 2. Validate skill.schema.json format ----
echo "=== [2/4] Checking skill.schema.json format ==="
if command -v python3 &>/dev/null; then
  python3 -c "
import json
with open('$SCHEMA_FILE') as f:
    data = json.load(f)
assert data.get('\$schema'), 'Missing \$schema'
assert 'name' in data.get('properties', {}), 'Missing name property'
print('  schema format OK')
" || { log_error "schema JSON format error"; errors=$((errors + 1)); }
else
  echo "  (skipped, needs python3)"
fi

# ---- 3. Check every skill in routes exists on disk ----
echo "=== [3/4] Checking route table references ==="
while IFS= read -r line; do
  skill_raw=$(echo "$line" | sed 's/.*name:[[:space:]]*//; s/"//g')
  if [[ -z "$skill_raw" ]]; then
    continue
  fi

  if [[ "$skill_raw" = gstack:* ]]; then
    skill_name="${skill_raw#gstack:}"
    skill_dir="gstack/${skill_name}"
  else
    skill_name="${skill_raw}"
    skill_dir="superpowers/${skill_name}"
  fi

  skill_path="$PROJECT_ROOT/skills/$skill_dir/SKILL.md"
  if [[ ! -f "$skill_path" ]]; then
    log_error "Route references '${skill_name}' (${skill_dir}) but SKILL.md not found"
    errors=$((errors + 1))
  fi
done < <(grep -E '^\s+- name:' "$ROUTES_FILE")
echo "  Route references check done"

# ---- 4. Check routes vs sync-filter consistency ----
echo "=== [4/4] Checking routes vs sync-filter consistency ==="
if [[ -f "$FILTER_FILE" ]]; then
  filter_json=$(python3 -c "
import json
with open('$FILTER_FILE') as f:
    data = json.load(f)
for s in data.get('gstack', {}).get('routed_skills', []):
    print(s)
" 2>/dev/null || echo "")

  route_gstack=$(grep -E '^\s+- name:.*gstack:' "$ROUTES_FILE" | sed 's/.*name:[[:space:]]*//; s/gstack://; s/"//g')

  echo "  sync-filter gstack routed skills: $(echo "$filter_json" | wc -l)"
  echo "  skill-routes.yaml gstack skills: $(echo "$route_gstack" | wc -l)"

  if [[ -n "$filter_json" ]]; then
    while IFS= read -r skill; do
      if [[ -n "$skill" ]]; then
        if ! echo "$route_gstack" | grep -qx "$skill"; then
          log_error "sync-filter includes '$skill' but not found in route table"
          errors=$((errors + 1))
        fi
      fi
    done < <(echo "$filter_json")
  fi
else
  echo "  (skipped, .sync-filter.json not found)"
fi

echo ""
if [[ $errors -gt 0 ]]; then
  echo "FAILED: $errors error(s)"
  exit 1
else
  echo "All checks passed"
fi
