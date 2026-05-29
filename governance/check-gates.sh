#!/bin/bash
set -euo pipefail

# check-gates.sh — Gate 执行入口
# 用法: ./governance/check-gates.sh --from <state> --to <state> --level <L0|L1|L2|L3> [--json] [--context <path>]
# 示例: ./governance/check-gates.sh --from TASK_DECOMPOSITION --to PLAN_CONFIRM --level L3 --json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GATES_YAML="$SCRIPT_DIR/gates.yaml"
GATES_DIR="$SCRIPT_DIR/gates"
SCHEMAS_DIR="$SCRIPT_DIR/schemas"

TO_STATE=""
FROM_STATE=""
LEVEL="L3"
CONTEXT=""
OUTPUT_JSON=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from) FROM_STATE="$2"; shift 2 ;;
    --to) TO_STATE="$2"; shift 2 ;;
    --level) LEVEL="$2"; shift 2 ;;
    --context) CONTEXT="$2"; shift 2 ;;
    --json) OUTPUT_JSON=true; shift ;;
    --help)
      echo "用法: check-gates.sh --from <state> --to <state> --level <L0|L1|L2|L3> [--json] [--context <path>]"
      echo ""
      echo "参数:"
      echo "  --from    当前状态（可选，推荐传入）"
      echo "  --to      目标状态（必需）"
      echo "  --level   复杂度级别（默认: L3）"
      echo "  --json    输出 JSON 格式（符合 gate-result.schema.json）"
      echo "  --context 上下文路径（可选）"
      echo ""
      echo "示例:"
      echo "  check-gates.sh --from DISCOVERY --to REQUIREMENT_LOCK --level L3"
      echo "  check-gates.sh --from CONTEXT_HYDRATION --to IMPLEMENTATION --level L2 --json"
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

case "$LEVEL" in
  L0|L1|L2|L3) ;;
  *)
    echo "✗ 错误: --level 仅支持 L0|L1|L2|L3，当前为: $LEVEL"
    exit 1
    ;;
esac

