---
name: "gs-hybrid-v3"
description: "结合 Superpowers 方法论和 GStack 工程标准的混合流程。v3.6 更新：Task 拆解增强（Spec→Task 分解方法、5 类 Task 模板、依赖图、跨切面处理），完全集成 Superpowers 编码前流程。"
---

# Superpowers + GStack 混合流程 v3.6 (任务拆解增强版)

> 本 Skill 强制 AI 遵循"先澄清需求(brainstorming)、再研究设计(Design Doc)、再结构化拆解Plan(writing-plans + Task拆解)、后评审、再编码"的严格流程
> 结合 Superpowers 的逻辑严密性和 gstack 的生产级标准
> **v3.6 更新**：Task 拆解系统增强（Spec→Task 分解、5类模板、依赖图、跨切面处理）

---

## 快速开始

### 启动方式

```
用户: hybrid 帮我开发新功能

AI: 收到。我将按照 Superpowers + GStack Hybrid 流程执行：

Step 0:     评估任务复杂度 (L1/L2/L3)
Phase 0.5a: 需求澄清 (brainstorming - 渐进式提问)
Phase 0.5b: Design Doc 编写 (编号设计文档)
Phase 0.6:  方案审核确认 (用户必须确认方案选择)
             ↓ 用户确认方案
Phase 1:    生成详细 PLAN.md
Phase 1.5:  Plan验证确认 (用户必须确认执行)
             ↓ 用户确认执行
Phase 2:    工程规范设计
Phase 3:    架构师评审
Phase 4:    QA 评审 (L3)
Phase 5:    CSO 安全评审 (L3)
Phase 6:    TDD 编码实现
Phase 7:    验证交付
```

### 专用指令

| 指令 | 功能 | 说明 |
|------|------|------|
| `/plan` | 规划流程 | 新功能开发前的完整规划 |
| `/review` | 代码审查 | 代码完成后的质量审查 |
| `/test` | 测试驱动 | TDD 开发流程 |
| `/ship` | 发布准备 | 提交前的最终检查 |
| `/qa` | 质量保证 | 功能完成后的验证 |
| `/debug` | 调试助手 | 问题诊断与修复 |
| `/refactor` | 重构建议 | 代码改进与优化 |

---

## 技能分类索引

本项目将技能分为三类，便于维护和更新：

| 分类 | 路径 | 技能数量 | 说明 |
|------|------|---------|------|
| **Superpowers** | `skills/superpowers/` | 14个 | 核心方法论技能 |
| **GStack** | `skills/gstack/` | 9个 | 工程工具技能 |
| **Hybrid** | `skills/hybrid/` | 1个 | 混合流程技能 |
| **Custom** | `skills/custom/` | - | 自定义扩展 |

### Superpowers 技能 (14个)

核心方法论技能，来自 Superpowers 官方：

| 技能 | 用途 | 触发方式 |
|------|------|---------|
| [brainstorming](../superpowers/brainstorming/) | 需求澄清、方案对比 | 自动触发 |
| [writing-plans](../superpowers/writing-plans/) | 编写实施计划 | 技能调用 |
| [executing-plans](../superpowers/executing-plans/) | 批量执行计划 | 技能调用 |
| [subagent-driven-development](../superpowers/subagent-driven-development/) | 子代理开发 | 技能调用 |
| [test-driven-development](../superpowers/test-driven-development/) | TDD 编码 | 自动触发 |
| [systematic-debugging](../superpowers/systematic-debugging/) | 系统调试 | 技能调用 |
| [requesting-code-review](../superpowers/requesting-code-review/) | 代码审查请求 | 自动触发 |
| [receiving-code-review](../superpowers/receiving-code-review/) | 响应审查反馈 | 技能调用 |
| [using-git-worktrees](../superpowers/using-git-worktrees/) | Git worktree | 自动触发 |
| [finishing-a-development-branch](../superpowers/finishing-a-development-branch/) | 分支收尾 | 自动触发 |
| [dispatching-parallel-agents](../superpowers/dispatching-parallel-agents/) | 并行代理 | 技能调用 |
| [verification-before-completion](../superpowers/verification-before-completion/) | 完成前验证 | 自动触发 |
| [writing-skills](../superpowers/writing-skills/) | 创建新技能 | 技能调用 |
| [using-superpowers](../superpowers/using-superpowers/) | 系统介绍 | 手动触发 |

### GStack 技能 (9个)

工程工具技能，来自 GStack：

