# 01 - 快速开始、项目配置、核心概念

## 快速开始

### 启动指令

| 指令 | 流程 | 说明 |
|------|------|------|
| `/plan` 或 `hybrid plan` | 规划流程 | 新功能开发前的完整规划 |
| `/review` 或 `hybrid review` | 代码审查 | 代码完成后的质量审查 |
| `/test` 或 `hybrid test` | 测试驱动 | TDD 开发流程 |
| `/ship` 或 `hybrid ship` | 发布准备 | 提交前的最终检查 |
| `/qa` 或 `hybrid qa` | 质量保证 | 功能完成后的验证 |
| `/debug` 或 `hybrid debug` | 调试助手 | 问题诊断与修复 |
| `/refactor` 或 `hybrid refactor` | 重构建议 | 代码改进与优化 |

### 标准工作流

```
用户: "hybrid 帮我开发新功能"

AI: 收到。我将按照 Superpowers + GStack Hybrid 流程执行：

Step 0:     评估任务复杂度 (L1/L2/L3)
Phase 0.5a: 需求澄清 (brainstorming - 渐进式提问 → spec 文件)
Phase 0.5b: Design Doc 编写 (方案对比/设计决策存档)
Phase 0.6:  方案审核确认 (用户必须确认方案选择)
             ↓ 用户确认方案
Phase 1:    结构化 Plan (writing-plans — Spec→Task 分解/5类模板/依赖图/No Placeholders)
Phase 1.5:  Plan验证确认 (用户必须确认执行)
             ↓ 用户确认执行
Phase 2:    工程规范设计
Phase 3:    架构师评审
Phase 4:    QA 评审 (L3)
Phase 5:    CSO 安全评审 (L3)
Phase 6:    TDD 编码实现
Phase 7:    验证交付
```

<HARD-GATE>
在用户确认方案、审查 PLAN 之前，不要进入下一阶段。这适用于所有任务，无论看起来多简单。
</HARD-GATE>

---

## 项目配置

**使用本 Skill 前，必须根据当前项目填充以下配置。** 所有 `{{KEY}}` 占位符将替换为下方对应值。若配置缺失，流程将阻断并提示补充。

### 通用配置模板

```yaml
# ============================================================
# 项目基础配置
# ============================================================
project:
  name: "your-project-name"
  language: "Go 1.21+"  # 或 "Python 3.11+", "TypeScript 5.0+"
  framework: "Gin"      # 或 "Django", "React", etc.

# ============================================================
# 测试配置
# ============================================================
testing:
  test_command: "go test ./... -race"
  coverage_command: "go test ./... -coverprofile=coverage.out"
  bench_command: "go test -bench=. -benchmem ./..."

# ============================================================
# 代码质量
# ============================================================
quality:
  lint_command: "golangci-lint run"
  code_review_guide: "https://github.com/golang/go/wiki/CodeReviewComments"

# ============================================================
# 安全扫描
# ============================================================
security:
  scanner: "gosec ./..."
  secret_patterns:
    - "password\\s*=\\s*[\"'][^\"']*[\"']"
    - "api_key\\s*=\\s*[\"'][^\"']*[\"']"
  injection_patterns:
    - "fmt\\.Sprintf.*%s.*query"
    - "exec\\.Command.*input"

# ============================================================
# 并发模型 (用于泄漏检查)
# ============================================================
concurrency:
  model: "goroutine"  # 或 "asyncio", "thread"
```

### 快速配置示例

**Go 项目**:
```yaml
language: "Go 1.21+"
test_command: "go test ./... -race"
coverage_command: "go test ./... -coverprofile=coverage.out"
bench_command: "go test -bench=. -benchmem ./..."
lint_command: "golangci-lint run"
security_scanner: "gosec ./..."
concurrency_model: "goroutine"
```

**Python 项目**:
```yaml
language: "Python 3.11+"
test_command: "pytest --cov=src tests/"
coverage_command: "pytest --cov-report=xml --cov=src tests/"
bench_command: "pytest --benchmark-only tests/"
lint_command: "ruff check . && black --check ."
security_scanner: "bandit -r src/"
concurrency_model: "asyncio"
```

