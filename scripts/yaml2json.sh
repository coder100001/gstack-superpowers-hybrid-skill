#!/bin/bash
set -euo pipefail

# yaml2json.sh — 从 YAML 真相源自动生成 JSON 运行时文件
# 用法: ./scripts/yaml2json.sh [--check]
# --check: 仅检查一致性，不生成文件

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CHECK_ONLY=false

if [[ "${1:-}" == "--check" ]]; then
  CHECK_ONLY=true
fi

# 检查依赖
has_python3=false
if command -v python3 &>/dev/null; then
  has_python3=true
fi

if ! $has_python3; then
  echo "错误: 需要 python3 来转换 YAML→JSON"
  echo "安装: brew install python3 或 apt install python3"
  exit 1
fi

# 检查 PyYAML
if ! python3 -c "import yaml" 2>/dev/null; then
  echo "错误: 需要 PyYAML 库"
  echo "安装: pip3 install pyyaml"
  exit 1
fi

errors=0

convert_yaml_to_json() {
  local yaml_file="$1"
  local json_file="$2"
  local label="$3"

  if [[ ! -f "$yaml_file" ]]; then
    echo "✗ $label: YAML 源文件不存在 ($yaml_file)"
    errors=$((errors + 1))
    return 1
  fi

  # 生成 JSON
  local generated
  generated=$(python3 -c "
import yaml, json, sys
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
print(json.dumps(data, indent=2, ensure_ascii=False))
" "$yaml_file" 2>/dev/null)

  if [[ -z "$generated" ]]; then
    echo "✗ $label: YAML 解析失败"
    errors=$((errors + 1))
    return 1
  fi

  if $CHECK_ONLY; then
    # 仅检查一致性：比较 YAML 和 JSON 的核心数据（忽略 metadata 和 backup_source）
    if [[ ! -f "$json_file" ]]; then
      echo "✗ $label: JSON 文件不存在 ($json_file)，需要生成"
      errors=$((errors + 1))
      return 1
    fi

    local yaml_normalized json_normalized
    yaml_normalized=$(python3 -c "
import yaml, json, sys
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
data.pop('backup_source', None)
data.pop('metadata', None)
print(json.dumps(data, indent=2, ensure_ascii=False, sort_keys=True))
" "$yaml_file" 2>/dev/null)

    json_normalized=$(python3 -c "
import json, sys
with open(sys.argv[1]) as f:
    data = json.load(f)
data.pop('backup_source', None)
data.pop('metadata', None)
print(json.dumps(data, indent=2, ensure_ascii=False, sort_keys=True))
" "$json_file" 2>/dev/null)

    if [[ "$yaml_normalized" == "$json_normalized" ]]; then
      echo "✓ $label: YAML 与 JSON 一致"
    else
      echo "✗ $label: YAML 与 JSON 不一致，需要重新生成"
      errors=$((errors + 1))
    fi
  else
    # 生成 JSON 文件
    # 保留 YAML 中的 backup_source 和 metadata
    local final_json
    final_json=$(python3 -c "
import yaml, json, sys, datetime
with open(sys.argv[1]) as f:
    data = yaml.safe_load(f)
# 添加生成时间戳
if 'metadata' not in data:
    data['metadata'] = {}
data['metadata']['generated_at'] = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
data['metadata']['generated_from'] = sys.argv[1]
print(json.dumps(data, indent=2, ensure_ascii=False))
" "$yaml_file" 2>/dev/null)

    echo "$final_json" > "$json_file"
    echo "✓ $label: 已生成 $json_file"
  fi
}

echo "=== YAML → JSON 转换 ==="
echo ""

# 状态机
convert_yaml_to_json \
  "$PROJECT_ROOT/governance/state-machine.yaml" \
  "$PROJECT_ROOT/governance/machine.json" \
  "状态机"

# Gate 定义
convert_yaml_to_json \
  "$PROJECT_ROOT/governance/gates.yaml" \
  "$PROJECT_ROOT/governance/gates.json" \
  "Gate 定义"

echo ""
if [[ $errors -eq 0 ]]; then
  echo "YAML2JSON:0 错误"
  exit 0
else
  echo "YAML2JSON:$errors 错误"
  exit 1
fi
