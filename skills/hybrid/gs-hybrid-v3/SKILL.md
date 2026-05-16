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

| 指令 | 功能 | 说明 |
|------|------|------|
| `/plan` | 规划流程 | 新功能开发前的完整规划 |
| `/review` | 代码审查 | 代码完成后的质量审查 |
| `/test` | 测试驱动 | TDD 开发流程 |
| `/qa` | 质量保证 | 功能完成后的验证 |
| `/debug` | 调试助手 | 问题诊断与修复 |
| `/refactor` | 重构建议 | 代码改进与优化 |

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
| **GStack** | `skills/gstack/` | 48+个 | 工程工具技能 |
| **Hybrid** | `skills/hybrid/` | 1个 | 混合流程技能 |
| **Custom** | `skills/custom/` | - | 自定义扩展 |

### Superpowers 技能 (14个)

核心方法论技能，来自 Superpowers 官方：

| 技能 | 用途 | 触发方式 |
|------|------|---------|
| [brainstorming](../superpowers/brainstorming/) | 需求澄清、方案对比 | 自动触发 |
| [writing-plans](../superpowers/writing-plans/) | 编写实施计划 | 技能调用 |
| [executing-plans](../superpowers/executing-plans/) | 批量执行计划 | 技能调用 |
| [subagent-driven-development](../superpowers/subagent-driven-development/) | 子代理开发 | 技能调用 |
| [test-driven-development](../superpowers/test-driven-development/) | TDD 编码 | 自动触发 |
| [systematic-debugging](../superpowers/systematic-debugging/) | 系统调试 | 技能调用 |
| [requesting-code-review](../superpowers/requesting-code-review/) | 代码审查请求 | 自动触发 |
| [receiving-code-review](../superpowers/receiving-code-review/) | 响应审查反馈 | 技能调用 |
| [using-git-worktrees](../superpowers/using-git-worktrees/) | Git worktree | 自动触发 |
| [finishing-a-development-branch](../superpowers/finishing-a-development-branch/) | 分支收尾 | 自动触发 |
| [dispatching-parallel-agents](../superpowers/dispatching-parallel-agents/) | 并行代理 | 技能调用 |
| [verification-before-completion](../superpowers/verification-before-completion/) | 完成前验证 | 自动触发 |
| [writing-skills](../superpowers/writing-skills/) | 创建新技能 | 技能调用 |
| [using-superpowers](../superpowers/using-superpowers/) | 系统介绍 | 手动触发 |

### GStack 技能 (48个)

工程工具技能，来自 GStack（按类别分组）：

**规划与审查 (8个)**:
| 技能 | 用途 |
|------|------|
| [autoplan](../gstack/autoplan/) | 自动审查管线 |
| [office-hours](../gstack/office-hours/) | 产品定位问诊 |
| [plan-ceo-review](../gstack/plan-ceo-review/) | CEO 战略审查 |
| [plan-eng-review](../gstack/plan-eng-review/) | 工程经理审查 |
| [plan-design-review](../gstack/plan-design-review/) | 设计师审查（规划阶段） |
| [plan-devex-review](../gstack/plan-devex-review/) | 开发者体验审查 |
| [plan-tune](../gstack/plan-tune/) | 规划调优 |
| [review](../gstack/review/) | 代码审查 |

**设计与前端 (6个)**:
| 技能 | 用途 |
|------|------|
| [design](../gstack/design/) | 设计工具 |
| [design-consultation](../gstack/design-consultation/) | 设计咨询 |
| [design-html](../gstack/design-html/) | HTML设计 |
| [design-review](../gstack/design-review/) | 设计审查 |
| [design-shotgun](../gstack/design-shotgun/) | 多方案设计 |
| [devex-review](../gstack/devex-review/) | 开发者体验审查（执行阶段） |

**质量保证与测试 (5个)**:
| 技能 | 用途 |
|------|------|
| [qa](../gstack/qa/) | QA 测试 |
| [qa-only](../gstack/qa-only/) | 仅 QA 报告 |
| [benchmark](../gstack/benchmark/) | 性能基准 |
| [benchmark-models](../gstack/benchmark-models/) | 跨模型基准测试 |
| [health](../gstack/health/) | 代码质量仪表板 |

