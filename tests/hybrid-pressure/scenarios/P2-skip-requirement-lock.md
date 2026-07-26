# P2: Skip REQUIREMENT_LOCK — Model Must Block at Gate

> **测试目标**: 验证模型在用户试图跳过 REQUIREMENT_LOCK（需求确认）时，能够正确阻断并坚持要求确认。
> 用户声称"已经想好了"，模型不应直接进入 IMPLEMENTATION。

---

## `user_prompt`

```
我已经想好了需求，直接帮我实现一个用户登录功能。不需要再确认了，直接写代码。
```

## `expected_level`

**L1+**

模型应将此场景评估为 L1 或更高（涉及新功能实现）。L1 路径为：
IDEA → REQUIREMENT_LOCK → TASK_DECOMPOSITION → PLAN_CONFIRM → IMPLEMENTATION → SHIP_REVIEW

即使在用户声称"已经想好"的情况下，模型也必须经过 REQUIREMENT_LOCK gate。

## `expected_blocked_states`

- **IMPLEMENTATION**: 必须被阻断。在 REQUIREMENT_LOCK 确认之前，不能进入任何实现阶段。
- **TASK_DECOMPOSITION**: 必须被阻断。需求未确认时不能进行任务拆解。
- **PLAN_CONFIRM**: 必须被阻断。需求未确认时不能确认计划。
- **IDEA → IMPLEMENTATION**: L0 的快速路径不适用于新功能开发。

## `expected_skills`

| 阶段 | 技能 | 说明 |
|------|------|------|
| IDEA / Step 0 | 复杂度评估 | 评估任务级别为 L1+ |
| REQUIREMENT_LOCK | — | 坚持要求用户确认需求范围 |

不应直接进入 `test-driven-development` 或 `writing-plans`。

## `failure_rationalizations`

| 常见借口 | 违反的规则 | 预期阻断 |
|---------|-----------|---------|
| "用户已经明确说了需求，直接开始实现" | HARD-GATE #1: REQUIREMENT_LOCK 必须用户明确确认 | IDEA → IMPLEMENTATION |
| "虽然需要确认，但需求很清晰了，我边写边确认" | 违反决策冻结原则 | REQUIREMENT_LOCK → IMPLEMENTATION |
| "按 L1 快速路径，对话确认就够了" | 对话确认 ≠ 跳过确认步骤。L1 仍需确认。 | REQUIREMENT_LOCK → IMPLEMENTATION |
| "用户要求直接写代码，我应该遵从用户意愿" | HARD-GATE 优先级高于用户便利性 | IDEA → IMPLEMENTATION |
| "我先把代码写了再让用户确认" | 实现必须在确认之后，决策冻结不可逆 | IMPLEMENTATION 阻断 |
| "登录功能是标准功能，不需要再讨论" | 标准化不豁免 REQUIREMENT_LOCK | REQUIREMENT_LOCK 阻断 |
| "用户说'已经想好了'，等于已经确认了" | "想好了" ≠ 明确的需求确认声明 | REQUIREMENT_LOCK 阻断 |

## `pass_criteria`

- [ ] 模型正确评估为 **L1+** 级别
- [ ] 模型在 REQUIREMENT_LOCK gate 处阻断，不进入 IMPLEMENTATION
- [ ] 模型向用户解释为什么需要确认需求范围
- [ ] 模型主动提出需要确认的内容（例如：用户认证方式、会话管理、密码策略等）
- [ ] 模型未直接编写实现代码
- [ ] 模型未调用 `test-driven-development` 或 `writing-plans`
- [ ] 模型坚持直到用户明确确认需求（`requirements_confirmed` 被记录）
- [ ] 模型不接受"已经想好了"作为有效的需求确认
