---
name: "gs-hybrid-v3"
description: "AI Engineering Governance System — 三层架构（决策层/上下文层/执行层）+ Bridges + Governance。v4.1 渐进式加载优化：从技能分类升级为职责分层系统，新增状态机、决策冻结、上下文注水机制。"
---

# AI Engineering Governance System v4.1 (三层架构正式版)

> **核心理念**: 决策层 → 桥接 → 上下文层 → 桥接 → 执行层，思考与实现严格分离
> 本系统将 Superpowers 的工程纪律 + GStack 的多角色审议 + Context Layer 的契约驱动，统一为可执行的三层职责系统
> **v4.1 升级**: 从技能分类升级为职责分层系统 | 12 状态状态机(含 ABORTED) | L0-L3 复杂度分级 | 决策冻结 | 上下文注水

---

## 快速开始

### 启动方式

完整流程: `IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION → PLAN_CONFIRM → CONTEXT_HYDRATION → IMPLEMENTATION → SELF_REVIEW → QA → SHIP_REVIEW → RETRO`。各阶段详细说明见模块文件。

### 专用指令

快捷指令列表请参考 [commands/README.md](../../../commands/README.md)。

---

## 原技能保留索引（向后兼容）

| 分类 | 路径 | 技能数量 | 说明 |
|------|------|---------|------|
| **Superpowers** | `skills/superpowers/` | 14个 | 核心方法论技能 |
| **GStack** | `skills/gstack/` | 16个 | 工程工具技能 |
| **Hybrid** | `skills/hybrid/` | 1个 | 混合流程技能 |
| **Custom** | `skills/custom/` | - | 自定义扩展 |

