# AI Engineering Governance System

> **设计文档编号**: 002
> **状态**: 已批准 (2026-05-16)
> **复杂度**: L2
> **设计者**: Human + AI

---

## 1. 背景与动机

当前 gs-hybrid-v3 v3.7 的问题：

1. **决策与执行混合**：Superpowers 和 GStack 的技能按来源组织而非按职责组织，导致"思考"和"实现"在同一技能中混杂。
2. **缺少 Decision Artifact**：讨论完直接跳 coding，缺少正式的决策记录→上下文固化→执行的传递链。
3. **角色扮演而非决策维度**：GStack 的评审技能以"角色 persona"而非"决策维度"运作，导致评审深度不足。
4. **无上下文注水机制**：session restart 后所有上下文丢失，没有强制加载契约的协议。

## 2. 核心架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                    AI Engineering Governance System                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐        │
│  │  Decision     │ ──→ │   Context     │ ──→ │  Execution    │        │
│  │  Layer        │     │   Layer       │     │  Layer        │        │
│  │               │     │               │     │               │        │
│  │  Multi-role   │     │  Spec Contract│     │  TDD          │        │
│  │  Deliberation │     │  ADR          │     │  Verification │        │
│  │  Tradeoff     │     │  Constraints  │     │  Self-Review  │        │
│  └──────┬───────┘     └──────┬───────┘     └──────┬───────┘        │
│         │                    │                     │                  │
│         └──────────┬─────────┴──────────┬──────────┘                  │
│                    │                     │                            │
│               ┌────▼────┐          ┌────▼────┐                       │
│               │ Bridges  │          │Governance│                      │
│               │ decision │          │ decision │                      │
│               │ →context │          │ freeze   │                      │
│               │ context  │          │ state    │                      │
│               │ →exec    │          │ machine  │                      │
│               └─────────┘          └─────────┘                       │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

## 3. 三层职责定义

### 3.1 Decision Layer

**职责**：多角色审议、方案决策、tradeoff 分析

**触发条件**：
- L2+ 任务自动触发
- L1 任务涉及边界模糊时触发
- 用户明确要求评审时触发

**角色（决策维度）**：
| 角色 | 决策维度 | 审议重点 |
|------|---------|---------|
| Product Reviewer | 业务价值 | 用户影响、范围合理性、ROI |
| System Architect | 架构 | 模块划分、依赖方向、技术选型 |
| Performance Reviewer | 性能 | 吞吐、延迟、缓存、瓶颈 |
| Security Reviewer | 安全 | 信任边界、数据暴露、权限 |
| Operations Reviewer | 运维 | 部署、回滚、监控、迁移成本 |

**输出工件**：
- 批准的方案
- 被否决的替代方案及理由
- 识别的风险与缓解策略
- 回滚策略

### 3.2 Context Layer

**职责**：上下文持久化、Spec 契约、边界强制

**核心契约**：
| 契约 | 内容 | 强制范围 |
|------|------|---------|
| 项目规范 | 架构风格、依赖方向、禁止模式 | 全局 |
| 领域边界 | 各域职责、隔离规则 | 模块级 |
| 约束规则 | 事务、并发、命名、安全 | 实现级 |
| ADR | 架构决策记录 | 全局 |

**上下文注水协议**：
在执行任何实现工作前，必须加载：
1. 项目规范（project-spec）
2. 架构规范（architecture-spec）
3. 活跃决策（current ADRs）
4. 活跃约束（active constraints）

注水完成前禁止进入执行层。

### 3.3 Execution Layer

**职责**：受约束实现、测试、验证

**强制流程**：
1. 上下文注水（读取所有 spec）
2. 测试失败（TDD 红）
3. 最简实现（TDD 绿）
4. 约束内重构
5. 契约对照自审

**红线**：
- 禁止重新设计架构
- 禁止修改领域边界
- 禁止忽略约束规则
- 禁止跳过测试

## 4. 状态机

```
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION
    → IMPLEMENTATION → SELF_REVIEW → QA → SHIP_REVIEW → RETRO
```

| 状态 | 职责 | 产出物 |
|------|------|--------|
| DISCOVERY | 需求发现 | 需求文档（功能/非功能/边界） |
| REQUIREMENT_LOCK | 需求锁定 | 确认的需求清单 |
| ARCH_REVIEW | 架构审议 | 架构设计文档 + ADR |
| TASK_DECOMPOSITION | 任务拆分 | 任务清单（含验收标准） |
| IMPLEMENTATION | 实现 | 通过测试的代码 |
| SELF_REVIEW | 自审 | 自审报告（对照契约） |
| QA | 质量验证 | 回归测试报告 |
| SHIP_REVIEW | 发布审议 | 发布检查清单 |
| RETRO | 复盘 | 复盘记录 |

## 5. 旧技能映射

| 新层 | 来源 | 映射技能 |
|:----|:-----|:---------|
| Decision Layer | GStack（主） | `plan-ceo-review`, `plan-eng-review`, `plan-design-review`, `plan-devex-review`, `office-hours`, `design-shotgun`, `cso` |
| Decision Layer | Superpowers（辅） | `brainstorming`（需求发散阶段） |
| Context Layer | GStack（主） | `context-save`, `context-restore`, `learn`, `document-generate` |
| Execution Layer | Superpowers（主） | `test-driven-development`, `requesting-code-review`, `verification-before-completion`, `systematic-debugging` |
| Execution Layer | GStack（辅） | `qa`, `review` |

## 6. 复杂度分级

| 级别 | 适用场景 | 必须阶段 | 可跳过 |
|:----|:---------|:---------|:-------|
| L1 | 小修复、变量重命名、文档修正 | IMPLEMENTATION → SELF_REVIEW | DISCOVERY → ARCH_REVIEW |
| L2 | 新功能、中等重构 | DISCOVERY → ARCH_REVIEW → TASK_DECOMPOSITION → IMPLEMENTATION → SELF_REVIEW | QA → RETRO |
| L3 | 跨系统、安全敏感、架构变更 | 全流程（含多角色审议、QA、RETRO） | 无 |

## 7. 治理规则

### 7.1 决策冻结
进入 IMPLEMENTATION 后以下内容冻结：
- 架构决策
- 需求范围
- API 契约
- 领域边界

变更冻结项必须：
1. 退回决策层重新审议
2. 更新上下文契约
3. 重新上下文注水
4. 评估对已有实现的影响

### 7.2 核心原则
1. 思考与实现严格分离
2. 所有决策必须有记录和理由
3. 上下文契约是唯一真相来源
4. 执行时不允许偏离契约
5. 变更必须走正式流程，不可绕过

---

**关联文档**：PLAN.md (`specs/plans/2026-05-16-three-layer-architecture-restructure.md`)