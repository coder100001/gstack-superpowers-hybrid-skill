# AI Engineering Governance System

> 一个实验性的三层架构治理系统 — v4.0 — Decision Layer → Context Layer → Execution Layer

[![Version](https://img.shields.io/badge/version-4.0-blue.svg)](./.upstream-versions.json)
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
cd gstack--superpowers--hybrid-skill
chmod +x scripts/*.sh
./scripts/sync-upstream.sh
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
│   │   ├── ADR-001-*.md         (8个ADR)
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
│   └── hydration/               ← 注水规范
│       └── hydration.md
│
├── execution-layer/             ← 执行层
│   ├── implementation.md        受约束执行规则
│   ├── testing.md               测试规则
│   ├── review.md                审查规则
│   └── validation.md            验证规则
│
├── bridges/                     ← 层间桥接
│   ├── decision-to-context.md   决策→上下文转化
│   ├── context-to-execution.md  上下文→执行注水
│   └── execution-to-decision.md 执行→决策回退
│
├── governance/                  ← 治理规则
│   ├── decision-freeze.md       决策冻结协议
│   ├── machine.json             状态机定义(12状态)
│   ├── gates.json               Gate规则定义(6个)
│   ├── transition.sh            跃迁入口脚本
│   ├── gates/                   ← Gate脚本
│   │   ├── requirement-lock.sh
│   │   ├── arch-review-lock.sh
│   │   ├── task-decomposition-lock.sh
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
│   │       └── modules/         (9个模块)
│   └── custom/
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
├── scripts/                     ← 维护脚本
└── README.md                    ← 本文件
```

> **详细架构**: 完整的三层架构设计请参考 [architecture.md](docs/architecture.md)。

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
