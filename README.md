# AI Engineering Governance System

> 一个实验性的三层架构治理系统 — v4.1 — Decision Layer → Context Layer → Execution Layer

[![Version](https://img.shields.io/badge/version-4.1-blue.svg)](./.upstream-versions.json)
[![Architecture](https://img.shields.io/badge/architecture-three--layer-green.svg)](./decision-layer/adr/ADR-001-initial-architecture-framework.md)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](./LICENSE)

---

## 这是什么

这不是一个普通的 AI 编码工作流，而是一个 **AI Engineering Governance System** — 尝试在 AI 辅助编码中引入治理约束，让思考与实现分离。

核心思路很简单：把开发过程分成三层，每层各司其职：

| 层 | 关心的问题 | 做什么 |
|---|-----------|--------|
| **Decision Layer** | "该做什么？" | 多角色审议、架构决策、tradeoff 分析 |
| **Context Layer** | "共识是什么？" | 上下文持久化、Spec 契约、边界强制 |
| **Execution Layer** | "如何做好？" | 受约束实现、TDD、验证、自审 |
| **Bridges** | "如何传递？" | 层间转化、上下文注水 |
| **Governance** | "如何不越界？" | 决策冻结、状态机、变更控制 |

---

## 项目背景

本项目整合了两个开源技能包，并在此基础上构建了一层治理系统：

- **[Superpowers](https://github.com/obra/superpowers)** (14个技能) — 软件开发方法论，提供工程纪律与结构化拆解
- **[GStack](https://github.com/garrytan/gstack)** (16个技能) — 工程工具集，提供多角色决策审议能力

三层架构是在这两个包的基础上重新组织的尝试。

---

## 快速开始

### 1分钟体验（推荐）

```bash
# 克隆项目后，打开 TRY_ME_NOW.md
# 将内容粘贴到 AI 对话中，即可启动最小化治理流程
```

👉 **[TRY_ME_NOW.md](./TRY_ME_NOW.md)** — 无需配置，立即体验三层治理

### 完整安装

```bash
git clone <repo-url>
cd gstack-superpowers-hybrid-skill
chmod +x scripts/*.sh
./scripts/install.sh install --force
```

### 使用

```bash
# 完整治理流程
hybrid 帮我开发用户认证功能

# 专用指令
/plan      # 规划流程
/review    # 代码审查
/test      # 测试驱动
/qa        # 质量保证
/debug     # 调试助手
/refactor  # 重构建议
```

---

## 项目结构

```
/
├── decision-layer/              ← 决策层
│   ├── adr/                     ← 架构决策记录
│   │   ├── ADR-001-*.md         (9个ADR)
│   │   └── README.md
│   └── reviews/                 ← 多角色审议协议
│       ├── architecture-review.md  架构审议
│       ├── product-review.md       产品审议
│       ├── risk-review.md          风险审议
│       └── tradeoff-review.md      权衡审议
│
├── context-layer/               ← 上下文层
│   ├── specs/                   ← 约束契约
│   │   ├── project-spec.md      项目约束
│   │   ├── architecture-spec.md 架构约束
│   │   ├── constraints-spec.md  约束清单
│   │   ├── domain-boundaries.md 领域边界
│   │   ├── api-spec.md          API 契约
│   │   ├── test-spec.md         测试契约
│   │   └── coding-standards/    ← 编码标准
│   │       ├── index.md
│   │       ├── common.md
│   │       ├── go.md
│   │       ├── typescript.md
│   │       ├── ai-red-lines.md
│   │       └── extension-guide.md
│   └── hydration/               ← 上下文注水协议
│
├── execution-layer/             ← 执行层
│   ├── implementation.md        受约束执行规则
│   ├── testing.md               测试规则
│   ├── review.md                审查规则
│   └── validation.md            验证规则
│
├── bridges/                     ← 层间桥接
│   ├── decision-to-context.md   决策→上下文转化
│   └── context-hydration.md     上下文→执行注水
│
├── governance/                  ← 治理规则（可执行化）
│   ├── state-machine.yaml       ← 状态机真相源 (13状态)
│   ├── machine.json             ← 运行时格式 (自动生成)
│   ├── gates.yaml               ← Gate定义真相源 (7个Gate)
│   ├── gates.json               ← 运行时格式 (自动生成)
│   ├── check-gates.sh           ← Gate检查入口
│   ├── transition.sh            ← 状态跃迁入口
│   ├── gates/                   ← Gate脚本
│   │   ├── requirement-lock.sh
│   │   ├── arch-review-lock.sh
│   │   ├── task-decomposition-lock.sh
│   │   ├── plan-confirm.sh
│   │   ├── context-hydration.sh
│   │   ├── decision-freeze.sh
│   │   └── test-presence.sh
│   └── state-journal/           ← 审计日志
│
├── skills/                      ← 技能目录
│   ├── superpowers/             (14个)
│   ├── gstack/                  (16个)
│   ├── hybrid/
│   │   └── gs-hybrid-v3/
│   │       ├── SKILL.md         ← 主入口
│   │       └── modules/         (7个模块)
│   └── custom/
│
├── schema/                      ← Schema定义
│   └── skill-routes.yaml        ← 技能路由真相源
│
├── scripts/                     ← 维护脚本
│   ├── install.sh               安装脚本
│   ├── validate-state-machine.sh 状态机校验
│   ├── check-skill-routes.sh    路由健康检查
│   └── yaml2json.sh             YAML→JSON自动生成
│
├── gstack-skills/bin/           (工具脚本)
├── docs/
│   ├── design-docs/
│   │   ├── 001-gstack-outer-loop-integration.md
│   │   └── 002-ai-engineering-governance-system.md
│   ├── architecture.md          ← 详细架构设计
│   ├── getting-started.md
│   └── skills-reference.md
│
├── specs/plans/                 ← 计划文档
├── artifacts/                   ← 产出物
│   ├── workflow-state.md        工作流状态
│   └── retro/                   复盘记录
└── README.md                    ← 本文件
```

> **详细架构**: 完整的三层架构设计请参考 [architecture.md](docs/architecture.md)。

---

## 治理脚本

### 状态机校验

```bash
./scripts/validate-state-machine.sh
# 输出: SM:0 (0错误, 0警告)
```

### Gate 检查

```bash
./governance/check-gates.sh --to REQUIREMENT_LOCK --level L3
# 输出: GATE:0 (通过) 或 GATE:1 (阻断)
```

### 技能路由健康检查

```bash
./scripts/check-skill-routes.sh
# 输出: ROUTE:0 (0错误)
```

### YAML→JSON 同步

```bash
# 检查一致性
./scripts/yaml2json.sh --check

# 自动生成
./scripts/yaml2json.sh
```

---

## 许可证

本项目继承了上游项目的许可证：
- Superpowers: MIT License
- GStack: 相关开源许可证

查看 [LICENSE](./LICENSE) 了解详情。

## 致谢

- **[Superpowers](https://github.com/obra/superpowers)**: 由 Jesse Vincent 和 Prime Radiant 团队开发
- **[GStack](https://github.com/garrytan/gstack)**: 增强开发工具集

---

> **文档维护规则**: 本文档为索引层，所有详细内容指向 [SKILL.md](skills/hybrid/gs-hybrid-v3/SKILL.md)。