| 技能 | 用途 | 触发方式 |
|------|------|---------|
| [design](../gstack/design/) | 设计工具 | 技能调用 |
| [design-consultation](../gstack/design-consultation/) | 设计咨询 | 技能调用 |
| [design-html](../gstack/design-html/) | HTML设计 | 技能调用 |
| [design-review](../gstack/design-review/) | 设计审查 | 技能调用 |
| [design-shotgun](../gstack/design-shotgun/) | 多方案设计 | 技能调用 |
| [gstack-browse](../gstack/gstack-browse/) | 浏览器自动化 | 技能调用 |
| [qa](../gstack/qa/) | 质量保证 | 技能调用 |
| [review](../gstack/review/) | 代码审查 | 技能调用 |

### Hybrid 技能 (1个)

混合流程技能，结合两者优势：

| 技能 | 用途 | 触发方式 |
|------|------|---------|
| [gs-hybrid-v3](./) | 完整混合流程 | 主入口 |

---

## 模块化按需加载

> **核心理念**: 不同阶段加载不同的模块，避免一次性加载所有内容消耗上下文。

### 本技能模块索引

| 模块 | 内容 | 加载时机 |
|------|------|---------|
| [01-intro.md](./modules/01-intro.md) | 快速开始、项目配置、核心概念 | 初始加载 |
| [02-complexity.md](./modules/02-complexity.md) | 复杂度分级、适用矩阵 | Step 0 |
| [03a-phase-0-06.md](./modules/03a-phase-0-06.md) | Step 0 + Phase 0.5 + 0.6 | Phase 0-0.6 |
| [03b-phase-1.md](./modules/03b-phase-1.md) | Phase 1 逻辑规划 | Phase 1 |
| [04a-phase-2-3.md](./modules/04a-phase-2-3.md) | Phase 2-3 工程规范 | Phase 2-3 |
| [04b-phase-4-5.md](./modules/04b-phase-4-5.md) | Phase 4-5 QA/安全评审 | Phase 4-5 |
| [05-phase-6-7.md](./modules/05-phase-6-7.md) | Phase 6-7 编码验证 | Phase 6-7 |
| [06-workflows.md](./modules/06-workflows.md) | 专用流程指令 | 指令触发 |
| [07-handling.md](./modules/07-handling.md) | 异常处理机制 | 异常发生时 |

### 加载策略

```
初始: 加载 01-intro.md (基础配置和概念)
      ↓
Step 0: 加载 02-complexity.md (复杂度评估)
      ↓
Phase 0-0.6: 加载 03a-phase-0-06.md (设计阶段)
      ↓
Phase 1: 加载 03b-phase-1.md (规划阶段)
      ↓
Phase 2-3: 加载 04a-phase-2-3.md (工程评审)
      ↓
Phase 4-5: 加载 04b-phase-4-5.md (QA/安全评审)
      ↓
Phase 6-7: 加载 05-phase-6-7.md (编码验证)
      ↓
异常: 加载 07-handling.md (异常处理)
```

---

