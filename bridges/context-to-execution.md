# Context Hydration Protocol

> **层**: Bridges · **方向**: Context Layer → Execution Layer
> **触发条件**: 任何实现工作开始前、session restart 后
> **强制规则**: 注水完成前禁止进入 Execution Layer

---

## 1. 目的

Context Hydration（上下文注水）是连接 Context Layer 和 Execution Layer 的强制性桥接协议。

当 AI 收到实现任务时，其上下文窗口是一个空白状态。如果不显式加载上下文契约，AI 将依赖自身训练数据的通用知识而非项目特定的约束做决策，这正是 "context drift"（上下文漂移）的根源。

**本协议强制：在执行任何实现工作前，必须完成上下文加载和确认。**

---

## 2. 注水清单

在执行前强制加载以下上下文：

```
Required Loading Order:

1. project-spec.md          ← 项目全局约束（最高优先级）
2. architecture-spec.md     ← 架构决策约束
3. current ADR history      ← 活跃的架构决策记录
4. active constraints       ← 当前活跃的约束清单
5. domain-boundaries.md     ← 领域边界定义
6. current workflow state   ← 当前工作流位置与产出物
```

### 加载验证

每加载一项后，AI 必须确认理解：

```
"已加载 [project-spec.md]：
  - 架构风格: [确认内容]
  - 依赖方向: [确认内容]
  - 禁止模式: [确认内容]"
```

如果有任何一项加载失败（文件不存在、路径错误），必须暂停并报告。

---

## 3. 注水确认模板

注水完成后，AI 必须明确声明：

```
✅ Context Hydration Complete

已加载：
  - project-spec.md: [版本/哈希]
  - architecture-spec.md: [版本/哈希]
  - ADR history: [N 条活跃记录]
  - active constraints: [N 条活跃约束]
  - domain-boundaries.md: [版本/哈希]
  - workflow state: [当前状态]

理解确认：
  - 架构范围: [简述当前架构约束]
  - 领域边界: [简述不可越界的域]
  - 决策冻结: [列举当前冻结项]

状态就绪，可以进入 Execution Layer。
```

---

## 4. 重新注水触发条件

以下情况必须重新执行注水：

| 触发条件 | 原因 | 操作 |
|:---------|:-----|:-----|
| Session restart | 上下文全部丢失 | 完整注水 |
| Decision Layer 产出新 ADR | 上下文契约变更 | 增量注水（仅加载变更项） |
| Context Layer 契约更新 | 约束条件变化 | 增量注水 |
| 切换到不同子系统 | 领域上下文不同 | 完整注水（加载新域契约） |
| 超过 [N] 条消息未引用契约 | 上下文漂移风险 | 检查并增量注水 |

---

## 5. 违规处理

如果检测到未完成注水就进入了实现阶段：

```
⚠️ Context Hydration Violation Detected

当前状态: [IMPLEMENTATION / CODING]
缺少的注水项: [缺失项列表]

立即暂停实现，执行注水。
已完成代码需对照契约重新审查。
```

---

## 6. 示例

### 正确流程

```
用户: 帮我添加用户注册功能

AI: 在执行之前，我先完成上下文注水。

✅ 加载 project-spec.md：
  - 架构：Clean Architecture，依赖方向从外到内
  - API：RESTful，版本化前缀 /v1/
  - 禁止：跳过领域层直接操作数据库

✅ 加载 architecture-spec.md：
  - 认证模块使用 JWT，用户模型在 identity 域
  - 注册流程：Controller → Service → Repository

✅ 加载 ADR 历史：
  - ADR-001: 使用 PostgreSQL 作为主存储
  - ADR-003: 密码哈希使用 bcrypt

✅ Context Hydration Complete.

架构范围: 用户注册属于 identity domain
领域边界: identity 不依赖 order/payment 域
决策冻结: 数据库选型、密码方案已冻结

状态就绪，进入 Execution Layer。
```

### 违规示例

```
用户: 帮我添加用户注册功能

AI: 我直接开始编码...

❌ 违规：未完成上下文注水即开始实现
   违反规则：Context Hydration Protocol
```

---

## 7. 与现有技能的集成

本协议与以下技能协作：

- **Superpowers TDD**: 执行层首步骤（红）前必须完成注水
- **Superpowers verification-before-completion**: 交付前检查注水是否被执行
- **GStack context-restore/context-save**: 作为契约的持久化/加载后端
- **gs-hybrid-v3 Phase 1.5**: Plan 确认检查注水是否列为前置条件

---

**关联文件**: [decision-to-context](../bridges/decision-to-context.md) · [hydration spec](../context-layer/hydration/hydration.md) · [governance](../governance/decision-freeze.md)