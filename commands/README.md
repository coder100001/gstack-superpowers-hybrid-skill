# 专用指令参考

> 本目录为向后兼容保留的指令映射。所有功能入口为 [gs-hybrid-v3](../skills/hybrid/gs-hybrid-v3/SKILL.md)。

## 快捷指令

| 指令 | 功能 | 触发阶段 | 命令文件 |
|------|------|---------|---------|
| `/plan` | 规划流程 | 新功能开发前 | — |
| `/brainstorm` | 头脑风暴 | DISCOVERY | [brainstorm.md](./brainstorm.md) |
| `/write-plan` | 编写计划 | TASK_DECOMPOSITION | [write-plan.md](./write-plan.md) |
| `/execute-plan` | 执行计划 | IMPLEMENTATION | [execute-plan.md](./execute-plan.md) |
| `/review` | 代码审查 | SELF_REVIEW | — |
| `/test` | 测试驱动 | IMPLEMENTATION | — |
| `/qa` | 质量保证 | QA | — |
| `/debug` | 调试助手 | 异常处理 | — |
| `/refactor` | 重构建议 | 任何阶段 | — |

> **注意**: 标记 `—` 的指令由 SKILL.md 路由表直接映射到对应技能，无需独立命令文件。