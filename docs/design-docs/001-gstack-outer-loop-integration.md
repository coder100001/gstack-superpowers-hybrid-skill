# Design Doc 001: gstack 外循环深度集成方案

## 元数据
- **ID**: 001
- **Title**: gstack 外循环深度集成方案
- **Status**: draft
- **Date**: 2026-05-15
- **Task**: gs-hybrid-v3 架构升级 — Superpowers 内循环 + gstack 外循环双引擎集成
- **Complexity**: L3
- **Parent**: 无

---

## 1. 背景与动机

### 1.1 现状

gs-hybrid-v3 v3.6 流程严重偏重 Superpowers 内循环。8 个 gstack 注册技能仅 2 个实际可用（`/qa`、`/design-review`），2 个引用的技能不存在（`/cso`、`/ship`），5 个技能闲置。实质上是 Superpowers 单引擎驱动。

### 1.2 问题

- 流程不完整：缺少产品决策、部署发布、浏览器验证、事后复盘
- 技能浪费：5 个 gstack 技能闲置 + 2 个悬空引用
- 违反设计初衷：项目定位"双引擎"，实为单引擎
- **无渐进式加载机制**：全量文档一次性加载，上下文浪费严重

### 1.3 驱动因素

用户分析文档明确了 Superpowers + gstack 的五大交接点理论：

```
Handoff 1: (gstack) 需求与产品诊断 → /office-hours
Handoff 2: (Superpowers) 技术规划 → brainstorming + writing-plans
Handoff 3: (gstack) 方案评审 → /plan-ceo-review + /plan-eng-review
Handoff 4: (Superpowers) 编码实现 → test-driven-development
Handoff 5: (gstack) 验证与交付 → /qa + /ship
```

当前流程仅实现了 Handoff 2、4 和 5 的部分。

---

## 2. 调研与现状分析

### 2.1 当前流程结构

详见 v3.6 模块文件。核心问题：
- Phase 编号不规则（0.5a/0.5b/0.6/1/1.5→2-7）
- 内循环 Phase 占比 ~75%，外循环 ~25%
- 无上下文裁剪机制
- 无冲突规避路由规则

### 2.2 gstack 8 个技能适用性

| gstack Skill | 当前路由 | 应有路由 | 状态 |
|-------------|:---:|------|:---:|
| `design` | ❌ | Phase 3 Design Doc | 闲置 |
| `design-consultation` | ❌ | Phase 2 需求澄清 | 闲置 |
| `design-html` | ❌ | Phase 5d 前端审查 | 闲置 |
| `design-review` | ✅ Phase 2.5 | Phase 5d 前端审查 | 已路由 |
| `design-shotgun` | ❌ | Phase 3 Design Doc | 闲置 |
| `gstack-browse` | ❌ | Phase 6 QA+安全 | 闲置 |
| `qa` | ✅ Phase 4,7 | Phase 6 QA, Phase 9 验证 | 已路由 |
| `review` | ❌ | Phase 5b gstack 评审 | 闲置 |

### 2.3 悬空引用

| 引用 | 位置 | 状态 |
|------|------|:---:|
| `/cso` | Phase 5 | gstack 中不存在，需替换 |
| `/ship` | Phase 7 | gstack 中不存在，需替换 |

---

## 3. 可选方案

### 方案 A: 渐进增强（打补丁）

在现有 Phase 编号基础上新增非整数 Phase（3.5、5.5），不改变现有结构。

**优点**: 改动最小、零风险迁移
**缺点**: Phase 臃肿(14+)、编号不规则、无渐进式加载、双轨不清晰
**推荐度**: ⭐⭐

---

### 方案 B: 双轨重构（高风险）

内循环轨 + 外循环轨并行，交接点交汇。

**优点**: 架构完美、五大交接点清晰映射
**缺点**: AI 执行极困难（轨道间跳跃混淆上下文）、工程量大、回退成本高
**推荐度**: ⭐

---

### 方案 C: 线性增强 + 渐进式加载（推荐方案）

保持线性流程，整数重编号，嵌入完整 gstack 外循环，增加渐进式加载与冲突规避机制。

**优点**:
- 线性结构保持，AI 执行可控
- 8 个 gstack 技能 100% 路由
- 五大交接点一一对应
- 渐进式加载：每次仅 2-3 模块在上下文
- 显式交接语言 + 冲突规避路由规则

**缺点**:
- Phase 编号迁移成本中等
- SKILL.md 需重写

**推荐度**: ⭐⭐⭐⭐⭐

---

## 4. 方案对比汇总

