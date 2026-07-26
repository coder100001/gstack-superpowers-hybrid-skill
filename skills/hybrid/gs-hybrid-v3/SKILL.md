---
name: "gs-hybrid-v3"
description: "AI Engineering Governance System — 三层架构（决策层/上下文层/执行层）+ Bridges + Governance。v6.0.0 按级别区分审查策略。"
---

# AI Engineering Governance System v6.0.0

> 决策层 → 桥接 → 上下文层 → 桥接 → 执行层，思考与实现严格分离

---

## 快速开始

```
用户: hybrid 帮我开发用户认证功能

AI: 收到。我将按照三层架构执行：

Step 0: 评估任务复杂度 (L0/L1/L2/L3)

DECISION LAYER:
  IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION → PLAN_CONFIRM
  ↓ 产出：ADR（唯一设计决策产物）+ Spec + Plan
CONTEXT LAYER:
  Context Hydration: 加载所有 Spec 契约
EXECUTION LAYER:
  IMPLEMENTATION(TDD, 决策冻结) → SELF_REVIEW → QA → SHIP_REVIEW → RETRO
```

### 专用指令
快捷指令列表请参考 [commands/README.md](../../../commands/README.md)。

---

## 快速路径（按复杂度分级）

| 级别 | 可跳过状态 | 必须状态 | 典型场景 |
|------|-----------|---------|---------|
| L0 | 全部 | IDEA → IMPLEMENTATION → SHIP_REVIEW | 单文件修改、配置调整 |
| L1 | DISCOVERY, ARCH_REVIEW, CONTEXT_HYDRATION, SELF_REVIEW, QA, RETRO | IDEA → REQUIREMENT_LOCK → TASK_DECOMPOSITION → PLAN_CONFIRM → IMPLEMENTATION → SHIP_REVIEW | 小功能、bugfix |
| L2 | QA, RETRO | IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION → PLAN_CONFIRM → CONTEXT_HYDRATION → IMPLEMENTATION → SELF_REVIEW → SHIP_REVIEW | 新功能、重构 |
| L3 | 无 | 完整流程 + 全量 Gate | 架构变更、跨模块影响 |

触发条件见 [02-complexity.md](./modules/02-complexity.md)。

---

## 架构职责索引

| 层 | 路径 | 用途 |
|----|------|------|
| **Decision Layer** | `decision-layer/` | 需求发散 → 多角色审议 → ADR 决策 |
| **Context Layer** | `context-layer/` | 契约持久化 → Spec → 约束强制 |
| **Execution Layer** | `execution-layer/` | 受约束 TDD → 自审 → QA → 交付 |
| **Bridges** | `bridges/` | Decision→Context 转化 + Context→Execution 注水 |
| **Governance** | `governance/` | 决策冻结 + 状态验证 + 变更流程 |

---

加载策略速查表见 `schema/module-load-map.yaml`。

---

## 真相源与校验入口

- 状态机真相源: [governance/state-machine.yaml](../../../governance/state-machine.yaml)
- Gate 真相源: [governance/gates.yaml](../../../governance/gates.yaml)
- 路由真相源: [schema/skill-routes.yaml](../../../schema/skill-routes.yaml)
- 校验: `scripts/validate-state-machine.sh`, `scripts/check-skill-routes.sh`, `scripts/resolve-skill-routes.sh`
- Gate 校验: `governance/check-gates.sh --from <state> --to <state> --level <L0|L1|L2|L3>`
- 运行时契约: `governance/context-contract.yaml`

规则：本文件不再重复维护状态转换明细表和 Hard Gate 细则表。若路由摘要/状态摘要与 YAML 冲突，以 YAML 为准。ADR 为唯一设计决策产物，plan 仅用于执行拆解。spec 使用 `REQ/NFR/OUT` 编号。

---

## 流程概览（简化）

