# 06 - 专用流程指令

> **Context Load**: 指令触发，无需框架文件。根据指令类型加载对应阶段模块。

## 指令-状态-模块映射表

| 指令 | 触发状态 | 执行流程 | 输出 | 详细模块 |
|------|---------|---------|------|---------|
| `/plan` | IDEA | DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION → PLAN_CONFIRM | PLAN.md, ADR, Requirement Mapping | [03a](./03a-discovery-arch.md), [03b](./03b-task-decomposition.md) |
| `/review` | SELF_REVIEW | SELF_REVIEW → QA → SHIP_REVIEW | 自审报告, QA 报告 | [04b](./04b-self-review.md), [05](./05-ship-review-retro.md) |
| `/test` | Context Hydration | Context Hydration → IMPLEMENTATION → SELF_REVIEW | 测试代码, 实现代码 | [04a](./04a-execution-hydration.md), [04b](./04b-self-review.md) |
| `/qa` | QA | QA → SHIP_REVIEW | QA 报告, 发布检查清单 | [04b](./04b-self-review.md), [05](./05-ship-review-retro.md) |
| `/debug` | EXCEPTION | systematic-debugging → RCA 证据锁定 → 最小修复 → 回归验证 | RCA 报告, 回归证据 | [07-handling.md](./07-handling.md) |
| `/refactor` | IMPLEMENTATION | 代码分析 → 方案确认 → 重构验证 | 重构代码 | [04a](./04a-execution-hydration.md) |

---

## 状态机映射

```
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION
    → PLAN_CONFIRM → CONTEXT_HYDRATION → IMPLEMENTATION → SELF_REVIEW → QA
    → SHIP_REVIEW → RETRO
```

| 状态 | 层归属 | 说明 |
|------|--------|------|
| **IDEA** | Decision Layer | 任务接收 |
| **DISCOVERY** | Decision Layer | 需求澄清 |
| **REQUIREMENT_LOCK** | Decision Layer | 需求确认 |
| **ARCH_REVIEW** | Decision Layer | 多角色架构审议 |
| **TASK_DECOMPOSITION** | Decision Layer | 任务拆解 |
| **PLAN_CONFIRM** | Decision Layer | Plan 确认 |
| **CONTEXT_HYDRATION** | Context Bridge | 加载 Spec 契约 |
| **IMPLEMENTATION** | Execution Layer | TDD 编码（决策冻结） |
| **SELF_REVIEW** | Execution Layer | 对照契约自审 |
| **QA** | Execution Layer | 质量验证 |
| **SHIP_REVIEW** | Governance | 发布检查 |
| **RETRO** | Governance | 复盘记录 |

---

## 指令组合使用

| 场景 | 指令组合 |
|------|---------|
| 完整开发流程 | `/plan` → `/test` → `/review` → `/qa` → SHIP_REVIEW → RETRO |
| 快速修复流程 | `/debug` → 回归验证 → SHIP_REVIEW |
| 代码优化流程 | `/review` → `/refactor` → `/test` → `/qa` |

---

## 决策冻结变更流程

如果在 IMPLEMENTATION 期间需要变更冻结项，必须走以下流程：

```
记录变更请求 → 暂停实现 → 退回 Decision Layer → 更新 Context Layer → 重新注水 → 恢复实现
```

> 详细流程见 [07-handling.md](./07-handling.md) 和 [governance/decision-freeze.md](../../../../governance/decision-freeze.md)。
