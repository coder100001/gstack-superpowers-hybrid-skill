# Implementation Rules

> **层**: Execution Layer · **职责**: 受约束实现
> **前置条件**: 上下文注水完成（见 bridges/context-hydration.md）
> **禁止**: 重新设计架构、修改领域边界、忽略约束规则、跳过测试

---

## 1. 角色定位

Execution Layer 不再负责"想清楚做什么"——那是 Decision Layer 的职责。
Execution Layer 只负责一件事：**严格遵循上下文契约，高质量地完成实现和测试。**

```
Execution Layer is a disciplined executor, not a designer.
```

---

## 2. 必须输入

| 输入 | 来源 | 用途 |
|:-----|:-----|:-----|
| 架构决策 | ADR 记录 | 指导模块组织和代码结构 |
| 项目约束 | project-spec | 约束代码风格和设计模式 |
| 任务分解 | tasks.md | 定义实现范围和验收标准 |
| 上下文契约 | context-layer/specs/ | 提供所有边界和规则 |

---

## 3. 实现流程

### 3.1 标准流程（TDD）

```
Step 1: 上下文注水验证
  └─ 确认所有上下文契约已加载（调用 hydration protocol）

Step 2: 测试先写（Red）
  └─ 基于验收标准写失败测试
  └─ 一次只聚焦一个任务

Step 3: 最简实现（Green）
  └─ 用最少的代码让测试通过
  └─ 不允许"顺便重构"

Step 4: 契约内重构（Refactor）
  └─ 在约束范围内优化代码质量
  └─ 重构后测试仍通过

Step 5: 自审（Self-Review）
  └─ 对照上下文契约逐条检查
  └─ 确认没有违反任何约束
```

### 3.2 快速路径（L1 任务）

```
Step 1: 上下文注水验证
Step 2: 直接实现 + 测试
Step 3: 自审
```

---

## 4. 红线

### 4.1 禁止行为
- 重新设计架构（这是 Decision Layer 的职责）
- 修改领域边界（这是 Context Layer 的契约）
- 忽略或绕过约束规则
- 跳过任何测试步骤
- 引入未经批准的依赖

### 4.2 必须行为
- 所有公开 API 必须有单元测试覆盖
- 所有错误路径必须有对应的测试用例
- 所有配置必须通过配置系统读入（禁止硬编码）
- 所有修改必须通过 lint 和类型检查

---

## 5. 与 Superpowers TDD 的关系

本协议与 Superpowers 的 [test-driven-development](../skills/superpowers/test-driven-development/SKILL.md) 技能协作：

- 本协议定义 **执行规则的边界**（什么可以做、什么不可以做）
- TDD 技能定义 **执行过程的方法**（如何写测试、如何重构）

**本协议优先级高于 TDD 技能的具体指导**——如果 TDD 技能的建议与本协议的约束冲突，以本协议为准。

---

**关联文件**: [testing.md](./testing.md) · [review.md](./review.md) · [validation.md](./validation.md) · [context-hydration](../bridges/context-hydration.md)