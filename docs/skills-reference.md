# 技能参考手册

> **文档状态**: 自动生成 · **真相源**: 技能定义来自各技能 `SKILL.md`，机器路由来自 [skill-routes.yaml](../schema/skill-routes.yaml)
>
> 本文档由脚本自动生成，禁止手动编辑。如需修改技能信息，请编辑对应 SKILL.md 后重新运行 `scripts/generate-skills-reference.sh`。

## 目录

1. [Superpowers 技能](#superpowers-技能)
2. [GStack 技能](#gstack-技能)
3. [Hybrid 技能](#hybrid-技能)
4. [Custom 技能](#custom-技能)
5. [三层架构对比](#三层架构对比)

---

## Superpowers 技能

**路径**: `skills/superpowers/`

**数量**: 16个

**定位**: 工程纪律与结构化拆解

**来源**: [Superpowers](https://github.com/obra/superpowers)

### 技能列表

| 技能 | 描述 | 触发方式 |
|------|------|---------|
| [brainstorming](../skills/superpowers/brainstorming/SKILL.md) | You MUST use this before any creative work - creating features, building compone... | 自动/手动 |
| [design](../skills/superpowers/design/SKILL.md) | Use when in ARCH_REVIEW to produce a concrete design doc with tradeoffs, constra... | 自动/手动 |
| [dispatching-parallel-agents](../skills/superpowers/dispatching-parallel-agents/SKILL.md) | Use when facing 2+ independent tasks that can be worked on without shared state ... | 自动/手动 |
| [executing-plans](../skills/superpowers/executing-plans/SKILL.md) | Use when you have a written implementation plan to execute in a separate session... | 自动/手动 |
| [finishing-a-development-branch](../skills/superpowers/finishing-a-development-branch/SKILL.md) | Use when implementation is complete, all tests pass, and you need to decide how ... | 自动/手动 |
| [plan-verification](../skills/superpowers/plan-verification/SKILL.md) | Use in PLAN_CONFIRM to verify plan completeness, risks, scope, acceptance criter... | 自动/手动 |
| [receiving-code-review](../skills/superpowers/receiving-code-review/SKILL.md) | Use when receiving code review feedback, before implementing suggestions, especi... | 自动/手动 |
| [requesting-code-review](../skills/superpowers/requesting-code-review/SKILL.md) | Use when completing tasks, implementing major features, or before merging to ver... | 自动/手动 |
| [subagent-driven-development](../skills/superpowers/subagent-driven-development/SKILL.md) | Use when executing implementation plans with independent tasks in the current se... | 自动/手动 |
| [systematic-debugging](../skills/superpowers/systematic-debugging/SKILL.md) | Use when encountering any bug, test failure, or unexpected behavior, before prop... | 自动/手动 |
| [test-driven-development](../skills/superpowers/test-driven-development/SKILL.md) | Use when implementing any feature or bugfix, before writing implementation code... | 自动/手动 |
| [using-git-worktrees](../skills/superpowers/using-git-worktrees/SKILL.md) | Use when starting feature work that needs isolation from current workspace or be... | 自动/手动 |
| [using-superpowers](../skills/superpowers/using-superpowers/SKILL.md) | Use when starting any conversation - establishes how to find and use skills, req... | 自动/手动 |
| [verification-before-completion](../skills/superpowers/verification-before-completion/SKILL.md) | Use when about to claim work is complete, fixed, or passing, before committing o... | 自动/手动 |
| [writing-plans](../skills/superpowers/writing-plans/SKILL.md) | Use when you have a spec or requirements for a multi-step task, before touching ... | 自动/手动 |
| [writing-skills](../skills/superpowers/writing-skills/SKILL.md) | Use when creating new skills, editing existing skills, or verifying skills work ... | 自动/手动 |

---

## GStack 技能

**路径**: `skills/gstack/`

**数量**: 16个

**定位**: 多角色决策审议

**来源**: [GStack](https://github.com/garrytan/gstack)

### 技能列表

| 技能 | 描述 | 触发方式 |
|------|------|---------|
| [benchmark](../skills/gstack/benchmark/SKILL.md) | Performance regression detection using the browse daemon. Establishes   baseline... | 手动 |
| [careful](../skills/gstack/careful/SKILL.md) | Safety guardrails for destructive commands. Warns before rm -rf, DROP TABLE,   f... | 手动 |
| [codex](../skills/gstack/codex/SKILL.md) | OpenAI Codex CLI wrapper — three modes. Code review: independent diff review v... | 手动 |
| [context-restore](../skills/gstack/context-restore/SKILL.md) | Restore working context saved earlier by /context-save. Loads the most recent   ... | 手动 |
| [context-save](../skills/gstack/context-save/SKILL.md) | Save working context. Captures git state, decisions made, and remaining work   s... | 手动 |
| [cso](../skills/gstack/cso/SKILL.md) | Chief Security Officer mode. Infrastructure-first security audit: secrets archae... | 手动 |
| [design-review](../skills/gstack/design-review/SKILL.md) | Designer's eye QA: finds visual inconsistency, spacing issues, hierarchy problem... | 手动 |
| [freeze](../skills/gstack/freeze/SKILL.md) | Restrict file edits to a specific directory for the session. Blocks Edit and   W... | 手动 |
| [guard](../skills/gstack/guard/SKILL.md) | Full safety mode: destructive command warnings + directory-scoped edits.   Combi... | 手动 |
| [investigate](../skills/gstack/investigate/SKILL.md) | Systematic debugging with root cause investigation. Four phases: investigate,   ... | 手动 |
| [learn](../skills/gstack/learn/SKILL.md) | Manage project learnings. Review, search, prune, and export what gstack   has le... | 手动 |
| [plan-devex-review](../skills/gstack/plan-devex-review/SKILL.md) | Interactive developer experience plan review. Explores developer personas,   ben... | 手动 |
| [plan-eng-review](../skills/gstack/plan-eng-review/SKILL.md) | Eng manager-mode plan review. Lock in the execution plan — architecture,   dat... | 手动 |
| [qa](../skills/gstack/qa/SKILL.md) | Systematically QA test a web application and fix bugs found. Runs QA testing,   ... | 手动 |
| [retro](../skills/gstack/retro/SKILL.md) | Weekly engineering retrospective. Analyzes commit history, work patterns,   and ... | 手动 |
| [ship](../skills/gstack/ship/SKILL.md) | Ship workflow: detect + merge base branch, run tests, review diff, bump VERSION,... | 手动 |

---

## Hybrid 技能

**路径**: `skills/hybrid/`

**数量**: 1个

### gs-hybrid-v3

**主入口技能（薄入口）**，AI Engineering Governance System v4.1。

#### 核心特性

- **三层架构**: Decision / Context / Execution 三层分离
- **模块化设计**: 7个模块按需加载
- **复杂度分级**: L0/L1/L2/L3 四级流程
- **强制确认机制**: REQUIREMENT_LOCK、TASK_DECOMPOSITION、PLAN_CONFIRM
- **多角色审议**: 产品/架构/性能/安全/运维 5个维度审查
- **决策冻结机制**: 执行层不允许更改架构和需求
- **Context Hydration**: 执行前强制注入上下文契约
- **需求追踪**: REQ/NFR/OUT 显式映射到 ADR 与 Plan，避免弱匹配覆盖
- **Governance 层**: 状态机 (13状态) + Gate 脚本 (7个) + CI Guard

#### 模块列表

| 模块 | 内容 | 加载时机 |
|------|------|---------|
| 01-intro.md | 三层架构介绍、项目配置 | 初始 |
| 02-complexity.md | 复杂度分级 (L0/L1/L2/L3) | Step 0 |
| 03a-discovery-arch.md | DISCOVERY（候选方向） + REQUIREMENT_LOCK + ARCH_REVIEW（方案对比） | Decision Layer |
| 03b-task-decomposition.md | TASK_DECOMPOSITION + PLAN_CONFIRM | Decision Layer |
| 04a-execution-hydration.md | CONTEXT_HYDRATION + IMPLEMENTATION 规范 | Context -> Execution |
| 04b-self-review.md | SELF_REVIEW + QA | Execution Layer |
| 05-ship-review-retro.md | SHIP_REVIEW + RETRO | Execution -> Governance |
| 06-workflows.md | 专用流程指令 | 指令触发 |
| 07-handling.md | 异常处理和状态回滚 | 异常发生时 |

#### 主流程（由状态机真相源定义）

`IDEA -> DISCOVERY -> REQUIREMENT_LOCK -> ARCH_REVIEW -> TASK_DECOMPOSITION -> PLAN_CONFIRM -> CONTEXT_HYDRATION -> IMPLEMENTATION -> SELF_REVIEW -> QA -> SHIP_REVIEW -> RETRO`

#### Gate 检查点（7个）

| Gate | 状态 | 检查内容 |
|------|------|---------|
| G001 requirement-lock | REQUIREMENT_LOCK | 用户确认需求 |
| G002 arch-review-lock | ARCH_REVIEW | L2+ 有 ADR |
| G003 task-decomposition-lock | TASK_DECOMPOSITION | plan 存在且无占位符 |
| G004 plan-confirm | PLAN_CONFIRM | 用户确认执行计划 + Requirement Mapping 摘要 |
| G005 context-hydration | CONTEXT_HYDRATION | Spec 文件存在 |
| G006 decision-freeze | IMPLEMENTATION | 冻结项未修改 |
| G007 test-presence | SELF_REVIEW | 测试文件存在 |

#### 专用指令

| 指令 | 功能 |
|------|------|
| `/plan` | 规划流程 |
| `/review` | 代码审查 |
| `/test` | 测试驱动 |
| `/qa` | 质量保证 |
| `/debug` | 调试助手 |
| `/refactor` | 重构建议 |

#### 真相源

| 文件 | 用途 |
|------|------|
| `governance/state-machine.yaml` | 状态机定义（唯一真相源） |
| `governance/gates.yaml` | Gate 定义（唯一真相源） |
| `schema/skill-routes.yaml` | 机器路由定义（唯一真相源） |
| `skills/hybrid/gs-hybrid-v3/SKILL.md` | 入口、加载策略与路由摘要 |

---

## Custom 技能

**路径**: `skills/custom/`

**用途**: 用户自定义扩展技能

---

## 三层架构对比

| 维度 | Superpowers | GStack | Hybrid |
|------|-------------|--------|--------|
| **定位** | 工程纪律 | 多角色审议 | AI工程治理 |
| **架构** | 单一流程 | 工具集 | Decision/Context/Execution三层 |
| **数量** | 16个 | 16个 | 1个（融合两者） |
| **重点** | 流程规范 | 决策审议 | 治理流程 |
| **触发** | 自动+手动 | 条件+手动 | 自动+条件+手动 |
| **维护** | 上游同步 | 上游同步 | 手动维护 |

### 三层职责分配

| 层 | 职责 | 激活的 Skills |
|------|------|:-------------|
| **Decision Layer** | 想清楚做什么 | `brainstorming`, `design`, `writing-plans`, `plan-verification`, `gstack:plan-eng-review`, `gstack:plan-devex-review` |
| **Context Layer** | 固化共识、防遗忘 | `context-save`, `context-restore`, `learn` |
| **Execution Layer** | 严格按契约做 | `test-driven-development`, `requesting-code-review`, `verification-before-completion`, `gstack:qa`, `gstack:cso`, `gstack:benchmark`, `gstack:codex` |
| **Governance** | 决策冻结、状态机控制 | `gstack:ship`, `gstack:retro`, `gstack:investigate`, `freeze`, `guard`, `careful` |

---

## 文档维护规则

| 文档 | 角色 | 同步方式 |
|:-----|:-----|:---------|
| [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md) | Hybrid 入口与加载策略 | 手动维护 |
| [skill-routes.yaml](../schema/skill-routes.yaml) | 机器路由真相源 | 手动维护 |
| 各技能 SKILL.md | 技能定义 | 上游同步/手动 |
| **skills-reference.md** | 技能索引与对照 | **脚本自动生成** |

---

> **生成时间**: 2026-06-02 07:31:49 UTC
>
> **生成命令**: `bash scripts/generate-skills-reference.sh`
