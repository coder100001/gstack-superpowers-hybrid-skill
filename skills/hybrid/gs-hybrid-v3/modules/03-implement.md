# 03 — IMPLEMENT: 上下文注水 + 编码实现 + 决策冻结

> 加载时机: PLAN→IMPLEMENT 跃迁后。入口先注水，注水完成后开始编码。

## 上下文注水（IMPLEMENT 入口硬阻断）

进入编码前，必须加载以下契约文件:

- `context-layer/specs/project-spec.md` — 项目约束
- `context-layer/specs/architecture-spec.md` — 架构约束
- `context-layer/specs/constraints-spec.md` — 编码约束
- `context-layer/specs/domain-boundaries.md` — 领域边界
- `decision-layer/adr/` — 活跃 ADR 历史
- `governance/decision-freeze.md` — 冻结协议

L1 可简化（只加载 project-spec + 当前功能相关约束）。L0 跳过注水。

## TDD 编码原则

1. 先写测试，再写实现（Iron Law）
2. 一次只让一个测试通过
3. 不写不通过测试就不会运行的代码
4. 重构前先确保测试全绿
5. L1 可写 test after（非强制 TDD），L2+ 强制 TDD

### 可用技能

- `test-driven-development` — TDD 全流程
- `dispatching-parallel-agents` — 并行独立子任务
- `subagent-driven-development` — 计划内独立任务
- `using-git-worktrees` — 需要隔离时

## 决策冻结（IMPLEMENT 持续约束）

IMPLEMENT 期间以下内容被冻结，不得自行修改:

| 冻结项 | 违反示例 |
|--------|---------|
| 架构决策 | 实现时觉得模块位置不合理自行移动 |
| 需求范围 | 实现时觉得"顺便加个功能" |
| API 契约 | 实现时修改参数签名"方便前端" |
| 领域边界 | 从 A 域直接操作 B 域数据库 |

需要修改冻结项 → 暂停实现 → 退回 DEFINE/PLAN → 重新确认。

### 决策冻结例外

以下不需要走变更流程: 拼写修正、局部变量重命名、测试补充、日志级别调整。commit message 标注 `[freeze-exception]`。

详见 `governance/decision-freeze.md`。
