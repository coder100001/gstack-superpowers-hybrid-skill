#!/bin/bash
set -euo pipefail

# acceptance-check.sh — 验收项与结果证据映射检查
# 用法:
#   ./governance/gates/acceptance-check.sh [plan_file] [evidence_dir]
# 返回:
#   0 - 通过（所有验收项都有证据）
#   1 - 阻断（存在未覆盖的验收项）
#   2 - 基础设施错误

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
source "$SCRIPT_DIR/common-context.sh"

PLAN_FILE="${1:-$PROJECT_ROOT/specs/plans/*.md}"
EVIDENCE_DIR="${2:-$PROJECT_ROOT/artifacts/acceptance}"
CONTRACT_FILE="$PROJECT_ROOT/context-layer/specs/contract-summary.md"

context_plan="$(gate_context_get "plan_file" "current_plan_file")"
if [[ -n "$context_plan" ]]; then
    PLAN_FILE="$(gate_context_path "$context_plan" "$PROJECT_ROOT")"
fi

context_evidence="$(gate_context_get "evidence_dir" "acceptance_evidence_dir")"
if [[ -z "$context_evidence" ]]; then
    gate_log_fallback "evidence_dir not set; using default artifacts/acceptance"
fi
if [[ -n "$context_evidence" ]]; then
    EVIDENCE_DIR="$(gate_context_path "$context_evidence" "$PROJECT_ROOT")"
fi

echo "=========================================="
echo "Acceptance Check Gate (G008)"
echo "=========================================="
echo ""
echo "Plan 文件: $PLAN_FILE"
echo "证据目录: $EVIDENCE_DIR"
echo ""

# 检查契约摘要文件是否存在
if [[ ! -f "$CONTRACT_FILE" ]]; then
    echo "⚠ 警告: 契约摘要文件不存在: $CONTRACT_FILE"
    echo "GATE_FAILED:acceptance-check"
    exit 2
fi

# 仅在未明确指定 plan 时，查找最新 plan 文件
if [[ "$PLAN_FILE" == *"*"* ]] && [[ -d "$PROJECT_ROOT/specs/plans" ]]; then
    gate_log_fallback "plan_file not set; selecting newest plan file"
    LATEST_PLAN=$(find "$PROJECT_ROOT/specs/plans" -name "*.md" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
    if [[ -n "$LATEST_PLAN" ]]; then
        PLAN_FILE="$LATEST_PLAN"
        echo "使用最新 Plan: $PLAN_FILE"
    fi
fi

# 检查 plan 文件是否存在
if [[ ! -f "$PLAN_FILE" ]]; then
    echo "⚠ 警告: Plan 文件不存在，跳过验收检查"
    echo "GATE_FAILED:acceptance-check"
    exit 2
fi

# 从 plan 提取验收项
# 查找 "验收标准" 或 "Acceptance Criteria" 或 "acceptance:" 部分
ACCEPTANCE_ITEMS=$(grep -A 20 -iE "验收标准|acceptance.*criteria|acceptance:" "$PLAN_FILE" 2>/dev/null | grep -E "^\s*[-*]\s*" | sed 's/^\s*[-*]\s*//' | head -20 || true)

if [[ -z "$ACCEPTANCE_ITEMS" ]]; then
    echo "✓ 未找到验收标准定义，默认通过"
    exit 0
fi

echo "-------------------------------------------"
echo "验收项检查"
echo "-------------------------------------------"
echo ""

# 创建证据目录
mkdir -p "$EVIDENCE_DIR"

UNCOVERED=0
COVERED=0

while IFS= read -r item; do
    if [[ -z "$item" ]]; then
        continue
    fi
    
    # 简化验收项用于匹配
    simple_item=$(echo "$item" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
    
    # 检查是否有对应证据
    evidence_found=false
    
    # 检查证据目录中的文件
    if [[ -d "$EVIDENCE_DIR" ]]; then
        for evidence_file in "$EVIDENCE_DIR"/*; do
            if [[ -f "$evidence_file" ]]; then
                evidence_name=$(basename "$evidence_file" | tr '[:upper:]' '[:lower:]')
                if [[ "$evidence_name" == *"$simple_item"* ]] || [[ "$simple_item" == *"$evidence_name"* ]]; then
                    evidence_found=true
                    break
                fi
            fi
        done
    fi
    
    # 检查测试文件作为证据
    if [[ "$evidence_found" == false ]]; then
        # 检查是否有相关测试
        if grep -rq "$item" "$PROJECT_ROOT/tests" 2>/dev/null || grep -rq "$item" "$PROJECT_ROOT/specs" 2>/dev/null; then
            evidence_found=true
        fi
    fi
    
    if [[ "$evidence_found" == true ]]; then
        echo "✓ 已覆盖: $item"
        COVERED=$((COVERED + 1))
    else
        echo "✗ 未覆盖: $item"
        UNCOVERED=$((UNCOVERED + 1))
    fi
done <<< "$ACCEPTANCE_ITEMS"

echo ""
echo "=========================================="
echo "检查结果"
echo "=========================================="
echo ""
echo "已覆盖: $COVERED"
echo "未覆盖: $UNCOVERED"
echo ""

if [[ $UNCOVERED -gt 0 ]]; then
    echo "GATE_FAILED:acceptance-check"
    echo ""
    echo "建议操作:"
    echo "1. 在 artifacts/acceptance/ 目录下创建证据文件"
    echo "2. 或更新 plan 调整验收标准"
    exit 1
fi

echo "✓ 验收检查通过"
exit 0
