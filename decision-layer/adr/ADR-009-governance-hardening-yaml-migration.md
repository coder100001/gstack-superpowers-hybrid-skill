# ADR-009: Governance Hardening - YAML Truth Source Migration

> **状态**: Approved
> **日期**: 2026-05-25
> **复杂度**: L3

---

## 背景

当前 `gs-hybrid-v3` 已具备完整状态机、Hard Gate、技能路由和冻结机制，但关键规则仍以文档约束为主，存在"可读但不可强校验"的执行落差。

现有治理资产：
- `governance/machine.json` - 状态机定义（JSON 格式）
- `governance/gates.json` - Gate 定义（JSON 格式）
- `governance/transition.sh` - 状态跃迁脚本
- `governance/gates/*.sh` - 6 个 Gate 脚本
- `schema/skill-routes.yaml` - 技能路由表

## 决策

将 P0 规则转成可执行资产，采用 YAML 作为真相源：

1. **状态机真相源统一**: 创建 `governance/state-machine.yaml` + `scripts/validate-state-machine.sh`
2. **Hard Gate 可执行化**: 创建 `governance/gates.yaml` + `governance/check-gates.sh`
3. **技能路由健康检查**: 创建 `scripts/check-skill-routes.sh` + `docs/route-health.md`

**迁移策略**: 保留现有 JSON 文件作为备份，新增 YAML 作为真相源。

## 被否决方案

| 方案 | 否决理由 |
|------|---------|
| 直接删除 JSON，仅保留 YAML | 迁移风险高，需要过渡期验证 |
| 不做格式迁移，仅增强校验 | 格式不一致（JSON vs YAML）增加维护成本 |
| 使用数据库存储状态机 | 过度工程化，增加依赖 |

## 风险与缓解

| 风险 | 等级 | 缓解措施 |
|------|------|---------|
| YAML 与 JSON 语义不一致 | Minor | 校验脚本对比两份文件 |
| Gate 过严阻断正常流程 | Minor | severity 分级 + L1 豁免 |
| 路由检查误报 | Minor | alias 映射 + error/warning 分离 |

## 回滚策略

1. 删除新增的 YAML 文件和脚本
2. 恢复以 `machine.json` 和 `gates.json` 为真相源
3. 保留失败样例，进入下一轮修复

## 审议结论

- **决策**: Approved
- **批准条件**: 无
- **风险登记**: 3 个 Minor 级别风险，已有缓解措施
- **未解决争议**: 无

---

**关联**: [ADR-001](ADR-001-initial-architecture-framework.md) · [ADR-007](ADR-007-context-hydration-protocol.md)
