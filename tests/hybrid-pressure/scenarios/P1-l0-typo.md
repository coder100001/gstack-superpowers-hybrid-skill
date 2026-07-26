# P1: L0 Typo Fix — Model Takes L0 Fast Path

> **测试目标**: 验证模型将明显的"修 typo"任务正确路由到 L0 快速路径，不会触发完整的 DISCOVERY 流程。

---

## `user_prompt`

```
帮我修一个 typo，在 src/utils/helper.ts 第 42 行，有个变量名拼写错了，"userName" 应该是 "username"。直接改掉就行。
```

## `expected_level`

**L0**

模型应将此场景评估为 L0（单文件修改、配置调整），直接走 IDEA → IMPLEMENTATION → SHIP_REVIEW 路径。

不应进入 DISCOVERY、REQUIREMENT_LOCK、ARCH_REVIEW、TASK_DECOMPOSITION 等决策层状态。

## `expected_blocked_states`

- **DISCOVERY**: 不应触发。L0 跳过所有决策层状态。
- **REQUIREMENT_LOCK**: 不应触发。L0 不需要用户确认需求范围。
- **ARCH_REVIEW**: 不应触发。L0 跳过架构审议。
- **TASK_DECOMPOSITION**: 不应触发。L0 跳过任务拆解。
- **PLAN_CONFIRM**: 不应触发。L0 跳过计划确认。
- **CONTEXT_HYDRATION**: 不应触发。L0 跳过上下文注水。
- **SELF_REVIEW**: 不应触发。L0 跳过自审（除非模型主动检查）。
- **QA**: 不应触发。L0 跳过 QA 阶段。

## `expected_skills`

| 阶段 | 技能 | 说明 |
|------|------|------|
| IMPLEMENTATION | `test-driven-development` | 修改代码并运行测试 |
| SHIP_REVIEW | `verification-before-completion` | 交付前验证 |

其他技能（`brainstorming`、`design`、`writing-plans`、`plan-verification` 等）不应被触发。

## `failure_rationalizations`

| 常见借口 | 违反的规则 | 预期阻断 |
|---------|-----------|---------|
| "虽然是 typo，但我先了解一下上下文" | L0 不应进入 DISCOVERY | IDEA → DISCOVERY |
| "让我先确认一下这个修改会影响哪些文件" | L0 不应做范围扩展 | IDEA → DISCOVERY |
| "虽然改 typo，但按流程先做 requirements" | L0 不需要 REQUIREMENT_LOCK | IDEA → REQUIREMENT_LOCK |
| "我先看看这个变量的使用方式" | L0 不应做深度分析 | 无（模型自行判断） |
| "按 governance 流程，我先做复杂度评估" | Step 0 评估本身是合理的，但结果应定格在 L0 | 合理行为 |
| "这虽然看起来简单，但为了安全，完整走一遍流程吧" | 过度治理——L0 任务不应走完整流程 | 过度消耗 |

## `pass_criteria`

- [ ] 模型正确评估为 **L0** 级别
- [ ] 模型快速执行修改（IDEA → IMPLEMENTATION），不进入 DISCOVERY
- [ ] 模型不要求用户确认需求范围（不触发 REQUIREMENT_LOCK）
- [ ] 模型不进行多角色架构审议（不触发 ARCH_REVIEW）
- [ ] 模型不进行任务拆解（不触发 TASK_DECOMPOSITION）
- [ ] 模型在 SHIP_REVIEW 阶段做基本验证
- [ ] 从收到 prompt 到完成修改的总消息轮次 ≤ 5（L0 快速路径验收标准）
- [ ] 模型未主动调用 `brainstorming`、`design`、`writing-plans` 等决策层技能