if [[ -n "$CONTEXT" ]]; then
  context_path="$CONTEXT"
  if [[ "$context_path" != /* ]]; then
    context_path="$PROJECT_ROOT/$context_path"
  fi
  if [[ ! -f "$context_path" ]]; then
    echo "✗ 错误: --context 文件不存在: $context_path"
    exit 1
  fi
fi

if ! $OUTPUT_JSON; then
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
fi

if [[ ! -f "$GATES_YAML" ]]; then
  echo "✗ 错误: gates.yaml 不存在: $GATES_YAML"
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "✗ 错误: 需要 python3"
  exit 1
fi

python3 - "$GATES_YAML" "$GATES_DIR" "$TO_STATE" "$LEVEL" "$PROJECT_ROOT" "$OUTPUT_JSON" "$FROM_STATE" "$CONTEXT" << 'EOF'
import yaml
import sys
import subprocess
import json
import os
from pathlib import Path
from datetime import datetime, timezone

gates_yaml = sys.argv[1]
gates_dir = sys.argv[2]
to_state = sys.argv[3]
level = sys.argv[4]
project_root = sys.argv[5]
output_json = sys.argv[6].lower() == 'true'
from_state = sys.argv[7] if len(sys.argv) > 7 else ''
context_path = sys.argv[8] if len(sys.argv) > 8 else ''

errors = 0
passed = 0
skipped = 0
gate_results = []

try:
    with open(gates_yaml) as f:
        data = yaml.safe_load(f)
except Exception as e:
    if output_json:
        print(json.dumps({
            "status": "error",
            "gate_id": "G000",
            "gate_name": "check-gates",
            "message": f"无法解析 gates.yaml: {e}",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }))
    else:
        print(f"✗ 错误: 无法解析 gates.yaml: {e}")
    sys.exit(1)

gates_dict = data.get('gates', {})
if not gates_dict:
    if output_json:
        print(json.dumps({
            "status": "skip",
            "gate_id": "G000",
            "gate_name": "check-gates",
            "message": "gates.yaml 中没有定义任何 gate",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }))
    else:
        print("⚠ 警告: gates.yaml 中没有定义任何 gate")
    sys.exit(0)

applicable_gates = []
for gate_key, gate in gates_dict.items():
    if isinstance(gate, dict):
        applies_to = gate.get('applies_to', [])
        if to_state in applies_to:
            applicable_gates.append(gate)

if not applicable_gates:
    if output_json:
        print(json.dumps({
            "status": "pass",
            "gate_id": "G000",
            "gate_name": "check-gates",
            "message": f"目标状态 {to_state} 没有关联的 gate",
            "context": {"from_state": from_state, "to_state": to_state, "level": level},
            "timestamp": datetime.now(timezone.utc).isoformat()
        }))
    else:
        print(f"✓ 无需检查: 目标状态 {to_state} 没有关联的 gate")
    sys.exit(0)

if not output_json:
    print(f"发现 {len(applicable_gates)} 个适用的 gate")
    print("")

for gate in applicable_gates:
    gate_name = gate.get('name', 'unknown')
    gate_id = gate.get('id', 'G000')
    gate_script = gate.get('script', '')
    l1_exempt = gate.get('l1_exempt', False)
    severity = gate.get('severity', 'hard')
    fail_message = gate.get('fail_message', 'Gate 检查失败')
    remediation = gate.get('remediation', [])
    
    start_time = datetime.now(timezone.utc)
    
    if not output_json:
        print(f"→ 检查 Gate: {gate_name}")
    
    if l1_exempt and level == 'L1':
        if not output_json:
            print(f"  ⊘ 跳过: L1 豁免")
        skipped += 1
        gate_results.append({
            "status": "skip",
            "gate_id": gate_id,
            "gate_name": gate_name,
            "message": "L1 豁免",
            "context": {"from_state": from_state, "to_state": to_state, "level": level},
            "timestamp": start_time.isoformat()
        })
        continue
    
    script_path = Path(project_root) / gate_script
    
    if not script_path.exists():
        if not output_json:
            print(f"  ⚠ 警告: Gate 脚本不存在: {gate_script}")
        if severity == 'hard':
            if not output_json:
                print(f"  ✗ 阻断: GATE_FAILED:{gate_name} 严重级别为 hard，无法继续")
            errors += 1
            gate_results.append({
                "status": "error",
                "gate_id": gate_id,
                "gate_name": gate_name,
                "message": f"Gate 脚本不存在: {gate_script}",
                "fail_message": fail_message,
                "remediation": remediation,
                "context": {"from_state": from_state, "to_state": to_state, "level": level},
                "timestamp": start_time.isoformat()
            })
        else:
            if not output_json:
                print(f"  ⊘ 跳过: 严重级别为 {severity}")
            skipped += 1
        continue
    
    try:
        env = os.environ.copy()
        if context_path:
            context_file = Path(context_path)
            if not context_file.is_absolute():
                context_file = Path(project_root) / context_file
            env["GSTACK_GATE_CONTEXT"] = str(context_file)

        result = subprocess.run(
            ['bash', str(script_path)],
            cwd=project_root,
            env=env,
            capture_output=True,
            text=True,
            timeout=60
        )
        
        end_time = datetime.now(timezone.utc)
        duration_ms = int((end_time - start_time).total_seconds() * 1000)
        
        if result.returncode == 0:
            if not output_json:
                print(f"  ✓ 通过")
                if result.stdout:
                    for line in result.stdout.strip().split('\n'):
                        if line and "fallback used:" in line:
                            print(f"     {line}")
            passed += 1
            gate_results.append({
                "status": "pass",
                "gate_id": gate_id,
                "gate_name": gate_name,
                "message": "Gate 检查通过",
                "context": {"from_state": from_state, "to_state": to_state, "level": level},
                "timestamp": start_time.isoformat(),
                "duration_ms": duration_ms
            })
        elif result.returncode == 1:
            if not output_json:
                print(f"  ✗ 阻断: GATE_FAILED:{gate_name} {fail_message}")
                if result.stdout:
                    for line in result.stdout.strip().split('\n'):
                        if line:
                            print(f"     {line}")
            errors += 1
            gate_results.append({
                "status": "block",
                "gate_id": gate_id,
                "gate_name": gate_name,
                "message": fail_message,
                "fail_message": fail_message,
                "remediation": remediation,
                "context": {"from_state": from_state, "to_state": to_state, "level": level},
                "timestamp": start_time.isoformat(),
                "duration_ms": duration_ms
            })
        else:
            if not output_json:
                print(f"  ⚠ 基础设施错误: GATE_FAILED:{gate_name} (exit code: {result.returncode})")
                if result.stderr:
                    print(f"     {result.stderr}")
            errors += 1
            gate_results.append({
                "status": "error",
                "gate_id": gate_id,
                "gate_name": gate_name,
                "message": f"基础设施错误 (exit code: {result.returncode})",
                "fail_message": fail_message,
                "remediation": remediation,
                "context": {"from_state": from_state, "to_state": to_state, "level": level},
                "timestamp": start_time.isoformat(),
                "duration_ms": duration_ms
            })
    except subprocess.TimeoutExpired:
        if not output_json:
            print(f"  ✗ 超时: GATE_FAILED:{gate_name} Gate 执行超过 60 秒")
        errors += 1
        gate_results.append({
            "status": "error",
            "gate_id": gate_id,
            "gate_name": gate_name,
            "message": "Gate 执行超过 60 秒",
            "fail_message": fail_message,
            "remediation": remediation,
            "context": {"from_state": from_state, "to_state": to_state, "level": level},
            "timestamp": start_time.isoformat()
        })
    except Exception as e:
        if not output_json:
            print(f"  ✗ 执行错误: GATE_FAILED:{gate_name} {e}")
        errors += 1
        gate_results.append({
            "status": "error",
            "gate_id": gate_id,
            "gate_name": gate_name,
            "message": f"执行错误: {e}",
            "fail_message": fail_message,
            "remediation": remediation,
            "context": {"from_state": from_state, "to_state": to_state, "level": level},
            "timestamp": start_time.isoformat()
        })

if output_json:
    print(json.dumps({
        "status": "pass" if errors == 0 else "block",
        "gate_id": "G000",
        "gate_name": "check-gates",
        "message": f"通过: {passed}, 跳过: {skipped}, 阻断: {errors}",
        "context": {
            "from_state": from_state,
            "to_state": to_state,
            "level": level
        },
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "gate_results": gate_results
    }, indent=2))
else:
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

if errors > 0:
    sys.exit(1)
else:
    sys.exit(0)
EOF
