# Hydration Specification

> **层**: Context Layer · **职责**: 定义可注水的上下文资产及加载方式
> **生命周期**: 项目级别，与 Context Layer 契约同步更新

---

## 1. 可注水资产清单

所有实现工作开始前需要加载的上下文资产：

| 资产 | 路径 | 优先级 | 更新频率 | 加载方式 |
|:-----|:-----|:-------|:---------|:---------|
| 项目约束 | `context-layer/specs/project-spec.md` | P0 | 项目级 | 首次加载后缓存 |
| 架构约束 | `context-layer/specs/architecture-spec.md` | P0 | 决策更新时 | 每次重新加载 |
| 约束清单 | `context-layer/specs/constraints-spec.md` | P0 | 决策更新时 | 每次重新加载 |
| 领域边界 | `context-layer/specs/domain-boundaries.md` | P0 | 决策更新时 | 每次重新加载 |
| 编码标准 | `context-layer/specs/coding-standards/index.md` | P0 | 规则变更时 | 每次重新加载 |
| ADR 历史 | `context-layer/adr/` 目录 | P0 | 决策更新时 | 仅加载活跃 ADR |
| 任务清单 | `specs/plans/tasks.md` | P1 | 任务分解时 | 每次重新加载 |
| 工作流状态 | `artifacts/workflow-state.md` | P1 | 状态变更时 | 每次重新加载 |
| 项目配置 | `project-config.yml` | P2 | 项目级 | 首次加载后缓存 |

### 优先级说明

- **P0**: 必须在进入 Execution Layer 前加载，缺失则阻断
- **P1**: 应在 Execution Layer 启动时加载，缺失不阻断但记录警告
- **P2**: 按需加载，非必需

---

## 2. 资产格式规范

### 2.1 版本标识

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

### 2.2 变更追踪

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

---

## 3. 缓存策略

为了优化性能，加载的上下文资产可以根据以下策略缓存：

| 资产 | 缓存策略 | 失效条件 |
|:-----|:---------|:---------|
| project-spec | 全局缓存（session 级） | ADR 更新、用户手动刷新 |
| architecture-spec | 每次刷新 | — |
| domain-boundaries | 每次刷新 | — |
| ADR 历史 | 缓存索引，按需加载具体 ADR | 新 ADR 创建 |
| 任务清单 | 每次刷新 | — |

---

## 4. 资产发现

注水系统按以下顺序发现可用资产：

```
1. 检查 context-layer/specs/ 目录
2. 检查 context-layer/adr/ 目录
3. 检查 artifacts/ 目录
4. 检查 specs/plans/ 目录
5. 检查 project-config.yml（根目录）
```

每个目录发现失败时记录日志但不阻断流程——仅 P0 资产的缺失会触发阻断。

---

**关联文件**: [context-hydration protocol](../bridges/context-to-execution.md) · [project-spec](../specs/project-spec.md)