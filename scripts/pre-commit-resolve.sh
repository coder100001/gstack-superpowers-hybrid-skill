#!/bin/bash
# pre-commit hook: resolve @mod(id) references before commit
# Ensures committed .md files have clickable markdown links instead of @mod() tags.
# Install: ln -sf ../../scripts/pre-commit-resolve.sh .git/hooks/pre-commit

set -euo pipefail
IFS=$'\n\t'

# Resolve symlink to real path (pre-commit hook runs via .git/hooks/ symlink)
real_script="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$real_script")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Resolve @mod() references in staged .md files
"$PROJECT_ROOT/scripts/resolve-module-refs.sh" --resolve

# Re-stage any resolved files so the commit includes the resolved links
# Only re-stage files that were already staged (don't add new files)
staged_md=$(git diff --cached --name-only --diff-filter=ACM | grep '\.md$' || true)
if [[ -n "$staged_md" ]]; then
  echo "$staged_md" | tr '\n' '\0' | xargs -0 git add 2>/dev/null || true
fi
