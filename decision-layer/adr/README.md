# ADR Index

> **层**: Decision Layer · **职责**: 架构决策记录索引
> **更新条件**: 每次架构审议产生新 ADR 时更新

---

## 活跃 ADR

| ADR | 标题 | 日期 | 状态 | 影响范围 |
|:----|:-----|:-----|:-----|:---------|
| ADR-001 | 初始三层架构设计 | 2025-11-22 | ✅ 活跃 | 全项目 |
| ADR-002 | 拒绝单体技能架构 | 2025-11-22 | ✅ 活跃 | skills/ |
| ADR-003 | Superpowers + GStack 混合集成 | 2025-11-22 | ✅ 活跃 | 技能体系 |
| ADR-004 | 面向领域组织架构 | 2025-11-22 | ✅ 活跃 | 全项目目录结构 |
| ADR-005 | 渐进式加载策略 | 2026-01-19 | ✅ 活跃 | context-layer |
| ADR-006 | 灵活工作流路由 (L1/L2/L3) | 2026-01-19 | ✅ 活跃 | 全流程 |
| ADR-007 | 上下文水合协议 | 2026-01-19 | ✅ 活跃 | context-layer, bridges |
| ADR-008 | 领域边界正式定义 | 2026-05-16 | ✅ 活跃 | context-layer/specs/domain-boundaries.md |

---

## ADR 存储说明

每个 ADR 的完整内容存放于 `decision-layer/adr/ADR-NNN-title.md`。此文件为索引，方便快速查找和状态追踪。

ADR 的完整生命周期：创建 → 审议 → 批准/否决 → 实施 → 回滚（如需要）

---

**关联文件**: [architecture-review](../reviews/architecture-review.md) · [decision-to-context](../../bridges/decision-to-context.md) · [decision-freeze](../../governance/decision-freeze.md)