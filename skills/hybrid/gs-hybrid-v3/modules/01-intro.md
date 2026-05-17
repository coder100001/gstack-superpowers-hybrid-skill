# 01 — 三层架构核心概念、项目配置

> **Context Load**: 初始加载，无需框架文件。本模块提供项目约束配置和基础概念。

## 快速开始

### 启动指令

| 指令 | 流程 | 说明 |
|------|------|------|
| `/plan` 或 `hybrid plan` | 规划流程 | IDEA → TASK_DECOMPOSITION |
| `/review` 或 `hybrid review` | 自审/代码审查 | SELF_REVIEW 流程 |
| `/test` 或 `hybrid test` | 测试驱动 | 进入 IMPLEMENTATION（确保 Context Hydration） |
| `/qa` 或 `hybrid qa` | 质量保证 | QA 阶段验证 |
| `/debug` 或 `hybrid debug` | 调试助手 | 问题诊断与修复 |
| `/refactor` 或 `hybrid refactor` | 重构建议 | 约束内代码改进 |

### 标准工作流

```
用户: "hybrid 帮我开发用户认证功能"

AI: 收到。我将按照 AI Engineering Governance System v4.0 执行：

Step 0:     评估任务复杂度 (L1/L2/L3)

◆ DECISION LAYER (决策层)
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION
      需求澄清      用户必须确认      多角色审议      任务拆解

◆ CONTEXT LAYER (上下文层)
Context Hydration (强制) — 加载所有 Spec 契约

◆ EXECUTION LAYER (执行层)
IMPLEMENTATION → SELF_REVIEW → QA → SHIP_REVIEW → RETRO
TDD编码      自审对照    QA验证     发布检查    复盘记录
```

<HARD-GATE>
在用户确认需求、确认执行计划、完成上下文注水之前，不要进入下一阶段。这适用于 L2/L3 所有任务。
</HARD-GATE>

---

## 项目配置

> **配置加载优先级**: 自动发现 > 显式配置 > 默认模板
> 若自动发现失败且未提供显式配置，流程将阻断并提示补充。

### 配置自动发现规则

进入 Step 0（复杂度评估）时，AI 必须按以下顺序尝试自动发现项目配置：

| 配置项 | 发现路径 | 示例 |
|--------|---------|------|
| **language** | `package.json` → `go.mod` → `pyproject.toml` → `Cargo.toml` | `"TypeScript"`, `"Go"`, `"Python"` |
| **test_command** | `package.json` scripts.test → `Makefile` test → 语言默认 | `"npm test"`, `"go test ./..."` |
| **lint_command** | `package.json` scripts.lint → `.github/workflows` → 语言默认 | `"eslint ."`, `"golangci-lint run"` |
| **security_scanner** | 语言推断 | `"npm audit"`, `"gosec ./..."` |

**自动发现成功** → 记录到上下文，继续流程  
**自动发现失败** → 提示用户提供，不阻断但记录为技术债务

### 显式配置模板（自动发现失败时使用）

```yaml
project:
  name: "your-project-name"
  language: "Go 1.21+"
  framework: "Gin"

testing:
  test_command: "go test ./... -race"
  coverage_command: "go test ./... -coverprofile=coverage.out"

quality:
  lint_command: "golangci-lint run"

security:
  scanner: "gosec ./..."

concurrency:
  model: "goroutine"
```

### 快速配置参考

**Go**: `go test ./... -race` / `golangci-lint run` / `gosec ./...`  
**Python**: `pytest` / `ruff check .` / `bandit -r src/`  
**Node.js**: `npm test` / `eslint .` / `npm audit`

---

## 三层架构核心概念

| 概念 | 定义 |
|------|------|
| **Decision Layer (决策层)** | 负责想清楚做什么：需求发散、多角色审议、ADR 决策 |
| **Context Layer (上下文层)** | 负责固化共识：Spec 契约、约束、边界，防止上下文漂移 |
| **Execution Layer (执行层)** | 负责受约束实现：TDD 编码、自审、验证，**不能做设计决策** |
| **Context Hydration (上下文注水)** | 进入执行层前必须加载所有 Spec，确保执行是在约束内完成 |
| **Decision Freeze (决策冻结)** | 执行期间架构/需求/契约不可自行更改，必须走 Decision Layer 变更流程 |
| **ADR (Architecture Decision Record)** | 架构决策记录，存储在 `docs/design-docs/` 目录 |
| **Spec Contract (Spec 契约)** | 上下文层的项目/架构/约束/边界文档，是执行的唯一真相来源 |
| **5 个决策维度** | 产品、架构、性能、安全、运维，多角色审议的独立视角 |

---

## Skill 路由表（向后兼容）

### 三层架构路由

| 层 | 核心文件 | 映射的原技能 |
|----|---------|-------------|
| Decision Layer | [architecture-review.md](../../../decision-layer/reviews/architecture-review.md) | `plan-ceo-review`, `plan-eng-review`, `brainstorming`, `design` |
| Context Layer | [context-to-execution.md](../../../bridges/context-to-execution.md), [project-spec.md](../../../context-layer/specs/project-spec.md) | `context-save`, `context-restore` |
| Execution Layer | [implementation.md](../../../execution-layer/implementation.md) | `test-driven-development`, `requesting-code-review`, `verification-before-completion`, `qa` |
| Bridges | [decision-to-context.md](../../../bridges/decision-to-context.md) | 新增职责 |
| Governance | [decision-freeze.md](../../../governance/decision-freeze.md) | 新增职责 |

### 原技能保留参考

| 原阶段 | 新状态 | 用途 |
|-------|-------|------|
| Phase 0.5a | DISCOVERY | 需求澄清 (brainstorming) |
| Phase 0.5b | ARCH_REVIEW | 架构审议 (architecture-review) |
| Phase 0.6 | REQUIREMENT_LOCK | 需求确认 |
| Phase 1 | TASK_DECOMPOSITION | 任务拆解 (writing-plans) |
| Phase 1.5 | TASK_DECOMPOSITION 确认 | 用户确认执行计划 |
| Phase 2-3 | ARCH_REVIEW 已包含 | 架构评审已合并到多角色审议 |
| Phase 4-5 | QA | QA 验证 (GStack qa) |
| Phase 6 | IMPLEMENTATION | TDD 编码 (test-driven-development) |
| Phase 7 | SELF_REVIEW/SHIP_REVIEW | 自审、发布检查 |

---

## 模块文件索引

| 模块 | 内容 |
|------|------|
| [02-complexity.md](./02-complexity.md) | 复杂度分级、适用矩阵 |
| [03a-discovery-arch.md](./03a-discovery-arch.md) | IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW |
| [03b-task-decomposition.md](./03b-task-decomposition.md) | TASK_DECOMPOSITION |
| [04a-execution-hydration.md](./04a-execution-hydration.md) | Context Hydration → IMPLEMENTATION |
| [04b-self-review.md](./04b-self-review.md) | SELF_REVIEW → QA |
| [05-ship-review-retro.md](./05-ship-review-retro.md) | SHIP_REVIEW → RETRO |
| [06-workflows.md](./06-workflows.md) | 专用流程指令 |
| [07-handling.md](./07-handling.md) | 异常处理、变更流程 |