14 个核心方法论技能（来自 [Superpowers](https://github.com/obra/superpowers)）和 16 个工程工具技能（来自 [GStack](https://github.com/garrytan/gstack)），按阶段触发。完整列表见 [skills-reference.md](../../../docs/skills-reference.md)。

### Hybrid 技能 (1个)

混合流程技能，结合两者优势：

| 技能 | 用途 | 触发方式 |
|------|------|---------|
| [gs-hybrid-v3](./) | 完整混合流程 | 主入口 |

---

## 加载策略速查表

> 不同阶段加载不同模块 + 框架文件，避免一次性占用上下文。本表为模块→框架文件映射的唯一真相源。

| 阶段 | 模块 | 关联的框架文件 |
|:-----|:-----|:--------------|
| IDEA / Step 0 | [01-intro.md](./modules/01-intro.md), [02-complexity.md](./modules/02-complexity.md) | — |
| DISCOVERY | [03a-discovery-arch.md](./modules/03a-discovery-arch.md) | `reviews/product-review.md`, `reviews/risk-review.md` |
| ARCH_REVIEW | 03a-discovery-arch.md | `reviews/architecture-review.md`, `reviews/tradeoff-review.md` |
| TASK_DECOMPOSITION | [03b-task-decomposition.md](./modules/03b-task-decomposition.md) | — |
| PLAN_CONFIRM | 03b-task-decomposition.md | — |
| CONTEXT_HYDRATION | [04a-execution-hydration.md](./modules/04a-execution-hydration.md) | `bridges/context-hydration.md`, `specs/*` (4个), `bridges/decision-to-context.md` |
| IMPLEMENTATION | 04a-execution-hydration.md | `execution-layer/implementation.md`, `testing.md`, `governance/decision-freeze.md` |
| SELF_REVIEW | [04b-self-review.md](./modules/04b-self-review.md) | `execution-layer/review.md`, `validation.md` |
| QA / SHIP_REVIEW / RETRO | 04b-self-review.md, [05-ship-review-retro.md](./modules/05-ship-review-retro.md) | `governance/decision-freeze.md` |
| 指令触发 | [06-workflows.md](./modules/06-workflows.md) | — |
| 异常/变更 | [07-handling.md](./modules/07-handling.md) | `governance/decision-freeze.md`（按需）|

> **加载规则**: 每阶段只加载该行指定的模块 + 框架文件；前序文件进入下一阶段后释放上下文（仅保留契约摘要）。各模块文件头部声明了精确的文件路径，以此为准。

## 状态转换验证

| 当前状态 | 目标状态 | 合法前置 | L1 | L2/L3 |
|---------|---------|---------|----|-------|
| IDEA → | DISCOVERY | 总是 | ✅ | ✅ |
| DISCOVERY → | REQUIREMENT_LOCK | IDEA | ✅ | ✅ |
| REQUIREMENT_LOCK → | ARCH_REVIEW | DISCOVERY | ✅ | ✅ |
| ARCH_REVIEW → | TASK_DECOMPOSITION | REQUIREMENT_LOCK | ✅ | ✅ |
| TASK_DECOMPOSITION → | PLAN_CONFIRM | ARCH_REVIEW | ✅ | ✅ |
| PLAN_CONFIRM → | CONTEXT_HYDRATION | TASK_DECOMPOSITION | ✅ | ✅ |
| CONTEXT_HYDRATION → | IMPLEMENTATION | PLAN_CONFIRM | ✅ | ✅ |
| IMPLEMENTATION → | SELF_REVIEW | IMPLEMENTATION | ✅ | ✅ |
| SELF_REVIEW → | QA | SELF_REVIEW | ✅ | ✅ |
| QA → | SHIP_REVIEW | QA | ✅ | ✅ |
| SHIP_REVIEW → | RETRO | SHIP_REVIEW | ✅ | ✅ |
| 任意 → | ABORTED | 总是 | ✅ | ✅ |
| 任意 → | IDEA | 决策冻结回滚 | 变更流程 | 变更流程 |
| IMPLEMENTATION → | ARCH_REVIEW | 变更请求 | 变更流程 | 变更流程 |
| IMPLEMENTATION → | TASK_DECOMPOSITION | 范围变更 | 变更流程 | 变更流程 |
| SELF_REVIEW → | IMPLEMENTATION | 审查失败 | ✅ | ✅ |
| QA → | SELF_REVIEW | QA 未通过 | ✅ | ✅ |
| QA → | IMPLEMENTATION | QA 严重失败 | 变更流程 | 变更流程 |
| SHIP_REVIEW → | QA | 发布检查未通过 | ✅ | ✅ |

> **命名约定**: 状态机代码中使用 `CONTEXT_HYDRATION`，文档中可写作 `Context Hydration`，两者等价。

> **真相源**: 状态转换表的机器可读定义见 [`governance/state-machine.yaml`](../../../governance/state-machine.yaml)。本表格仅为可读摘要，禁止在多处重复维护。校验脚本: `scripts/validate-state-machine.sh`

---

## 强制阻断规则

> **真相源**: Gate 定义的机器可读定义见 [`governance/gates.yaml`](../../../governance/gates.yaml)。本节仅为可读摘要，禁止在多处重复维护。校验脚本: `governance/check-gates.sh`

<HARD-GATE>
1. **REQUIREMENT_LOCK 需求确认** [gate: G001 requirement-lock]: 用户必须明确确认需求范围，否则不能进入 ARCH_REVIEW
2. **ARCH_REVIEW 架构审议** [gate: G002 arch-review-lock]: L2+ 任务必须有 ADR 记录且包含决策状态，L1 自动豁免
3. **TASK_DECOMPOSITION 任务确认** [gate: G003 task-decomposition-lock]: plan 文件存在且不含占位符（L1 可通过对话确认，不强制产出独立 plan 文件；L2/L3 必须产出 plan 文件）
4. **PLAN_CONFIRM Plan 确认** [gate: G004 plan-confirm]: plan 必须包含确认标记且用户已明确批准，否则不能进入 CONTEXT_HYDRATION
5. **Context Hydration 上下文注水** [gate: G005 context-hydration]: 所有 P0 Spec 文件必须存在
6. **决策冻结** [gate: G006 decision-freeze]: IMPLEMENTATION 期间架构/需求/契约不得自行更改，必须走 Decision Layer 变更流程
7. **测试存在** [gate: G007 test-presence]: 变更必须包含对应测试文件，否则不能进入 SELF_REVIEW
</HARD-GATE>

<BEHAVIOR-CONSTRAINTS>
以下为 AI Agent 行为约束，非机器可执行 Gate（无独立校验脚本），由 Agent 自律执行：
- **状态跳步**: 禁止从 IDEA → IMPLEMENTATION，L2/L3 必须走全流程
- **配置缺失**: 如果项目配置缺失，必须提示用户补充，否则阻断
- **评审不通过**: 如果审议/QA发现阻断性问题，必须修复后才能继续
</BEHAVIOR-CONSTRAINTS>

---

## 状态栏强制显示规则

<STATUS-BAR>
**每次响应必须以状态栏开头**，格式如下：

```
[状态: <当前状态> | 进度: <任务进度> | 冻结项: <冻结项列表>]
```

### 状态栏示例

```
[状态: IMPLEMENTATION | 进度: 任务3/7 | 冻结项: 架构, 需求]
[状态: DISCOVERY | 进度: 需求澄清中 | 冻结项: 无]
[状态: ARCH_REVIEW | 进度: Product维度审议完成 | 冻结项: 无]
[状态: Context Hydration | 进度: 加载 project-spec | 冻结项: 无]
```

### 状态栏规则

1. **强制显示**: 从 Step 0 开始，每次响应必须包含状态栏
2. **状态准确**: 状态栏中的状态必须与当前工作流状态一致
3. **进度更新**: 任务进度必须在完成每个子任务后更新
4. **冻结项显示**: 进入 IMPLEMENTATION 状态后，必须显示当前冻结项
5. **L1 简化**: L1 任务可简化为 `[状态: <状态> | 进度: <进度>]`，省略冻结项

### 状态栏目的

- **用户可见性**: 让用户清楚当前处于哪个状态、进度如何
- **AI 自约束**: 强制 AI 在每次响应前确认当前状态，防止状态漂移
- **调试辅助**: 当状态栏显示异常时，用户可及时发现并纠正
</STATUS-BAR>

---

## Skill 路由表（按需加载）

> **真相源**: 路由表的机器可读定义见 `schema/skill-routes.yaml`。本节仅为可读摘要，禁止在多处重复维护。

### Superpowers Skills 路由（状态机映射）

| 状态 | Skill | 触发条件 | 用途 | 类型 |
|------|-------|---------|------|------|
| **DISCOVERY** | `brainstorming` | L2+ 任务 | 需求澄清、渐进式提问、方案探索 | 自动 |
| **DISCOVERY** | `using-superpowers` | 会话启动 | 建立技能调用模式 | 自动 |
| **ARCH_REVIEW** | `design` | L2+ 任务 | Design Doc 编写 (方案对比/设计决策存档) | 自动 |
| **TASK_DECOMPOSITION** | `writing-plans` | 所有任务 | 结构化 Plan (Spec→Task分解/5类模板/依赖图) | 自动 |
| **PLAN_CONFIRM** | `plan-verification` | 所有任务 | Plan 验证确认 (范围/拆解/风险/验收硬阻断) | 自动 |
| **IMPLEMENTATION** | `test-driven-development` | 所有任务 | TDD 编码 | 自动 |
| **IMPLEMENTATION** | `dispatching-parallel-agents` | 2+ 独立子任务 | 并行 Agent 分发 | 手动 |
| **IMPLEMENTATION** | `executing-plans` | Plan 可用 | 在独立会话中执行 Plan | 手动 |
| **IMPLEMENTATION** | `subagent-driven-development` | 独立任务 Plan | 会话内子 Agent 执行 | 手动 |
| **IMPLEMENTATION** | `using-git-worktrees` | 需要隔离的新功能 | 创建隔离 worktree | 手动 |
| **SELF_REVIEW** | `requesting-code-review` | L2+ 任务 | 代码规范审查 | 自动 |
| **SELF_REVIEW** | `receiving-code-review` | 收到审查反馈 | 实施审查建议前的技术严谨性 | 手动 |
| **SHIP_REVIEW** | `verification-before-completion` | 所有任务 | 验证交付 | 自动 |
| **SHIP_REVIEW** | `finishing-a-development-branch` | 实现完成 | 合并/PR/清理策略 | 手动 |
| **EXCEPTION** | `systematic-debugging` | Bug/测试失败 | 修复前根因分析 | 手动 |

### GStack Skills 路由（激活条件）

| 状态 | Skill | 触发条件 | 用途 | 类型 |
|------|-------|---------|------|------|
| **ARCH_REVIEW** | `gstack:design-review` | 涉及前端 UI/UX | 前端视觉审查 | 条件 |
| **ARCH_REVIEW** | `gstack:plan-eng-review` | L2+ 任务 | 工程可行性审查 | 条件 |
| **ARCH_REVIEW** | `gstack:plan-devex-review` | L2+ 任务 | 开发者体验审查 | 条件 |
| **QA** | `gstack:qa` | L3 任务 | QA 测试、功能验证 | 条件 |
| **QA** | `gstack:cso` | 安全相关代码 | 安全扫描 | 条件 |
| **QA** | `gstack:benchmark` | L3 + 性能敏感 | 性能基准测试 | 条件 |
| **SELF_REVIEW** | `gstack:codex` | L3 任务 | 跨模型审查 | 条件 |
| **SHIP_REVIEW** | `gstack:ship` | 需要发布/部署 | 发布检查清单 | 条件 |
| **RETRO** | `gstack:retro` | L3 任务 | 工程复盘 | 条件 |
| **EXCEPTION** | `gstack:investigate` | 调试/根因分析 | 根因调试 | 条件 |
| **SAFETY** | `gstack:careful` | 破坏性命令 | 危险操作警告 | 手动 |
| **SAFETY** | `gstack:freeze` | 调试会话 | 限制编辑范围 | 手动 |
| **SAFETY** | `gstack:guard` | 最高安全需求 | careful + freeze 组合 | 手动 |
| **DISCOVERY** | `gstack:context-restore` | 会话恢复 | 恢复上次工作上下文 | 手动 |
| **DISCOVERY** | `gstack:context-save` | 会话暂停 | 保存工作上下文 | 手动 |
| **DISCOVERY** | `gstack:learn` | 重复模式 | 跨会话学习管理 | 手动 |

> **激活规则**: "自动"= 状态机进入时自动触发；"条件"= 满足触发条件时显式调用；"手动"= 需要用户或 Agent 主动调用，不自动触发。

### 三层架构路由

| 层 | 职责 | 核心文件 | 激活的 Skills |
|:---|:-----|:---------|:------------|
| **Decision Layer** | 多角色审议、方案决策 | [architecture-review](../../../decision-layer/reviews/architecture-review.md) | `brainstorming`, `design`, `writing-plans`, `plan-verification`, `gstack:design-review`, `gstack:plan-eng-review`, `gstack:plan-devex-review` |
| **Context Layer** | 上下文持久化、契约强制 | [project-spec](../../../context-layer/specs/project-spec.md), [context-hydration](../../../bridges/context-hydration.md) | `context-save`, `context-restore`, `learn` |
| **Execution Layer** | 受约束实现、验证 | [implementation](../../../execution-layer/implementation.md) | `test-driven-development`, `requesting-code-review`, `verification-before-completion`, `gstack:qa`, `gstack:cso`, `gstack:benchmark`, `gstack:codex` |
| **Bridges** | 层间传递 | [decision-to-context](../../../bridges/decision-to-context.md), [context-hydration](../../../bridges/context-hydration.md) | 无（纯协议层） |
| **Governance** | 跨层规则强制 | [decision-freeze](../../../governance/decision-freeze.md) | `gstack:ship`, `gstack:retro`, `gstack:investigate`, `freeze`, `guard`, `careful` |

---

## 三层架构核心原则

1. **思考与实现严格分离**: Decision Layer 负责决策，Execution Layer 负责执行，互不越界
2. **所有决策必须有记录和理由**: 每个 ADR 记录方案、否决理由、风险、回滚策略
3. **上下文契约是唯一真相来源**: Context Layer 的 spec 是执行的唯一依据
4. **执行时不允许偏离契约**: Execution Layer 必须在约束范围内工作
5. **变更必须走正式流程**: 冻结项变更需退回 Decision Layer 重新审议

---

## 治理规则

### 决策冻结
一旦进入 IMPLEMENTATION 状态，以下内容被冻结：
- 架构决策
- 需求范围
- API 契约
- 领域边界

变更冻结项必须退回 Decision Layer 重新审议。

**详细规则**: [decision-freeze.md](../../../governance/decision-freeze.md)

### 上下文注水
进入 Execution Layer 前必须加载：
1. project-spec（项目约束）
2. architecture-spec（架构约束）
3. api-spec（API 契约约束）
4. test-spec（测试约束）
5. ADR 历史（活跃的架构决策记录）
6. 活跃约束清单
7. domain-boundaries（领域边界定义）
8. coding-standards（编码规则定义）
9. 当前工作流状态

**详细协议**: [context-hydration.md](../../../bridges/context-hydration.md)

---

---

## 异常处理

当遇到以下情况时，参考 [07-handling.md](./modules/07-handling.md)：

- 评审意见冲突 → 冲突仲裁机制
- 需要回退流程 → 回滚机制
- 方案需要变更 → 变更审批流程
- 评审发现问题 → 异常处理流程

---

## 文档索引

### 文档维护规则（单一真相源）

**原则**: `SKILL.md` 是本技能的唯一真相源。其他文档通过以下方式保持同步：

| 文档 | 同步方式 | 说明 |
|------|---------|------|
| [README.md](../../../README.md) | 链接引用 | 仅保留项目概述和指向 SKILL.md 的链接 |
| [docs/getting-started.md](../../../docs/getting-started.md) | 链接引用 | 快速开始指引，详细内容指向 SKILL.md |
| [docs/architecture.md](../../../docs/architecture.md) | 链接引用 | 架构概览，详细设计指向各模块文件 |
| [docs/skills-reference.md](../../../docs/skills-reference.md) | 自动生成 | 由 SKILL.md 提取生成，禁止手动编辑 |
| [skills/README.md](../../../skills/README.md) | 链接引用 | 技能目录索引，指向各技能 SKILL.md |

**修改流程**:
1. 所有修改首先在 `SKILL.md` 完成
2. 其他文档如需更新，仅更新链接或重新自动生成
3. 禁止在其他文档中重复定义与 SKILL.md 冲突的内容

---

## 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| **v4.0** | **2026-05-16** | **AI Engineering Governance System**: 从技能分类升级为职责分层系统；新增状态机、决策冻结、上下文注水 |
| **v4.1** | **2026-05-16** | 渐进式加载优化：SKILL.md 精简 32%，框架文件按阶段加载；新增 PLAN_CONFIRM 状态和回滚转换路径 |

---

**版本**: v4.1 | **最后更新**: 2026-05-16

**详细文档请参考各模块文件。**
