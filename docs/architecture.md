# AI Engineering Governance System 架构设计 v4.0

> **文档版本**: v4.0 (三层架构正式版)
> **最后更新**: 2026-05-16
> **关联文档**: [design-doc-002](./design-docs/002-ai-engineering-governance-system.md) · [gs-hybrid-v3 SKILL](../skills/hybrid/gs-hybrid-v3/SKILL.md)

---

## 目录

1. [系统概述](#系统概述)
2. [三层架构](#三层架构)
3. [状态机设计](#状态机设计)
4. [上下文注水](#上下文注水)
5. [决策冻结机制](#决策冻结机制)
6. [流程设计](#流程设计)
7. [数据流](#数据流)
8. [设计原则](#设计原则)

---

## 系统概述

### 核心理念

AI Engineering Governance System v4.0 将系统从 **技能分类** 升级为 **职责分层** 系统：

- **旧架构**: 5层（用户交互 → 流程编排 → 技能层 → 工具层 → 输出层）
- **新架构**: 3层（Decision Layer → Context Layer → Execution Layer）+ Bridges + Governance

### 核心问题解决

v4.0 解决了以下关键问题：

1. **决策与执行混合**: 旧架构中思考和实现在同一技能中混杂
2. **缺少 Decision Artifact**: 讨论完直接跳 coding，没有正式的决策记录
3. **角色扮演而非决策维度**: 评审以"角色 persona"而非"决策维度"运作
4. **无上下文注水机制**: session restart 后所有上下文丢失

---

## 三层架构

### 整体架构图

```
┌─────────────────────────────────────────────────────────────────────────┐
│               AI Engineering Governance System v4.0                       │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  ◆ Decision Layer (决策层)                                       │    │
│  │  ─────────────────────────────────────────────────────────────   │    │
│  │  · 多角色审议 (Product / Architect / Performance / Security /    │    │
│  │    Operations)                                                   │    │
│  │  · 方案决策 & tradeoff 分析                                      │    │
│  │  · 产出: 批准方案 + ADR + 风险策略                                │    │
│  └────────────────────┬────────────────────────────────────────────┘    │
│                       │                                                  │
│                       │ [Bridge: Decision → Context]                    │
│                       │ 转化为可执行的 Spec 契约                          │
│                       ▼                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  ◆ Context Layer (上下文层)                                       │    │
│  │  ─────────────────────────────────────────────────────────────   │    │
│  │  · 上下文持久化 (project-spec / architecture-spec / ADR)          │    │
│  │  · 边界强制 & 约束规则                                            │    │
│  │  · 领域隔离 & 契约验证                                            │    │
│  └────────────────────┬────────────────────────────────────────────┘    │
│                       │                                                  │
│                       │ [Bridge: Context → Execution]                   │
│                       │ 上下文注水协议                                    │
│                       ▼                                                  │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  ◆ Execution Layer (执行层)                                       │    │
│  │  ─────────────────────────────────────────────────────────────   │    │
│  │  · 受约束 TDD 实现                                                │    │
│  │  · 契约对照自审 & QA                                             │    │
│  │  · 交付物验证                                                    │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                           │
│  ┌─────────────────────────────────────────────────────────────────┐    │
│  │  ◆ Governance (治理层)                                           │    │
│  │  ─────────────────────────────────────────────────────────────   │    │
│  │  · 决策冻结规则                                                  │    │
│  │  · 状态机验证                                                    │    │
│  │  · 变更流程强制                                                  │    │
│  └─────────────────────────────────────────────────────────────────┘    │
│                                                                           │
└─────────────────────────────────────────────────────────────────────────┘
```

### 层职责定义

| 层 | 路径 | 职责 | 核心文件 |
|:---|:-----|:-----|:---------|
| **Decision Layer** | `decision-layer/` | 需求发散 → 多角色审议 → ADR 决策 | [architecture-review](../decision-layer/reviews/architecture-review.md) |
| **Context Layer** | `context-layer/` | 契约持久化 → Spec → 约束强制 → 边界隔离 | [project-spec](../context-layer/specs/project-spec.md) · [hydration](../context-layer/hydration/hydration.md) |
| **Execution Layer** | `execution-layer/` | 受约束 TDD → 自审 → QA → 交付 | [implementation](../execution-layer/implementation.md) |
| **Bridges** | `bridges/` | Decision→Context 转化 + Context→Execution 注水 | [decision-to-context](../bridges/decision-to-context.md) · [context-to-execution](../bridges/context-to-execution.md) |
| **Governance** | `governance/` | 决策冻结 + 状态验证 + 变更流程 | [decision-freeze](../governance/decision-freeze.md) |

### Decision Layer (决策层)

**职责**: 多角色审议、方案决策、tradeoff 分析

**触发条件**:
- L2+ 任务自动触发
- L1 任务涉及边界模糊时触发
- 用户明确要求评审时触发

**决策维度（按复杂度分级）**:

| 级别 | 启用维度 | 说明 |
|------|---------|------|
| L1 | 跳过 | 无架构变更时不触发 ARCH_REVIEW |
| L2 | Product + Architect | 2 维度审议，聚焦业务价值与技术可行性 |
| L3 | 全 5 维度 | Product + Architect + Performance + Security + Operations |

**5 个维度定义**（L3 全量，L2 仅用前 2 项）：

| 维度 | 审议重点 | 映射技能 |
|------|---------|:---------|
| **Product** | 业务价值、用户影响、范围合理性、ROI | `office-hours`, `plan-ceo-review` |
| **Architect** | 模块划分、依赖方向、技术选型 | `plan-eng-review`, `design-shotgun` |
| **Performance** | 吞吐、延迟、缓存、瓶颈 | `benchmark`, `health` |
| **Security** | 信任边界、数据暴露、权限控制 | `cso`, `careful`, `guard` |
| **Operations** | 部署、回滚、监控、迁移成本 | `ship`, `devex-review` |

**输出工件**:
- 批准的方案
- 被否决的替代方案及理由
- 识别的风险与缓解策略
- 回滚策略
- 架构决策记录 (ADR)

详细审议规则请参考 [SKILL.md - 架构审议章节](../skills/hybrid/gs-hybrid-v3/modules/03a-discovery-arch.md)

### Context Layer (上下文层)

**职责**: 上下文持久化、Spec 契约、边界强制

**核心契约**:

| 契约 | 内容 | 强制范围 |
|------|------|:---------|
| **project-spec** | 架构风格、依赖方向、禁止模式 | 全局 |
| **architecture-spec** | 模块边界、通信协议、数据流向 | 模块级 |
| **domain-boundaries** | 各域职责、隔离规则 | 领域级 |
| **constraints-spec** | 事务、并发、命名、安全 | 实现级 |
| **ADR** | 架构决策历史 | 全局 |

**上下文注水协议（分级制）**:

| 优先级 | 加载内容 | L1 | L2 | L3 |
|--------|---------|:--:|:--:|:--:|
| **P0** | 技术栈确认 + 当前任务验收标准 + 模块边界 | ✅ | ✅ | ✅ |
| **P1** | 工程规范 + 性能约束 + 相关 ADR | ⚪ | 🟡 | ✅ |
| **P2** | 完整架构图 + SOLID 检查 + 全部 ADR 历史 | ⚪ | ⚪ | ✅ |

**阻断规则**: P0 项缺失 → 禁止进入 Execution Layer。  
**记录规则**: P1/P2 项缺失 → 记录技术债务，不阻断。

详细注水规则请参考 [SKILL.md - Context Hydration 章节](../skills/hybrid/gs-hybrid-v3/modules/04a-execution-hydration.md)

### Execution Layer (执行层)

**职责**: 受约束实现、测试、验证

**强制流程**:
1. 上下文注水（读取所有 spec）
2. 测试失败（TDD 红）
3. 最简实现（TDD 绿）
4. 约束内重构
5. 契约对照自审

**红线**:
- 禁止重新设计架构
- 禁止修改领域边界
- 禁止忽略约束规则
- 禁止跳过测试

### Bridges (桥接层)

**Decision → Context Bridge**:
- 将决策层的审议结果转化为结构化 Spec 契约
- 生成 ADR 记录
- 建立约束清单

**Context → Execution Bridge**:
- 执行上下文注水协议
- 验证 Spec 完整性
- 建立执行期约束检查点

### Governance (治理层)

**核心职责**:
- 决策冻结规则强制执行
- 状态机迁移验证
- 变更流程管理
- 违规检测与处理

---

## 状态机设计

### 状态转换图

```
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION
    → [Context Hydration] → IMPLEMENTATION → SELF_REVIEW → QA
    → SHIP_REVIEW → RETRO
```

### 状态详情

| 状态 | 层归属 | 职责 | 产出物 | L1 | L2 | L3 |
|------|--------|------|---------|:--:|:--:|:--:|
| **IDEA** | Decision | 任务接收 | — | ✅ | ✅ | ✅ |
| **DISCOVERY** | Decision | 需求澄清 (brainstorming) | 需求文档 | ⚪ | 🔴 | 🔴 |
| **REQUIREMENT_LOCK** | Decision | 需求确认 | 确认的需求清单 | 🔴(合并) | 🔴 | 🔴 |
| **ARCH_REVIEW** | Decision | 多角色架构审议 | 架构设计 + ADR | ⚪ | 🟡 | 🔴 |
| **TASK_DECOMPOSITION** | Decision | 任务拆解 | 任务清单 | ✅ | ✅ | ✅ |
| **PLAN_CONFIRM** | Decision | Plan 验证确认 | 确认记录 | 🔴(合并) | 🔴 | 🔴 |
| **Context Hydration** | Context Bridge | 加载 Spec 契约 | 注水完成确认 | ⚪ | 🟡 | 🔴 |
| **IMPLEMENTATION** | Execution | TDD 编码（决策冻结） | 通过测试的代码 | ✅ | ✅ | ✅ |
| **SELF_REVIEW** | Execution | 对照契约自审 | 自审报告 | ⚪ | 🟡 | 🔴 |
| **QA** | Execution | 质量验证 | 回归测试报告 | ⚪ | ⚪ | 🔴 |
| **SHIP_REVIEW** | Governance | 发布检查 | 发布检查清单 | ✅ | ✅ | ✅ |
| **RETRO** | Governance | 复盘记录 | 复盘记录 | ⚪ | ⚪ | 🔴 |

**图例**: ✅ 必须 · 🟡 L2+必须 · 🔴 必须/强制确认 · ⚪ 可选 · 🔴(合并) L1 合并确认

### L1 快速通道规则

L1 任务（文件<3, 代码<100行）适用以下简化：
- DISCOVERY + REQUIREMENT_LOCK → **合并为单次确认**
- TASK_DECOMPOSITION + PLAN_CONFIRM → **合并为单次确认**
- ARCH_REVIEW → **跳过**（无架构变更时）
- Context Hydration → **仅 P0 阻断项**（技术栈 + 验收标准）
- SELF_REVIEW → **跳过**
- QA → **跳过**
- RETRO → **跳过**

详细分级规则请参考 [SKILL.md - 复杂度评估章节](../skills/hybrid/gs-hybrid-v3/modules/02-complexity.md)

### 状态转换验证

| 当前状态 → 目标状态 | 合法前置 | L1 | L2/L3 |
|--------------------|:---------|:----|:------|
| IDEA → DISCOVERY | 总是 | ✅ | ✅ |
| DISCOVERY → REQUIREMENT_LOCK | IDEA | ✅ | ✅ |
| REQUIREMENT_LOCK → ARCH_REVIEW | DISCOVERY | ✅ | ✅ |
| ARCH_REVIEW → TASK_DECOMPOSITION | REQUIREMENT_LOCK | ✅ | ✅ |
| TASK_DECOMPOSITION → Context Hydration | ARCH_REVIEW | ✅ | ✅ |
| Context Hydration → IMPLEMENTATION | TASK_DECOMPOSITION | ✅ | ✅ |
| IMPLEMENTATION → SELF_REVIEW | IMPLEMENTATION | ✅ | ✅ |
| SELF_REVIEW → QA | SELF_REVIEW | ✅ | ✅ |
| QA → SHIP_REVIEW | QA | ✅ | ✅ |
| SHIP_REVIEW → RETRO | SHIP_REVIEW | ✅ | ✅ |
| 任意 → Decision Layer | 决策冻结变更 | 变更流程 | 变更流程 |

---

## 上下文注水

### 注水协议

进入 Execution Layer 前必须完成 **Context Hydration**，加载以下资产：

| 资产 | 路径 | 优先级 | 加载方式 |
|:-----|:-----|:-------|:---------|
| project-spec | `context-layer/specs/project-spec.md` | P0 | 首次加载后缓存 |
| architecture-spec | `context-layer/specs/architecture-spec.md` | P0 | 每次重新加载 |
| constraints-spec | `context-layer/specs/constraints-spec.md` | P0 | 每次重新加载 |
| domain-boundaries | `context-layer/specs/domain-boundaries.md` | P0 | 每次重新加载 |
| ADR 历史 | `context-layer/adr/` | P0 | 仅加载活跃 ADR |
| 任务清单 | `specs/plans/tasks.md` | P1 | 每次重新加载 |
| 工作流状态 | `artifacts/workflow-state.md` | P1 | 每次重新加载 |
| 项目配置 | `project-config.yml` | P2 | 首次加载后缓存 |

**优先级说明**:
- **P0**: 必须在进入 Execution Layer 前加载，缺失则阻断
- **P1**: 应在 Execution Layer 启动时加载，缺失不阻断但记录警告
- **P2**: 按需加载，非必需

### 资产格式规范

每个注水资产文件必须包含版本标识：

```yaml
---
# 文件头
hydration:
  asset: "project-spec"
  version: "1.2.0"
  updated: "2026-05-16"
  adr_ref: "ADR-001, ADR-003"
---
```

资产文件尾部必须包含变更历史：

```markdown
---

## 变更历史

| 版本 | 日期 | 变更内容 | ADR |
|:----|:-----|:---------|:----|
| 1.0.0 | 2026-05-01 | 初始创建 | — |
| 1.2.0 | 2026-05-16 | 新增安全约束章节 | ADR-008 |
```

---

## 决策冻结机制

### 冻结范围

一旦工作流进入 **IMPLEMENTATION** 状态，以下内容被冻结：

| 冻结项 | 冻结内容 | 违反示例 |
|:-------|:---------|:---------|
| **架构决策** | 模块划分、依赖方向、技术选型 | 实现时发现"这个模块放这里不合理"自行移动 |
| **需求范围** | 功能清单、非功能需求、边界条件 | 实现时觉得"这个功能顺便加了吧" |
| **API 契约** | 接口签名、数据格式、版本化策略 | 实现时修改 API 参数以"方便前端" |
| **领域边界** | 各域职责、隔离规则、跨域通信 | 实现时从 A 域直接访问 B 域的数据库 |

### 冻结生命周期

```
Decision  ──→  Context  ──→  Execution
Layer          Layer          Layer
│                              │
│  ┌───────────────────────────┤
│  │  冻结开始                  │
│  │  (进入 IMPLEMENTATION)     │
│  │                           │
│  │  冻结生效                  │
│  │  以下不可更改：             │
│  │  · 架构决策                │
│  │  · 需求范围                │
│  │  · API 契约                │
│  │  · 领域边界                │
│  │                           │
│  │  冻结解除                  │
│  │  (进入 SHIP_REVIEW)        │
└──┘                           └──
```

### 变更流程

如果在冻结期间需要修改冻结项，必须走以下正式流程：

```
发现需要变更
    │
    ▼
[1] 记录变更请求
    ├─ 变更项: [架构决策 / 需求范围 / API 契约 / 领域边界]
    ├─ 当前状态: [冻结项的当前内容]
    ├─ 期望变更: [希望改成什么]
    └─ 变更理由: [为什么需要改]
    │
    ▼
[2] 暂停实现
    ├─ 标记所有受影响文件为 "pending-review"
    └─ 记录当前实现进度
    │
    ▼
[3] 退回 Decision Layer
    ├─ 使用 architecture-review 协议重新审议
    ├─ 变更范围超过原始需求 → 重新触发 DISCOVERY
    ├─ 仅架构微调 → 触发增量审议（2-3 个维度）
    └─ 审议必须包含变更影响评估
    │
    ▼
[4] 更新 Context Layer
    ├─ 更新对应的 spec 文件
    ├─ 新增 ADR 记录变更
    └─ 标记已影响的实现文件
    │
    ▼
[5] 重新注水
    ├─ 加载更新后的上下文契约
    ├─ 确认变更影响范围
    └─ 评估已有实现是否需要重做
    │
    ▼
[6] 恢复实现
    └─ 从变更影响点继续
```

### 禁止的变更路径

```
❌ "我先改再告诉你"
    → 违反决策冻结条例

❌ "这个改动很小，不需要走流程"
    → 无大小例外，所有对冻结项的变更必须走正式流程

❌ "用户口头同意了"
    → 必须有书面 ADR 记录
```

### 例外条款

以下变更不需要经过决策冻结变更流程：

| 例外类型 | 说明 | 限制 |
|:---------|:-----|:-----|
| 拼写/注释修正 | 不影响行为的文本错误 | 不超过 3 处 |
| 重命名局部变量 | 仅限函数级作用域 | 不改变公共 API |
| 测试用例补充 | 不修改被测代码的行为 | 禁止修改测试框架配置 |
| 日志级别调整 | 不改变日志内容和格式 | 仅 info/debug 级别 |

所有例外必须在 commit message 中标注 `[freeze-exception]`。

---

## 流程设计

### 主流程 (AI Engineering Governance System)

```
需求输入
    │
    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ Step 0: 复杂度评估                                                       │
│ - 统计变更文件数                                                         │
│ - 预估代码行数                                                           │
│ - 识别架构影响                                                           │
│ - 确定级别: L1 / L2 / L3                                                │
└─────────────────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ ◆ DECISION LAYER (决策层)                                               │
├─────────────────────────────────────────────────────────────────────────┤
│ IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION │
│ [L1⚪   [L1⚪  [L1🔴  [L1⚪   [L1✅  │
│         L2🔴   L2🔴   L2🔴   L2✅  │
│         L3🔴   L3🔴   L3🔴   L3✅  │
│ - DISCOVERY: Superpowers brainstorming → 需求文档                       │
│ - REQUIREMENT_LOCK: 用户必须确认 🔴                                     │
│ - ARCH_REVIEW: 5 个维度审议 → ADR                                      │
│ - TASK_DECOMPOSITION: writing-plans → 任务清单                         │
└─────────────────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ ◆ CONTEXT LAYER (上下文层) → 桥接                                       │
├─────────────────────────────────────────────────────────────────────────┤
│ Context Hydration (强制) 🔴                                             │
│ - 加载所有 Spec 契约 → 进入 Execution Layer 必须完成                    │
└─────────────────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│ ◆ EXECUTION LAYER (执行层)                                               │
├─────────────────────────────────────────────────────────────────────────┤
│ IMPLEMENTATION → SELF_REVIEW → QA → SHIP_REVIEW → RETRO                │
│ [L1✅      [L1✅    [L1✅    [L1✅    [L1✅  │
│           L2✅      L2🟡    L2🟡    L2⚪  │
│           L3✅      L3🔴    L3🔴    L3🔴  │
│ - IMPLEMENTATION: TDD (决策冻结)                                        │
│ - SELF_REVIEW: 对照契约自审                                              │
│ - QA: GStack qa                                                          │
│ - SHIP_REVIEW: 发布检查                                                  │
│ - RETRO: 复盘记录                                                        │
└─────────────────────────────────────────────────────────────────────────┘
    │
    ▼
完成
```

### 复杂度分级

| 级别 | 判定标准 | 适用场景 | 必须阶段 |
|:----|:---------|:---------|:---------|
| **L1** | 文件<3, 代码<100行 | 简单任务、文档更新 | IDEA → TASK_DECOMPOSITION → IMPLEMENTATION → SELF_REVIEW |
| **L2** | 文件3-8, 代码100-500行 | 中等任务、新增模块 | 完整 Decision Layer + Execution Layer |
| **L3** | 文件>8, 代码>500行 | 复杂任务、架构重构 | 全流程（含多角色审议、QA、RETRO） |

### 强制阻断规则

<HARD-GATE>

1. **REQUIREMENT_LOCK 需求确认**: 用户必须明确确认需求范围，否则不能进入 ARCH_REVIEW
   - L1 快速通道: 可与 DISCOVERY 合并为单次确认
2. **TASK_DECOMPOSITION 任务确认**: 用户必须明确确认执行计划，否则不能进入 Context Hydration
   - L1 快速通道: 可与 REQUIREMENT_LOCK 合并为单次确认
3. **Context Hydration**: 执行层编码前必须完成 P0 项加载，否则禁止进入 IMPLEMENTATION
4. **决策冻结**: IMPLEMENTATION 期间架构/需求/契约不得自行更改，必须走 Decision Layer 变更流程
5. **状态跳步**: 禁止从 IDEA → IMPLEMENTATION，L2/L3 必须走全流程
6. **配置缺失**: 优先自动发现，失败则提示用户补充，记录为技术债务
7. **评审不通过**: 如果审议/QA发现阻断性问题，必须修复后才能继续
8. **GStack 技能激活**: 满足触发条件时必须显式调用，不得跳过

</HARD-GATE>

详细阻断规则请参考 [SKILL.md - 各模块硬阻断定义](../skills/hybrid/gs-hybrid-v3/modules/)

---

## 数据流

### 决策 → 执行 数据流

```
需求输入
    │
    ▼
Decision Layer:
    ├─ DISCOVERY → 需求文档
    ├─ REQUIREMENT_LOCK → 确认的需求清单
    ├─ ARCH_REVIEW → 架构设计 + ADR
    └─ TASK_DECOMPOSITION → 任务清单
    │
    ▼ [Bridge: Decision → Context]
    │
Context Layer:
    ├─ 更新 project-spec
    ├─ 更新 architecture-spec
    ├─ 更新 domain-boundaries
    ├─ 生成 ADR 记录
    └─ 建立约束清单
    │
    ▼ [Bridge: Context → Execution]
    │
Context Hydration:
    ├─ 加载所有 Spec 契约
    ├─ 验证完整性
    └─ 建立约束检查点
    │
    ▼
Execution Layer:
    ├─ IMPLEMENTATION → 通过测试的代码
    ├─ SELF_REVIEW → 自审报告
    ├─ QA → 回归测试报告
    ├─ SHIP_REVIEW → 发布检查清单
    └─ RETRO → 复盘记录
```

### 文档数据流

```
需求输入
    │
    ▼
docs/design-docs/NNN-title.md (ARCH_REVIEW)
    │
    ▼
context-layer/adr/ADR-NNN.md (决策记录)
    │
    ▼
context-layer/specs/*.md (Spec 契约)
    │
    ▼
specs/plans/PLAN-XXX.md (TASK_DECOMPOSITION)
    │
    ▼
代码实现 (IMPLEMENTATION)
    │
    ▼
测试报告、Changelog (QA + SHIP_REVIEW)
```

---

## 设计原则

### 1. 思考与实现严格分离

- Decision Layer 负责决策，Execution Layer 负责执行，互不越界
- 决策层不碰代码，执行层不做架构决策

### 2. 所有决策必须有记录和理由

- 每个 ADR 记录方案、否决理由、风险、回滚策略
- 决策可追溯，避免重复争论

### 3. 上下文契约是唯一真相来源

- Context Layer 的 spec 是执行的唯一依据
- 执行层必须在约束范围内工作

### 4. 执行时不允许偏离契约

- Execution Layer 必须严格遵循已冻结的上下文契约
- 任何偏离都视为违规

### 5. 变更必须走正式流程

- 冻结项变更需退回 Decision Layer 重新审议
- 无大小例外，所有变更必须有记录

### 6. 最小干预原则

- 用户不需要知道技能存在
- 自动在正确时机触发
- 自然流畅的工作流程

### 7. 按需加载原则

- 不同阶段加载不同内容
- 避免一次性加载所有内容
- 降低上下文消耗

---

## 文件索引

| 路径 | 内容 |
|:-----|:-----|
| [decision-layer/reviews/](../decision-layer/reviews/) | 多角色审议协议 |
| [context-layer/specs/](../context-layer/specs/) | 上下文约束契约 |
| [context-layer/hydration/](../context-layer/hydration/) | 注水规范 |
| [execution-layer/](../execution-layer/) | 执行规则 |
| [bridges/](../bridges/) | 层间桥接协议 |
| [governance/](../governance/) | 治理规则 |
| [docs/design-docs/002-ai-engineering-governance-system.md](./design-docs/002-ai-engineering-governance-system.md) | 设计文档 |
| [skills/hybrid/gs-hybrid-v3/SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md) | 主技能 |

---

## 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|:---------|
| **v4.1** | **2026-05-16** | **规则化重构**: L1 快速通道（合并确认点）；ARCH_REVIEW 分级审议（L2→2维度，L3→5维度）；Context Hydration 分级（P0/P1/P2）；GStack 技能显式激活规则；安全审查委托 gstack:cso；项目配置自动发现；文档单一真相源 |
| **v4.0** | **2026-05-16** | **AI Engineering Governance System**: 完全重写，从 5 层架构升级为 3 层（Decision/Context/Execution Layer + Bridges + Governance）；新增状态机（9 状态严格迁移）；新增多角色架构审议协议；新增上下文注水机制；新增决策冻结规则；与 SKILL.md 和 design-doc-002 完全一致 |
| v3.7 | 2026-05-15 | GStack 完整集成：从 8 个扩展到 48 个 GStack 技能 |
| v3.0 | 2026-05-12 | 初始版本，结合 Superpowers + GStack |

---

## 文档维护规则

**本文档为索引层**，所有详细规则指向 [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md)。禁止在本文档中重复定义与 SKILL.md 冲突的内容。

| 文档 | 角色 | 同步方式 |
|:-----|:-----|:---------|
| [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md) | 唯一真相源 | 手动维护 |
| [README.md](../README.md) | 项目索引 | 链接引用 |
| [getting-started.md](./getting-started.md) | 快速开始 | 链接引用 |
| [skills-reference.md](./skills-reference.md) | 技能列表 | 自动生成 |

---

**文档状态**: 已批准 · **维护者**: AI Engineering Governance Team