| 方案 | 实施难度 | 风险 | 推荐度 |
|------|:---:|:---:|:---:|
| A: 渐进增强 | 低 | 低 | ⭐⭐ |
| B: 双轨重构 | 极高 | 高 | ⭐ |
| **C: 线性增强+渐进式加载** | **中** | **中** | **⭐⭐⭐⭐⭐** |

---

## 5. 推荐方案详细设计：方案 C（10 阶段，5 交接点，渐进式加载）

### 5.1 新流程全貌

```
Phase 0: 复杂度评估 + 产品诊断                                      [Hybrid + GStack]
    │  0a: 复杂度评估 (L1/L2/L3)
    │  0b: 产品诊断 [GStack: /office-hours]  ← Handoff 1
    │      显式交接: "接下来由 brainstorming 进行技术方案探索"
    ▼
Phase 1: 需求澄清                                                 [Superpowers]
    │  [Superpowers: brainstorming]
    │  苏格拉底式渐进提问 → 方案探索 → 设计呈现
    │  [可选: gstack: design-consultation 提供设计咨询视角]
    │
    ▼
Phase 2: Design Doc 编写 + 方案审核 🔴 HARD-GATE                   [混合]
    │  2a: Design Doc [Superpowers: design + gstack: design-shotgun]
    │  2b: Spec 自审查 (占位符/一致性/范围/歧义)
    │  2c: 方案审核确认 🔴 HARD-GATE (方案对比表+AI推荐+用户确认)
    │
    ▼ 用户确认方案
Phase 3: 结构化 Plan 编写                                           [Superpowers + Hybrid]
    │  [Superpowers: writing-plans]
    │  + gs-hybrid 增强: Spec→Task分解/5类模板/依赖图/跨切面
    │  + gs-hybrid 追加: 风险评估/边界条件/回滚策略
    │
    ▼
Phase 4: Plan 验证确认 🔴 HARD-GATE                                [Hybrid]
    │  8项验证清单 + 用户确认
    │  显式交接: "评审通过，接下来由 GStack CEO 进行方案评审"
    │
    ▼ 用户确认执行
Phase 5: 方案角色化评审                                             [GStack]
    │  5a: CEO 评审 [GStack: /plan-ceo-review]  ← Handoff 3
    │      商业和产品视角：用户体验、防作弊、过期策略等
    │  5b: 工程评审 [GStack: /plan-eng-review]
    │      工程视角：架构合理性、技术风险、扩展性
    │  5c: gstack 代码审查 [GStack: review] (可选，补充视角)
    │  5d: 前端审查 [GStack: /design-review] (仅前端项目)
    │
    │  显式交接: "评审通过，接下来进行 QA 测试策略评审"
    ▼
Phase 6: QA + 安全评审 [GStack] (L3 必须)                          [GStack]
    │  6a: QA 测试策略 [GStack: /qa]
    │  6b: 浏览器验证 [GStack: gstack-browse] (仅前端/Web)
    │  6c: 安全评审 [GStack: review/specialists/security + 手册]
    │      修复 /cso 悬空引用
    │
    │  显式交接: "所有评审通过，开始 TDD 编码"
    ▼
Phase 7: TDD 编码                                                   [Superpowers]
    │  [Superpowers: test-driven-development]    ← Handoff 4
    │  红→绿→重构 循环
    │  [可选: subagent-driven-development 并行开发]
    │  
    │  ⚠ GStack 介入时机:
    │    当用户输入 /qa 测试浏览器界面 → 强制切换 GStack 域
    │    测试完成后切回 TDD 流程
    │
    ▼
Phase 8: 代码审查                                                   [Superpowers + GStack]
    │  8a: Superpowers code-review [requesting-code-review]
    │      独立上下文，静态分析+工程规范
    │  8b: GStack 功能验证 [GStack: /qa]
    │      真实运行环境验证行为
    │
    │  显式交接: "代码审查通过，准备部署"
    ▼
Phase 9: 验证与部署                               [GStack] ← Handoff 5
    │  9a: QA 验收测试 [GStack: /qa]
    │  9b: 部署上线 [项目配置 DEPLOY_COMMAND]
    │      修复 /ship 悬空引用，使用项目自定义部署命令
    │
    ▼
Phase 10: 复盘总结 [GStack] (L3 建议)                              [GStack]
    │  回顾会议：做得好/需改进/行动计划
    │  更新流程、检查清单、模板
    │
    ▼
  完成 ✅
```

### 5.2 复杂度分级适用矩阵

