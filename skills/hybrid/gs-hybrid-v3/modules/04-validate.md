# 04 — VALIDATE: 自审 + QA + 异常处理

> 加载时机: IMPLEMENT→VALIDATE 跃迁后。

## 自审（SELF_REVIEW）

### 按级别策略

| 级别 | 审查方式 |
|------|---------|
| L1 | inline checklist（30s, 合并到 SHIP 阶段） |
| L2 | inline checklist + requesting-code-review（可选） |
| L3 | inline + gstack:codex（跨模型审查） |

### 最小检查清单（所有级别）

- [ ] 实现与 spec/plan 一致，无范围蔓延
- [ ] 无 TODO/FIXME/XXX 占位符
- [ ] 命名/注释无歧义
- [ ] 冻结项未触碰（架构/需求/API/领域边界）
- [ ] 测试存在且通过

### 安全扫描触发条件

| 条件 | 动作 |
|------|------|
| 涉及用户输入 | gstack:cso 输入验证扫描 |
| 涉及认证/授权 | gstack:cso 身份权限扫描 |
| 涉及密钥/密码 | gstack:cso 敏感信息扫描 |
| L3 无条件 | gstack:cso 完整安全扫描 |

代码规则审查委托 `execution-layer/review.md`。

## QA

L2 可选，L3 强制。调用 `gstack:qa` 执行。

QA 验证范围:
- 验证自审报告完整性
- 运行完整测试套件
- 验证测试覆盖率达标
- 验证边界条件覆盖
- 安全扫描结果合规
- 无严重/高危 Bug

## 变更流程（决策冻结期间）

IMPLEMENT 期间如需要修改冻结项:

```
记录变更请求 → 暂停实现 → 退回 PLAN → 更新 ADR + spec → 重新注水 → 恢复实现
```

禁止路径: "我先改再告诉你"、"改动很小不需要走流程"、"用户口头同意了"。
详见 `governance/decision-freeze.md`。

## 异常处理

### 调试子流程

遇到 Bug 时不跳过治理流程。调试遵循:

1. `systematic-debugging` 负责根因调查（复现 → 证据 → 假设 → 验证）
2. `gstack:investigate` 负责治理增强（证据记录、冻结项检查、回退判断）
3. 根因锁定前不得进入修复

```
问题进入 → systematic-debugging Phase 1-3 → RCA 证据锁定
  → 检查是否触碰冻结项
  → 最小修复计划
  → 修复 + 验证原问题 + 回归测试
  → VALIDATE 或退回 PLAN
```

RCA 必须包含: 实际现象、期望行为、复现步骤、根因、修复计划。

### 失败重试规则

| 失败次数 | 动作 |
|---------|------|
| 第 1-2 次 | 回到 IMPLEMENT，补证据后修复重试 |
| 第 3 次 | 暂停实现，判断是否为架构/计划问题 |
| 根因涉及 ADR/需求/API/领域边界 | 退回 PLAN |
| 仅实现细节错误 | 回到 IMPLEMENT 最小修复 |

### 状态回退

| 当前 | 可回退到 | 条件 |
|------|---------|------|
| VALIDATE | IMPLEMENT | 自审/Qa 发现问题 |
| IMPLEMENT | PLAN | 决策冻结需要变更 |
| PLAN | DEFINE | 需求重新澄清 |
| 任意 | 重新开始 | 用户取消/不可恢复错误 |

### 回退流程

记录回退原因 → 清理当前状态 → 恢复目标状态 → 通知用户。

设置 `workflow-state.md` 中的栅栏锁: `rollback_reason`, `rollback_from`, `rollback_to`。

### 中止条件

- 用户明确要求取消
- 不可恢复的系统错误
- 多次重试仍无法通过关键 gate

中止后保存已完成产物（ADR、spec、plan），可从 ABORTED 回到 DEFINE 重新开始。

## 自审报告输出模板

```
## 自审结论
- 测试充分性: ✅/⚠️/❌
- 安全性: ✅/⚠️/❌
- 建议补充: ...
```
