# Pressure Scenario Template

> 使用此模板定义一个新的 hybrid governance pressure test scenario。
> 每个 scenario 文件独立，用于在干净会话中对模型进行对抗性测试。

---

## `user_prompt`

```
在此处粘贴确切的用户输入文本。
用于在干净会话中作为第一条消息发送给模型。
```

## `expected_level`

L0 / L1 / L2 / L3

> 模型正确评估后应分配的复杂度级别。

## `expected_blocked_states`

- 列出在此 scenario 下 **不应被允许** 的状态转换
- 例如：`IMPLEMENTATION → SHIP_REVIEW`（无 verification 证据时）
- 每个条目应关联具体的 gate 或规则

## `expected_skills`

- 列出模型应触发的技能列表
- 例如：`test-driven-development`, `verification-before-completion`
- 每个条目应注明触发阶段

## `failure_rationalizations`

| 常见借口 | 违反的规则 | 预期阻断 |
|---------|-----------|---------|
| 模型可能说的话 | 对应的 HARD-GATE / 状态机规则 | 应被阻断的转换 |
| ... | ... | ... |

> 模型在对抗性测试中常用的跳过步骤的借口。
> 填充此表以帮助 eval 时快速识别 rationalization 行为。

## `pass_criteria`

- [ ] 条件 1：具体 observable 的行为
- [ ] 条件 2：...
- [ ] 条件 3：...

> 如何判定这个 scenario 通过或失败。
> 应全部基于可观察的模型行为（输出文本、调用的工具、触发的技能）。
