#!/bin/bash
# validate-module-load.sh — 验证 module-load-map.yaml 与 modules 一致性
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
MAP="$PROJECT_ROOT/schema/module-load-map.yaml"
MODULES_DIR="$PROJECT_ROOT/skills/hybrid/gs-hybrid-v3/modules"

errors=0

# Check MAP exists
if [[ ! -f "$MAP" ]]; then
  echo "✗ 缺少 module-load-map.yaml"
  exit 1
fi

# Check each referenced module file exists
for module in $(grep -oP 'modules/\K[^"'\''\]]+' "$MAP" 2>/dev/null || grep -oE '[0-9]+[a-z]*-[a-z-]+\.md' "$MAP"); do
  if [[ ! -f "$MODULES_DIR/$module" ]]; then
    echo "✗ 模块文件缺失: $MODULES_DIR/$module"
    errors=$((errors + 1))
  fi
done

if [[ $errors -eq 0 ]]; then
  echo "✓ module-load-map 校验通过"
else
  echo "✗ $errors 个错误"
  exit 1
fi