**Node.js/TypeScript 项目**:
```yaml
language: "TypeScript 5.0+"
test_command: "npm test"
coverage_command: "npm run test:coverage"
bench_command: "npm run benchmark"
lint_command: "eslint . --ext .ts,.tsx"
security_scanner: "npm audit"
concurrency_model: "promise"
```

---

## 核心概念定义

| 概念 | 定义 |
|-----|------|
| **Design Doc** | 编号设计文档，存储在 `docs/design-docs/` 目录，记录重大功能/改动的调研、设计决策和演进理由 |
| **方案审核确认** | 在 Design Doc 完成后、Plan 创建前，AI 必须展示多个可选方案对比，由用户确认选择哪个方案 |
| **Plan验证确认** | 在 Plan 完成后、编码开始前，AI 必须进行范围、风险、验收标准的验证，由用户确认开始执行 |
| **变更文件数** | 新增、修改、删除的文件总数（不含自动生成文件） |
| **新增代码行** | 不含空行和注释的净增代码行数 |
| **架构影响** | 涉及模块间接口、数据流、部署方式的变更 |
| **风险等级** | 低：仅影响非核心功能；中：影响核心功能但可回滚；高：涉及数据迁移或不可逆变更 |
| **接口变更** | 对已有公共 API 的签名、参数、返回值的修改 |
| **依赖变更** | 新增或替换项目依赖管理器中的外部依赖 |

---

## Skill 路由表（按需加载）

> **核心理念**: 不同阶段加载不同的 skill，避免一次性加载所有 skill 消耗上下文。

### Superpowers Skills 路由

| 阶段 | Skill | 触发条件 | 用途 |
|------|-------|---------|------|
| **Phase 0.5a** | `brainstorming` | L2+ 任务 | 需求澄清、渐进式提问、方案探索、spec 文件 |
| **Phase 0.5b** | `design` | L2+ 任务 | Design Doc 编写 (方案对比/设计决策存档) |
| **Phase 1** | `writing-plans` | 所有任务 | 结构化 Plan (Spec→Task分解/5类模板/依赖图) |
| **Phase 1.5** | `plan-verification` | 所有任务 | Plan 验证确认 (范围/拆解/风险/验收硬阻断) |
| **Phase 2** | `requesting-code-review` | L2+ 任务 | 代码规范审查 |
| **Phase 3** | `requesting-code-review` | L3 任务 | 架构评审 |
| **Phase 6** | `test-driven-development` | 所有任务 | TDD 编码 |
| **Phase 7** | `verification-before-completion` | 所有任务 | 验证交付 |

### GStack Skills 路由

| 阶段 | Skill | 触发条件 | 用途 |
|------|-------|---------|------|
| **Phase 2.5** | `/design-review` | 涉及前端 | 前端视觉审查 |
| **Phase 4** | `/qa` | L3 任务 | QA 测试、功能验证 |
| **Phase 5** | `/cso` | L3 任务 | 安全扫描 |
| **Phase 7** | `/qa` | 所有任务 | 部署验证 |
| **Phase 7** | `/ship` | L3 任务 | 发布准备 |

---

## 模块文件索引

按需加载参考以下模块：

| 模块 | 内容 |
|------|------|
| [02-complexity.md](./02-complexity.md) | 复杂度分级、适用矩阵 |
| [03a-phase-0-06.md](./03a-phase-0-06.md) | Step 0 + Phase 0.5 + 0.6 |
| [03b-phase-1.md](./03b-phase-1.md) | Phase 1 逻辑规划 |
| [04a-phase-2-3.md](./04a-phase-2-3.md) | Phase 2-3 工程规范 |
| [04b-phase-4-5.md](./04b-phase-4-5.md) | Phase 4-5 QA/安全评审 |
| [05-phase-6-7.md](./05-phase-6-7.md) | Phase 6-7 编码验证 |
| [06-workflows.md](./06-workflows.md) | 专用流程指令 |
| [07-handling.md](./07-handling.md) | 异常处理机制 |
