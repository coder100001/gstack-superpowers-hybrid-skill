# Superpowers + GStack Hybrid Skills v3.3

> **生产级 AI 开发流程** - 结合 Superpowers 方法论与 GStack 工程标准，提供从设计到交付的完整工作流。

[![Version](https://img.shields.io/badge/version-3.3-blue.svg)](./.upstream-versions.json)
[![Skills](https://img.shields.io/badge/skills-22+-green.svg)](./skills/)
[![License](https://img.shields.io/badge/license-MIT-yellow.svg)](./LICENSE)

## 项目概述

本项目是一个**生产级 AI 开发流程框架**，将两套顶级开源技能包整合：

- **[Superpowers](https://github.com/obra/superpowers)** (14个技能) - 成熟的软件开发方法论
- **[GStack](https://github.com/gstack)** (7个技能) - 强大的工程工具集
- **Hybrid** (1个核心技能) - 融合两者优势的完整工作流

### 核心特性

| 特性 | 说明 |
|------|------|
| **复杂度分级** | L1/L2/L3 三级流程，按需执行 |
| **模块化加载** | 按需加载，降低上下文消耗 |
| **强制确认机制** | Phase 0.6 和 1.5 强制用户确认 |
| **多角色评审** | 架构师/QA/CSO 多角度审查 |
| **分类维护** | Superpowers/GStack/Hybrid/Custom 独立管理 |
| **自动同步** | 一键同步上游更新，避免冲突 |

---

## 快速开始

### 1. 安装

```bash
# 克隆项目
git clone <repo-url>
cd gstack--superpowers--hybrid-skill

# 添加执行权限
chmod +x scripts/*.sh

# 同步上游技能
./scripts/sync-upstream.sh
```

### 2. 配置项目

在项目根目录创建 `.trae/rules/project_rules.md`：

```yaml
project:
  name: "your-project"
  language: "Go 1.21+"  # 或 Python, TypeScript 等

testing:
  test_command: "go test ./... -race"
  coverage_command: "go test ./... -coverprofile=coverage.out"

quality:
  lint_command: "golangci-lint run"

security:
  scanner: "gosec ./..."
```

### 3. 使用

```bash
# 完整开发流程
hybrid 帮我开发用户认证功能

# 专用指令
/plan      # 规划流程
/review    # 代码审查
/test      # 测试驱动
/ship      # 发布准备
/qa        # 质量保证
/debug     # 调试助手
/refactor  # 重构建议
```

---

## 完整工作流程

```
需求输入
    ↓
Step 0: 复杂度评估 (L1/L2/L3)
    ↓
Phase 0.5: Design Doc (L2+ 必须)
    ↓
Phase 0.6: 方案审核确认 🔴 (强制确认)
    ↓ 用户确认
Phase 1: 逻辑规划
    ↓
Phase 1.5: Plan验证确认 🔴 (强制确认)
    ↓ 用户确认
Phase 2-3: 工程规范 + 架构评审 (L2+)
    ↓
Phase 4-5: QA + 安全评审 (L3)
    ↓
Phase 6: TDD 编码实现
    ↓
Phase 7: 验证交付
    ↓
完成
```

> 🔴 表示强制阻断点，必须用户确认才能继续

---

## 技能分类

所有技能按来源分为四类，便于维护和更新：

### 1. Superpowers 技能 (14个)

**路径**: `skills/superpowers/`

核心方法论技能，提供成熟的开发流程：

| 技能 | 用途 | 触发 |
|------|------|------|
| `brainstorming` | 需求澄清、方案对比 | 自动 |
| `writing-plans` | 编写实施计划 | 技能调用 |
| `test-driven-development` | TDD 编码 | 自动 |
| `systematic-debugging` | 系统调试 | 技能调用 |
| `requesting-code-review` | 代码审查请求 | 自动 |
| ... | ... | ... |

**更新**: `./scripts/sync-upstream.sh --superpowers`

### 2. GStack 技能 (7个)

**路径**: `skills/gstack/`

工程工具技能，提供丰富的开发和审查工具：

| 技能 | 用途 | 触发 |
|------|------|------|
| `design` | 设计工具 | 技能调用 |
| `gstack-browse` | 浏览器自动化 | 技能调用 |
| `review` | 代码审查 | 技能调用 |
| `qa` | 质量保证 | 技能调用 |
| ... | ... | ... |

**更新**: `./scripts/sync-upstream.sh --gstack`

### 3. Hybrid 技能 (1个)

**路径**: `skills/hybrid/gs-hybrid-v3/`

融合两者优势的主技能：

- **模块化设计**: 9个模块按需加载
- **复杂度分级**: L1/L2/L3 三级流程
- **强制确认**: Phase 0.6 和 1.5 强制用户确认
- **多角色评审**: 架构师/QA/CSO 多角度审查

### 4. Custom 技能

**路径**: `skills/custom/`

用户自定义扩展，不受同步影响。

---

## 项目结构

```
gstack--superpowers--hybrid-skill/
├── skills/                      # 技能目录
│   ├── superpowers/            # Superpowers 官方技能 (14个)
│   ├── gstack/                 # GStack 工程技能 (7个)
│   ├── hybrid/                 # 混合流程技能 (1个)
│   │   └── gs-hybrid-v3/
│   │       ├── SKILL.md        # 主入口 (15.5KB)
│   │       └── modules/        # 9个模块按需加载
│   │           ├── 01-intro.md
│   │           ├── 02-complexity.md
│   │           ├── 03a-phase-0-06.md
│   │           ├── 03b-phase-1.md
│   │           ├── 04a-phase-2-3.md
│   │           ├── 04b-phase-4-5.md
│   │           ├── 05-phase-6-7.md
│   │           ├── 06-workflows.md
│   │           └── 07-handling.md
│   └── custom/                 # 自定义扩展
│
├── gstack-skills/              # GStack 工具脚本 (53个)
│   └── bin/
│
├── scripts/                    # 维护脚本
│   └── sync-upstream.sh        # 上游同步脚本
│
├── docs/                       # 文档目录
│   ├── getting-started.md      # 快速开始指南
│   ├── architecture.md         # 架构设计文档
│   ├── skills-reference.md     # 技能参考手册
│   └── maintenance.md          # 维护更新指南
│
├── .upstream-versions.json     # 版本追踪
├── README.md                   # 本文件
└── LICENSE                     # 许可证
```

---

## 维护与更新

### 同步上游更新

```bash
# 同步所有上游更新
./scripts/sync-upstream.sh

# 仅同步 superpowers
./scripts/sync-upstream.sh --superpowers

# 仅同步 gstack
./scripts/sync-upstream.sh --gstack

# 检查更新但不执行
./scripts/sync-upstream.sh --check

# 同步前备份
./scripts/sync-upstream.sh --backup

# 回滚到上一个备份
./scripts/sync-upstream.sh --rollback
```

### 避免冲突策略

| 分类 | 维护方式 | 是否可修改 |
|------|---------|-----------|
| Superpowers | 完全由上游同步 | ❌ 不要手动修改 |
| GStack | 完全由上游同步 | ❌ 不要手动修改 |
| Hybrid | 手动维护 | ✅ 可以修改 |
| Custom | 完全自由 | ✅ 自由修改 |

### 扩展方式

如需修改或扩展现有技能，建议在 `skills/custom/` 创建扩展版本：

```
skills/custom/
└── gs-hybrid-v3-extended/
    └── SKILL.md
```

---

## 文档索引

| 文档 | 内容 | 路径 |
|------|------|------|
| **快速开始** | 安装配置、基础使用 | [docs/getting-started.md](./docs/getting-started.md) |
| **架构设计** | 系统设计、流程说明 | [docs/architecture.md](./docs/architecture.md) |
| **技能参考** | 所有技能详细说明 | [docs/skills-reference.md](./docs/skills-reference.md) |
| **维护更新** | 同步策略、扩展方法 | [docs/maintenance.md](./docs/maintenance.md) |
| **技能目录** | 技能分类说明 | [skills/README.md](./skills/README.md) |
| **完整分析** | 三项目对比分析 | [COMPLETE_ANALYSIS.md](./COMPLETE_ANALYSIS.md) |

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
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

## 相关资源

- Superpowers 原始仓库: https://github.com/obra/superpowers
- Superpowers 社区 Discord: https://discord.gg/35wsABTejz
- 完整分析文档: [COMPLETE_ANALYSIS.md](./COMPLETE_ANALYSIS.md)

---

> **注意**: 本文档与主 SKILL.md 保持同步更新。修改 SKILL.md 时，请同步更新本文档和 docs/ 目录下的相关文档。
