# 05 — SHIP: 发布检查 + 复盘

> 加载时机: VALIDATE→SHIP 跃迁后。

## 发布检查（SHIP_REVIEW）

VALIDATE→SHIP 跃迁前提: **验证证据存在**（测试通过报告、审查记录等可复现证据）。

### 检查清单

- [ ] 所有测试通过（输出保存在 `artifacts/verification/`）
- [ ] 自审报告完成（L2+）
- [ ] QA 通过（L3）
- [ ] spec/plan/ADR 与最终实现一致
- [ ] CHANGELOG 已更新
- [ ] 无未确认的技术债务
- [ ] commit message 合规

### 可用技能

- `verification-before-completion` — 证据优先验证
- `gstack:ship` — 发布检查清单 + PR 创建

## 复盘（RETRO）

仅 L3 强制。产出复盘记录:

### 复盘要点

- 流程回顾（各级决策质量、执行效率）
- 数据（需求澄清率、评审通过率、返工率）
- 做得好的 + 需要改进的 + 改进措施
- 流程优化建议

### 复盘模板

```
## 流程回顾
- DEFINE: ...
- PLAN: ...
- IMPLEMENT: ...
- VALIDATE: ...
- SHIP: ...

## 做得好的 / 需要改进的
1. ...

## 改进措施
1. ... (时间: ...)
```
