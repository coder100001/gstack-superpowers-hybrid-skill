
# 快速开始指南

&gt; 本指南帮助您在 5 分钟内开始使用 AI Engineering Governance System v4.0。

## 目录

1. [安装](#安装)
2. [配置](#配置)
3. [使用](#使用)
4. [常见问题](#常见问题)

---

## 安装

### 前提条件

- macOS / Linux / Windows (WSL)
- Git
- Bash / Zsh

### 安装步骤

#### 1. 克隆项目

```bash
git clone &lt;repo-url&gt;
cd gstack--superpowers--hybrid-skill
```

#### 2. 添加执行权限

```bash
chmod +x scripts/*.sh
```

#### 3. 同步上游技能

```bash
# 同步所有上游更新
./scripts/sync-upstream.sh

# 验证安装
ls skills/superpowers/  # 应该看到 14 个技能
ls skills/gstack/       # 应该看到 16 个技能
ls skills/hybrid/       # 应该看到 gs-hybrid-v3
```

#### 4. 验证工具脚本

```bash
ls gstack-skills/bin/ | wc -l  # 应该显示 53+
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

### 完整开发流程

```bash
# 启动完整流程
hybrid 帮我开发用户认证功能
```

AI 将执行：
1. **IDEA**: 评估任务复杂度 (L1/L2/L3)
2. **DISCOVERY**: 需求澄清（brainstorming）
3. **REQUIREMENT_LOCK**: 需求锁定（🔴 强制确认）
4. **ARCH_REVIEW**: 多角色架构审议（L2+）
5. **TASK_DECOMPOSITION**: 任务拆分
6. **Context Hydration**: 上下文契约注入
7. **IMPLEMENTATION**: TDD 编码实现
8. **SELF_REVIEW**: 自审（对照契约）
9. **QA**: 质量验证（L3 强制，调用 gstack:qa）
10. **SHIP_REVIEW**: 交付审查
11. **RETRO**: 复盘记录（L3 强制）

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

### 使用示例

#### 示例 1: 规划新功能

```
用户: /plan 开发用户认证模块

AI: 收到。启动规划流程...

IDEA: 评估复杂度...
→ 评估结果: L2 (中等任务)

DISCOVERY: 需求澄清（brainstorming）...
→ 产出：初版需求文档

REQUIREMENT_LOCK: 需求锁定确认...
→ 展示需求范围
→ 等待用户确认...

用户: 确认需求范围

ARCH_REVIEW: 多角色架构审议...
→ 产品视角：业务价值评估
→ 架构视角：模块划分
→ 性能视角：吞吐量预估
→ 安全视角：信任边界
→ 运维视角：部署方案
→ 产出：架构设计文档 + ADR

TASK_DECOMPOSITION: 任务拆分...
→ 产出：tasks.md

上下文注水：加载契约...

执行层开始...
```

#### 示例 2: 代码审查

```
用户: /review 请审查这段代码

AI: 收到。启动代码审查...

上下文注水：加载契约...

代码审查...
→ 对照架构规范
→ 检查领域边界
→ 验证约束遵循
→ 检查测试覆盖

审查完成！
→ 生成审查报告
```

#### 示例 3: 调试问题

```
用户: /debug 这个 API 返回 500 错误

AI: 收到。启动调试助手...

问题理解...
→ 分析错误现象

信息收集...
→ 查看日志
→ 检查配置

根因分析...
→ 定位问题原因

方案制定...
→ 提出修复方案

修复验证...
→ 应用修复
→ 验证解决

调试完成！
```

---

## 常见问题

### Q1: 如何查看当前技能版本？

```bash
cat .upstream-versions.json
```

### Q2: 如何更新上游技能？

```bash
# 同步所有
./scripts/sync-upstream.sh

# 仅同步 superpowers
./scripts/sync-upstream.sh --superpowers

# 仅同步 gstack
./scripts/sync-upstream.sh --gstack
```

### Q3: 如何自定义技能？

在 `skills/custom/` 目录创建自定义技能：

```
skills/custom/
└── my-custom-skill/
    └── SKILL.md
```

### Q4: 同步出现问题如何回滚？

```bash
# 回滚到上一个备份
./scripts/sync-upstream.sh --rollback
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

详细路由请参考 [SKILL.md - 技能路由表](../skills/hybrid/gs-hybrid-v3/SKILL.md)。

---

## 文档索引

| 文档 | 内容 | 路径 |
|:-----|:-----|:-----|
| **主入口** | gs-hybrid-v3 v4.0 完整流程 | [SKILL.md](../skills/hybrid/gs-hybrid-v3/SKILL.md) |
| **架构设计** | 三层架构详细设计 | [architecture.md](./architecture.md) |
| **技能参考** | 所有技能列表（自动生成） | [skills-reference.md](./skills-reference.md) |
| **维护更新** | 同步策略 | [maintenance.md](./maintenance.md) |

> **文档维护规则**: 本文档为索引层，所有详细内容指向 SKILL.md。禁止在本文档中重复定义与 SKILL.md 冲突的内容。

