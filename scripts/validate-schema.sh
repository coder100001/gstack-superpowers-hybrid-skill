#!/bin/bash
set -euo pipefail

# validate-schema.sh — JSON Schema 校验脚本
# 用法: ./scripts/validate-schema.sh [--schema <schema-file>] [--data <data-file>]
# 示例:
#   ./scripts/validate-schema.sh                          # 校验所有 Schema 文件
#   ./scripts/validate-schema.sh --schema gate-result     # 校验指定 Schema
#   ./scripts/validate-schema.sh --data result.json       # 校验数据文件

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SCHEMAS_DIR="$PROJECT_ROOT/governance/schemas"

# 检查依赖
has_python3=false
if command -v python3 &>/dev/null; then
  has_python3=true
fi

if ! $has_python3; then
  echo "错误: 需要 python3 来校验 JSON Schema"
  echo "安装: brew install python3 或 apt install python3"
  exit 1
fi

# 检查 jsonschema 库
if ! python3 -c "import jsonschema" 2>/dev/null; then
  echo "警告: 未安装 jsonschema 库，仅检查 Schema 语法"
  echo "安装: pip3 install jsonschema"
  CHECK_SYNTAX_ONLY=true
else
  CHECK_SYNTAX_ONLY=false
fi

# 解析参数
SCHEMA_FILTER=""
DATA_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --schema) SCHEMA_FILTER="$2"; shift 2 ;;
    --data) DATA_FILE="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

errors=0
validated=0

echo "=========================================="
echo "JSON Schema Validation"
echo "=========================================="
echo ""
echo "Schema 目录: $SCHEMAS_DIR"
echo ""

# 校验单个数据文件
if [[ -n "$DATA_FILE" ]]; then
  if [[ ! -f "$DATA_FILE" ]]; then
    echo "错误: 数据文件不存在: $DATA_FILE"
    exit 1
  fi

  if [[ -z "$SCHEMA_FILTER" ]]; then
    echo "错误: 校验数据文件时必须指定 --schema"
    exit 1
  fi

  SCHEMA_FILE="$SCHEMAS_DIR/${SCHEMA_FILTER}.schema.json"
  if [[ ! -f "$SCHEMA_FILE" ]]; then
    echo "错误: Schema 文件不存在: $SCHEMA_FILE"
    exit 1
  fi

  echo "校验: $DATA_FILE against ${SCHEMA_FILTER}.schema.json"
  
  if $CHECK_SYNTAX_ONLY; then
    echo "  跳过: 未安装 jsonschema 库"
    exit 1
  fi

  if python3 -c "
import json, sys, jsonschema
with open(sys.argv[1]) as f:
    schema = json.load(f)
with open(sys.argv[2]) as f:
    data = json.load(f)
jsonschema.validate(data, schema)
print('  ✓ 校验通过')
" "$SCHEMA_FILE" "$DATA_FILE" 2>&1; then
    exit 0
  else
    echo "  ✗ 校验失败"
    exit 1
  fi
fi

# 校验所有 Schema 文件
echo "-------------------------------------------"
echo "Step 1: 检查 Schema 文件语法"
echo "-------------------------------------------"

for schema_file in "$SCHEMAS_DIR"/*.schema.json; do
  if [[ ! -f "$schema_file" ]]; then
    continue
  fi

  schema_name=$(basename "$schema_file" .schema.json)

  # 过滤
  if [[ -n "$SCHEMA_FILTER" ]] && [[ "$schema_name" != "$SCHEMA_FILTER" ]]; then
    continue
  fi

  # 检查 JSON 语法
  if python3 -c "import json; json.load(open('$schema_file'))" 2>/dev/null; then
    echo "  ✓ $schema_name: JSON 语法正确"
  else
    echo "  ✗ $schema_name: JSON 语法错误"
    errors=$((errors + 1))
    continue
  fi

  # 检查 Schema 结构
  if python3 -c "
import json
with open('$schema_file') as f:
    s = json.load(f)
required = ['\$schema', 'type']
for r in required:
    if r not in s:
        print(f'  缺少必需字段: {r}')
        exit(1)
if s['type'] not in ['object', 'array', 'string', 'number', 'boolean', 'null']:
    print(f'  无效的 type: {s[\"type\"]}')
    exit(1)
" 2>&1; then
    echo "  ✓ $schema_name: Schema 结构正确"
    validated=$((validated + 1))
  else
    echo "  ✗ $schema_name: Schema 结构错误"
    errors=$((errors + 1))
  fi
done

echo ""
echo "-------------------------------------------"
echo "Step 2: 检查 Schema 引用"
echo "-------------------------------------------"

# 检查 transition-result.schema.json 是否正确引用 gate-result.schema.json
TRANSITION_SCHEMA="$SCHEMAS_DIR/transition-result.schema.json"
if [[ -f "$TRANSITION_SCHEMA" ]]; then
  if grep -q '"\$ref": "gate-result.schema.json"' "$TRANSITION_SCHEMA"; then
    echo "  ✓ transition-result 正确引用 gate-result"
  else
    echo "  ⚠ transition-result 未引用 gate-result"
  fi
fi

echo ""
echo "=========================================="
echo "校验结果"
echo "=========================================="
echo ""
echo "校验通过: $validated"
echo "错误: $errors"
echo ""

if [[ $errors -eq 0 ]]; then
  echo "SCHEMA:0 错误"
  exit 0
else
  echo "SCHEMA:$errors 错误"
  exit 1
fi
