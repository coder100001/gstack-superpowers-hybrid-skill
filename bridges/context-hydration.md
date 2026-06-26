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

## 2. 可注水资产清单

所有实现工作开始前需要加载的上下文资产：

| 资产 | 路径 | 优先级 | 更新频率 | 加载方式 |
|:-----|:-----|:-------|:---------|:---------|
| 项目约束 | `context-layer/specs/project-spec.md` | P0 | 项目级 | 首次加载后缓存 |
| 架构约束 | `context-layer/specs/architecture-spec.md` | P0 | 决策更新时 | 每次重新加载 |
| API 约束 | `context-layer/specs/api-spec.md` | P0 | 决策更新时 | 每次重新加载 |
| 测试约束 | `context-layer/specs/test-spec.md` | P0 | 决策更新时 | 每次重新加载 |
| 约束清单 | `context-layer/specs/constraints-spec.md` | P0 | 决策更新时 | 每次重新加载 |
| 领域边界 | `context-layer/specs/domain-boundaries.md` | P0 | 决策更新时 | 每次重新加载 |
| 编码标准 | `context-layer/specs/coding-standards/index.md` | P0 | 规则变更时 | 每次重新加载 |
| ADR 历史 | `decision-layer/adr/` 目录 | P0 | 决策更新时 | 仅加载活跃 ADR |
| 任务清单 | `specs/plans/tasks.md` | P1 | 任务分解时 | 每次重新加载 |
| 工作流状态 | `artifacts/workflow-state.md` | P1 | 状态变更时 | 由 `governance/lib/state-manager.sh` 统一管理 |
| 项目配置 | `project-config.yml` | P2 | 项目级 | 首次加载后缓存 |

### 优先级说明

- **P0**: 必须在进入 Execution Layer 前加载，缺失则阻断
- **P1**: 应在 Execution Layer 启动时加载，缺失不阻断但记录警告
- **P2**: 按需加载，非必需

### Token 预算机制

注水会占用上下文窗口，需按复杂度级别控制加载量：

| 级别 | 加载范围 | 预估 Token 消耗 | 策略 |
|:-----|:---------|:---------------|:-----|
| **L1** | P0 项（1-2） | ~1,500 tokens | 仅加载当前任务直接相关的 spec 条款，引述 2 条核心约束即可 |
| **L2** | P0 + P1 项（1-4） | ~3,000 tokens | 加载项目 spec + 架构 spec + 相关 ADR，每项引述 2-3 条 |
| **L3** | 全部项（1-7） | ~5,000 tokens | 完整加载，每项引述 3 条，含完整约束清单和领域边界 |

**预算超限处理**：
- 如果注水后剩余上下文不足以完成实现任务（预估 < 4,000 tokens），优先保留 P0 项，P1/P2 项改为摘要引用
- ADR 历史仅加载与当前任务相关的记录（按 ADR 标题/标签过滤），而非全量加载
- coding-standards 仅加载当前语言相关的规则子集

---

## 3. 资产格式规范

### 3.1 版本标识

每个注水资产文件必须包含版本标识：

```yaml
---
hydration:
  asset: "project-spec"
  version: "1.2.0"
  updated: "2026-05-16"
  adr_ref: "ADR-001, ADR-003"
---
```

### 3.2 变更追踪

资产文件尾部必须包含变更历史：

```markdown
---

## 变更历史

| 版本 | 日期 | 变更内容 | ADR |
|:----|:-----|:---------|:----|
| 1.0.0 | 2026-05-01 | 初始创建 | — |
| 1.1.0 | 2026-05-10 | 新增并发规则章节 | ADR-005 |
| 1.2.0 | 2026-05-16 | 新增安全约束章节 | ADR-008 |
```

### 3.3 资产发现

按以下顺序发现可用资产：

```
1. 检查 context-layer/specs/ 目录
2. 检查 decision-layer/adr/ 目录
3. 检查 artifacts/ 目录
4. 检查 specs/plans/ 目录
5. 检查 project-config.yml（根目录）
```

每个目录发现失败时记录日志但不阻断流程——仅 P0 资产的缺失会触发阻断。

---

## 4. 加载验证（强制引述）

