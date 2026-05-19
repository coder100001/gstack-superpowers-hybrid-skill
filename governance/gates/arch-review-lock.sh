#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# arch-review-lock.sh — 检查 ARCH_REVIEW 是否已通过
# 验证条件：ADR 文件存在（L2+ 任务必须）
# L1 任务自动通过（L1 无架构变更时可跳过 ARCH_REVIEW）

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ADR_DIR="$PROJECT_ROOT/decision-layer/adr"
STATE_FILE="$PROJECT_ROOT/artifacts/workflow-state.md"

# 读取复杂度级别（精确匹配行首格式）
complexity=""
if [[ -f "$STATE_FILE" ]]; then
  complexity=$(grep -i "^- *complexity:\|^- *level:\|^- *级别:" "$STATE_FILE" 2>/dev/null | head -1 | sed 's/.*:[[:space:]]*//' | tr '[:upper:]' '[:lower:]' || true)
fi

# L1 任务自动通过
if [[ "$complexity" == "l1" ]]; then
  echo "✓ ARCH_REVIEW 通过（L1 豁免）"
  echo "  复杂度级别: L1"
  echo "  说明: L1 任务可跳过架构审议"
  exit 0
fi

# L2+ 任务必须检查 ADR
if [[ ! -d "$ADR_DIR" ]]; then
  echo ""
  echo "✗ ARCH_REVIEW 未通过：ADR 目录不存在"
  echo ""
  echo "期望路径: decision-layer/adr/"
  echo ""
  echo "修复步骤:"
  echo "  1. 运行架构审议流程生成 ADR"
  echo "  2. 或手动创建 ADR 文件到 decision-layer/adr/ 目录"
  exit 1
fi

adr_files=$(ls "$ADR_DIR"/ADR-*.md 2>/dev/null || true)

if [[ -z "$adr_files" ]]; then
  echo ""
  echo "✗ ARCH_REVIEW 未通过：未找到 ADR 文件"
  echo ""
  echo "期望路径: decision-layer/adr/ADR-NNN-*.md"
  echo ""
  echo "修复步骤:"
  echo "  1. 运行架构审议流程生成 ADR"
  echo "  2. ADR 模板参考: decision-layer/adr/ADR-001-initial-architecture-framework.md"
  echo "  3. L2+ 任务必须有至少一个 ADR 记录架构决策"
  exit 1
fi

# 检查最新 ADR 是否包含审议结论
latest_adr=$(ls -t "$ADR_DIR"/ADR-*.md 2>/dev/null | head -1)
if [[ -n "$latest_adr" ]]; then
  # 检查 ADR 是否包含决策状态（结构化格式匹配）
  if ! grep -qi "^Decision:\|^Status:.*Approved\|^Status:.*Accepted\|^- \[x\].*approved\|^- \[x\].*确认" "$latest_adr" 2>/dev/null; then
    echo ""
    echo "✗ ARCH_REVIEW 未通过：最新 ADR 缺少决策状态"
    echo "  文件: $latest_adr"
    echo ""
    echo "修复步骤:"
    echo "  1. 在 ADR 中添加决策状态（Approved / Rejected / Superseded）"
    echo "  2. 格式: Decision: [Approved | Rejected | Superseded]"
    exit 1
  fi
fi

# 记录状态
mkdir -p "$(dirname "$STATE_FILE")"
ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00")

if [[ -f "$STATE_FILE" ]]; then
  echo "" >> "$STATE_FILE"
  echo "### Arch Review Lock" >> "$STATE_FILE"
  echo "- Timestamp: $ts" >> "$STATE_FILE"
  echo "- Status: passed" >> "$STATE_FILE"
  echo "- ADRs: $(echo "$adr_files" | wc -l | tr -d ' ') file(s)" >> "$STATE_FILE"
else
  cat > "$STATE_FILE" << EOF
# Workflow State

> **Last Updated**: $ts

### Arch Review Lock
- Timestamp: $ts
- Status: passed
- ADRs: $(echo "$adr_files" | wc -l | tr -d ' ') file(s)
EOF
fi

echo "✓ ARCH_REVIEW 通过"
echo "  复杂度级别: ${complexity:-未指定（默认 L2+）}"
echo "  ADR 文件: $(echo "$adr_files" | wc -l | tr -d ' ') 个"
echo "  最新 ADR: $(basename "$latest_adr")"
exit 0
