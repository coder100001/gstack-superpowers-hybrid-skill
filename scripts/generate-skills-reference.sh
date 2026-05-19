#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_FILE="$PROJECT_ROOT/docs/skills-reference.md"

echo "=== Generating skills-reference.md ==="

# Count skills
SUPERPOWERS_COUNT=$(find "$PROJECT_ROOT/skills/superpowers" -maxdepth 2 -name "SKILL.md" | wc -l | tr -d ' ')
GSTACK_COUNT=$(find "$PROJECT_ROOT/skills/gstack" -maxdepth 2 -name "SKILL.md" | wc -l | tr -d ' ')

# Start writing
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

# Extract Superpowers skills
for skill_dir in "$PROJECT_ROOT/skills/superpowers"/*/; do
    if [[ -f "$skill_dir/SKILL.md" ]]; then
        skill_name=$(basename "$skill_dir")
        # Get description from YAML front matter (single line format)
        description=$(grep "^description:" "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/^description:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//' | head -c 80 || true)
        # Fallback to first # heading
        if [[ -z "$description" ]]; then
            description=$(grep "^# " "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/^# //' | head -c 80 || echo "—")
        fi
        # Clean up description
        description=$(echo "$description" | head -c 80)
        echo "| [$skill_name](../skills/superpowers/$skill_name/SKILL.md) | ${description}... | 自动/手动 |" >> "$OUTPUT_FILE"
    fi
done

# GStack section
cat >> "$OUTPUT_FILE" << GSTACK_HEADER

---

## GStack 技能

**路径**: \`skills/gstack/\`

**数量**: ${GSTACK_COUNT}个

**定位**: 多角色决策审议

**来源**: [GStack](https://github.com/gstack)

### 技能列表

| 技能 | 描述 | 触发方式 |
|------|------|---------|
GSTACK_HEADER

# Extract GStack skills
for skill_dir in "$PROJECT_ROOT/skills/gstack"/*/; do
    if [[ -f "$skill_dir/SKILL.md" ]]; then
        skill_name=$(basename "$skill_dir")
        # Get description from multi-line YAML (starts with |)
        # Read lines after "description: |" until we hit a line starting with a YAML key
        description=$(sed -n '/^description: *|/,/^[a-z-]*:/p' "$skill_dir/SKILL.md" 2>/dev/null | grep -v "^description:" | grep -v "^[a-z-]*:" | head -3 | tr '\n' ' ' | sed 's/^[[:space:]]*//' | head -c 80 || true)
        # Fallback to single line format
        if [[ -z "$description" ]]; then
            description=$(grep "^description:" "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/^description:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//' | head -c 80 || true)
        fi
        # Fallback to heading
        if [[ -z "$description" ]]; then
            description=$(grep "^# " "$skill_dir/SKILL.md" 2>/dev/null | head -1 | sed 's/^# //' | head -c 80 || echo "—")
        fi
        description=$(echo "$description" | head -c 80)
        echo "| [$skill_name](../skills/gstack/$skill_name/SKILL.md) | ${description}... | 手动 |" >> "$OUTPUT_FILE"
    fi
done

# Hybrid section
cat >> "$OUTPUT_FILE" << HYBRID_SECTION

---

## Hybrid 技能

**路径**: \`skills/hybrid/\`

**数量**: 1个

### gs-hybrid-v3

**主入口技能**，AI Engineering Governance System v4.0。

#### 核心特性

- **三层架构**: Decision / Context / Execution 三层分离
- **模块化设计**: 9个模块按需加载
- **复杂度分级**: L1/L2/L3 三级流程
- **强制确认机制**: REQUIREMENT_LOCK 和 TASK_DECOMPOSITION 强制用户确认
- **多角色审议**: 产品/架构/性能/安全/运维 5个维度审查
- **决策冻结机制**: 执行层不允许更改架构和需求
- **Context Hydration**: 执行前强制注入上下文契约
- **Governance 层**: 状态机 + Gate 脚本 + CI Guard

#### 模块列表

| 模块 | 内容 | 加载时机 |
|------|------|---------|
| 01-intro.md | 三层架构介绍、项目配置 | 初始 |
| 02-complexity.md | 复杂度分级 (L1/L2/L3) | Step 0 |
| 03a-discovery-arch.md | DISCOVERY + REQUIREMENT_LOCK + ARCH_REVIEW | Decision Layer |
| 03b-task-decomposition.md | TASK_DECOMPOSITION 任务拆分 | Decision Layer |
| 04a-execution-hydration.md | Context Hydration + Execution 规范 | Context → Execution |
| 04b-self-review.md | SELF_REVIEW + QA | Execution Layer |
| 05-ship-review-retro.md | SHIP_REVIEW + RETRO | Execution → Governance |
| 06-workflows.md | 专用流程指令 | 指令触发 |
| 07-handling.md | 异常处理和状态回滚 | 异常发生时 |

#### 状态机流程

\`\`\`
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION
    → Context Hydration → IMPLEMENTATION → SELF_REVIEW → QA
    → SHIP_REVIEW → RETRO
\`\`\`

#### 专用指令

| 指令 | 功能 |
|------|------|
| \`/plan\` | 规划流程 |
| \`/review\` | 代码审查 |
| \`/test\` | 测试驱动 |
| \`/qa\` | 质量保证 |
| \`/debug\` | 调试助手 |
| \`/refactor\` | 重构建议 |

---

## Custom 技能

**路径**: \`skills/custom/\`

**用途**: 用户自定义扩展技能

### 创建自定义技能

\`\`\`
skills/custom/
└── my-custom-skill/
    ├── SKILL.md
    └── README.md
\`\`\`

---

## 三层架构对比

### Superpowers vs GStack vs Hybrid

| 维度 | Superpowers | GStack | Hybrid |
|------|-------------|--------|--------|
| **定位** | 工程纪律 | 多角色审议 | AI工程治理 |
| **架构** | 单一流程 | 工具集 | Decision/Context/Execution三层 |
| **数量** | ${SUPERPOWERS_COUNT}个 | ${GSTACK_COUNT}个 | 1个（融合两者） |
| **重点** | 流程规范 | 决策审议 | 治理流程 |
| **触发** | 自动+手动 | 手动 | 自动+手动 |
| **维护** | 上游同步 | 上游同步 | 手动维护 |

### 三层职责分配

| 层 | 职责 | 激活的 Skills |
|------|------|:-------------|
| **Decision Layer** | 想清楚做什么 | \`brainstorming\`, \`writing-plans\`, \`gstack:plan-eng-review\`, \`gstack:plan-devex-review\` |
| **Context Layer** | 固化共识、防遗忘 | \`context-save\`, \`context-restore\`, \`learn\` |
| **Execution Layer** | 严格按契约做 | \`test-driven-development\`, \`requesting-code-review\`, \`gstack:qa\`, \`gstack:cso\` |
| **Governance** | 决策冻结、状态机控制 | \`gstack:ship\`, \`gstack:retro\`, \`freeze\`, \`guard\`, \`careful\` |

---

## 文档维护规则

**本文档为自动生成层**，真相源为各技能的 SKILL.md 文件。

| 文档 | 角色 | 同步方式 |
|:-----|:-----|:---------|
| [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md) | Hybrid 唯一真相源 | 手动维护 |
| 各技能 SKILL.md | 技能定义 | 上游同步/手动 |
| **skills-reference.md** | 技能列表 | **自动生成** |

---

> **生成时间**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
> 
> **生成命令**: \`bash scripts/generate-skills-reference.sh\`
HYBRID_SECTION

echo "✅ Generated: $OUTPUT_FILE"
echo "   Superpowers: $SUPERPOWERS_COUNT skills"
echo "   GStack: $GSTACK_COUNT skills"
