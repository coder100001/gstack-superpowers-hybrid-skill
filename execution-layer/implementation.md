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

## 5. SDD 文件化交接（v5.0）

当使用 `subagent-driven-development` 执行 plan 时，任务上下文和审查通过文件传递，而非 prompt 嵌入：

### 5.1 Task Brief（任务文本文件化）

Controller 调用脚本将 plan 中单个 task 的完整文本提取到文件：

```bash
skills/superpowers/subagent-driven-development/scripts/task-brief PLAN_FILE TASK_NUMBER
```

产出：`.superpowers/sdd/task-<N>-brief.md`

Implementer subagent 通过一次 `Read` 调用获取完整 task 上下文，避免 prompt 嵌入导致的 token 浪费和截断。

### 5.2 Review Package（审查 diff 文件化）

实现完成后，controller 调用脚本生成审查包：

```bash
skills/superpowers/subagent-driven-development/scripts/review-package BASE HEAD
```

产出：`.superpowers/sdd/review-<base7>..<head7>.diff`

包含 commit 列表、文件变更统计和完整 diff（-U10 上下文）。Reviewer subagent 通过一次 `Read` 调用获取完整审查材料。

### 5.3 SDD Workspace

所有 SDD 临时文件存放在 `.superpowers/sdd/`，由 `sdd-workspace` 脚本管理。该目录通过 `.gitignore` 自动忽略，不会进入 `git status` 或意外提交。

```
.superpowers/sdd/
├── .gitignore          # 自动忽略所有文件
├── task-1-brief.md     # Task 1 的完整文本
├── task-2-brief.md     # Task 2 的完整文本
├── review-abc1234..def5678.diff  # 审查包
└── progress.md         # Progress Ledger（见 §6）
```

### 5.4 与执行层的关系

- **Task Brief** 替代了 prompt 中嵌入的 task 描述 → implementer 更准确、更少遗漏
- **Review Package** 替代了 prompt 中嵌入的 diff → reviewer 看到完整变更
- **Controller 禁止干预**：不能压制 reviewer 发现或预评级严重程度

---

## 6. Progress Ledger（v5.0）

长任务执行过程中，controller 维护进度账本到 `.superpowers/sdd/progress.md`：

```markdown
# Progress Ledger

## Task Status
| Task | Status | Verdict | Notes |
|------|--------|---------|-------|
| Task 1 | ✅ done | PASS | spec: PASS, quality: PASS |
| Task 2 | ✅ done | PASS (fixed) | initial FAIL → fix → re-review PASS |
| Task 3 | 🔄 in progress | — | implementer running |
| Task 4 | ⏳ pending | — | blocked on Task 3 |

## Key Decisions
- Task 2: reviewer flagged missing error handling → fixed in commit def5678
```

**用途**：
- 断点恢复：session 中断后重新进入时，controller 可通过读取 `progress.md` 恢复进度
- 进度可见：用户可随时查看当前执行状态
- 审计追踪：记录每个 task 的审查 verdict 和修复历史

---

## 7. 与 Superpowers TDD 的关系

本协议与 Superpowers 的 [test-driven-development](../skills/superpowers/test-driven-development/SKILL.md) 技能协作：

- 本协议定义 **执行规则的边界**（什么可以做、什么不可以做）
- TDD 技能定义 **执行过程的方法**（如何写测试、如何重构）

**本协议优先级高于 TDD 技能的具体指导**——如果 TDD 技能的建议与本协议的约束冲突，以本协议为准。

---

**关联文件**: [testing.md](./testing.md) · [review.md](./review.md) · [validation.md](./validation.md) · [context-hydration](../bridges/context-hydration.md) · [subagent-driven-development](../skills/superpowers/subagent-driven-development/SKILL.md)