| Phase | 名称 | L1 | L2 | L3 | 负责方 |
|-------|------|:--:|:--:|:--:|--------|
| 0 | 复杂度评估 + 产品诊断 | ✅ | ✅ | ✅ | Hybrid + GStack |
| 1 | 需求澄清 | ✅ | ✅ | ✅ | Superpowers |
| 2 | Design Doc + 方案审核 🔴 | 🔴 | 🔴 | 🔴 | 混合 |
| 3 | 结构化 Plan | ✅ | ✅ | ✅ | Superpowers + Hybird |
| 4 | Plan 验证确认 🔴 | 🔴 | 🔴 | 🔴 | Hybrid |
| 5 | 方案角色化评审 | ⚪ | ✅ | ✅ | GStack |
| 6 | QA + 安全评审 | ⚪ | ⚪ | 🔴 | GStack |
| 7 | TDD 编码 | ✅ | ✅ | ✅ | Superpowers |
| 8 | 代码审查 | ✅ | ✅ | ✅ | Superpowers + GStack |
| 9 | 验证与部署 | ✅ | ✅ | ✅ | GStack |
| 10 | 复盘总结 | ⚪ | ⚪ | 🟡 | GStack |

> L1 简化路径: `0 → 1 → 2(简化) → 3 → 4 → 7 → 9` (7 Phase)
> L2 标准路径: `0 → 1 → 2 → 3 → 4 → 5 → 7 → 8 → 9` (9 Phase)
> L3 完整路径: 全部 10 Phase

### 5.3 五大交接点映射

| 交接点 | Phase | 从 | 到 | 交接语言 |
|:---:|:---:|-----|-----|---------|
| Handoff 1 | Phase 0b→1 | GStack /office-hours | Superpowers brainstorming | "需求诊断完成，接下来由 brainstorming 进行技术方案探索" |
| Handoff 2 | Phase 1→2 | Superpowers brainstorming | Hybrid Design Doc | "需求已澄清，开始编写 Design Doc" |
| Handoff 3 | Phase 4→5 | Hybrid Plan确认 | GStack /plan-ceo-review | "Plan 确认通过，接下来由 GStack CEO 进行方案角色化评审" |
| Handoff 4 | Phase 6→7 | GStack QA评审 | Superpowers TDD | "所有评审通过，开始 TDD 编码" |
| Handoff 5 | Phase 8→9 | Superpowers+GStack 审查 | GStack /qa+/ship | "代码审查通过，准备部署" |

### 5.4 渐进式加载机制（核心新增）

```
初始加载:  SKILL.md 入口 + 加载规则（~1K token）
         ↓
Phase 0:  加载 modules/00-complexity.md + gstack /office-hours（~4K）
         ↓ 卸载 Phase 0 模块
Phase 1:  加载 modules/01-brainstorming.md + Superpowers brainstorming（~6K）
         ↓ 卸载 brainstorming
Phase 2:  加载 modules/02-design-doc.md + gstack design-shotgun（~5K）
         ↓ 卸载 Design Doc 模块
Phase 3:  加载 modules/03-plan.md + Superpowers writing-plans + hybrid 增强（~10K）
         ↓ 卸载 Plan 模块
Phase 4:  加载 modules/04-plan-review.md（~3K）
         ↓
Phase 5:  加载 modules/05-gstack-review.md + GStack /plan-ceo/eng-review（~8K）
         ↓ 卸载 GStack 评审模块
Phase 6:  加载 modules/06-qa-security.md + GStack /qa + security（~8K）
         ↓
Phase 7:  加载 modules/07-coding.md + Superpowers TDD（~8K）
         ↓
Phase 8:  加载 modules/08-code-review.md + Superpowers + GStack（~6K）
         ↓
Phase 9:  加载 modules/09-deploy.md + GStack /qa+/ship（~5K）
         ↓
Phase 10: 加载 modules/10-retro.md（~3K）
```

**关键原则**:
- 任意时刻上下文中仅保留 **2-3 个关键模块**
- 每个 Phase 结束**必须卸载**前一阶段模块（通过"显式交接语言"标记上下文切换点）
- 总 token 消耗控制在 15K-30K，远低于全量加载的 100K+

### 5.5 冲突规避路由规则（核心新增）

```
路由决策流程:

1. 用户输入包含显式 gstack 斜杠命令 (/qa, /office-hours, /plan-ceo-review)?
   ├─ 是 → 无条件路由到 gstack，加载对应技能
   └─ 否 ↓

2. 指令关键词同时匹配 Superpowers 和 GStack?
   ├─ 是 → 检查领域归属
   │   ├─ code-quality 域 → Superpowers (如 review|审查|检查)
   │   └─ browser-testing 域 → GStack (如 /qa|测试|验证)
   └─ 否 → 使用唯一匹配的技能

3. 模糊指令 (如"帮我审查代码")?
   ├─ 默认 → Superpowers code-review
   └─ 提示用户: "如需浏览器功能测试，请使用 /qa"

4. 用户坚持?
   └─ 显式输入 /qa → 无条件使用 GStack
```

