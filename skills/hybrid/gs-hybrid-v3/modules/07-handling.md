# 07 - 异常处理机制

> **Context Load**: 异常/变更时加载，无需额外框架文件。按需加载 `governance/decision-freeze.md`（如果涉及冻结项变更）。

## 异常类型

| 类型 | 描述 | 处理方式 |
|------|------|---------|
| **流程阻断** | 用户未确认、配置缺失、Spec 不完整 | 等待或提示补充 |
| **评审失败** | Decision Layer 多维度审议未通过 | 修复后重新审议 |
| **执行失败** | 测试失败、构建失败 | 修复后重试 |
| **决策冻结违规** | 在 IMPLEMENTATION 期间修改冻结项 | 回滚违规修改，触发变更流程 |
| **上下文缺失** | Context Hydration 未完成 | 强制完成注水 |
| **外部依赖** | 第三方服务不可用 | 降级或等待 |

---

## Debug Exception Subflow

`/debug` 不定义一套新的调试方法。调试主流程必须依赖 Superpowers 原生 `systematic-debugging`，gs-hybrid 只增加治理增强：证据记录、冻结项检查、回退决策和验证摘要。

### 职责分工

| 能力 | 负责人 | 说明 |
|------|--------|------|
| 根因调查方法 | `systematic-debugging` | 复现、读错误、查最近变更、形成单一假设、最小验证 |
| 调试会话治理 | `gstack:investigate` | 记录证据、检查冻结项、判断是否回退 Decision Layer、输出 RCA 摘要 |
| 修复执行 | `test-driven-development` / 现有计划 | 只在根因明确后执行最小修复 |
| 完成验证 | `verification-before-completion` | 证明原问题消失、回归测试通过、无新增失败 |

### Debug 流程

```
问题进入 → systematic-debugging Phase 1-3 → RCA 证据锁定
       → 判断是否触碰冻结项
       → 最小修复计划
       → regression test / reproduction command
       → 修复实现
       → 验证原问题与回归测试
       → SHIP_REVIEW 或回退 Decision Layer
```

### RCA 最小记录

每次 debug 至少记录以下字段，可写入 `workflow-state`、自审报告或调试摘要；L2/L3 建议保存到 `artifacts/debug/YYYY-MM-DD-<topic>-rca.md`。

```markdown
## RCA Summary

- Observed: [实际现象、错误信息、失败命令]
- Expected: [期望行为]
- Reproduction: [稳定复现步骤；不可稳定复现时写明已收集的证据]
- Recent Changes: [相关 diff / commit / 配置变化]
- Hypothesis: [单一根因假设]
- Evidence: [支持该假设的具体证据]
- Root Cause: [确认的根因]
- Fix Plan: [最小修复，不含顺手重构]
- Regression Evidence: [失败先于修复、修复后通过的测试或命令]
- Freeze Impact: [是否触碰架构/需求/API/领域边界]
```

### Root Cause Lock

在进入修复前必须满足：

- [ ] 已完成 `systematic-debugging` 的根因调查与假设验证
- [ ] 有稳定复现，或有足够证据解释为什么不可稳定复现
- [ ] 根因是单一、具体、可验证的，不是泛泛描述
- [ ] 修复计划只针对根因，不包含无关重构
- [ ] bugfix 至少有 regression evidence；无测试时必须说明替代验证命令和风险
- [ ] 若修复需要改变冻结项，必须回退 Decision Layer，不能在 IMPLEMENTATION 中直接修改

### 失败重试规则

- 第 1-2 次假设失败：回到 `systematic-debugging` Phase 1，补证据后重新形成假设
- 第 3 次修复失败：暂停实现，判断是否为架构/计划问题
- 若根因涉及 ADR、需求范围、API 契约或领域边界：回退到 `ARCH_REVIEW` 或 `TASK_DECOMPOSITION`
- 若只是实现细节错误：回到 `IMPLEMENTATION` 执行最小修复

### QA / Review 失败接入

当 SELF_REVIEW、QA 或 SHIP_REVIEW 发现失败时，不应直接叠加补丁。先进入本 Debug Exception Subflow，完成 RCA 记录后再决定回到 `IMPLEMENTATION`、`TASK_DECOMPOSITION` 或 `ARCH_REVIEW`。

---

## Decision Freeze 变更流程

> **单一真相源**: 冻结范围、变更流程、禁止路径、例外条款、违规处理、变更评估矩阵的完整定义均在 [governance/decision-freeze.md](../../../../governance/decision-freeze.md)。本节仅保留摘要，详细内容以 decision-freeze.md 为准。

### 冻结范围（摘要）

IMPLEMENTATION 期间冻结 4 类项：**架构决策**、**需求范围**、**API 契约**、**领域边界**。完整定义见 [decision-freeze.md §1](../../../../governance/decision-freeze.md)。

### 变更流程（摘要）

冻结项变更必须走 6 步正式流程：记录变更请求 → 暂停实现 → 退回 Decision Layer → 更新 Context Layer → 重新注水 → 恢复实现。完整流程见 [decision-freeze.md §3](../../../../governance/decision-freeze.md)。

### 禁止路径与例外条款

3 条禁止路径 + 4 类例外条款的完整定义见 [decision-freeze.md §3 禁止的变更路径](../../../../governance/decision-freeze.md) 及 [decision-freeze.md §6 例外条款](../../../../governance/decision-freeze.md)。

### 违规处理（摘要）

发现冻结违规：立即标记 → 回滚违规修改 → 记录违规 → 触发变更流程。完整流程见 [decision-freeze.md §5](../../../../governance/decision-freeze.md)。

### 变更评估矩阵（摘要）

