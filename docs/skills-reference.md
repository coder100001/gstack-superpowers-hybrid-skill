
# 技能参考手册

&gt; **文档状态**: 自动生成 · **真相源**: [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md)
&gt;
&gt; 本文档由 SKILL.md 提取生成，禁止手动编辑。如需修改技能信息，请编辑 SKILL.md 后重新生成。

## 目录

1. [Superpowers 技能](#superpowers-技能)
2. [GStack 技能](#gstack-技能)
3. [Hybrid 技能](#hybrid-技能)
4. [Custom 技能](#custom-技能)
5. [三层架构对比](#三层架构对比)

---

## Superpowers 技能

**路径**: `skills/superpowers/`

**数量**: 14个

**定位**: 工程纪律与结构化拆解

### 测试与验证

#### test-driven-development
- **用途**: RED-GREEN-REFACTOR 循环，TDD 编码
- **触发**: 自动触发
- **层**: Execution Layer
- **说明**: 强制执行测试驱动开发，先写测试再写代码

#### verification-before-completion
- **用途**: 确保问题真正解决
- **触发**: 自动触发
- **层**: Execution Layer (SHIP_REVIEW)
- **说明**: 完成前验证，确保交付质量

### 调试与诊断

#### systematic-debugging
- **用途**: 4 阶段根本原因分析流程
- **触发**: 技能调用
- **说明**: 系统化调试方法，定位问题根因

#### subagent-driven-development
- **用途**: 快速迭代，带两阶段审查
- **触发**: 技能调用
- **说明**: 子代理驱动开发，规范符合性 + 代码质量审查

### 协作与规划

#### brainstorming
- **用途**: 苏格拉底式设计细化
- **触发**: 自动触发
- **层**: Decision Layer (DISCOVERY)
- **说明**: 需求澄清、方案对比、设计细化

#### writing-plans
- **用途**: 详细的实施计划
- **触发**: 技能调用
- **层**: Decision Layer (TASK_DECOMPOSITION)
- **说明**: 将工作分解为小块任务，每个任务都有精确的文件路径和验证步骤

#### executing-plans
- **用途**: 带检查点的批量执行
- **触发**: 技能调用
- **说明**: 批量执行任务，带有人工检查点

#### dispatching-parallel-agents
- **用途**: 并发子代理工作流
- **触发**: 技能调用
- **说明**: 并行执行多个子代理任务

#### requesting-code-review
- **用途**: 预审查清单
- **触发**: 自动触发
- **层**: Execution Layer (SELF_REVIEW)
- **说明**: 代码审查请求，对照计划审查

#### receiving-code-review
- **用途**: 回应反馈
- **触发**: 技能调用
- **说明**: 响应代码审查反馈

#### using-git-worktrees
- **用途**: 并行开发分支
- **触发**: 自动触发
- **说明**: 使用 Git worktrees 管理并行开发

#### finishing-a-development-branch
- **用途**: 合并/PR 决策工作流
- **触发**: 自动触发
- **说明**: 完成开发分支，决定合并、PR、保留或丢弃

### 元技能

#### writing-skills
- **用途**: 遵循最佳实践创建新技能
- **触发**: 技能调用
- **说明**: 创建符合规范的新技能

#### using-superpowers
- **用途**: 技能系统介绍
- **触发**: 手动触发
- **说明**: Superpowers 系统介绍和使用指南

---

## GStack 技能

**路径**: `skills/gstack/`

**数量**: 16个

**定位**: 多角色决策审议

### 设计类

#### design
- **用途**: 设计工具和设计评审流程
- **触发**: 技能调用
- **层**: Decision Layer
- **说明**: 提供设计工具和评审流程

#### design-consultation
- **用途**: 设计咨询服务
- **触发**: 技能调用
- **层**: Decision Layer
- **说明**: 设计咨询和建议

#### design-html
- **用途**: HTML 设计生成
- **触发**: 技能调用
- **说明**: 生成 HTML 设计代码

#### design-review
- **用途**: 设计审查
- **触发**: 技能调用
- **层**: Decision Layer (ARCH_REVIEW)
- **说明**: 前端视觉审查

#### design-shotgun
- **用途**: 多方案设计
- **触发**: 技能调用
- **层**: Decision Layer
- **说明**: 快速生成多个设计方案

### 工具类

#### gstack-browse
- **用途**: 浏览器自动化和网页交互
- **触发**: 技能调用
- **说明**: Headless browser 自动化，网页测试和交互

#### qa
- **用途**: 质量保证和测试工具
- **触发**: 技能调用
- **层**: Execution Layer (QA)
- **说明**: QA 测试、功能验证、部署验证

#### review
- **用途**: 多维度代码审查专家
- **触发**: 技能调用
- **层**: Execution Layer (SELF_REVIEW)
- **说明**: 代码审查，多维度分析

---

## Hybrid 技能

**路径**: `skills/hybrid/gs-hybrid-v3/`

**数量**: 1个

### gs-hybrid-v3

**主入口技能**，AI Engineering Governance System。

#### 特性

- **三层架构**: Decision / Context / Execution 三层分离
- **模块化设计**: 8个模块按需加载
- **复杂度分级**: L1/L2/L3 三级流程
- **强制确认机制**: REQUIREMENT_LOCK 和 ARCH_REVIEW 强制用户确认
- **多角色审议**: 产品/架构/性能/安全/运维 5个维度审查
- **决策冻结机制**: 执行层不允许更改架构和需求
- **Context Hydration**: 执行前强制注入上下文契约

#### 模块列表

| 模块 | 内容 | 加载时机 |
|------|------|---------|
| 01-intro.md | 三层架构介绍、项目配置 | 初始 |
| 02-complexity.md | 复杂度分级 | IDEA |
| 03a-discovery-arch.md | IDEA + DISCOVERY + REQUIREMENT_LOCK + ARCH_REVIEW | Decision Layer |
| 03b-task-decomposition.md | TASK_DECOMPOSITION 任务拆分 | Decision Layer |
| 04a-execution-hydration.md | Context Hydration + Execution 规范 | Context → Execution |
| 04b-self-review.md | SELF_REVIEW + QA | Execution Layer |
| 05-ship-review-retro.md | SHIP_REVIEW + RETRO | Execution → Governance |
| 06-workflows.md | 专用流程指令 | 指令触发 |
| 07-handling.md | 异常处理和状态回滚 | 异常发生时 |

#### 专用指令

| 指令 | 功能 | 说明 |
|------|------|------|
| `/plan` | 规划流程 | 新功能开发前的完整规划 |
| `/review` | 代码审查 | 代码完成后的质量审查 |
| `/test` | 测试驱动 | TDD 开发流程 |
| `/qa` | 质量保证 | 功能完成后的验证 |
| `/debug` | 调试助手 | 问题诊断与修复 |
| `/refactor` | 重构建议 | 代码改进与优化 |

#### 状态机流程

```
IDEA
    ↓
DISCOVERY (Decision Layer)
    ↓
REQUIREMENT_LOCK (🔴 强制确认)
    ↓
ARCH_REVIEW (Decision Layer, L2+ 必须)
    ↓
TASK_DECOMPOSITION (Decision Layer)
    ↓
Context Hydration (Context Layer, 🔴 强制)
    ↓
IMPLEMENTATION (Execution Layer)
    ↓
SELF_REVIEW (Execution Layer)
    ↓
QA (Execution Layer)
    ↓
SHIP_REVIEW (Governance)
    ↓
RETRO (Governance)
    ↓
完成
```

---

## Custom 技能

**路径**: `skills/custom/`

**用途**: 用户自定义扩展技能

### 创建自定义技能

```
skills/custom/
└── my-custom-skill/
    ├── SKILL.md
    └── README.md
```

### 示例

```markdown
---
name: "my-custom-skill"
description: "我的自定义技能"
---

# My Custom Skill

## 用途

描述技能的用途。

## 使用方法

描述如何使用这个技能。

## 参数

| 参数 | 类型 | 说明 |
|------|------|------|
| param1 | string | 参数1说明 |
| param2 | number | 参数2说明 |
```

---

## 三层架构对比

### Superpowers vs GStack vs Hybrid

| 维度 | Superpowers | GStack | Hybrid |
|------|-------------|--------|--------|
| **定位** | 工程纪律 | 多角色审议 | AI工程治理 |
| **架构** | 单一流程 | 工具集 | Decision/Context/Execution三层 |
| **数量** | 14个 | 16个 | 1个（融合两者） |
| **重点** | 流程规范 | 决策审议 | 治理流程 |
| **触发** | 自动+手动 | 手动 | 自动+手动 |
| **维护** | 上游同步 | 上游同步 | 手动维护 |

### 三层职责分配

| 层 | 职责 | 负责 | 激活的 Skills |
|------|------|------|:-------------|
| **Decision Layer** | 想清楚做什么 | GStack + 多角色审议 | `brainstorming`, `design`, `writing-plans`, `plan-verification`, `gstack:design-review`, `gstack:plan-eng-review`, `gstack:plan-devex-review` |
| **Context Layer** | 固化共识、防遗忘 | Spec契约、ADR、领域边界 | `context-save`, `context-restore`, `learn` |
| **Execution Layer** | 严格按契约做 | Superpowers + TDD | `test-driven-development`, `requesting-code-review`, `verification-before-completion`, `gstack:qa`, `gstack:cso`, `gstack:benchmark`, `gstack:codex` |
| **Governance** | 决策冻结、状态机控制 | 全局规则 | `gstack:ship`, `gstack:retro`, `gstack:investigate`, `freeze`, `guard`, `careful` |

### 复杂度响应

#### L1（小修复）

```
IDEA → DISCOVERY + REQUIREMENT_LOCK(合并确认) → TASK_DECOMPOSITION + PLAN_CONFIRM(合并确认) → Context Hydration(P0) → IMPLEMENTATION → SHIP_REVIEW
```

**使用技能**:
- `test-driven-development` (IMPLEMENTATION)
- `verification-before-completion` (SHIP_REVIEW)

**简化规则**: 两次确认合并为单次对话；ARCH_REVIEW/SELF_REVIEW/QA/RETRO 跳过

#### L2（新功能/中等重构）

```
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW(2维度) → TASK_DECOMPOSITION → PLAN_CONFIRM → Context Hydration(P0+P1) → IMPLEMENTATION → SELF_REVIEW → SHIP_REVIEW
```

**使用技能**:
- `brainstorming` (DISCOVERY)
- `writing-plans` (TASK_DECOMPOSITION)
- `test-driven-development` (IMPLEMENTATION)
- `requesting-code-review` (SELF_REVIEW)
- `verification-before-completion` (SHIP_REVIEW)

**规则**: ARCH_REVIEW 仅 Product + Architect 2 维度；QA 可选

#### L3（跨系统/安全敏感）

```
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW(全5维度) → TASK_DECOMPOSITION → PLAN_CONFIRM → Context Hydration(完整) → IMPLEMENTATION → SELF_REVIEW → QA(gstack:qa) → SHIP_REVIEW → RETRO
```

**使用技能**:
- `brainstorming` (DISCOVERY)
- `writing-plans` (TASK_DECOMPOSITION)
- 5维度审议 (ARCH_REVIEW)
- `test-driven-development` (IMPLEMENTATION)
- `requesting-code-review` (SELF_REVIEW)
- `gstack:qa` (QA)
- `gstack:cso` (安全审查)
- `verification-before-completion` (SHIP_REVIEW)
- `gstack:retro` (RETRO)

**规则**: 全流程无跳过；GStack 技能满足条件时显式调用

---

## 更新策略

### Superpowers 技能

```bash
./scripts/sync-upstream.sh --superpowers
```

- 完全由上游同步
- 不要手动修改
- 保留原有结构和功能

### GStack 技能

```bash
./scripts/sync-upstream.sh --gstack
```

- 完全由上游同步
- 不要手动修改
- 同步到 `skills/gstack/` 目录

### Hybrid 技能

- 手动维护
- 可以修改模块
- 建议通过扩展方式定制

### Custom 技能

- 完全自由
- 不受同步影响
- 可以任意修改

---

## 文档维护规则

**本文档为自动生成层**，真相源为 [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md)。禁止手动编辑本文档。

| 文档 | 角色 | 同步方式 |
|:-----|:-----|:---------|
| [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md) | 唯一真相源 | 手动维护 |
| [README.md](../README.md) | 项目索引 | 链接引用 |
| [getting-started.md](./getting-started.md) | 快速开始 | 链接引用 |
| [architecture.md](./architecture.md) | 架构设计 | 链接引用 |
| **skills-reference.md** | 技能列表 | **自动生成** |

## 相关文档

- [主入口 SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md)
- [快速开始指南](./getting-started.md)
- [架构设计文档](./architecture.md)
- [维护更新指南](./maintenance.md)
- [技能目录说明](../skills/README.md)

