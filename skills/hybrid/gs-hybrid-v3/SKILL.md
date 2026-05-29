---
name: "gs-hybrid-v3"
description: "AI Engineering Governance System — 三层架构（决策层/上下文层/执行层）+ Bridges + Governance。v4.1.1 渐进式加载优化与治理收敛版。"
---

# AI Engineering Governance System v4.1.1

> 入口文档（薄层）：只保留流程入口、加载策略与技能路由。  
> 状态机与 Gate 细则以治理层机器可读文件为唯一真相源。

## 快速开始

主流程：
`IDEA -> DISCOVERY -> REQUIREMENT_LOCK -> ARCH_REVIEW -> TASK_DECOMPOSITION -> PLAN_CONFIRM -> CONTEXT_HYDRATION -> IMPLEMENTATION -> SELF_REVIEW -> QA -> SHIP_REVIEW -> RETRO`

快捷指令见 [commands/README.md](../../../commands/README.md)。

## 快速路径（按复杂度分级）

| 级别 | 可跳过状态 | 必须状态 | 典型场景 |
|------|-----------|---------|---------|
| L0 | 全部 | IDEA → IMPLEMENTATION → SHIP_REVIEW | 单文件修改、配置调整 |
| L1 | DISCOVERY, ARCH_REVIEW, CONTEXT_HYDRATION, SELF_REVIEW, QA, RETRO | IDEA → REQUIREMENT_LOCK → TASK_DECOMPOSITION → PLAN_CONFIRM → IMPLEMENTATION → SHIP_REVIEW | 小功能、bugfix |
| L2 | QA, RETRO | IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION → PLAN_CONFIRM → CONTEXT_HYDRATION → IMPLEMENTATION → SELF_REVIEW → SHIP_REVIEW | 新功能、重构 |
| L3 | 无 | 完整流程 + 全量 Gate | 架构变更、跨模块影响 |

快速路径触发条件见 [02-complexity.md](./modules/02-complexity.md)。

## 真相源与校验入口

- 状态机真相源: [governance/state-machine.yaml](../../../governance/state-machine.yaml)
- Gate 真相源: [governance/gates.yaml](../../../governance/gates.yaml)
- 路由真相源: [schema/skill-routes.yaml](../../../schema/skill-routes.yaml)
- 状态机校验: `scripts/validate-state-machine.sh`
- Gate 校验: `governance/check-gates.sh --from <state> --to <state> --level <L0|L1|L2|L3>`
- 路由解析: `scripts/resolve-skill-routes.sh --category <category> --state <state> --level <L0|L1|L2|L3>`
- 路由摘要健康检查: `scripts/check-skill-routes.sh`
- 运行时上下文契约: `governance/context-contract.yaml`

规则：
- 本文件不再重复维护“状态转换明细表”和“Hard Gate 细则表”。
- 若本文件路由摘要与 `schema/skill-routes.yaml` 冲突，以 `schema/skill-routes.yaml` 为准。
- 若本文件状态/Gate 摘要与治理层 YAML 冲突，以治理层 YAML 为准。
- Gate 读取优先级：`context 文件 > workflow-state（secondary source） > 自动发现（fallback）`。
- `workflow-state` 中的 `plan_file` / `level` 仅作为 secondary hints，不应覆盖 context。

## 加载策略速查表

| 阶段 | 模块 | 关联框架文件 |
|:-----|:-----|:-------------|
| IDEA / Step 0 | [01-intro.md](./modules/01-intro.md), [02-complexity.md](./modules/02-complexity.md) | — |
| DISCOVERY | [03a-discovery-arch.md](./modules/03a-discovery-arch.md) | `reviews/product-review.md`, `reviews/risk-review.md` |
| ARCH_REVIEW | 03a-discovery-arch.md | `reviews/architecture-review.md`, `reviews/tradeoff-review.md` |
| TASK_DECOMPOSITION | [03b-task-decomposition.md](./modules/03b-task-decomposition.md) | — |
| PLAN_CONFIRM | 03b-task-decomposition.md | — |
| CONTEXT_HYDRATION | [04a-execution-hydration.md](./modules/04a-execution-hydration.md) | `bridges/context-hydration.md`, `specs/*`, `bridges/decision-to-context.md` |
| IMPLEMENTATION | 04a-execution-hydration.md | `execution-layer/implementation.md`, `testing.md`, `governance/decision-freeze.md` |
| SELF_REVIEW | [04b-self-review.md](./modules/04b-self-review.md) | `execution-layer/review.md`, `validation.md` |
| QA / SHIP_REVIEW / RETRO | 04b-self-review.md, [05-ship-review-retro.md](./modules/05-ship-review-retro.md) | `governance/decision-freeze.md` |
| 指令触发 | [06-workflows.md](./modules/06-workflows.md) | — |
| 异常/变更 | [07-handling.md](./modules/07-handling.md) | `governance/decision-freeze.md`（按需） |

加载规则：进入下一阶段后释放前序上下文，仅保留契约摘要。

## 执行路由（可读摘要）

### Superpowers 路由

| 状态 | Skill | 触发条件 | 用途 |
|------|-------|---------|------|
| DISCOVERY | `brainstorming` | L2+ | 需求澄清、方案探索 |
| ARCH_REVIEW | `design` | L2+ | 设计文档与决策说明 |
| TASK_DECOMPOSITION | `writing-plans` | 所有任务 | 结构化计划拆解 |
| PLAN_CONFIRM | `plan-verification` | 所有任务 | 计划完整性与确认校验 |
| IMPLEMENTATION | `test-driven-development` | 所有任务 | TDD 实现 |
| SELF_REVIEW | `requesting-code-review` | L2+ | 代码审查 |
| SHIP_REVIEW | `verification-before-completion` | 所有任务 | 交付前验证 |

### GStack 路由

| 状态 | Skill | 触发条件 | 用途 |
|------|-------|---------|------|
| ARCH_REVIEW | `gstack:design-review` | 涉及前端 UI/UX | 视觉设计审查 |
| ARCH_REVIEW | `gstack:plan-eng-review` | L2+ | 工程可行性审查 |
| ARCH_REVIEW | `gstack:plan-devex-review` | L2+ | 开发体验审查 |
| QA | `gstack:qa` | L3 | QA 测试验证 |
| QA | `gstack:cso` | 安全相关变更 | 安全扫描 |
| QA | `gstack:benchmark` | L3 + 性能敏感 | 性能基准 |
| SELF_REVIEW | `gstack:codex` | L3 | 跨模型审查 |
| SHIP_REVIEW | `gstack:ship` | 需要发布/部署 | 发布检查 |
| RETRO | `gstack:retro` | L3 | 复盘 |
| 异常处理 | `gstack:investigate` | 调试/根因分析 | 根因调查 |

## 三层职责（摘要）

- Decision Layer：需求澄清、方案审议、ADR 决策
- Context Layer：Spec 契约、上下文注水、约束持久化
- Execution Layer：受约束实现、自审、QA、发布前验证
- Bridges：层间传递协议（Decision -> Context -> Execution）
- Governance：状态机、Gate、冻结与变更控制

## 异常处理

异常流程见 [07-handling.md](./modules/07-handling.md)：
- 评审冲突
- 流程回退
- 方案变更
- 阻断问题修复

## 文档索引

- [README.md](../../../README.md)
- [docs/getting-started.md](../../../docs/getting-started.md)
- [docs/architecture.md](../../../docs/architecture.md)
- [docs/skills-reference.md](../../../docs/skills-reference.md)
- [skills/README.md](../../../skills/README.md)

版本: v4.1.1
最后更新: 2026-05-29
