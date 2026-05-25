#!/bin/bash
set -euo pipefail

# validate-state-machine.sh — 状态机校验脚本
# 用法: ./scripts/validate-state-machine.sh [--yaml path/to/state-machine.yaml]
# 依赖: python3 + pyyaml

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
YAML_FILE="$PROJECT_ROOT/governance/state-machine.yaml"
JSON_FILE="$PROJECT_ROOT/governance/machine.json"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --yaml) YAML_FILE="$2"; shift 2 ;;
    --json) JSON_FILE="$2"; shift 2 ;;
    --help) 
      echo "用法: validate-state-machine.sh [--yaml path] [--json path]"
      exit 0
      ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

echo "=========================================="
echo "State Machine Validation"
echo "=========================================="
echo ""
echo "YAML 文件: $YAML_FILE"
echo "JSON 文件: $JSON_FILE"
echo ""

if [[ ! -f "$YAML_FILE" ]]; then
  echo "✗ 错误: YAML 文件不存在: $YAML_FILE"
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "✗ 错误: 需要 python3"
  exit 1
fi

python3 - "$YAML_FILE" "$JSON_FILE" << 'EOF'
import yaml
import json
import sys
from pathlib import Path

yaml_file = sys.argv[1]
json_file = sys.argv[2]

errors = 0
warnings = 0

try:
    with open(yaml_file) as f:
        data = yaml.safe_load(f)
except Exception as e:
    print(f"✗ 错误: 无法解析 YAML: {e}")
    sys.exit(1)

print("-------------------------------------------")
print("1. 状态唯一性检查")
print("-------------------------------------------")

states = data.get('states', {})
if not states:
    print("✗ 错误: states 为空或不存在")
    errors += 1
else:
    state_names = list(states.keys())
    duplicates = [s for s in state_names if state_names.count(s) > 1]
    if duplicates:
        print(f"✗ 发现重复状态: {set(duplicates)}")
        errors += 1
    else:
        print(f"✓ 通过: {len(state_names)} 个状态，无重复")

print("")
print("-------------------------------------------")
print("2. 转换引用合法性检查")
print("-------------------------------------------")

transitions = data.get('transitions', [])
valid_states = set(state_names)
invalid_refs = 0

for t in transitions:
    from_state = t.get('from', '')
    to_state = t.get('to', '')
    
    if from_state != '*' and from_state not in valid_states:
        print(f"✗ 无效的 from 状态: {from_state}")
        invalid_refs += 1
    
    if to_state not in valid_states:
        print(f"✗ 无效的 to 状态: {to_state}")
        invalid_refs += 1

if invalid_refs == 0:
    print(f"✓ 通过: {len(transitions)} 条转换，引用合法")
else:
    errors += invalid_refs

print("")
print("-------------------------------------------")
print("3. 必需状态检查")
print("-------------------------------------------")

required_states = ['IDEA', 'IMPLEMENTATION', 'ABORTED']
missing = [s for s in required_states if s not in valid_states]

if missing:
    for s in missing:
        print(f"✗ 缺少必需状态: {s}")
    errors += len(missing)
else:
    print("✓ 通过: 所有必需状态存在")

print("")
print("-------------------------------------------")
print("4. 状态可达性检查")
print("-------------------------------------------")

reachable = {'IDEA'}

for _ in range(10):
    changed = False
    for t in transitions:
        from_state = t.get('from', '')
        to_state = t.get('to', '')
        if from_state == '*' or from_state in reachable:
            if to_state not in reachable:
                reachable.add(to_state)
                changed = True
    if not changed:
        break

unreachable = valid_states - reachable
if unreachable:
    for s in unreachable:
        print(f"⚠ 不可达状态: {s}")
    warnings += len(unreachable)
else:
    print("✓ 通过: 所有状态可达")

print("")
print("-------------------------------------------")
print("5. YAML 与 JSON 一致性检查")
print("-------------------------------------------")

json_path = Path(json_file)
if json_path.exists():
    try:
        with open(json_file) as f:
            json_data = json.load(f)
        json_states = set(json_data.get('states', {}).keys())
        
        yaml_only = valid_states - json_states
        json_only = json_states - valid_states
        
        if yaml_only:
            print(f"⚠ YAML 有但 JSON 无: {yaml_only}")
            warnings += len(yaml_only)
        if json_only:
            print(f"⚠ JSON 有但 YAML 无: {json_only}")
            warnings += len(json_only)
        
        if not yaml_only and not json_only:
            print("✓ 通过: YAML 与 JSON 状态一致")
    except Exception as e:
        print(f"⚠ 警告: 无法解析 JSON: {e}")
        warnings += 1
else:
    print("⚠ 警告: JSON 文件不存在，跳过一致性检查")
    warnings += 1

print("")
print("==========================================")
print("校验结果")
print("==========================================")
print(f"")
print(f"错误: {errors}")
print(f"警告: {warnings}")
print(f"")

if errors > 0:
    print(f"✗ 校验失败: 发现 {errors} 个错误")
    sys.exit(1)
else:
    print("✓ 校验通过")
    if warnings > 0:
        print(f"  (有 {warnings} 个警告，建议检查)")
    sys.exit(0)
EOF
