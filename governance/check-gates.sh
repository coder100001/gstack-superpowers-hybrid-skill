#!/bin/bash
set -euo pipefail

# check-gates.sh — Gate 执行入口
# 用法: ./governance/check-gates.sh --from <state> --to <state> --level <L1|L2|L3> [--context <path>]
# 示例: ./governance/check-gates.sh --from TASK_DECOMPOSITION --to PLAN_CONFIRM --level L3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GATES_YAML="$SCRIPT_DIR/gates.yaml"
GATES_DIR="$SCRIPT_DIR/gates"

TO_STATE=""
FROM_STATE=""
LEVEL="L3"
CONTEXT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM_STATE="$2"; shift 2 ;;
    --to) TO_STATE="$2"; shift 2 ;;
    --level) LEVEL="$2"; shift 2 ;;
    --context) CONTEXT="$2"; shift 2 ;;
    --help)
      echo "用法: check-gates.sh --from <state> --to <state> --level <L1|L2|L3> [--context <path>]"
      echo ""
      echo "参数:"
      echo "  --from    当前状态（可选，推荐传入）"
      echo "  --to      目标状态（必需）"
      echo "  --level   复杂度级别（默认: L3）"
      echo "  --context 上下文路径（可选）"
      echo ""
      echo "示例:"
      echo "  check-gates.sh --from DISCOVERY --to REQUIREMENT_LOCK --level L3"
      echo "  check-gates.sh --from CONTEXT_HYDRATION --to IMPLEMENTATION --level L2"
      exit 0
      ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

if [[ -z "$TO_STATE" ]]; then
  echo "✗ 错误: 必须指定 --to 参数"
  echo "运行 --help 查看用法"
  exit 1
fi

echo "=========================================="
echo "Gate Check"
echo "=========================================="
echo ""
if [[ -n "$FROM_STATE" ]]; then
  echo "当前状态: $FROM_STATE"
fi
echo "目标状态: $TO_STATE"
echo "复杂度级别: $LEVEL"
echo ""

if [[ ! -f "$GATES_YAML" ]]; then
  echo "✗ 错误: gates.yaml 不存在: $GATES_YAML"
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "✗ 错误: 需要 python3"
  exit 1
fi

python3 - "$GATES_YAML" "$GATES_DIR" "$TO_STATE" "$LEVEL" "$PROJECT_ROOT" << 'EOF'
import yaml
import sys
import subprocess
from pathlib import Path

gates_yaml = sys.argv[1]
gates_dir = sys.argv[2]
to_state = sys.argv[3]
level = sys.argv[4]
project_root = sys.argv[5]

errors = 0
passed = 0
skipped = 0

try:
    with open(gates_yaml) as f:
        data = yaml.safe_load(f)
except Exception as e:
    print(f"✗ 错误: 无法解析 gates.yaml: {e}")
    sys.exit(1)

gates_dict = data.get('gates', {})
if not gates_dict:
    print("⚠ 警告: gates.yaml 中没有定义任何 gate")
    sys.exit(0)

applicable_gates = []
for gate_key, gate in gates_dict.items():
    if isinstance(gate, dict):
        applies_to = gate.get('applies_to', [])
        if to_state in applies_to:
            applicable_gates.append(gate)

if not applicable_gates:
    print(f"✓ 无需检查: 目标状态 {to_state} 没有关联的 gate")
    sys.exit(0)

print(f"发现 {len(applicable_gates)} 个适用的 gate")
print("")

for gate in applicable_gates:
    gate_name = gate.get('name', 'unknown')
    gate_script = gate.get('script', '')
    l1_exempt = gate.get('l1_exempt', False)
    severity = gate.get('severity', 'hard')
    fail_message = gate.get('fail_message', 'Gate 检查失败')
    
    print(f"→ 检查 Gate: {gate_name}")
    
    if l1_exempt and level == 'L1':
        print(f"  ⊘ 跳过: L1 豁免")
        skipped += 1
        continue
    
    script_path = Path(project_root) / gate_script
    
    if not script_path.exists():
        print(f"  ⚠ 警告: Gate 脚本不存在: {gate_script}")
        if severity == 'hard':
            print(f"  ✗ 阻断: GATE_FAILED:{gate_name} 严重级别为 hard，无法继续")
            errors += 1
        else:
            print(f"  ⊘ 跳过: 严重级别为 {severity}")
            skipped += 1
        continue
    
    try:
        result = subprocess.run(
            ['bash', str(script_path)],
            cwd=project_root,
            capture_output=True,
            text=True,
            timeout=60
        )
        
        if result.returncode == 0:
            print(f"  ✓ 通过")
            passed += 1
        elif result.returncode == 1:
            print(f"  ✗ 阻断: GATE_FAILED:{gate_name} {fail_message}")
            if result.stdout:
                for line in result.stdout.strip().split('\n'):
                    if line:
                        print(f"     {line}")
            errors += 1
        else:
            print(f"  ⚠ 基础设施错误: GATE_FAILED:{gate_name} (exit code: {result.returncode})")
            if result.stderr:
                print(f"     {result.stderr}")
            errors += 1
    except subprocess.TimeoutExpired:
        print(f"  ✗ 超时: GATE_FAILED:{gate_name} Gate 执行超过 60 秒")
        errors += 1
    except Exception as e:
        print(f"  ✗ 执行错误: GATE_FAILED:{gate_name} {e}")
        errors += 1

print("")
print("==========================================")
print("Gate 检查结果")
print("==========================================")
print(f"")
print(f"通过: {passed}")
print(f"跳过: {skipped}")
print(f"阻断: {errors}")
print(f"")

if errors > 0:
    print(f"✗ Gate 检查失败: {errors} 个 gate 阻断")
    print("")
    print("修复建议:")
    for gate in applicable_gates:
        if gate.get('name') and gate.get('remediation'):
            print(f"  {gate['name']}:")
            for step in gate['remediation'][:3]:
                print(f"    - {step}")
    sys.exit(1)
else:
    print("✓ Gate 检查通过")
    sys.exit(0)
EOF