## 流程概览

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                 Superpowers + GStack 混合流程 v3.4 (模块化)                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                               │
│   需求输入                                                                     │
│      │                                                                         │
│      ▼                                                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Step 0: 复杂度评估                                                   │   │
│   │ 加载: 02-complexity.md                                               │   │
│   │ - 统计变更文件数                                                     │   │
│   │ - 预估代码行数                                                       │   │
│   │ - 识别架构影响                                                       │   │
│   │ - 确定级别: L1 / L2 / L3                                            │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│      │                                                                         │
│      ▼                                                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Phase 0.5a: 需求澄清 (brainstorming)           [L1⚪ L2🔴 L3🔴]   │   │
│   │ - 探索项目上下文                                                     │   │
│   │ - 范围评估与拆解                                                     │   │
│   │ - 渐进式提问 (一次一个，优先选择题)                                  │   │
│   │ - 方案探索 (2-3 个方案)                                              │   │
│   │ - 设计呈现 (逐章节确认)                                              │   │
│   │ - 用户确认设计 → 保存 spec 文件                                      │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│      │                                                                         │
│      ▼                                                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Phase 0.5b: Design Doc 编写                       [L1⚪ L2🔴 L3🔴]   │   │
│   │ Phase 0.6:  方案审核确认 (强制) 🔴               [L1🔴 L2🔴 L3🔴]   │   │
│   │ 加载: 03a-phase-0-06.md                                              │   │
│   │ - Spec 自审查 (占位符/一致性/范围/歧义)                              │   │
│   │ - 方案调研与对比                                                     │   │
│   │ - 产出编号设计文档 → specs/design-docs/NNN-title.md                 │   │
│   │ - 用户必须确认方案选择 ✅                                            │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│      │                                                                         │
│      ▼                                                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Phase 1: 结构化 Plan (writing-plans + Task拆解)     [L1✅ L2✅ L3✅]   │   │
│   │ Phase 1.5: Plan验证确认 (强制) 🔴                [L1🔴 L2🔴 L3🔴]   │   │
│   │ 加载: 03b-phase-1.md                                                 │   │
│   │ - Spec→Task 分解 (需求→任务的结构化映射)                              │   │
│   │ - 5 类 Task 模板 (Feature/Bugfix/Config/Refactor/Integration)        │   │
│   │ - Task 依赖图 (依赖/并行/阻塞) + 跨切面处理                          │   │
│   │ - Bite-Sized Tasks + No Placeholders + Self-Review                   │   │
│   │ - gs-hybrid 增强: 风险评估/边界条件/回滚策略                         │   │
│   │ - 用户必须确认执行 ✅                                                │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│      │                                                                         │
│      ▼                                                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Phase 2: 工程规范设计                             [L1⚪ L2🟡 L3🔴]   │   │
│   │ Phase 3: 架构师评审                               [L1⚪ L2🟡 L3🔴]   │   │
│   │ 加载: 04a-phase-2-3.md                                               │   │
│   │ - 架构设计审查                                                       │   │
│   │ - SOLID 原则检查                                                     │   │
│   │ - 技术栈合规检查                                                     │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│      │                                                                         │
│      ▼                                                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Phase 4: QA 评审                                  [L1⚪ L2⚪ L3🔴]   │   │
│   │ Phase 5: CSO 安全评审                             [L1⚪ L2⚪ L3🔴]   │   │
│   │ 加载: 04b-phase-4-5.md                                               │   │
│   │ - 测试策略制定                                                       │   │
│   │ - 边界条件识别                                                       │   │
│   │ - 安全漏洞扫描                                                       │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│      │                                                                         │
│      ▼                                                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │ Phase 6: 编码实现 (Test-Driven Development)     [L1✅ L2✅ L3✅]   │   │
│   │ Phase 7: 验证交付                               [L1✅ L2✅ L3✅]   │   │
│   │ 加载: 05-phase-6-7.md                                                │   │
│   │ - 先写测试，再写功能                                                  │   │
│   │ - 小步快跑，频繁验证                                                  │   │
│   │ - 生成交付物 (测试报告、Changelog)                                    │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                               │
│   图例: ✅ 必须  🟡 L2+必须  🔴 L3必须  ⚪ 可选  🔴 强制确认               │
│                                                                               │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 强制阻断规则

<HARD-GATE>
1. **Phase 0.6 方案审核确认**: 用户必须明确确认方案选择，否则不能进入 Phase 1
2. **Phase 1.5 Plan验证确认**: 用户必须明确确认 PLAN，否则不能进入 Phase 2
3. **配置缺失**: 如果项目配置缺失，必须提示用户补充，否则阻断流程
4. **评审不通过**: 如果评审发现阻断性问题，必须修复后才能继续
</HARD-GATE>

---

## 项目配置 (快速参考)

使用前必须配置以下项目参数：

```yaml
language: "Go 1.21+"                    # 开发语言
test_command: "go test ./... -race"     # 测试命令
coverage_command: "go test ./... -coverprofile=coverage.out"  # 覆盖率
lint_command: "golangci-lint run"       # 代码检查
security_scanner: "gosec ./..."         # 安全扫描
concurrency_model: "goroutine"          # 并发模型
```

**详细配置请参考**: [01-intro.md](./modules/01-intro.md)

---

## Skill 路由表（按需加载）

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

## 异常处理

当遇到以下情况时，参考 [07-handling.md](./modules/07-handling.md)：

- 评审意见冲突 → 冲突仲裁机制
- 需要回退流程 → 回滚机制
- 方案需要变更 → 变更审批流程
- 评审发现问题 → 异常处理流程

---

## 文档索引

> **重要**: 本文档与 README.md 和 docs/ 目录下的文档保持同步更新。

