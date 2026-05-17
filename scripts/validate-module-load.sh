#!/bin/bash

# validate-module-load.sh - 校验模块文件 Context Load 与 SKILL.md 加载策略表一致性
# 用法: ./scripts/validate-module-load.sh [-v|--verbose]
# 返回: 0 (全部一致) / 1 (有不一致)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_DIR="$PROJECT_ROOT/skills/hybrid/gs-hybrid-v3"
MODULES_DIR="$SKILL_DIR/modules"
ERRORS=0

echo "=== 模块文件 Context Load 一致性校验 ==="
echo ""

# 从模块文件提取 Context Load 声明
MODULE_NAMES=()
MODULE_LOADS=()
for f in "$MODULES_DIR"/*.md; do
    name=$(basename "$f")
    load=$(head -5 "$f" | grep "^> \*\*Context Load\*\*:" | sed 's/^> \*\*Context Load\*\*: //')
    if [[ -n "$load" ]]; then
        MODULE_NAMES+=("$name")
        MODULE_LOADS+=("$load")
        echo "[OK] $name: 已声明 Context Load"
    else
        echo "[WARN] $name: 无 Context Load 声明"
    fi
done

echo ""
echo "--- 校验 SKILL.md 路径与模块声明的对应关系 ---"
echo ""

# 从 SKILL.md 提取加载策略表
SKILL_FILE="$SKILL_DIR/SKILL.md"

# 检测 加载策略速查表 是否完整
if ! grep -q "^## 加载策略速查表" "$SKILL_FILE"; then
    echo "[FAIL] SKILL.md 缺少 '加载策略速查表' 章节"
    ERRORS=$((ERRORS + 1))
fi

# 校验每个模块是否在表中被引用
for i in "${!MODULE_NAMES[@]}"; do
    name="${MODULE_NAMES[$i]}"
    if grep -q "$name" "$SKILL_FILE"; then
        echo "[OK] $name 在加载策略速查表中"
    else
        echo "[FAIL] $name 不在加载策略速查表中"
        ERRORS=$((ERRORS + 1))
    fi
done

echo ""
echo "--- 校验框架文件路径映射 ---"
echo ""

# 模块声明的框架文件应可访问
for i in "${!MODULE_NAMES[@]}"; do
    name="${MODULE_NAMES[$i]}"
    load="${MODULE_LOADS[$i]}"
    # 提取反引号路径
    files=$(echo "$load" | tr '`' '\n' | grep "\.md" | grep "/" || true)
    for f in $files; do
        # 跳过非文件路径（如标点）
        if [[ "$f" == *"/"* ]] && [[ "$f" == *".md" ]]; then
            # 尝试从项目根目录解析
            full_path="$PROJECT_ROOT/$f"
            if [[ -f "$full_path" ]]; then
                echo "[OK] $name -> $f"
            else
                # 尝试从 decision-layer 解析
                alt_path="$PROJECT_ROOT/decision-layer/$f"
                if [[ -f "$alt_path" ]]; then
                    echo "[OK] $name -> decision-layer/$f"
                else
                    alt_path2="$PROJECT_ROOT/context-layer/$f"
                    if [[ -f "$alt_path2" ]]; then
                        echo "[OK] $name -> context-layer/$f"
                    else
                        alt_path3="$PROJECT_ROOT/execution-layer/$f"
                        if [[ -f "$alt_path3" ]]; then
                            echo "[OK] $name -> execution-layer/$f"
                        else
                            echo "[FAIL] $name -> $f: 文件不存在"
                            ERRORS=$((ERRORS + 1))
                        fi
                    fi
                fi
            fi
        fi
    done
done

echo ""
if [[ $ERRORS -eq 0 ]]; then
    echo "✅ 全部一致 (${#MODULE_NAMES[@]} 个模块)"
    exit 0
else
    echo "❌ 发现 $ERRORS 处不一致"
    exit 1
fi