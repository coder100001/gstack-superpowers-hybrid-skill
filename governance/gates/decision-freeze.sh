#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# decision-freeze.sh — 检查 IMPLEMENTATION 期间决策冻结
# 验证条件：ADR 和 specs 在进入 IMPLEMENTATION 后未被修改
# 使用 workflow-state.md 或 ADR 时间戳作为基准

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
STATE_FILE="$PROJECT_ROOT/artifacts/workflow-state.md"
ADR_DIR="$PROJECT_ROOT/decision-layer/adr"

FROZEN_PATTERNS="^decision-layer/adr/|^context-layer/specs/"

# 非 git 环境警告但不阻断
if ! git -C "$PROJECT_ROOT" rev-parse --git-dir &>/dev/null; then
  echo "警告: 非 git 环境，跳过决策冻结检查"
  exit 0
fi

# 确定基准 commit
BASE_COMMIT=""

# 方法1: 从 workflow-state.md 获取 IMPLEMENTATION 开始时间
if [[ -f "$STATE_FILE" ]]; then
  impl_ts=$(grep -A5 "Current State" "$STATE_FILE" 2>/dev/null | grep "status: IMPLEMENTATION" | head -1 || true)
  if [[ -n "$impl_ts" ]]; then
    # 获取状态文件中记录的时间戳
    state_ts=$(grep "Last Updated:" "$STATE_FILE" | sed 's/.*: //' | head -1 || true)
    if [[ -n "$state_ts" ]]; then
      # 找到该时间戳对应的 commit
      base_commit=$(git -C "$PROJECT_ROOT" log --before="$state_ts" -1 --format="%H" 2>/dev/null || true)
      if [[ -n "$base_commit" ]]; then
        BASE_COMMIT="$base_commit"
        echo "基准 commit (from state): $BASE_COMMIT"
      fi
    fi
  fi
fi

# 方法2: 从最新的 ADR 获取时间戳
if [[ -z "$BASE_COMMIT" ]] && [[ -d "$ADR_DIR" ]]; then
  latest_adr=$(ls -t "$ADR_DIR"/ADR-*.md 2>/dev/null | head -1 || true)
  if [[ -n "$latest_adr" ]]; then
    # 从 ADR 文件提取日期
    adr_date=$(grep -E "^Date:|^date:" "$latest_adr" 2>/dev/null | head -1 | sed 's/[Dd]ate:[[:space:]]*//' || true)
    if [[ -n "$adr_date" ]]; then
      base_commit=$(git -C "$PROJECT_ROOT" log --before="$adr_date 23:59:59" -1 --format="%H" 2>/dev/null || true)
      if [[ -n "$base_commit" ]]; then
        BASE_COMMIT="$base_commit"
        echo "基准 commit (from ADR): $BASE_COMMIT"
      fi
    fi
  fi
fi

# 方法3: 回退到 HEAD~1
if [[ -z "$BASE_COMMIT" ]]; then
  BASE_COMMIT="HEAD~1"
  echo "基准 commit (fallback): HEAD~1"
fi

# 检查冻结文件变更
changed_files=$(git -C "$PROJECT_ROOT" diff "$BASE_COMMIT" --name-only 2>/dev/null | grep -E "$FROZEN_PATTERNS" || true)

if [[ -n "$changed_files" ]]; then
  echo ""
  echo "✗ 决策冻结违规：IMPLEMENTATION 期间修改了以下冻结文件："
  echo "$changed_files" | sed 's/^/  - /'
  echo ""
  echo "修复步骤:"
  echo "  1. 如果需要修改冻结项，请先回退到 Decision Layer"
  echo "  2. 运行: transition.sh IMPLEMENTATION ARCH_REVIEW --reason change_request"
  echo "  3. 或创建新的 ADR 记录变更决策"
  echo ""
  echo "基准 commit: $BASE_COMMIT"
  exit 1
fi

echo "✓ 决策冻结检查通过"
exit 0
