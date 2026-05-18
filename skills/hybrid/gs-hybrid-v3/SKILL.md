---
name: "gs-hybrid-v3"
description: "AI Engineering Governance System — 三层架构（决策层/上下文层/执行层）+ Bridges + Governance。v4.0 重构：从技能分类升级为职责分层系统，新增状态机、决策冻结、上下文注水机制。"
---

# AI Engineering Governance System v4.0 (三层架构正式版)

> **核心理念**: 决策层 → 桥接 → 上下文层 → 桥接 → 执行层，思考与实现严格分离
> 本系统将 Superpowers 的工程纪律 + GStack 的多角色审议 + Context Layer 的契约驱动，统一为可执行的三层职责系统
> **v4.0 升级**: 从技能分类升级为职责分层系统 | 9 状态状态机 | 决策冻结 | 上下文注水

---

## 快速开始

### 启动方式

```
用户: hybrid 帮我开发用户认证功能

AI: 收到。我将按照 AI Engineering Governance System (v4.0) 三层架构执行：

Step 0:     评估任务复杂度 (L1/L2/L3)

┌─────────────────────────────────────────────────────────────────┐
│  DECISION LAYER (决策层)                                         │
└─────────────────────────────────────────────────────────────────┘
IDEA:       任务接收
DISCOVERY:  需求澄清 (Superpowers brainstorming - 渐进式提问)
             ↓ 产出：需求文档
REQUIREMENT_LOCK: 需求确认 (用户必须确认)
             ↓
ARCH_REVIEW: 多角色架构审议 (5 个维度独立投票)
             ↓ 产出：架构设计 + ADR
TASK_DECOMPOSITION: 任务拆解 (Superpowers writing-plans)
             ↓ 用户确认

┌─────────────────────────────────────────────────────────────────┐
│  CONTEXT LAYER (上下文层)                                        │
└─────────────────────────────────────────────────────────────────┘
Context Hydration: 加载所有 Spec 契约

┌─────────────────────────────────────────────────────────────────┐
│  EXECUTION LAYER (执行层)                                        │
└─────────────────────────────────────────────────────────────────┘
IMPLEMENTATION:  TDD 编码 (决策冻结)
SELF_REVIEW:    自审 (对照契约)
QA:             质量验证 (GStack qa)
SHIP_REVIEW:    发布检查 (GStack 检查清单)
RETRO:          复盘记录
```

### 专用指令

快捷指令列表请参考 [commands/README.md](../../../commands/README.md)。

---

## 架构职责索引

### 层职责表

| 层 | 路径 | 用途 |
|----|------|------|
| **Decision Layer** | `decision-layer/` | 需求发散 → 多角色审议 → ADR 决策 |
| **Context Layer** | `context-layer/` | 契约持久化 → Spec → 约束强制 → 边界隔离 |
| **Execution Layer** | `execution-layer/` | 受约束 TDD → 自审 → QA → 交付 |
| **Bridges** | `bridges/` | Decision→Context 转化 + Context→Execution 注水 |
| **Governance** | `governance/` | 决策冻结 + 状态验证 + 变更流程 |

---

## 原技能保留索引（向后兼容）

| 分类 | 路径 | 技能数量 | 说明 |
|------|------|---------|------|
| **Superpowers** | `skills/superpowers/` | 14个 | 核心方法论技能 |
| **GStack** | `skills/gstack/` | 16个 | 工程工具技能 |
| **Hybrid** | `skills/hybrid/` | 1个 | 混合流程技能 |
| **Custom** | `skills/custom/` | - | 自定义扩展 |

