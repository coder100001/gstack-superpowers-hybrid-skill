#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# aggregate-journal.sh — 聚合所有 journal 文件，输出流程时间线

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
JOURNAL_DIR="$PROJECT_ROOT/governance/state-journal"

if [[ ! -d "$JOURNAL_DIR" ]]; then
  echo "No journal files found (directory does not exist)"
  exit 0
fi

journal_files=("$JOURNAL_DIR"/*.json)
if [[ ! -f "${journal_files[0]}" ]]; then
  echo "No journal files found"
  exit 0
fi

echo "=== 状态跃迁时间线 ==="
echo ""

for f in "$JOURNAL_DIR"/*.json; do
  [[ -f "$f" ]] || continue
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if command -v python3 &>/dev/null; then
      ts=$(printf '%s' "$line" | python3 -c "import sys,json; print(json.load(sys.stdin).get('timestamp','?'))" 2>/dev/null || echo "?")
      from=$(printf '%s' "$line" | python3 -c "import sys,json; print(json.load(sys.stdin).get('from','?'))" 2>/dev/null || echo "?")
      to=$(printf '%s' "$line" | python3 -c "import sys,json; print(json.load(sys.stdin).get('to','?'))" 2>/dev/null || echo "?")
      gates=$(printf '%s' "$line" | python3 -c "import sys,json; g=json.load(sys.stdin).get('gates_passed',[]); print(','.join(g) if g else 'none')" 2>/dev/null || echo "?")
      printf "  %-25s %-20s → %-20s [gate: %s]\n" "$ts" "$from" "$to" "$gates"
    fi
  done < "$f"
done

echo ""
echo "=== 聚合完成 ==="