变更按严重程度分为 Minor / Major / Critical 三级，对应不同重审维度。完整矩阵见 [decision-freeze.md §4](../../../../governance/decision-freeze.md)。

---

## 状态回滚机制

### 回滚策略

从任意状态回滚到合适的前一状态：

| 当前状态 | 可回滚到的状态 | 触发条件 |
|----------|---------------|---------|
| **RETRO** | SHIP_REVIEW, QA, SELF_REVIEW | 发布准备不充分 |
| **SHIP_REVIEW** | QA, SELF_REVIEW, IMPLEMENTATION | 发现重大问题 |
| **QA** | SELF_REVIEW, IMPLEMENTATION | 测试不通过 |
| **SELF_REVIEW** | IMPLEMENTATION | 自审发现问题 |
| **IMPLEMENTATION** | TASK_DECOMPOSITION, ARCH_REVIEW | 决策冻结变更 |
| **Context Hydration** | TASK_DECOMPOSITION | Spec 不完整 |
| **TASK_DECOMPOSITION** | ARCH_REVIEW, REQUIREMENT_LOCK | 任务拆解不合理 |
| **ARCH_REVIEW** | REQUIREMENT_LOCK, DISCOVERY | 架构审议未通过 |
| **REQUIREMENT_LOCK** | DISCOVERY, IDEA | 需求需要重新澄清 |
| **DISCOVERY** | IDEA | 需求理解错误 |

### 回滚流程

```
识别回滚需求 → 确定回滚目标状态 → 清理当前状态 → 恢复目标状态 → 继续执行
```

### 回滚检查清单

- [ ] 记录回滚原因
- [ ] 确定回滚目标状态
- [ ] 清理当前状态的临时文件
- [ ] 恢复目标状态的文档/工件
- [ ] 通知用户回滚完成
- [ ] 更新 workflow-state.md

---

## 评审异常处理

### 发现问题时的处理

#### 阻断性问题

```
发现阻断性问题 → 立即暂停 → 修复问题 → 重新评审 → 继续流程
```

#### 严重性问题

```
发现严重性问题 → 记录问题 → 用户决策 → 修复/接受风险 → 继续/记录债务
```

#### 一般性问题

```
发现一般性问题 → 记录待办 → 继续流程 → 后续优化
```

### 用户决策选项

当评审发现问题时，提供以下选项：

1. **立即修复** - 暂停流程，先修复问题
2. **继续但记录** - 继续流程，记录技术债务
3. **接受风险** - 明确接受风险，继续执行
4. **回滚重审** - 问题太大，回滚到 Decision Layer

---

## 度量指标 (KPI)

### 流程效率指标

| 指标 | 说明 | 目标值 |
|------|------|--------|
| **需求澄清率** | REQUIREMENT_LOCK 一次通过率 | ≥ 80% |
| **架构审议通过率** | ARCH_REVIEW 一次通过率 | ≥ 70% |
| **评审通过率** | SELF_REVIEW + QA 一次通过率 | ≥ 60% |
| **返工率** | 需要回滚的比例 | ≤ 20% |
| **决策冻结违规率** | 违规次数/项目 | 0 |

### 代码质量指标

| 指标 | 说明 | 目标值 |
|------|------|--------|
| **测试覆盖率** | 代码覆盖率 | ≥ 80% |
| **缺陷密度** | 每千行代码缺陷数 | ≤ 0.5 |
| **技术债务** | 记录的技术债务数 | 持续减少 |
| **契约符合率** | 与 Context Layer Spec 符合度 | 100% |

### 安全指标

| 指标 | 说明 | 目标值 |
|------|------|--------|
| **高危漏洞** | 生产环境高危漏洞数 | 0 |
| **中危漏洞** | 未修复中危漏洞数 | ≤ 3 |
| **安全扫描通过率** | 安全扫描通过比例 | 100% |

---

## 持续改进

### 复盘记录模板

```markdown
# RETRO - 迭代复盘

## 项目信息
- 项目名称: [名称]
- 复杂度级别: [L1/L2/L3]
- 开始/结束日期: [日期]

## 流程回顾

### Decision Layer
- IDEA → DISCOVERY: [评价]
- DISCOVERY → REQUIREMENT_LOCK: [评价]
- REQUIREMENT_LOCK → ARCH_REVIEW: [评价]
- ARCH_REVIEW → TASK_DECOMPOSITION: [评价]

### Context Layer
- Context Hydration: [评价]

### Execution Layer
- IMPLEMENTATION: [评价]
- SELF_REVIEW: [评价]
- QA: [评价]
- SHIP_REVIEW: [评价]

### Governance
- 决策冻结执行情况: [评价]
- 变更流程执行情况: [评价]

## 数据回顾

### 流程效率
- 需求澄清率: X%
- 架构审议通过率: X%
- 评审通过率: X%
- 返工率: X%
- 决策冻结违规率: X%

### 代码质量
- 测试覆盖率: X%
- 缺陷密度: X
- 技术债务: X 项
- 契约符合率: X%

## 做得好的
1. ...
2. ...

## 需要改进的
1. ...
2. ...

## 改进措施
1. ... (负责人: ..., 时间: ...)
2. ... (负责人: ..., 时间: ...)

## 流程优化建议
1. ...
2. ...
```

### 流程优化机制

1. **定期复盘** - 每个项目/里程碑进行 RETRO
2. **数据分析** - 基于 KPI 数据分析问题
3. **实验改进** - 小范围实验新流程
4. **文档更新** - 及时更新流程文档
5. **知识分享** - 分享最佳实践

---

**关联文件**: [decision-freeze](../../../../governance/decision-freeze.md) · [architecture-review](../../../../decision-layer/reviews/architecture-review.md) · [context-hydration](../../../../bridges/context-hydration.md)
