#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_FILE="$PROJECT_ROOT/docs/skills-reference.md"

echo "=== Generating skills-reference.md ==="

SUPERPOWERS_COUNT=$(find "$PROJECT_ROOT/skills/superpowers" -maxdepth 2 -name "SKILL.md" | wc -l | tr -d ' ')
GSTACK_COUNT=$(find "$PROJECT_ROOT/skills/gstack" -maxdepth 2 -name "SKILL.md" | wc -l | tr -d ' ')

cat > "$OUTPUT_FILE" << HEADER
# 技能参考手册

> **文档状态**: 自动生成 · **真相源**: [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md)
>
> 本文档由脚本自动生成，禁止手动编辑。如需修改技能信息，请编辑对应 SKILL.md 后重新运行 \`scripts/generate-skills-reference.sh\`。

## 目录

1. [Superpowers 技能](#superpowers-技能)
2. [GStack 技能](#gstack-技能)
3. [Hybrid 技能](#hybrid-技能)
4. [Custom 技能](#custom-技能)
5. [三层架构对比](#三层架构对比)

---

## Superpowers 技能

**路径**: \`skills/superpowers/\`

**数量**: ${SUPERPOWERS_COUNT}个

**定位**: 工程纪律与结构化拆解

**来源**: [Superpowers](https://github.com/obra/superpowers)

### 技能列表

| 技能 | 描述 | 触发方式 |
|------|------|---------|
HEADER

for skill_dir in "$PROJECT_ROOT/skills/superpowers"/*/; do
    if [[ -f "$skill_dir/SKILL.md" ]]; then
        skill_name=$(basename "$skill_dir")
        description=$(grep "^description:" "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/^description:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//' | head -c 80 || true)
        if [[ -z "$description" ]]; then
            description=$(grep "^# " "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/^# //' | head -c 80 || echo "—")
        fi
        description=$(echo "$description" | head -c 80)
        echo "| [$skill_name](../skills/superpowers/$skill_name/SKILL.md) | ${description}... | 自动/手动 |" >> "$OUTPUT_FILE"
    fi
done

cat >> "$OUTPUT_FILE" << GSTACK_HEADER

---

## GStack 技能

**路径**: \`skills/gstack/\`

**数量**: ${GSTACK_COUNT}个

**定位**: 多角色决策审议

**来源**: [GStack](https://github.com/garrytan/gstack)

### 技能列表

| 技能 | 描述 | 触发方式 |
|------|------|---------|
GSTACK_HEADER

for skill_dir in "$PROJECT_ROOT/skills/gstack"/*/; do
    if [[ -f "$skill_dir/SKILL.md" ]]; then
        skill_name=$(basename "$skill_dir")
        description=$(sed -n '/^description: *|/,/^[a-z-]*:/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -v "^description:" | grep -v "^[a-z-]*:" | head -3 | tr '\n' ' ' | sed 's/^[[:space:]]*//' | head -c 80 || true)
        if [[ -z "$description" ]]; then
            description=$(grep "^description:" "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/^description:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//' | head -c 80 || true)
        fi
        if [[ -z "$description" ]]; then
            description=$(grep "^# " "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/^# //' | head -c 80 || echo "—")
        fi
        description=$(echo "$description" | head -c 80)
        echo "| [$skill_name](../skills/gstack/$skill_name/SKILL.md) | ${description}... | 手动 |" >> "$OUTPUT_FILE"
    fi
done

cat >> "$OUTPUT_FILE" << HYBRID_SECTION

---

## Hybrid 技能

**路径**: \`skills/hybrid/\`

**数量**: 1个

### gs-hybrid-v3

**主入口技能（薄入口）**，AI Engineering Governance System v4.1。

#### 核心特性

- **三层架构**: Decision / Context / Execution 三层分离
- **模块化设计**: 7个模块按需加载
- **复杂度分级**: L1/L2/L3 三级流程
- **强制确认机制**: REQUIREMENT_LOCK、TASK_DECOMPOSITION、PLAN_CONFIRM
- **多角色审议**: 产品/架构/性能/安全/运维 5个维度审查
- **决策冻结机制**: 执行层不允许更改架构和需求
- **Context Hydration**: 执行前强制注入上下文契约
- **Governance 层**: 状态机 (13状态) + Gate 脚本 (7个) + CI Guard

#### 模块列表

| 模块 | 内容 | 加载时机 |
|------|------|---------|
| 01-intro.md | 三层架构介绍、项目配置 | 初始 |
| 02-complexity.md | 复杂度分级 (L1/L2/L3) | Step 0 |
| 03a-discovery-arch.md | DISCOVERY + REQUIREMENT_LOCK + ARCH_REVIEW | Decision Layer |
| 03b-task-decomposition.md | TASK_DECOMPOSITION + PLAN_CONFIRM | Decision Layer |
| 04a-execution-hydration.md | CONTEXT_HYDRATION + IMPLEMENTATION 规范 | Context -> Execution |
| 04b-self-review.md | SELF_REVIEW + QA | Execution Layer |
| 05-ship-review-retro.md | SHIP_REVIEW + RETRO | Execution -> Governance |
| 06-workflows.md | 专用流程指令 | 指令触发 |
| 07-handling.md | 异常处理和状态回滚 | 异常发生时 |

#### 主流程（由状态机真相源定义）

\`IDEA -> DISCOVERY -> REQUIREMENT_LOCK -> ARCH_REVIEW -> TASK_DECOMPOSITION -> PLAN_CONFIRM -> CONTEXT_HYDRATION -> IMPLEMENTATION -> SELF_REVIEW -> QA -> SHIP_REVIEW -> RETRO\`

#### Gate 检查点（7个）

| Gate | 状态 | 检查内容 |
|------|------|---------|
| G001 requirement-lock | REQUIREMENT_LOCK | 用户确认需求 |
| G002 arch-review-lock | ARCH_REVIEW | L2+ 有 ADR |
| G003 task-decomposition-lock | TASK_DECOMPOSITION | plan 存在且无占位符 |
| G004 plan-confirm | PLAN_CONFIRM | 用户确认执行计划 |
| G005 context-hydration | CONTEXT_HYDRATION | Spec 文件存在 |
| G006 decision-freeze | IMPLEMENTATION | 冻结项未修改 |
| G007 test-presence | SELF_REVIEW | 测试文件存在 |

#### 专用指令

| 指令 | 功能 |
|------|------|
| \`/plan\` | 规划流程 |
| \`/review\` | 代码审查 |
| \`/test\` | 测试驱动 |
| \`/qa\` | 质量保证 |
| \`/debug\` | 调试助手 |
| \`/refactor\` | 重构建议 |

#### 真相源

| 文件 | 用途 |
|------|------|
| \`governance/state-machine.yaml\` | 状态机定义（唯一真相源） |
| \`governance/gates.yaml\` | Gate 定义（唯一真相源） |
| \`skills/hybrid/gs-hybrid-v3/SKILL.md\` | 路由与加载策略入口 |

---

## Custom 技能

**路径**: \`skills/custom/\`

**用途**: 用户自定义扩展技能

---

## 三层架构对比

| 维度 | Superpowers | GStack | Hybrid |
|------|-------------|--------|--------|
| **定位** | 工程纪律 | 多角色审议 | AI工程治理 |
| **架构** | 单一流程 | 工具集 | Decision/Context/Execution三层 |
| **数量** | ${SUPERPOWERS_COUNT}个 | ${GSTACK_COUNT}个 | 1个（融合两者） |
| **重点** | 流程规范 | 决策审议 | 治理流程 |
| **触发** | 自动+手动 | 条件+手动 | 自动+条件+手动 |
| **维护** | 上游同步 | 上游同步 | 手动维护 |

### 三层职责分配

| 层 | 职责 | 激活的 Skills |
|------|------|:-------------|
| **Decision Layer** | 想清楚做什么 | \`brainstorming\`, \`design\`, \`writing-plans\`, \`plan-verification\`, \`gstack:plan-eng-review\`, \`gstack:plan-devex-review\` |
| **Context Layer** | 固化共识、防遗忘 | \`context-save\`, \`context-restore\`, \`learn\` |
| **Execution Layer** | 严格按契约做 | \`test-driven-development\`, \`requesting-code-review\`, \`verification-before-completion\`, \`gstack:qa\`, \`gstack:cso\`, \`gstack:benchmark\`, \`gstack:codex\` |
| **Governance** | 决策冻结、状态机控制 | \`gstack:ship\`, \`gstack:retro\`, \`gstack:investigate\`, \`freeze\`, \`guard\`, \`careful\` |

---

## 文档维护规则

| 文档 | 角色 | 同步方式 |
|:-----|:-----|:---------|
| [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md) | Hybrid 入口与路由真相源 | 手动维护 |
| 各技能 SKILL.md | 技能定义 | 上游同步/手动 |
| **skills-reference.md** | 技能索引与对照 | **脚本自动生成** |

---

> **生成时间**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
>
> **生成命令**: \`bash scripts/generate-skills-reference.sh\`
HYBRID_SECTION

echo "✅ Generated: $OUTPUT_FILE"
echo "   Superpowers: $SUPERPOWERS_COUNT skills"
echo "   GStack: $GSTACK_COUNT skills"