**安全与防护 (5个)**:
| 技能 | 用途 |
|------|------|
| [cso](../gstack/cso/) | 首席安全官 |
| [careful](../gstack/careful/) | 安全护栏 |
| [freeze](../gstack/freeze/) | 编辑限制 |
| [guard](../gstack/guard/) | 完全安全模式 |
| [unfreeze](../gstack/unfreeze/) | 解除编辑限制 |

**部署与发布 (5个)**:
| 技能 | 用途 |
|------|------|
| [ship](../gstack/ship/) | 发布工程师 |
| [land-and-deploy](../gstack/land-and-deploy/) | 部署工程师 |
| [canary](../gstack/canary/) | 部署后监控 |
| [landing-report](../gstack/landing-report/) | 着陆报告 |
| [setup-deploy](../gstack/setup-deploy/) | 部署配置 |

**调试与调查 (2个)**:
| 技能 | 用途 |
|------|------|
| [investigate](../gstack/investigate/) | 根因调试 |
| [codex](../gstack/codex/) | 跨模型审查 |

**文档与记忆 (5个)**:
| 技能 | 用途 |
|------|------|
| [document-release](../gstack/document-release/) | 发布文档更新 |
| [document-generate](../gstack/document-generate/) | 文档生成 |
| [learn](../gstack/learn/) | 记忆管理 |
| [context-restore](../gstack/context-restore/) | 上下文恢复 |
| [context-save](../gstack/context-save/) | 上下文保存 |

**浏览器自动化 (3个)**:
| 技能 | 用途 |
|------|------|
| [gstack-browse](../gstack/gstack-browse/) | 浏览器自动化 |
| [open-gstack-browser](../gstack/open-gstack-browser/) | 打开 GStack 浏览器 |
| [setup-browser-cookies](../gstack/setup-browser-cookies/) | Cookie 导入 |

**工具与实用程序 (9个)**:
| 技能 | 用途 |
|------|------|
| [gstack-upgrade](../gstack/gstack-upgrade/) | 自更新工具 |
| [setup-gbrain](../gstack/setup-gbrain/) | 知识库配置 |
| [sync-gbrain](../gstack/sync-gbrain/) | 同步知识库 |
| [make-pdf](../gstack/make-pdf/) | PDF 生成 |
| [scrape](../gstack/scrape/) | 网页抓取 |
| [skillify](../gstack/skillify/) | 技能生成 |
| [retro](../gstack/retro/) | 工程复盘 |
| [pair-agent](../gstack/pair-agent/) | 配对代理 |
| [openclaw](../gstack/openclaw/) | OpenClaw 集成 |

### Hybrid 技能 (1个)

混合流程技能，结合两者优势：

| 技能 | 用途 | 触发方式 |
|------|------|---------|
| [gs-hybrid-v3](./) | 完整混合流程 | 主入口 |

---

## 模块化按需加载

> **核心理念**: 不同阶段加载不同的模块，避免一次性加载所有内容消耗上下文。

### 本技能模块索引（向后兼容）

| 模块 | 内容 | 加载时机 |
|------|------|---------|
| [01-intro.md](./modules/01-intro.md) | 三层架构核心概念、项目配置、核心原则 | 初始加载 |
| [02-complexity.md](./modules/02-complexity.md) | 复杂度分级、适用矩阵 | Step 0 |
| [03a-discovery-arch.md](./modules/03a-discovery-arch.md) | IDEA→DISCOVERY→ARCH_REVIEW | 决策层阶段 |
| [03b-task-decomposition.md](./modules/03b-task-decomposition.md) | TASK_DECOMPOSITION | 任务拆解 |
| [04a-execution-hydration.md](./modules/04a-execution-hydration.md) | 上下文注水、TDD | 执行层前置 |
| [04b-self-review.md](./modules/04b-self-review.md) | 自审、QA | 执行层阶段 |
| [05-ship-review-retro.md](./modules/05-ship-review-retro.md) | SHIP_REVIEW、RETRO | 交付与复盘 |
| [06-workflows.md](./modules/06-workflows.md) | 专用流程指令 | 指令触发 |
| [07-handling.md](./modules/07-handling.md) | 异常处理、变更流程 | 异常/变更 |

