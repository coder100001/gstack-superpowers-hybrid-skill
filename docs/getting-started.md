
# 快速开始指南

> 本指南帮助您在 5 分钟内开始使用 AI Engineering Governance System v4.1。

## 目录

1. [安装](#安装)
2. [配置](#配置)
3. [使用](#使用)
4. [治理脚本](#治理脚本)
5. [常见问题](#常见问题)

---

## 安装

### 前提条件

- macOS / Linux / Windows (WSL)
- Git
- Bash / Zsh
- Python 3 (可选，用于 YAML→JSON 转换)

### 安装步骤

#### 1. 克隆项目

```bash
git clone <repo-url>
cd gstack-superpowers-hybrid-skill
```

#### 2. 添加执行权限

```bash
chmod +x scripts/*.sh governance/*.sh governance/gates/*.sh
```

#### 3. 安装到本地

```bash
./scripts/install.sh install --force
```

安装目录: `~/.trae-cn/superpowers/`

#### 4. 验证安装

```bash
# 验证状态机
./scripts/validate-state-machine.sh
# 输出: SM:0 (0错误, 0警告)

# 验证技能路由
./scripts/check-skill-routes.sh
# 输出: ROUTE:0 (0错误)

# 验证 YAML→JSON 同步
./scripts/yaml2json.sh --check
# 输出: YAML2JSON:0 错误
```

---

## 配置

### 项目配置

**配置加载优先级**: 自动发现 > 显式配置 > 默认模板。

详细配置规则请参考 [SKILL.md - 项目配置章节](../skills/hybrid/gs-hybrid-v3/modules/01-intro.md)。

#### 自动发现规则

进入 Step 0（复杂度评估）时，AI 按以下顺序尝试自动发现项目配置：

| 配置项 | 发现路径 | 示例 |
|--------|---------|------|
| **language** | `package.json` → `go.mod` → `pyproject.toml` → `Cargo.toml` | `"TypeScript"`, `"Go"`, `"Python"` |
| **test_command** | `package.json` scripts.test → `Makefile` test → 语言默认 | `"npm test"`, `"go test ./..."` |
| **lint_command** | `package.json` scripts.lint → `.github/workflows` → 语言默认 | `"eslint ."`, `"golangci-lint run"` |
| **security_scanner** | 语言推断 | `"npm audit"`, `"gosec ./..."` |

**自动发现成功** → 记录到上下文，继续流程  
**自动发现失败** → 提示用户提供，不阻断但记录为技术债务

#### 显式配置（自动发现失败时使用）

在项目根目录创建 `.trae/rules/project_rules.md`：

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

#### 快速配置参考

**Go**: `go test ./... -race` / `golangci-lint run` / `gosec ./...`  
**Python**: `pytest` / `ruff check .` / `bandit -r src/`  
**Node.js**: `npm test` / `eslint .` / `npm audit`

---

## 使用

### 核心概念：三层架构

```
Decision Layer (决策层)
  ├─ 产品视角：业务价值、用户影响
  ├─ 架构视角：模块划分、依赖方向
  ├─ 性能视角：吞吐、延迟、瓶颈
  ├─ 安全视角：信任边界、数据暴露
  └─ 运维视角：部署、回滚、监控

Context Layer (上下文层)
  ├─ 项目规范：架构风格、依赖方向、禁止模式
  ├─ 领域边界：各域职责、隔离规则
  ├─ 约束规则：事务、并发、命名、安全
  └─ ADR：架构决策记录

Execution Layer (执行层)
  ├─ Context Hydration（强制前置）
  ├─ TDD 编码实现
  └─ 自审 + QA 验证
```

### 状态机流程 (13 状态)

```
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION 
    → PLAN_CONFIRM → CONTEXT_HYDRATION → IMPLEMENTATION → SELF_REVIEW 
    → QA → SHIP_REVIEW → RETRO
                                       
(任意状态) → ABORTED (异常终止)
```

### Gate 检查点 (7 个)

| Gate | 状态 | 检查内容 |
|------|------|---------|
| G001 requirement-lock | REQUIREMENT_LOCK | 用户确认需求 |
| G002 arch-review-lock | ARCH_REVIEW | L2+ 有 ADR |
| G003 task-decomposition-lock | TASK_DECOMPOSITION | plan 存在且无占位符 |
| G004 plan-confirm | PLAN_CONFIRM | 用户确认执行计划 |
| G005 context-hydration | CONTEXT_HYDRATION | Spec 文件存在 |
| G006 decision-freeze | IMPLEMENTATION | 冻结项未修改 |
| G007 test-presence | SELF_REVIEW | 测试文件存在 |

### 复杂度分级响应

| 级别 | 判定标准 | 简化规则 |
|------|---------|---------|
| **L1（小修复）** | 文件<3, 代码<100行 | DISCOVERY + REQUIREMENT_LOCK 合并为单次确认；可跳过 ARCH_REVIEW；不产出独立 ADR |
| **L2（新功能/中等重构）** | 文件3-8, 代码100-500行 | ARCH_REVIEW 启用 2 维度审议（Product + Architect）；QA 可选 |
| **L3（跨系统/安全敏感）** | 文件>8, 代码>500行 | 全流程；ARCH_REVIEW 全 5 维度；QA 强制（gstack:qa）；RETRO 强制 |

> 详细分级规则请参考 [SKILL.md - 复杂度评估章节](../skills/hybrid/gs-hybrid-v3/modules/02-complexity.md)

### 专用指令

| 指令 | 功能 | 使用场景 |
|------|------|---------|
| `/plan` | 规划流程 | 新功能开发前的完整规划 |
| `/review` | 代码审查 | 代码完成后的质量审查 |
| `/test` | 测试驱动 | TDD 开发流程 |
| `/qa` | 质量保证 | 功能完成后的验证 |
| `/debug` | 调试助手 | 问题诊断与修复 |
| `/refactor` | 重构建议 | 代码改进与优化 |

---

## 治理脚本

### 状态机校验

```bash
./scripts/validate-state-machine.sh
```

检查项：
1. 状态唯一性 (13 状态)
2. 转换引用合法性 (19 转换)
3. 必需状态存在
4. 状态可达性
5. YAML/JSON 一致性

### Gate 检查

```bash
./governance/check-gates.sh --to REQUIREMENT_LOCK --level L3
```

参数：
- `--from`: 起始状态
- `--to`: 目标状态
- `--level`: 复杂度级别 (L1/L2/L3)

### 技能路由健康检查

```bash
./scripts/check-skill-routes.sh
```

检查项：
- 技能目录扫描 (33 技能)
- SKILL.md 路由引用提取 (37 引用)
- 一致性检查

### YAML→JSON 同步

```bash
# 检查一致性
./scripts/yaml2json.sh --check

# 自动生成
./scripts/yaml2json.sh
```

确保 `governance/machine.json` 和 `governance/gates.json` 始终与 YAML 真相源同步。

---

## 常见问题

### Q1: 如何查看当前技能版本？

```bash
cat .upstream-versions.json
```

### Q2: 如何更新上游技能？

```bash
./scripts/sync-upstream.sh
```

### Q3: 如何自定义技能？

在 `skills/custom/` 目录创建自定义技能：

```
skills/custom/
└── my-custom-skill/
    └── SKILL.md
```

### Q4: 安装出现问题如何回滚？

```bash
# 查看备份
ls ~/.trae-cn/superpowers-backups/

# 恢复备份
cp -r ~/.trae-cn/superpowers-backups/backup_YYYYMMDD_HHMMSS/* ~/.trae-cn/superpowers/
```

### Q5: 如何扩展 gs-hybrid-v3？

**方法 1**: 在 `skills/custom/` 创建扩展版本

```
skills/custom/
└── gs-hybrid-v3-extended/
    └── SKILL.md
```

**方法 2**: 修改 `skills/hybrid/gs-hybrid-v3/modules/` 下的模块

### Q6: 为什么 REQUIREMENT_LOCK 和 ARCH_REVIEW 需要确认？

这是决策冻结机制，确保：
- 用户对方案有充分理解
- 避免 AI 擅自决定重要事项
- 减少返工和方向错误

**L1 快速通道**: 简单任务可将需求确认与 Plan 确认合并为单次对话。

### Q7: 什么是 Context Hydration？

Context Hydration 是执行层的强制前置步骤：
1. 加载所有项目规范、架构契约、领域边界
2. 加载所有 ADR 和历史决策
3. 明确当前状态和约束
4. 确认理解后才允许进入编码

**分级规则**: L1 仅需 P0 阻断项（技术栈 + 验收标准），L2+ 需完整加载。

### Q8: GStack 技能何时激活？

GStack 技能不是默认加载，而是满足条件时显式调用：
- 代码涉及用户输入 → 调用 `gstack:cso`
- L3 任务 → 调用 `gstack:qa`
- 性能敏感任务 → 调用 `gstack:benchmark`
- 发布/部署 → 调用 `gstack:ship`

详细路由请参考 [skill-routes.yaml](../schema/skill-routes.yaml)。

### Q9: 真相源文件有哪些？

| 文件 | 用途 |
|------|------|
| `governance/state-machine.yaml` | 状态机定义 |
| `governance/gates.yaml` | Gate 定义 |
| `schema/skill-routes.yaml` | 技能路由 |

JSON 文件 (`machine.json`, `gates.json`) 是运行时格式，由 `yaml2json.sh` 自动生成，不应手动编辑。

---

## 文档索引

| 文档 | 内容 | 路径 |
|:-----|:-----|:-----|
| **主入口** | gs-hybrid-v3 v4.1 完整流程 | [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md) |
| **架构设计** | 三层架构详细设计 | [architecture.md](./architecture.md) |
| **技能参考** | 所有技能列表 | [skills-reference.md](./skills-reference.md) |
| **维护更新** | 同步策略 | [MAINTENANCE.md](../MAINTENANCE.md) |

> **文档维护规则**: 本文档为索引层，所有详细内容指向 SKILL.md。禁止在本文档中重复定义与 SKILL.md 冲突的内容。