| 文档 | 内容 | 路径 |
|------|------|------|
| **项目 README** | 项目概述、快速开始 | [README.md](../../../README.md) |
| **快速开始** | 安装配置、基础使用 | [docs/getting-started.md](../../../docs/getting-started.md) |
| **架构设计** | 系统设计、流程说明 | [docs/architecture.md](../../../docs/architecture.md) |
| **技能参考** | 所有技能详细说明 | [docs/skills-reference.md](../../../docs/skills-reference.md) |
| **维护更新** | 同步策略、扩展方法 | [docs/maintenance.md](../../../docs/maintenance.md) |
| **技能目录** | 技能分类说明 | [skills/README.md](../../../skills/README.md) |
| **完整分析** | 三项目对比分析 | [COMPLETE_ANALYSIS.md](../../../COMPLETE_ANALYSIS.md) |

### 同步更新清单

修改本 SKILL.md 时，请同步更新以下文档：

- [ ] [README.md](../../../README.md) - 项目主文档
- [ ] [docs/getting-started.md](../../../docs/getting-started.md) - 快速开始
- [ ] [docs/architecture.md](../../../docs/architecture.md) - 架构设计
- [ ] [docs/skills-reference.md](../../../docs/skills-reference.md) - 技能参考
- [ ] [skills/README.md](../../../skills/README.md) - 技能目录

---

## 版本历史

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| v3.6 | 2026-05-15 | **Task 拆解增强**：新增 Spec→Task 分解方法、5 类 Task 模板（Feature/Bugfix/Config/Refactor/Integration）、Task 依赖图（依赖/并行/阻塞）、跨切面处理机制；强化 Phase 0.5a 多子系统检测标准 |
| v3.5 | 2026-05-15 | **重大更新**：编码前流程完全集成 Superpowers，Phase 1 委托给 writing-plans（TDD五步/No Placeholders/Self-Review/Execution Handoff），保留 gs-hybrid 专属增强（风险评估/边界条件/回滚策略/Plan验证确认硬阻断） |
| v3.4 | 2026-05-15 | Phase 0.5 拆分为 0.5a(需求澄清/brainstorming) + 0.5b(Design Doc)，新增 Spec 自审查，强化渐进式提问方法 |
| v3.3 | 2026-05-15 | 模块化拆分，分类维护，按需加载 |
| v3.2 | 2026-05-14 | 强化方案审核确认环节 |
| v3.1 | 2026-05-13 | 增加 Plan验证确认环节 |
| v3.0 | 2026-05-12 | 初始版本，结合 Superpowers + GStack |

---

## 使用示例

### 示例 1: 完整开发流程

```
用户: hybrid 帮我开发用户认证功能

AI: 收到。我将按照 Superpowers + GStack Hybrid 流程执行：

Step 0: 评估任务复杂度...
[加载 02-complexity.md]
→ 评估结果: L2 (中等任务)

Phase 0.5a: 需求澄清 (brainstorming)...
[加载 03a-phase-0-06.md]
→ Announce: "使用 brainstorming 进行需求澄清"
→ 探索项目上下文
→ 渐进式提问 (目的 → 用户 → 约束 → 成功标准)
→ 方案探索 (提出 2-3 个方案)
→ 用户确认设计 → 保存 spec 文件

Phase 0.5b: Design Doc 编写...
→ Spec 自审查 + 方案调研 + 详细设计
→ 产出: specs/design-docs/001-auth.md

Phase 0.6: 方案审核确认...
→ 用户确认方案选择

Phase 1: 详细 Plan (writing-plans)...
[加载 03b-phase-1.md]
→ Scope Check + File Structure
→ Bite-Sized Tasks (2-5min/TDD五步)
→ Self-Review (spec coverage/placeholder/type consistency)
→ 产出: specs/plans/2026-05-15-auth.md

Phase 1.5: Plan验证确认...
→ 等待用户确认...

用户: 确认执行

Phase 2-3: 工程规范 + 架构评审...
[加载 04a-phase-2-3.md]
→ 评审通过

Phase 6-7: TDD 编码 + 验证交付...
[加载 05-phase-6-7.md]
→ 编码完成
→ 测试通过
→ 交付成功
```

### 示例 2: 使用专用指令

```
用户: /plan 开发支付模块

AI: 启动规划流程...
[加载 02-complexity.md + 03a-phase-0-06.md + 03b-phase-1.md]
→ 完成规划，产出 Design Doc 和 PLAN.md
```

---

**版本**: v3.6 (任务拆解增强版，5类模板+依赖图+跨切面)
**最后更新**: 2026-05-15

**详细文档请参考各模块文件。**