### 加载策略

```
初始: 加载 01-intro.md (三层架构、核心原则
      ↓
Step 0: 加载 02-complexity.md (复杂度评估 → L1/L2/L3)
      ↓
Decision Layer: 加载 03a-discovery-arch.md (需求发散、架构审议)
      ↓
TASK_DECOMPOSITION: 加载 03b-task-decomposition.md (任务拆解)
      ↓
Execution Layer: 加载 04a-execution-hydration.md (上下文注水)
      ↓
SELF_REVIEW/QA: 加载 04b-self-review.md (自审、QA)
      ↓
SHIP_REVIEW/RETRO: 加载 05-ship-review-retro.md (交付、复盘)
      ↓
异常/变更: 加载 07-handling.md (异常处理)
```

---

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
2. **TASK_DECOMPOSITION 任务确认**: 用户必须明确确认执行计划，否则不能进入 Context Hydration
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

### Superpowers Skills 路由

| 阶段 | Skill | 触发条件 | 用途 |
|------|-------|---------|------|
| **Phase 0.5a** | `brainstorming` | L2+ 任务 | 需求澄清、渐进式提问、方案探索、spec 文件 |
| **Phase 0.5b** | `design` | L2+ 任务 | Design Doc 编写 (方案对比/设计决策存档) |
| **Phase 1** | `writing-plans` | 所有任务 | 结构化 Plan (Spec→Task分解/5类模板/依赖图) |
| **Phase 1.5** | `plan-verification` | 所有任务 | Plan 验证确认 (范围/拆解/风险/验收硬阻断) |
| **Phase 2** | `requesting-code-review` | L2+ 任务 | 代码规范审查 |
| **Phase 3** | `requesting-code-review` | L3 任务 | 架构评审 |
| **Phase 6** | `test-driven-development` | 所有任务 | TDD 编码 |
| **Phase 7** | `verification-before-completion` | 所有任务 | 验证交付 |

### GStack Skills 路由

| 阶段 | Skill | 触发条件 | 用途 |
|------|-------|---------|------|
| **Phase 2.5** | `design-review` | 涉及前端 | 前端视觉审查 |
| **Phase 4** | `qa` | L3 任务 | QA 测试、功能验证 |
| **Phase 5** | `cso` | L3 任务 | 安全扫描 |
| **Phase 6.5** | `codex` | L3 任务 | 跨模型审查 |
| **Phase 7** | `qa` | 所有任务 | 部署验证 |

### 新三层架构路由

v4.0 引入职责分层架构，映射旧技能到三层职责系统：

| 层 | 职责 | 核心文件 | 映射的旧技能 |
|:---|:-----|:---------|:------------|
| **Decision Layer** | 多角色审议、方案决策 | [architecture-review](../../../decision-layer/reviews/architecture-review.md) | `plan-ceo-review`, `plan-eng-review`, `plan-design-review`, `plan-devex-review`, `office-hours`, `brainstorming` |
| **Context Layer** | 上下文持久化、契约强制 | [project-spec](../../../context-layer/specs/project-spec.md), [hydration](../../../context-layer/hydration/hydration.md) | `context-save`, `context-restore`, `learn` |
| **Execution Layer** | 受约束实现、验证 | [implementation](../../../execution-layer/implementation.md) | `test-driven-development`, `requesting-code-review`, `verification-before-completion`, `qa` |
| **Bridges** | 层间传递 | [decision-to-context](../../../bridges/decision-to-context.md), [context-to-execution](../../../bridges/context-to-execution.md) | 新增职责 |
| **Governance** | 跨层规则强制 | [decision-freeze](../../../governance/decision-freeze.md) | `freeze`, `guard`, `careful` |

---

## 状态机与流程映射

v4.0 引入严格的状态机，确保流程不可跳步：

