# 技能参考手册

> 完整的技能列表和使用说明。

## 目录

1. [Superpowers 技能](#superpowers-技能)
2. [GStack 技能](#gstack-技能)
3. [Hybrid 技能](#hybrid-技能)
4. [Custom 技能](#custom-技能)
5. [技能对比](#技能对比)

---

## Superpowers 技能

**路径**: `skills/superpowers/`

**数量**: 14个

### 测试与验证

#### test-driven-development
- **用途**: RED-GREEN-REFACTOR 循环，TDD 编码
- **触发**: 自动触发
- **阶段**: Phase 6
- **说明**: 强制执行测试驱动开发，先写测试再写代码

#### verification-before-completion
- **用途**: 确保问题真正解决
- **触发**: 自动触发
- **阶段**: Phase 7
- **说明**: 完成前验证，确保交付质量

### 调试与诊断

#### systematic-debugging
- **用途**: 4 阶段根本原因分析流程
- **触发**: 技能调用
- **说明**: 系统化调试方法，定位问题根因

#### subagent-driven-development
- **用途**: 快速迭代，带两阶段审查
- **触发**: 技能调用
- **说明**: 子代理驱动开发，规范符合性 + 代码质量审查

### 协作与规划

#### brainstorming
- **用途**: 苏格拉底式设计细化
- **触发**: 自动触发
- **阶段**: Phase 0.5
- **说明**: 需求澄清、方案对比、设计细化

#### writing-plans
- **用途**: 详细的实施计划
- **触发**: 技能调用
- **阶段**: Phase 1
- **说明**: 将工作分解为小块任务，每个任务都有精确的文件路径和验证步骤

#### executing-plans
- **用途**: 带检查点的批量执行
- **触发**: 技能调用
- **说明**: 批量执行任务，带有人工检查点

#### dispatching-parallel-agents
- **用途**: 并发子代理工作流
- **触发**: 技能调用
- **说明**: 并行执行多个子代理任务

#### requesting-code-review
- **用途**: 预审查清单
- **触发**: 自动触发
- **阶段**: Phase 2-3
- **说明**: 代码审查请求，对照计划审查

#### receiving-code-review
- **用途**: 回应反馈
- **触发**: 技能调用
- **说明**: 响应代码审查反馈

#### using-git-worktrees
- **用途**: 并行开发分支
- **触发**: 自动触发
- **说明**: 使用 Git worktrees 管理并行开发

#### finishing-a-development-branch
- **用途**: 合并/PR 决策工作流
- **触发**: 自动触发
- **说明**: 完成开发分支，决定合并、PR、保留或丢弃

### 元技能

#### writing-skills
- **用途**: 遵循最佳实践创建新技能
- **触发**: 技能调用
- **说明**: 创建符合规范的新技能

#### using-superpowers
- **用途**: 技能系统介绍
- **触发**: 手动触发
- **说明**: Superpowers 系统介绍和使用指南

---

## GStack 技能

**路径**: `skills/gstack/`

**数量**: 7个

### 设计类

#### design
- **用途**: 设计工具和设计评审流程
- **触发**: 技能调用
- **说明**: 提供设计工具和评审流程

#### design-consultation
- **用途**: 设计咨询服务
- **触发**: 技能调用
- **说明**: 设计咨询和建议

#### design-html
- **用途**: HTML 设计生成
- **触发**: 技能调用
- **说明**: 生成 HTML 设计代码

#### design-review
- **用途**: 设计审查
- **触发**: 技能调用
- **阶段**: Phase 2.5
- **说明**: 前端视觉审查

#### design-shotgun
- **用途**: 多方案设计
- **触发**: 技能调用
- **说明**: 快速生成多个设计方案

### 工具类

#### gstack-browse
- **用途**: 浏览器自动化和网页交互
- **触发**: 技能调用
- **说明**: Headless browser 自动化，网页测试和交互

#### review
- **用途**: 多维度代码审查专家
- **触发**: 技能调用
- **说明**: 代码审查，多维度分析

#### qa
- **用途**: 质量保证和测试工具
- **触发**: 技能调用
- **阶段**: Phase 4, 7
- **说明**: QA 测试、功能验证、部署验证

---

## Hybrid 技能

**路径**: `skills/hybrid/gs-hybrid-v3/`

**数量**: 1个

### gs-hybrid-v3

**主入口技能**，融合 Superpowers 和 GStack 优势。

#### 特性

- **模块化设计**: 9个模块按需加载
- **复杂度分级**: L1/L2/L3 三级流程
- **强制确认机制**: Phase 0.6 和 1.5 强制用户确认
- **多角色评审**: 架构师/QA/CSO 多角度审查

#### 模块列表

| 模块 | 内容 | 加载时机 |
|------|------|---------|
| 01-intro.md | 快速开始、项目配置 | 初始 |
| 02-complexity.md | 复杂度分级 | Step 0 |
| 03a-phase-0-06.md | Step 0 + Phase 0.5 + 0.6 | Phase 0-0.6 |
| 03b-phase-1.md | Phase 1 逻辑规划 | Phase 1 |
| 04a-phase-2-3.md | Phase 2-3 工程规范 | Phase 2-3 |
| 04b-phase-4-5.md | Phase 4-5 QA/安全评审 | Phase 4-5 |
| 05-phase-6-7.md | Phase 6-7 编码验证 | Phase 6-7 |
| 06-workflows.md | 专用流程指令 | 指令触发 |
| 07-handling.md | 异常处理机制 | 异常发生时 |

#### 专用指令

| 指令 | 功能 | 说明 |
|------|------|------|
| `/plan` | 规划流程 | 新功能开发前的完整规划 |
| `/review` | 代码审查 | 代码完成后的质量审查 |
| `/test` | 测试驱动 | TDD 开发流程 |
| `/ship` | 发布准备 | 提交前的最终检查 |
| `/qa` | 质量保证 | 功能完成后的验证 |
| `/debug` | 调试助手 | 问题诊断与修复 |
| `/refactor` | 重构建议 | 代码改进与优化 |

#### 工作流程

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

---

## Custom 技能

**路径**: `skills/custom/`

**用途**: 用户自定义扩展技能

### 创建自定义技能

```
skills/custom/
└── my-custom-skill/
    ├── SKILL.md
    └── README.md
```

### 示例

```markdown
---
name: "my-custom-skill"
description: "我的自定义技能"
---

# My Custom Skill

## 用途

描述技能的用途。

## 使用方法

描述如何使用这个技能。

## 参数

| 参数 | 类型 | 说明 |
|------|------|------|
| param1 | string | 参数1说明 |
| param2 | number | 参数2说明 |
```

---

## 技能对比

### Superpowers vs GStack vs Hybrid

| 维度 | Superpowers | GStack | Hybrid |
|------|-------------|--------|--------|
| **定位** | 方法论 | 工具集 | 完整流程 |
| **数量** | 14个 | 7个 | 1个 |
| **重点** | 流程规范 | 工程实践 | 两者结合 |
| **触发** | 自动+手动 | 手动 | 自动+手动 |
| **维护** | 上游同步 | 上游同步 | 手动维护 |

### 技能选择指南

#### 简单任务 (L1)

```
需求 → Step 0 → Phase 0.6 → Phase 1 → Phase 1.5 → Phase 6 → Phase 7
```

**使用技能**:
- `writing-plans` (Phase 1)
- `test-driven-development` (Phase 6)
- `verification-before-completion` (Phase 7)

#### 中等任务 (L2)

```
需求 → Step 0 → Phase 0.5 → Phase 0.6 → Phase 1 → Phase 1.5 → Phase 2-3 → Phase 6 → Phase 7
```

**使用技能**:
- `brainstorming` (Phase 0.5)
- `writing-plans` (Phase 1)
- `requesting-code-review` (Phase 2-3)
- `test-driven-development` (Phase 6)
- `verification-before-completion` (Phase 7)

#### 复杂任务 (L3)

```
需求 → Step 0 → Phase 0.5 → Phase 0.6 → Phase 1 → Phase 1.5 → Phase 2-3 → Phase 4-5 → Phase 6 → Phase 7
```

**使用技能**:
- `brainstorming` (Phase 0.5)
- `writing-plans` (Phase 1)
- `requesting-code-review` (Phase 2-3)
- `/qa` (Phase 4)
- `/cso` (Phase 5)
- `test-driven-development` (Phase 6)
- `verification-before-completion` (Phase 7)
- `/qa` (Phase 7)

---

## 更新策略

### Superpowers 技能

```bash
./scripts/sync-upstream.sh --superpowers
```

- 完全由上游同步
- 不要手动修改
- 保留原有结构和功能

### GStack 技能

```bash
./scripts/sync-upstream.sh --gstack
```

- 完全由上游同步
- 不要手动修改
- 同步到 `skills/gstack/` 目录

### Hybrid 技能

- 手动维护
- 可以修改模块
- 建议通过扩展方式定制

### Custom 技能

- 完全自由
- 不受同步影响
- 可以任意修改

---

## 相关文档

- [快速开始指南](./getting-started.md)
- [架构设计文档](./architecture.md)
- [维护更新指南](./maintenance.md)
- [技能目录说明](../skills/README.md)