14 个核心方法论技能（来自 [Superpowers](https://github.com/obra/superpowers)），按阶段触发（自动/技能调用/手动）。完整列表见 [skills-reference.md](../../../docs/skills-reference.md)。

### GStack 技能 (16个)

16 个工程工具技能（来自 [GStack](https://github.com/gstack)），按类别分组，仅在对应阶段满足条件时触发。类别概览：

| 类别 | 数量 | 典型技能 |
|:-----|:----:|:---------|
| 规划与审查 | 3 | `plan-eng-review`, `plan-devex-review`, `design-review` |
| 质量保证 | 2 | `qa`, `benchmark` |
| 安全与防护 | 3 | `cso`, `careful`, `guard` |
| 部署与发布 | 1 | `ship` |
| 调试与调查 | 2 | `investigate`, `codex` |
| 文档与记忆 | 3 | `context-save`, `context-restore`, `learn` |
| 工具与实用程序 | 2 | `retro`, `freeze` |

完整列表见 [skills-reference.md](../../../docs/skills-reference.md)。

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
| Context Hydration | [04a-execution-hydration.md](./modules/04a-execution-hydration.md) | `hydration/hydration.md`, `specs/*` (4个), `bridges/*` (2个) |
| IMPLEMENTATION | 04a-execution-hydration.md | `execution-layer/implementation.md`, `testing.md`, `governance/decision-freeze.md` |
| SELF_REVIEW | [04b-self-review.md](./modules/04b-self-review.md) | `execution-layer/review.md`, `validation.md` |
| QA / SHIP_REVIEW / RETRO | 04b-self-review.md, [05-ship-review-retro.md](./modules/05-ship-review-retro.md) | `governance/decision-freeze.md` |
| 指令触发 | [06-workflows.md](./modules/06-workflows.md) | — |
| 异常/变更 | [07-handling.md](./modules/07-handling.md) | `governance/decision-freeze.md`（按需）|

> **加载规则**: 每阶段只加载该行指定的模块 + 框架文件；前序文件进入下一阶段后释放上下文（仅保留契约摘要）。各模块文件头部声明了精确的文件路径，以此为准。

## 流程概览

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│         AI Engineering Governance System v4.0 — 三层职责分层 (三层架构)                       │
├─────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                         │
│   需求输入                                                                               │
│      │                                                                                   │
│      ▼                                                                                   │
│   ┌───────────────────────────────────────────────────────────────────────────┐       │
│   │ Step 0: 复杂度评估                                                     │       │
│   │ 加载: 02-complexity.md                                               │       │
│   │ - 统计变更文件数                                                     │       │
│   │ - 预估代码行数                                                       │       │
│   │ - 确定级别: L1 / L2 / L3                                            │       │
│   └───────────────────────────────────────────────────────────────────────────┘       │
│      │                                                                                   │
│      ▼                                                                                   │
│   ┌───────────────────────────────────────────────────────────────────────────┐       │
│   │ ◆ DECISION LAYER (决策层)                                               │       │
│   ├───────────────────────────────────────────────────────────────────────────┤       │
│   │ IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION  │       │
│   │ [L1⚪   [L1⚪  [L1🔴  [L1⚪   [L1✅  │       │
│   │         L2🔴   L2🔴   L2🔴   L2✅  │       │
│   │         L3🔴   L3🔴   L3🔴   L3✅  │       │
│   │ 加载: 03a-discovery-arch.md, architecture-review.md                    │       │
│   │ - DISCOVERY: Superpowers brainstorming → 需求文档                        │       │
│   │ - REQUIREMENT_LOCK: 用户必须确认 🔴                                 │       │
│   │ - ARCH_REVIEW: 5 个维度审议 → ADR                                   │       │
│   │ - TASK_DECOMPOSITION: writing-plans → 任务清单                        │       │
│   └───────────────────────────────────────────────────────────────────────────┘       │
│      │                                                                                   │
│      ▼                                                                                   │
│   ┌───────────────────────────────────────────────────────────────────────────┐       │
│   │ ◆ CONTEXT LAYER (上下文层) → 桥接                                             │       │
│   ├───────────────────────────────────────────────────────────────────────────┤       │
│   │ Context Hydration (强制) 🔴                                            │       │
│   │ 加载: decision-to-context.md, context-to-execution.md                      │       │
│   │ - 加载所有 Spec 契约 → 进入 Execution Layer 必须完成                     │       │
│   └───────────────────────────────────────────────────────────────────────────┘       │
│      │                                                                                   │
│      ▼                                                                                   │
│   ┌───────────────────────────────────────────────────────────────────────────┐       │
│   │ ◆ EXECUTION LAYER (执行层)                                               │       │
│   ├───────────────────────────────────────────────────────────────────────────┤       │
│   │ IMPLEMENTATION → SELF_REVIEW → QA → SHIP_REVIEW → RETRO       │       │
│   │ [L1✅      [L1✅    [L1✅    [L1✅    [L1✅  │       │
│   │           L2✅      L2🟡    L2🟡    L2⚪  │       │
│   │           L3✅      L3🔴    L3🔴    L3🔴  │       │
│   │ 加载: 04a-execution-hydration.md, 04b-self-review.md             │       │
│   │ - IMPLEMENTATION: TDD (决策冻结)                                   │       │
│   │ - SELF_REVIEW: 对照契约自审                                         │       │
│   │ - QA: GStack qa                                                       │       │
│   │ - SHIP_REVIEW: 发布检查                                             │       │
│   │ - RETRO: 复盘记录                                                   │       │
│   └───────────────────────────────────────────────────────────────────────────┘       │
│                                                                                         │
│   图例: ✅ 必须   🟡 L2+必须   🔴 L3必须   ⚪ 可选   🔴 强制确认                         │
│                                                                                         │
└─────────────────────────────────────────────────────────────────────────────────────────┘
```

---

## 状态转换验证

| 当前状态 | 目标状态 | 合法前置 | L1 | L2/L3 |
|---------|---------|---------|----|-------|
| IDEA → | DISCOVERY | 总是 | ✅ | ✅ |
| DISCOVERY → | REQUIREMENT_LOCK | IDEA | ✅ | ✅ |
| REQUIREMENT_LOCK → | ARCH_REVIEW | DISCOVERY | ✅ | ✅ |
| ARCH_REVIEW → | TASK_DECOMPOSITION | REQUIREMENT_LOCK | ✅ | ✅ |
| TASK_DECOMPOSITION → | Context Hydration | ARCH_REVIEW | ✅ | ✅ |
| Context Hydration → | IMPLEMENTATION | TASK_DECOMPOSITION | ✅ | ✅ |
| IMPLEMENTATION → | SELF_REVIEW | IMPLEMENTATION | ✅ | ✅ |
| SELF_REVIEW → | QA | SELF_REVIEW | ✅ | ✅ |
| QA → | SHIP_REVIEW | QA | ✅ | ✅ |
| SHIP_REVIEW → | RETRO | SHIP_REVIEW | ✅ | ✅ |
| 任意 → | Decision Layer | 决策冻结变更 | 变更流程 | 变更流程 |

---

## 强制阻断规则

<HARD-GATE>
1. **REQUIREMENT_LOCK 需求确认**: 用户必须明确确认需求范围，否则不能进入 ARCH_REVIEW
2. **TASK_DECOMPOSITION 任务确认**: 用户必须明确确认执行计划，否则不能进入 Context Hydration（L1 可通过对话确认，不强制产出独立 plan 文件；L2/L3 必须产出 plan 文件）
3. **Context Hydration**: 执行层编码前必须完成上下文注水，否则禁止进入 IMPLEMENTATION
4. **决策冻结**: IMPLEMENTATION 期间架构/需求/契约不得自行更改，必须走 Decision Layer 变更流程
5. **状态跳步**: 禁止从 IDEA → IMPLEMENTATION，L2/L3 必须走全流程
6. **配置缺失**: 如果项目配置缺失，必须提示用户补充，否则阻断
7. **评审不通过**: 如果审议/QA发现阻断性问题，必须修复后才能继续
</HARD-GATE>

---

## 项目配置 (快速参考)

使用前必须配置以下项目参数：

```yaml
language: "Go 1.21+"                    # 开发语言
test_command: "go test ./... -race"     # 测试命令
coverage_command: "go test ./... -coverprofile=coverage.out"  # 覆盖率
lint_command: "golangci-lint run"       # 代码检查
security_scanner: "gosec ./..."         # 安全扫描
concurrency_model: "goroutine"          # 并发模型
```

**详细配置请参考**: [01-intro.md](./modules/01-intro.md)

---

## Skill 路由表（按需加载）

### Superpowers Skills 路由（状态机映射）

| 状态 | Skill | 触发条件 | 用途 |
|------|-------|---------|------|
| **DISCOVERY** | `brainstorming` | L2+ 任务 | 需求澄清、渐进式提问、方案探索、spec 文件 |
| **ARCH_REVIEW** | `design` | L2+ 任务 | Design Doc 编写 (方案对比/设计决策存档) |
| **TASK_DECOMPOSITION** | `writing-plans` | 所有任务 | 结构化 Plan (Spec→Task分解/5类模板/依赖图) |
| **PLAN_CONFIRM** | `plan-verification` | 所有任务 | Plan 验证确认 (范围/拆解/风险/验收硬阻断) |
| **SELF_REVIEW** | `requesting-code-review` | L2+ 任务 | 代码规范审查 |
| **IMPLEMENTATION** | `test-driven-development` | 所有任务 | TDD 编码 |
| **SHIP_REVIEW** | `verification-before-completion` | 所有任务 | 验证交付 |

### GStack Skills 路由（激活条件）

| 状态 | Skill | 触发条件 | 用途 |
|------|-------|---------|------|
| **ARCH_REVIEW** | `gstack:design-review` | 涉及前端 UI/UX | 前端视觉审查 |
| **ARCH_REVIEW** | `gstack:plan-eng-review` | L2+ 任务 | 工程可行性审查 |
| **ARCH_REVIEW** | `gstack:plan-devex-review` | L2+ 任务 | 开发者体验审查 |
| **QA** | `gstack:qa` | L3 任务 | QA 测试、功能验证 |
| **QA** | `gstack:cso` | 检测到安全相关代码 | 安全扫描 |
| **QA** | `gstack:benchmark` | L3 + 性能敏感任务 | 性能基准测试 |
| **SELF_REVIEW** | `gstack:codex` | L3 任务 | 跨模型审查 |
| **SHIP_REVIEW** | `gstack:ship` | 需要发布/部署 | 发布检查清单 |
| **RETRO** | `gstack:retro` | L3 任务 | 工程复盘 |
| **异常处理** | `gstack:investigate` | 调试/根因分析 | 根因调试 |

> **激活规则**: GStack 技能不是默认加载，而是在对应状态满足触发条件时显式调用。AI 必须在进入对应状态时检查触发条件，满足则调用，不满足则跳过。

### 三层架构路由

| 层 | 职责 | 核心文件 | 激活的 Skills |
|:---|:-----|:---------|:------------|
| **Decision Layer** | 多角色审议、方案决策 | [architecture-review](../../../decision-layer/reviews/architecture-review.md) | `brainstorming`, `design`, `writing-plans`, `plan-verification`, `gstack:design-review`, `gstack:plan-eng-review`, `gstack:plan-devex-review` |
| **Context Layer** | 上下文持久化、契约强制 | [project-spec](../../../context-layer/specs/project-spec.md), [hydration](../../../context-layer/hydration/hydration.md) | `context-save`, `context-restore`, `learn` |
| **Execution Layer** | 受约束实现、验证 | [implementation](../../../execution-layer/implementation.md) | `test-driven-development`, `requesting-code-review`, `verification-before-completion`, `gstack:qa`, `gstack:cso`, `gstack:benchmark`, `gstack:codex` |
| **Bridges** | 层间传递 | [decision-to-context](../../../bridges/decision-to-context.md), [context-to-execution](../../../bridges/context-to-execution.md) | 无（纯协议层） |
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
3. 当前 ADR 历史
4. 活跃约束清单

**详细协议**: [context-to-execution.md](../../../bridges/context-to-execution.md)

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
| **v4.0** | **2026-05-16** | **AI Engineering Governance System**: 从技能分类升级为职责分层系统；新增状态机、决策冻结、上下文注水；**v4.1** 渐进式加载优化：SKILL.md 精简 32%，框架文件按阶段加载 |

---

**版本**: v4.1 | **最后更新**: 2026-05-16

**详细文档请参考各模块文件。**