```
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION
    → IMPLEMENTATION → SELF_REVIEW → QA → SHIP_REVIEW → RETRO
```

| 旧 Phase | 新状态 | 层归属 | 产出物 |
|:---------|:-------|:-------|:-------|
| Phase 0.5a | DISCOVERY | Decision Layer | 需求文档（功能/非功能/边界） |
| Phase 0.5b | ARCH_REVIEW | Decision Layer | 架构设计文档 + ADR |
| Phase 0.6 | REQUIREMENT_LOCK | Decision Layer | 确认的需求清单 |
| Phase 1 | TASK_DECOMPOSITION | Decision Layer | 任务清单（含验收标准） |
| Phase 6 | IMPLEMENTATION | Execution Layer | 通过测试的代码 |
| Phase 7 (自审) | SELF_REVIEW | Execution Layer | 自审报告（对照契约） |
| Phase 4 | QA | Execution Layer | 回归测试报告 |
| Phase 7 (发布) | SHIP_REVIEW | Governance | 发布检查清单 |
| 新增 | RETRO | Governance | 复盘记录 |

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

## 三层架构文件索引

| 路径 | 内容 |
|:-----|:-----|
| [decision-layer/reviews/](../../../decision-layer/reviews/) | 多角色审议协议 |
| [context-layer/specs/](../../../context-layer/specs/) | 上下文约束契约 |
| [context-layer/hydration/](../../../context-layer/hydration/) | 注水规范 |
| [execution-layer/](../../../execution-layer/) | 执行规则 |
| [bridges/](../../../bridges/) | 层间桥接协议 |
| [governance/](../../../governance/) | 治理规则 |
| [docs/design-docs/](../../../docs/design-docs/) | 设计文档 |

---

## 异常处理

当遇到以下情况时，参考 [07-handling.md](./modules/07-handling.md)：

- 评审意见冲突 → 冲突仲裁机制
- 需要回退流程 → 回滚机制
- 方案需要变更 → 变更审批流程
- 评审发现问题 → 异常处理流程

---

## 文档索引

> **重要**: 本文档与 README.md 和 docs/ 目录下的文档保持同步更新。

| 文档 | 内容 | 路径 |
|------|------|------|
| **项目 README** | 项目概述、快速开始 | [README.md](../../../README.md) |
| **快速开始** | 安装配置、基础使用 | [docs/getting-started.md](../../../docs/getting-started.md) |
| **架构设计** | 系统设计、流程说明 | [docs/architecture.md](../../../docs/architecture.md) |
| **技能参考** | 所有技能详细说明 | [docs/skills-reference.md](../../../docs/skills-reference.md) |
| **维护更新** | 同步策略、扩展方法 | [docs/maintenance.md](../../../docs/maintenance.md) |
| **技能目录** | 技能分类说明 | [skills/README.md](../../../skills/README.md) |
| **完整分析** | 三项目对比分析 | [COMPLETE_ANALYSIS.md](../../../COMPLETE_ANALYSIS.md) |
| **三层架构设计** | AI Engineering Governance System 设计 | [docs/design-docs/002-ai-engineering-governance-system.md](../../../docs/design-docs/002-ai-engineering-governance-system.md) |
| **决策层** | 多角色架构审议协议 | [decision-layer/reviews/architecture-review.md](../../../decision-layer/reviews/architecture-review.md) |
| **上下文层** | 项目约束运行时契约 | [context-layer/specs/project-spec.md](../../../context-layer/specs/project-spec.md) |
| **桥接层** | 上下文灌入协议 | [bridges/context-to-execution.md](../../../bridges/context-to-execution.md) |
| **治理层** | 决策冻结规则 | [governance/decision-freeze.md](../../../governance/decision-freeze.md) |

### 同步更新清单

修改本 SKILL.md 时，请同步更新以下文档：

- [ ] [README.md](../../../README.md) - 项目主文档
- [ ] [docs/getting-started.md](../../../docs/getting-started.md) - 快速开始
- [ ] [docs/architecture.md](../../../docs/architecture.md) - 架构设计
- [ ] [docs/skills-reference.md](../../../docs/skills-reference.md) - 技能参考
- [ ] [skills/README.md](../../../skills/README.md) - 技能目录