```
DECISION LAYER:  IDEA → DISCOVERY → REQ_LOCK → ARCH_REVIEW → TASK_DECOMP → PLAN_CONFIRM
                      ↓ 产出：ADR + Plan + Spec
CONTEXT LAYER:   Context Hydration（加载所有 Spec 契约）
                      ↓
EXECUTION LAYER: IMPLEMENTATION(TDD, 决策冻结) → SELF_REVIEW → QA → SHIP_REVIEW → RETRO
```

详细状态转换表见 `governance/state-machine.yaml`，Gate 细则见 `governance/gates.yaml`。

---

## 强制阻断规则

<HARD-GATE>
1. **REQUIREMENT_LOCK**: 用户必须明确确认需求范围
2. **TASK_DECOMPOSITION**: 用户必须明确确认执行计划
3. **Context Hydration**: 编码前必须完成上下文注水
4. **决策冻结**: IMPLEMENTATION 期间架构/需求/契约不得自行更改
5. **状态跳步**: 禁止 IDEA → IMPLEMENTATION，L2/L3 必须走全流程
6. **配置缺失**: 必须提示用户补充
7. **评审不通过**: 阻断性问题必须修复后才能继续
</HARD-GATE>

---

## 三层架构核心原则

1. 思考与实现严格分离：Decision Layer 负责决策，Execution Layer 负责执行
2. 所有决策必须有记录和理由
3. 上下文契约是唯一真相来源
4. 执行时不允许偏离契约
5. 变更必须走正式流程

---

## 治理规则

**决策冻结**: 进入 IMPLEMENTATION 后架构决策/需求范围/API 契约/领域边界被冻结。变更须退回 Decision Layer。详见 [decision-freeze.md](../../../governance/decision-freeze.md)

**上下文注水**: 进入 Execution Layer 前加载 project-spec、architecture-spec、ADR 历史、活跃约束清单。详见 [context-hydration.md](../../../bridges/context-hydration.md)

---

## 模块入口（按阶段加载）

- IDEA / Step 0: [01-intro.md](./modules/01-intro.md), [02-complexity.md](./modules/02-complexity.md)
- DISCOVERY / ARCH_REVIEW: [03a-discovery-arch.md](./modules/03a-discovery-arch.md)
- TASK_DECOMPOSITION / PLAN_CONFIRM: [03b-task-decomposition.md](./modules/03b-task-decomposition.md)
- CONTEXT_HYDRATION / IMPLEMENTATION: [04a-execution-hydration.md](./modules/04a-execution-hydration.md)
- SELF_REVIEW / QA / SHIP_REVIEW / RETRO: [04b-self-review.md](./modules/04b-self-review.md), [05-ship-review-retro.md](./modules/05-ship-review-retro.md)
- 指令触发: [06-workflows.md](./modules/06-workflows.md)
- 异常/变更: [07-handling.md](./modules/07-handling.md)

---

## 路由与职责（摘要）

- 路由真相源: `schema/skill-routes.yaml`
- 路由解析: `scripts/resolve-skill-routes.sh` / `scripts/check-skill-routes.sh`

路由锚点:
- Decision: `brainstorming`, `design`, `writing-plans`, `plan-verification`
- Execution: `test-driven-development`, `requesting-code-review`, `verification-before-completion`
- Quality/Ship: `gstack:qa`, `gstack:ship`

---

## 文档与校验索引

- 项目总览: [README.md](../../../README.md)
- 快速上手: [docs/getting-started.md](../../../docs/getting-started.md)
- 架构说明: [docs/architecture.md](../../../docs/architecture.md)
- 技能索引: [docs/skills-reference.md](../../../docs/skills-reference.md)

---

## 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| **v6.0.0** | **2026-07-26** | 按级别区分审查策略: L1/L2 inline checklist; L3 才跨模型审查; SDD 仅并行任务; 路由表对齐 |
| **v4.1.1** | **2026-05-29** | 渐进式加载优化与治理收敛版 |
| **v4.1** | **2026-05-16** | SKILL.md 精简 32%，框架文件按阶段加载 |
| **v4.0** | **2026-05-16** | AI Engineering Governance System: 职责分层系统 |

---

版本: v6.0.0 | 最后更新: 2026-07-26

**详细文档请参考各模块文件。**