### 5.6 悬空引用修复

| 悬空引用 | 修复方案 |
|---------|---------|
| `/cso` (原 Phase 5) | 替换为 gstack `review/specialists/security` + gs-hybrid 安全手册，路由到 Phase 6c |
| `/ship` (原 Phase 7) | 替换为项目配置 `DEPLOY_COMMAND`，路由到 Phase 9b。未来 gstack 上线 `ship` 可直接替换 |

### 5.7 闲置技能全路由

| 技能 | 路由位置 | 使用方式 |
|------|---------|---------|
| `design` | Phase 2a | Design Doc 辅助设计输出 |
| `design-consultation` | Phase 1 | 设计咨询视角 |
| `design-html` | Phase 5d | HTML 原型生成 |
| `design-shotgun` | Phase 2a | 自动生成多方案变体 |
| `gstack-browse` | Phase 6b, Phase 9a | 浏览器自动化验证、截图 |
| `review` | Phase 5c | gstack 工程视角代码审查 |

---

## 6. 风险评估与缓解

| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|----------|
| Phase 0→10 编号迁移混乱 | 中 | 中 | 提供 v3.6→v4.0 迁移对照表；保留旧编号注释 |
| SKILL.md 全量重写引入 bug | 中 | 中 | 分模块逐步重写，每模块独立验证一致性 |
| 渐进式加载 AI 未正确卸载模块 | 高 | 高 | 强制规定每 Phase 结束必须输出显式交接语言；交接语言是硬信号 |
| `/office-hours` 在 gstack 中不存在 | 高 | 高 | Phase 0b 设计为"可选建议"，不阻断流程；提供 fallback 手动诊断流程 |
| 10 个 Phase L1 流程仍过长 | 低 | 低 | L1 只走 7 个 Phase，跳过 5,6,10 |
| gstack 技能行为不符合预期 | 中 | 中 | 每个 gstack Phase 提供 fallback（手动替代） |

---

## 7. 影响范围

### 7.1 影响的文件

| 文件 | 变更 |
|------|------|
| `SKILL.md` | 完全重写：新 10 Phase 流程 + 渐进式加载规则 |
| `modules/01-intro.md` | 重写：新 Phase 路由表、配置扩展、冲突规避规则 |
| `modules/02-complexity.md` | 重写：新分级矩阵 |
| `03a-phase-0-06.md` → `03-phase-0-2.md` | 重写：Phase 0-2 |
| `03b-phase-1.md` → `04-phase-3-4.md` | 重写：Phase 3-4 Plan+验证 |
| `04a-phase-2-3.md` → `05-phase-5.md` | 重写：Phase 5 方案角色化评审 |
| `04b-phase-4-5.md` → `06-phase-6.md` | 重写：Phase 6 QA+安全 |
| `05-phase-6-7.md` → `07-phase-7-8.md` | 重写：编码+代码审查 |
| 新增 `08-phase-9.md` | 验证与部署 |
| 新增 `09-phase-10.md` | 复盘总结 |
| `06-workflows.md` | 更新：指令新增 |
| `07-handling.md` | 更新：冲突规避仲裁规则 |
| `docs/*` | 同步更新 |

### 7.2 新增项目配置

| 配置项 | 说明 | 示例 |
|-------|------|------|
| `DEPLOY_COMMAND` | 部署命令 | `npm run deploy` |
| `BROWSER_TEST_COMMAND` | 浏览器测试命令 | `npm run test:e2e` |

---

## 8. 开放问题

- [ ] `/office-hours` 在 gstack 注册列表中是否存在？不存在时 Phase 0b fallback 方案是什么？
- [ ] `/plan-ceo-review` 和 `/plan-eng-review` 在 gstack 中是否存在？
- [ ] 版本号：v3.7（小版本）还是 v4.0（主版本）？建议 v4.0（Phase 编号变更属 breaking change）
- [ ] gstack 的 `design` 和 Superpowers `brainstorming` 设计环节是否存在功能重叠？重叠时的裁决规则是什么？
- [ ] Phase 5（方案角色化评审）是否应该与 Phase 6（QA+安全）合并？两个都是 GStack 域

---
**Status**: draft