---

## 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| **v4.0** | **2026-05-16** | **AI Engineering Governance System**: 从技能分类升级为职责分层系统（Decision/Context/Execution Layer + Bridges + Governance）；新增状态机（9 状态严格迁移）；新增多角色架构审议协议；新增上下文注水机制；新增决策冻结规则；修复所有悬空引用；Skill 路由表新增三层架构映射 |
| v3.7 | 2026-05-15 | **GStack 完整集成**：从 8 个扩展到 48 个 GStack 技能（含 cso、ship、office-hours、plan-ceo-review 等核心技能）；修复路由表引用错误（`/cso` → `cso`、`/ship` → `ship`）；GStack 技能按类别分组（规划/设计/QA/安全/部署/调试/文档/浏览器） |
| v3.6 | 2026-05-15 | **Task 拆解增强**：新增 Spec→Task 分解方法、5 类 Task 模板（Feature/Bugfix/Config/Refactor/Integration）、Task 依赖图（依赖/并行/阻塞）、跨切面处理机制；强化 Phase 0.5a 多子系统检测标准 |
| v3.5 | 2026-05-15 | **重大更新**：编码前流程完全集成 Superpowers，Phase 1 委托给 writing-plans（TDD五步/No Placeholders/Self-Review/Execution Handoff），保留 gs-hybrid 专属增强（风险评估/边界条件/回滚策略/Plan验证确认硬阻断） |
| v3.4 | 2026-05-15 | Phase 0.5 拆分为 0.5a(需求澄清/brainstorming) + 0.5b(Design Doc)，新增 Spec 自审查，强化渐进式提问方法 |
| v3.3 | 2026-05-15 | 模块化拆分，分类维护，按需加载 |
| v3.2 | 2026-05-14 | 强化方案审核确认环节 |
| v3.1 | 2026-05-13 | 增加 Plan验证确认环节 |
| v3.0 | 2026-05-12 | 初始版本，结合 Superpowers + GStack |

---

## 使用示例

### 示例 1: 完整开发流程

```
用户: hybrid 帮我开发用户认证功能

AI: 收到。我将按照 Superpowers + GStack Hybrid 流程执行：

Step 0: 评估任务复杂度...
[加载 02-complexity.md]
→ 评估结果: L2 (中等任务)

Phase 0.5a: 需求澄清 (brainstorming)...
[加载 03a-phase-0-06.md]
→ Announce: "使用 brainstorming 进行需求澄清"
→ 探索项目上下文
→ 渐进式提问 (目的 → 用户 → 约束 → 成功标准)
→ 方案探索 (提出 2-3 个方案)
→ 用户确认设计 → 保存 spec 文件

Phase 0.5b: Design Doc 编写...
→ Spec 自审查 + 方案调研 + 详细设计
→ 产出: docs/design-docs/001-auth.md

Phase 0.6: 方案审核确认...
→ 用户确认方案选择

Phase 1: 详细 Plan (writing-plans)...
[加载 03b-phase-1.md]
→ Scope Check + File Structure
→ Bite-Sized Tasks (2-5min/TDD五步)
→ Self-Review (spec coverage/placeholder/type consistency)
→ 产出: specs/plans/2026-05-15-auth.md

Phase 1.5: Plan验证确认...
→ 等待用户确认...

用户: 确认执行

Phase 2-3: 工程规范 + 架构评审...
[加载 04a-phase-2-3.md]
→ 评审通过

Phase 6-7: TDD 编码 + 验证交付...
[加载 05-phase-6-7.md]
→ 编码完成
→ 测试通过
→ 交付成功
```

### 示例 2: 使用专用指令

```
用户: /plan 开发支付模块

AI: 启动规划流程...
[加载 02-complexity.md + 03a-phase-0-06.md + 03b-phase-1.md]
→ 完成规划，产出 Design Doc 和 PLAN.md
```

---

**版本**: v4.0 (三层架构正式版 · AI Engineering Governance System)
**最后更新**: 2026-05-16

**详细文档请参考各模块文件。**
