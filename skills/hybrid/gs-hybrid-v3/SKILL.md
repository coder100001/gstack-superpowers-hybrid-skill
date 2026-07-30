---
name: "gs-hybrid-v3"
description: "AI Engineering Governance System — 5-state workflow (DEFINE→PLAN→IMPLEMENT→VALIDATE→SHIP). v7.0.0"
---

# AI Engineering Governance System v7.0.0

## 5 态工作流

```
DEFINE → PLAN → IMPLEMENT → VALIDATE → SHIP
```

每个态是一个工作阶段，跃迁条件见下方硬阻断规则。

### 快速路径（按复杂度分级）

| 级别 | 路径 | 典型场景 |
|------|------|---------|
| L0 | DEFINE(极简) → IMPLEMENT → SHIP | 单文件修改（governance 显式豁免，非跳过门禁） |
| L1 | DEFINE → PLAN(轻量) → IMPLEMENT → SHIP | 小功能、bugfix |
| L2 | DEFINE → PLAN → IMPLEMENT → VALIDATE → SHIP | 新功能、重构 |
| L3 | 全流程 + 多轮 VALIDATE | 架构变更、跨模块影响 |

复杂度评估见 [01-define.md](modules/01-define.md)。

### 跃迁条件（硬阻断）

| 跃迁 | 条件 |
|------|------|
| DEFINE → PLAN | **用户确认需求**。spec 文件已创建且包含用户确认标记。 |
| PLAN → IMPLEMENT | **用户确认计划** + **上下文注水完成**。计划已确认，架构/约束契约已加载。 |
| IMPLEMENT → VALIDATE | **代码可验证**。实现完成后触发自审。 |
| VALIDATE → SHIP | **验证证据存在**。测试通过/审查通过的证据必须可复现。 |

### 每个态做什么

| 态 | 核心活动 | 产出 |
|----|---------|------|
| DEFINE | 复杂度评估 → 需求澄清 → 确认 | spec 文件 |
| PLAN | 方案设计 → 任务拆解 → 确认 | ADR + plan |
| IMPLEMENT | 上下文注水 → TDD 实现（决策冻结） | 代码 + 测试 |
| VALIDATE | 自审 → QA | 测试报告 + 审查记录 |
| SHIP | 发布检查 → 复盘 | 交付物 |

### 强制阻断规则（HARD GATE）

1. **需求确认**（DEFINE→PLAN）：用户必须明确确认需求
2. **计划确认**（PLAN→IMPLEMENT）：用户必须确认执行计划
3. **上下文注水**（IMPLEMENT 入口）：编码前必须完成上下文注水
4. **决策冻结**（IMPLEMENT 期间）：架构/需求/契约不得自行更改
5. **验证证据**（VALIDATE→SHIP）：必须提供可复现的测试通过证据
6. **状态跳步**：L2/L3 不能跳过中间态
7. **配置缺失**：必须提示用户补充

### 模块（按态加载）

| 态 | 模块 |
|----|------|
| DEFINE | [01-define.md](modules/01-define.md) |
| PLAN | [02-plan.md](modules/02-plan.md) |
| IMPLEMENT | [03-implement.md](modules/03-implement.md) |
| VALIDATE | [04-validate.md](modules/04-validate.md) |
| SHIP | [05-ship.md](modules/05-ship.md) |

### 路由

- 路由真相源: `schema/skill-routes.yaml`
- 决策锚点: `brainstorming` → `writing-plans` → `test-driven-development` → `requesting-code-review` → `verification-before-completion`
- Quality/Ship: `gstack:qa`, `gstack:ship`

### 治理参考

- 状态机定义: `governance/state-machine.yaml`（治理/CI 层使用）
- Gate 细则: `governance/gates.yaml`
- 决策冻结协议: `governance/decision-freeze.md`
- 校验入口: `scripts/validate-state-machine.sh`, `governance/check-gates.sh`

---

版本: v7.0.0 | 上次更新: 2026-07-29
