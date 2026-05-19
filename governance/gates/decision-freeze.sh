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

# 非 git 环境：降级为基于 workflow-state.md 时间戳的检查
if ! git -C "$PROJECT_ROOT" rev-parse --git-dir &>/dev/null; then
  echo "⚠ 非 git 环境，使用降级模式检查决策冻结"

  # 降级模式：检查 workflow-state.md 是否存在且包含 IMPLEMENTATION 状态
  if [[ -f "$STATE_FILE" ]]; then
    # 检查最近一次 IMPLEMENTATION 进入时间
    impl_ts=$(grep -i "IMPLEMENTATION\|implementation" "$STATE_FILE" 2>/dev/null | head -1 || true)
    if [[ -n "$impl_ts" ]]; then
      # 检查 ADR/specs 目录下文件的修改时间是否晚于 IMPLEMENTATION 进入时间
      state_mtime=$(stat -f "%m" "$STATE_FILE" 2>/dev/null || stat -c "%Y" "$STATE_FILE" 2>/dev/null || echo "0")

      # 检查冻结目录中的文件是否有比状态文件更新的修改
      frozen_dirs=("$ADR_DIR" "$PROJECT_ROOT/context-layer/specs")
      violations=()

      for dir in "${frozen_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
          while IFS= read -r file; do
            file_mtime=$(stat -f "%m" "$file" 2>/dev/null || stat -c "%Y" "$file" 2>/dev/null || echo "0")
            if [[ "$file_mtime" -gt "$state_mtime" ]]; then
              violations+=("$file")
            fi
          done < <(find "$dir" -name "*.md" -type f 2>/dev/null)
        fi
      done

      if [[ ${#violations[@]} -gt 0 ]]; then
        echo ""
        echo "✗ 决策冻结违规（降级模式）：以下文件在 IMPLEMENTATION 后被修改："
        printf '  - %s\n' "${violations[@]}"
        echo ""
        echo "修复步骤:"
        echo "  1. 如果需要修改冻结项，请先回退到 Decision Layer"
        echo "  2. 或创建新的 ADR 记录变更决策"
        exit 1
      fi

      echo "✓ 决策冻结检查通过（降级模式：基于文件时间戳）"
      exit 0
    fi
  fi

  # 无状态文件时记录警告但不阻断
  echo "⚠ 非 git 环境且无 workflow-state.md，无法验证决策冻结"
  echo "  建议：初始化 git 仓库或确保 workflow-state.md 存在"
  echo "  降级行为：放行但记录警告"
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
