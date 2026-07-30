#!/bin/bash
# resolve-module-refs.sh — Scan .md files for @mod(id) and generate markdown links
# Usage: ./scripts/resolve-module-refs.sh [--check | --resolve]
#   --check:   exit non-zero if any @mod(id) references a non-existent module ID (CI mode)
#   --resolve: replace @mod(id) with [filename](./path/filename.md) in-place
#   (default): print unresolved references as warnings, exit 0

set -euo pipefail
IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REGISTRY="$PROJECT_ROOT/schema/module-registry.yaml"
MODULES_DIR="skills/hybrid/gs-hybrid-v3/modules"

MODE="${1:---check}"

# Parse registry
if [[ ! -f "$REGISTRY" ]]; then
  echo "✗ Module registry not found: $REGISTRY"
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "✗ Requires python3"
  exit 1
fi

python3 - "$REGISTRY" "$MODULES_DIR" "$PROJECT_ROOT" "$MODE" << 'PYEOF'
import yaml, sys, os, re, glob

registry_path = sys.argv[1]
modules_dir = sys.argv[2]
project_root = sys.argv[3]
mode = sys.argv[4] if len(sys.argv) > 4 else "--check"

with open(registry_path) as f:
    registry = yaml.safe_load(f)

modules = registry.get("modules", {})
# Build id→filename map
id_to_file = {mid: info if isinstance(info, str) else info.get("file", "") 
              for mid, info in modules.items()}
# Build reverse: filename→id
file_to_id = {v: k for k, v in id_to_file.items()}

pattern = re.compile(r'@mod\((\w+)\)')

errors = 0
warnings = 0
resolved_count = 0

# Scan all .md files in the project (exclude .git, .omo, .codegraph, .history)
for root, dirs, files in os.walk(project_root):
    # Skip excluded dirs
    dirs[:] = [d for d in dirs if d not in ('.git', '.omo', '.codegraph', '.history', '.backups', 'node_modules')]
    for f in files:
        if not f.endswith('.md'):
            continue
        path = os.path.join(root, f)
        rel = os.path.relpath(path, project_root)
        
        try:
            with open(path, 'r', encoding='utf-8') as fh:
                content = fh.read()
        except:
            continue
        
        matches = pattern.findall(content)
        if not matches:
            continue
        
        if mode == "--resolve":
            new_content = content
            changed = False
            file_dir = os.path.dirname(path)
            for mid in set(matches):
                if mid not in id_to_file:
                    print(f"  ⚠ {rel}: unknown @mod({mid}) — skipped")
                    warnings += 1
                    continue
                filename = id_to_file[mid]
                abs_mod_path = os.path.join(project_root, modules_dir, filename)
                # Compute relative path from the referencing file's directory
                rel_mod_path = os.path.relpath(abs_mod_path, file_dir)
                link_text = f"[{filename}]({rel_mod_path})"
                new_content = new_content.replace(f'@mod({mid})', link_text)
                resolved_count += 1
                changed = True
            
            if changed:
                with open(path, 'w', encoding='utf-8') as fh:
                    fh.write(new_content)
        else:
            # Check mode or default
            for mid in set(matches):
                if mid not in id_to_file:
                    print(f"  ✗ {rel}: @mod({mid}) — module ID not found in registry")
                    errors += 1
                else:
                    filename = id_to_file[mid]
                    full_path = os.path.join(project_root, modules_dir, filename)
                    if not os.path.exists(full_path):
                        print(f"  ✗ {rel}: @mod({mid}) → {filename} — file not found on disk")
                        errors += 1

print(f"\n{'='*50}")
if mode == "--resolve":
    print(f"Resolved {resolved_count} references, {warnings} warnings")
else:
    print(f"Checked: {errors} errors, {warnings} warnings")
    if errors > 0:
        print(f"✗ Run ./scripts/resolve-module-refs.sh --resolve to fix")
        sys.exit(1)
    else:
        print("✓ All module references valid")
PYEOF
