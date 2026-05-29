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
- 设计产物约束：ADR 为唯一设计决策产物；plan 仅用于执行拆解，不维护平行设计文档。
- 优化策略：优先增强既有 Superpowers 产物（spec/ADR/plan）质量，不新增产物类型。
- 提交信息规范由 SHIP_REVIEW Gate 执行：建议统一 `type(scope): summary`（scope 可选）。

## 模块入口（按阶段加载）

- IDEA / Step 0： [01-intro.md](./modules/01-intro.md), [02-complexity.md](./modules/02-complexity.md)
- DISCOVERY / ARCH_REVIEW： [03a-discovery-arch.md](./modules/03a-discovery-arch.md)
- TASK_DECOMPOSITION / PLAN_CONFIRM： [03b-task-decomposition.md](./modules/03b-task-decomposition.md)
- CONTEXT_HYDRATION / IMPLEMENTATION： [04a-execution-hydration.md](./modules/04a-execution-hydration.md)
- SELF_REVIEW / QA / SHIP_REVIEW / RETRO： [04b-self-review.md](./modules/04b-self-review.md), [05-ship-review-retro.md](./modules/05-ship-review-retro.md)
- 指令触发： [06-workflows.md](./modules/06-workflows.md)
- 异常/变更： [07-handling.md](./modules/07-handling.md)

加载规则：进入下一阶段后释放前序上下文，仅保留契约摘要。

## 路由与职责（摘要）

- 执行路由机器真相源：`schema/skill-routes.yaml`
- 路由可读说明：`docs/skills-reference.md`
- 路由解析与体检：`scripts/resolve-skill-routes.sh` / `scripts/check-skill-routes.sh`
- 三层职责与治理说明：`docs/architecture.md`

最小路由锚点（用于保持入口可读性与路由体检价值）：
- Decision：`brainstorming`, `design`, `writing-plans`, `plan-verification`
- Execution：`test-driven-development`, `requesting-code-review`, `verification-before-completion`
- GStack：`gstack:plan-eng-review`, `gstack:qa`, `gstack:ship`, `gstack:investigate`

## 文档与校验索引

- 项目总览： [README.md](../../../README.md)
- 快速上手： [docs/getting-started.md](../../../docs/getting-started.md)
- 架构说明： [docs/architecture.md](../../../docs/architecture.md)
- 技能索引： [docs/skills-reference.md](../../../docs/skills-reference.md)

版本: v4.1.1
最后更新: 2026-05-29
