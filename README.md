# AI Engineering Governance System v4.0

> **三层架构正式版** — Decision Layer → Context Layer → Execution Layer，思考与实现严格分离

[![Version](https://img.shields.io/badge/version-4.0-blue.svg)](./.upstream-versions.json)
[![Architecture](https://img.shields.io/badge/architecture-three--layer-green.svg)](./docs/design-docs/002-ai-engineering-governance-system.md)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](./LICENSE)

---

## 核心理念

本项目不是一个普通的 AI 编码工作流，而是一个 **AI Engineering Governance System**（AI 工程治理系统）。

核心架构是三层严格分离的职责系统：

```
┌─────────────────────────────────────────────────────────────────────┐
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐       │
│  │  Decision     │ ──→ │   Context     │ ──→ │  Execution    │       │
│  │  Layer        │     │   Layer       │     │  Layer        │       │
│  │               │     │               │     │               │       │
│  │  多角色审议    │     │  Spec 契约     │     │  受约束实现    │       │
│  │  ADR          │     │  约束强制      │     │  TDD + 验证    │       │
│  │  Tradeoff     │     │  上下文持久化   │     │  自审          │       │
│  └──────┬───────┘     └──────┬───────┘     └──────┬───────┘       │
│         └──────────┬─────────┴──────────┬──────────┘               │
│               ┌────▼────┐          ┌────▼────┐                     │
│               │ Bridges  │          │Governance│                    │
│               │ decision │          │ decision │                    │
│               │ →context │          │ freeze   │                    │
│               │ context  │          │ state    │                    │
│               │ →exec    │          │ machine  │                    │
│               └─────────┘          └─────────┘                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 三层的职责分工

| 层 | 核心问题 | 负责什么 | 来源 |
|:---|:---------|:---------|:-----|
| **Decision Layer** | "该做什么？" | 多角色审议、架构决策、tradeoff 分析 | GStack（多角色评审）+ Superpowers（需求澄清） |
| **Context Layer** | "共识是什么？" | 上下文持久化、Spec 契约、边界强制 | GSD/OpenSpec 理念 |
| **Execution Layer** | "如何做好？" | 受约束实现、TDD、验证、自审 | Superpowers（工程纪律） |
| **Bridges** | "如何传递？" | 层间转化、上下文注水 | 新增职责 |
| **Governance** | "如何不越界？" | 决策冻结、状态机、变更控制 | 新增职责 |

---

## 项目概述

本项目整合了两个顶级开源技能包，并在此基础上构建了三层治理系统：

- **[Superpowers](https://github.com/obra/superpowers)** (14个技能) — 成熟的软件开发方法论，提供工程纪律与结构化拆解
- **[GStack](https://github.com/gstack)** (47个技能) — 强大的工程工具集，提供多角色决策审议能力

三层架构将这两种能力按职责重新组织：
- **Superpowers** → Execution Layer（执行纪律）+ Decision Layer（需求发散辅助）
- **GStack** → Decision Layer（多角色审议主引擎）+ Context Layer（持久化机制）
- **本系统新增** → Bridges（层间桥接）+ Governance（治理规则）+ 状态机

---

## 状态机

完整的状态机设计请参考 [docs/architecture.md](./docs/architecture.md#状态机设计)。
---

## 核心特性

| 特性 | 说明 |
|:-----|:------|
| **三层职责分离** | 决策/上下文/执行严格隔离，禁止越界 |
| **状态机严格迁移** | 9 状态不可跳步，每步有强制产出物 |
| **多角色审议** | 5 个决策维度（产品/架构/性能/安全/运维）独立审议 |
| **上下文注水** | 执行前强制加载所有上下文契约 |
| **决策冻结** | 执行期间架构/需求/API/领域边界冻结 |
| **复杂度分级** | L1/L2/L3 三级响应，按需执行 |
| **ADR 记录** | 所有决策必须有记录、理由、回滚策略 |
| **向后兼容** | 旧技能直接可用，新三层结构作为增强层叠加 |

---

## 快速开始

### 1. 安装

```bash
git clone <repo-url>
cd gstack--superpowers--hybrid-skill
chmod +x scripts/*.sh
./scripts/sync-upstream.sh
```

### 2. 配置项目约束

在 `context-layer/specs/project-spec.md` 中配置项目特定约束（架构风格、依赖方向、禁止模式等）。

### 3. 使用

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
│   └── reviews/                 ← 多角色审议协议
│       ├── architecture-review.md  * 架构审议
│       ├── product-review.md      产品审议
│       ├── risk-review.md         风险审议
│       └── tradeoff-review.md     权衡审议
│
├── context-layer/               ← 上下文层
│   ├── specs/                   ← 约束契约（运行时上下文的唯一真相来源）
│   │   ├── project-spec.md      * 项目约束
│   │   ├── architecture-spec.md    架构约束
│   │   ├── constraints-spec.md    约束清单
│   │   └── domain-boundaries.md   领域边界
│   └── hydration/               ← 注水规范
│       └── hydration.md
│
├── execution-layer/             ← 执行层
│   ├── implementation.md        * 受约束执行规则
│   ├── testing.md                  测试规则
│   ├── review.md                   审查规则
│   └── validation.md               验证规则
│
├── bridges/                     ← 层间桥接
│   ├── decision-to-context.md   * 决策→上下文转化
│   └── context-to-execution.md  * 上下文→执行注水
│
├── governance/                  ← 治理规则
│   └── decision-freeze.md       * 决策冻结协议
│
├── skills/                      ← 旧技能目录（向后兼容）
│   ├── superpowers/             (14个)
│   ├── gstack/                  (47个)
│   ├── hybrid/
│   │   └── gs-hybrid-v3/
│   │       ├── SKILL.md         ← 主入口（v4.0）
│   │       └── modules/         (9个模块)
│   └── custom/
│
├── gstack-skills/bin/           (53个工具脚本)
├── docs/                        ← 文档
│   ├── design-docs/             ← 设计文档
│   │   ├── 001-gstack-outer-loop-integration.md
│   │   └── 002-ai-engineering-governance-system.md
│   ├── architecture.md
│   ├── getting-started.md
│   └── skills-reference.md
│
├── specs/plans/                 ← 计划文档
├── scripts/                     ← 维护脚本
└── README.md                    ← 本文件
```

> `*` 标记的文件为 v4.0 新增的核心文件

---

## 三层架构核心原则

1. **思考与实现严格分离** — Decision Layer 负责决策，Execution Layer 负责执行，互不越界
2. **所有决策必须有记录和理由** — 每个 ADR 记录方案、否决理由、风险、回滚策略
3. **上下文契约是唯一真相来源** — Context Layer 的 spec 是执行的唯一依据
4. **执行时不允许偏离契约** — Execution Layer 必须在约束范围内工作
5. **变更必须走正式流程** — 冻结项变更需退回 Decision Layer 重新审议

---

## 文档索引

| 文档 | 内容 | 路径 |
|:-----|:-----|:-----|
| **三层架构设计** | AI Engineering Governance System 完整设计 | [docs/design-docs/002-ai-engineering-governance-system.md](./docs/design-docs/002-ai-engineering-governance-system.md) |
| **主入口 SKILL.md** | gs-hybrid-v3 v4.0 | [skills/hybrid/gs-hybrid-v3/SKILL.md](./skills/hybrid/gs-hybrid-v3/SKILL.md) |
| **决策层** | 多角色架构审议协议 | [decision-layer/reviews/architecture-review.md](./decision-layer/reviews/architecture-review.md) |
| **上下文层** | 项目约束运行时契约 | [context-layer/specs/project-spec.md](./context-layer/specs/project-spec.md) |
| **桥接层** | 上下文灌入协议 | [bridges/context-to-execution.md](./bridges/context-to-execution.md) |
| **治理层** | 决策冻结规则 | [governance/decision-freeze.md](./governance/decision-freeze.md) |
| **架构设计** | 系统整体架构 | [docs/architecture.md](./docs/architecture.md) |
| **完整分析** | 三项目对比分析 | [COMPLETE_ANALYSIS.md](./COMPLETE_ANALYSIS.md) |
| **快速开始** | 安装配置、基础使用 | [docs/getting-started.md](./docs/getting-started.md) |

---

## 版本历史

| 版本 | 日期 | 变更 |
|:-----|:-----|:-----|
| **v4.0** | **2026-05-16** | **AI Engineering Governance System**: 从技能分类升级为职责分层系统（Decision/Context/Execution Layer + Bridges + Governance）；新增状态机；多角色审议；上下文注水；决策冻结 |
| v3.3 | 2026-05-15 | 模块化拆分，分类维护，按需加载 |
| v3.2 | 2026-05-14 | 强化方案审核确认环节 |
| v3.1 | 2026-05-13 | 增加 Plan验证确认环节 |
| v3.0 | 2026-05-12 | 初始版本，结合 Superpowers + GStack |

---

## 许可证

本项目继承了上游项目的许可证：
- Superpowers: MIT License
- GStack: 相关开源许可证

查看 [LICENSE](./LICENSE) 了解详情。

## 致谢

- **[Superpowers](https://github.com/obra/superpowers)**: 由 Jesse Vincent 和 Prime Radiant 团队开发
- **[GStack](https://github.com/gstack)**: 强大的增强开发工具集

---

> **文档维护规则**: 本文档为索引层，所有详细内容指向 [SKILL.md](skills/hybrid/gs-hybrid-v3/SKILL.md)。禁止在本文档中重复定义与 SKILL.md 冲突的内容。