> **单一真相源**: 引述规则的定义以本节为准。[04a-execution-hydration.md](../skills/hybrid/gs-hybrid-v3/modules/04a-execution-hydration.md) 中的引述规则引用本协议。

每加载一项后，AI **必须引述具体约束条款作为证明**，而非仅声明"已加载"：

```
✅ 已加载 project-spec.md：
  - 架构风格: "Layered Architecture + Hybrid Integration Pattern"
  - 依赖方向: "外层依赖内层，领域层独立，实现依赖抽象"
  - 禁止模式: "禁止使用 any / interface{} 作为公开 API 参数类型"
```

**引述规则**：
1. 必须使用**原文引述**（用引号包裹），而非概括性描述
2. 每个加载项至少引述 **2-3 条具体约束**（L1 可减至 2 条）
3. 引述内容必须来自实际文件，禁止编造

**错误示例**（不可接受）：
```
❌ 已加载 project-spec.md：理解了项目约束
❌ 已加载 project-spec.md：架构风格正确，依赖方向清晰
```

**正确示例**（必须遵循）：
```
✅ 已加载 project-spec.md：
  - 架构风格: "Layered Architecture + Hybrid Integration Pattern"
  - 模块组织: "按功能域（Domain-oriented）组织"
  - 禁止模式: "禁止基础设施层依赖业务层"
```

如果有任何一项加载失败（文件不存在、路径错误），必须暂停并报告。

---

## 5. 注水确认模板

注水完成后，AI 必须明确声明：

```
✅ Context Hydration Complete

已加载：
  - project-spec.md: [版本号，必填]
  - architecture-spec.md: [版本号，必填]
  - api-spec.md: [版本号，必填]
  - test-spec.md: [版本号，必填]
  - ADR history: [N 条活跃记录]
  - active constraints: [N 条活跃约束]
  - domain-boundaries.md: [版本号，必填]
  - coding-standards/index.md: [版本/规则数量]
  - workflow state: [当前状态]

理解确认：
  - 架构范围: [简述当前架构约束]
  - 领域边界: [简述不可越界的域]
  - 决策冻结: [列举当前冻结项]

状态就绪，可以进入 Execution Layer。
```

---

## 6. 缓存策略

| 资产 | 缓存策略 | 失效条件 |
|:-----|:---------|:---------|
| project-spec | 全局缓存（session 级） | ADR 更新、用户手动刷新 |
| architecture-spec | 每次刷新 | — |
| domain-boundaries | 每次刷新 | — |
| ADR 历史 | 缓存索引，按需加载具体 ADR | 新 ADR 创建 |
| 任务清单 | 每次刷新 | — |

---

## 7. 重新注水触发条件

以下情况必须重新执行注水：

| 触发条件 | 原因 | 操作 |
|:---------|:-----|:-----|
| Session restart | 上下文全部丢失 | 完整注水 |
| Decision Layer 产出新 ADR | 上下文契约变更 | 增量注水（仅加载变更项） |
| Context Layer 契约更新 | 约束条件变化 | 增量注水 |
| 切换到不同子系统 | 领域上下文不同 | 完整注水（加载新域契约） |
| 超过 15 条消息未引用契约 | 上下文漂移风险 | 检查并增量注水 |

---

## 8. 违规处理

如果检测到未完成注水就进入了实现阶段：

```
⚠️ Context Hydration Violation Detected

当前状态: [IMPLEMENTATION / CODING]
缺少的注水项: [缺失项列表]

立即暂停实现，执行注水。
已完成代码需对照契约重新审查。
```

---

## 9. 示例

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

## 10. 与现有技能的集成

本协议与以下技能协作：

- **Superpowers TDD**: 执行层首步骤（红）前必须完成注水
- **Superpowers verification-before-completion**: 交付前检查注水是否被执行
- **GStack context-restore/context-save**: 作为契约的持久化/加载后端
- **gs-hybrid-v3 TASK_DECOMPOSITION**: Plan 确认检查注水是否列为前置条件

---

**关联文件**: [decision-to-context](decision-to-context.md) · [decision-freeze](../governance/decision-freeze.md) · [04a-execution-hydration.md](../skills/hybrid/gs-hybrid-v3/modules/04a-execution-hydration.md)