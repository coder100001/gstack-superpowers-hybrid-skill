# 04a — Context Layer → Execution Layer: Context Hydration

> **Context Load**: 加载 `context-layer/specs/project-spec.md`, `context-layer/specs/architecture-spec.md`, `context-layer/specs/constraints-spec.md`, `context-layer/specs/domain-boundaries.md`, `bridges/decision-to-context.md`, `bridges/context-hydration.md`（Context Hydration 阶段）；`execution-layer/implementation.md`, `execution-layer/testing.md`, `governance/decision-freeze.md`（IMPLEMENTATION 阶段）。

## 核心概念

Context Hydration 是执行前的**强制检查阶段**，确保 Execution Layer 启动前所有必要的 Spec 契约、架构规范和历史决策已完整加载，为后续执行提供完整的上下文支撑。

### 三层架构映射

```
┌─────────────────────────────────────────────────────────┐
│ Context Layer (上下文层)                                 │
│  • Project Spec (项目规格)                               │
│  • Architecture Spec (架构规格)                          │
│  • Constraints (约束)                                    │
│  • ADR History (架构决策记录)                            │
└─────────────────────────────────────────────────────────┘
                            ↓ Hydration (注水)
┌─────────────────────────────────────────────────────────┐
│ Execution Layer (执行层)                                  │
│  • Code Generation (代码生成)                            │
│  • Implementation (实现)                                  │
│  • Testing (测试)                                        │
└─────────────────────────────────────────────────────────┘
```

---

## Context Hydration 协议

### 触发条件

| 级别 | 触发规则 |
|------|---------|
| L1 | 简化注水（P0 项即可），可在对话中隐式完成 |
| L2 | 标准注水（P0 + P1 项），产出简要 Hydration 记录 |
| L3 | 完整注水（全部项），产出正式 Hydration 报告 |

**前置条件**: TASK_DECOMPOSITION 与 PLAN_CONFIRM 已完成

### 目标

验证 Execution Layer 执行前的所有必要上下文已就绪，确保：
- 没有遗漏关键规格信息
- 架构决策已完整记录
- 约束条件已明确
- 历史决策可追溯

### Hydration 流程

```
开始 → 按级别加载对应优先级 Spec → 验证就绪 → 进入 Execution Layer
```

### 加载验证规则

**重要**: 加载 Spec 时的强制引述规则以 [context-hydration.md §4](../../../../bridges/context-hydration.md) 为唯一真相源，包括引述格式、条数要求、Token 预算机制。本文件不重复定义。

---

## Hydration 检查清单（分级制）

### P0 — 阻断项（所有级别必须）

**缺失任一项 → 禁止进入 Execution Layer**

#### 1. 加载项目 Spec (Project Specification)

- [ ] **技术栈确认**
  - 开发语言 / 框架
  - 测试命令可用
  - 构建命令可用

- [ ] **业务需求（当前任务）**
  - 验收标准（至少 1 条可量化标准）
  - 范围边界（明确不做什么）

#### 2. 加载架构 Spec（当前任务相关）

- [ ] **接口契约**
  - 输入/输出类型
  - 错误处理策略

- [ ] **模块边界**
  - 当前修改涉及哪些模块
  - 不触碰哪些模块

---

### P1 — 建议项（L2+ 建议，L3 必须）

**缺失时可记录技术债务，不阻断执行**

#### 3. 加载完整约束 (Constraints)

- [ ] **工程规范**
  - 代码风格约定
  - 命名规范

- [ ] **性能约束**
  - 算法复杂度要求
  - 资源使用限制

#### 4. 加载 ADR 历史（相关决策）

- [ ] **当前任务相关的 ADR**
  - 影响本次实现的历史决策
  - 被否决的方案及原因（如有）

---

### P2 — 优化项（仅 L3 强制）

**用于复杂任务的全面上下文加载**

#### 5. 完整架构 Spec

- [ ] **系统架构图**
- [ ] **SOLID 原则检查**
  - S - 单一职责原则
  - O - 开闭原则
  - L - 里氏替换原则
  - I - 接口隔离原则
  - D - 依赖倒置原则

#### 6. 完整 ADR 历史

- [ ] **全部决策记录**
- [ ] **技术债务清单**
- [ ] **风险评估**

---

### 验证就绪 (Readiness Verification)

| 检查项 | L1 | L2 | L3 |
|--------|:--:|:--:|:--:|
| P0 项全部通过 | ✅ | ✅ | ✅ |
| P1 项无阻断缺失 | ⚪ | ✅ | ✅ |
| P2 项全部通过 | ⚪ | ⚪ | ✅ |
| 一致性检查 | ⚪ | 🟡 | ✅ |
| 可执行性检查 | ✅ | ✅ | ✅ |

> 图例: ✅ 必须 | 🟡 建议 | ⚪ 可选

---

## Hydration 输出

### Context Hydration 报告

```markdown
# Context Hydration 报告

## 加载状态

### 项目 Spec
- [x] 项目基本信息
- [x] 业务需求
- [x] 技术需求

### 架构 Spec
- [x] 架构设计
- [x] 接口设计
- [x] SOLID 原则检查

### 约束
- [x] 工程规范
- [x] 最佳实践
- [x] 性能约束

### ADR 历史
- [x] 决策记录
- [x] 技术债务

## 就绪验证

| 检查项 | 状态 | 说明 |
|--------|------|------|
| 完整性 | ✅/⚠️/❌ | ... |
| 一致性 | ✅/⚠️/❌ | ... |
| 可执行性 | ✅/⚠️/❌ | ... |

## 缺失信息清单

- [ ] 缺失项 1: ...
- [ ] 缺失项 2: ...

## 决策

**总体状态**: ✅ 就绪 / ⚠️ 有条件就绪 / ❌ 未就绪

**下一步**:
- [ ] 进入 Execution Layer
- [ ] 需要用户补充信息
- [ ] 返回 Discovery 阶段
```

---

## Execution Layer 规则

> 执行层的编码规范遵循 SOLID 原则和通用工程最佳实践。
> 具体实现流程和红线规则见 [execution-layer/implementation.md](../../../../execution-layer/implementation.md)。

---

## 异常处理

### Hydration 失败处理

```
发现缺失信息 → 记录缺失项 → 评估影响 → 用户决策
```

### 问题分级

| 级别 | 定义 | 处理方式 |
|------|------|---------|
| **阻断性** | 必须补充，否则不能进入 Execution Layer | 立即补充 |
| **严重性** | 影响执行质量，建议补充 | 协商补充 |
| **一般性** | 可在执行中补充 | 记录待办 |
| **建议性** | 改进建议，不强制 | 可选采纳 |

### 用户决策选项

当发现缺失信息时，给用户以下选项：

1. **补充信息** - 暂停当前流程，先补充缺失信息
2. **继续但记录** - 进入 Execution Layer，但记录技术债务
3. **接受风险** - 明确接受风险，继续执行
4. **返回 Discovery** - 信息不足，需要回到 Discovery 阶段