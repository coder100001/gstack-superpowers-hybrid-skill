# 三层架构重构方案 PLAN

> **版本**: v1.0 · **日期**: 2026-05-16 · **复杂度**: L2

---

## 1. 背景与目标

当前 repo 结构将 Superpowers（14技能）、GStack（50+技能）、Hybrid（1技能）按**来源**组织，而非按**职责**组织。这导致：

- 决策逻辑与执行逻辑混合在同一个 skill 文件中
- 上下文契约（specs/constraints）缺乏强制消费机制
- 讨论完直接跳 coding，缺少 Decision Artifact → Context Layer → Execution 的正式传递链

**本次重构目标**：将 repo 从"来源分类"重构成"职责分层"架构：

```
旧：skills/superpowers/xxx  +  skills/gstack/xxx  →  按来源
新：decision-layer/         +  context-layer/     +  execution-layer/  →  按职责
```

---

## 2. 旧技能 → 新三层映射表

| 三层职责 | 职责说明 | 映射的旧技能 | 新增组件 |
|:---------|:---------|:------------|:---------|
| **Decision Layer** | 多角色审议、方案决策、tradeoff 分析 | `plan-ceo-review`, `plan-eng-review`, `plan-design-review`, `plan-devex-review`, `cso`, `office-hours`, `design-shotgun` | 4 个审议协议（architecture/product/risk/tradeoff） |
| **Context Layer** | 上下文持久化、Spec 契约、边界强制 | `context-restore`, `context-save`, `learn`, `document-generate`, `document-release` | 4 个契约 spec + 1 个 hydration 协议 |
| **Execution Layer** | 受约束执行、测试、验证 | `test-driven-development`, `requesting-code-review`, `verification-before-completion`, `qa`, `systematic-debugging` | 4 个执行规则文件 |
| **Bridges** | 层间传递与转换 | 无（新增职责） | `decision-to-context`, `context-to-execution` |
| **Governance** | 跨层规则强制 | `freeze`, `guard`, `careful` | `decision-freeze` |

---

## 3. 文件创建清单

### 优先级 P0（用户指定 — 必须首批落地）

| 序号 | 文件路径 | 职责 |
|:----|:---------|:-----|
| P0-1 | `decision-layer/reviews/architecture-review.md` | 多角色架构审议协议 |
| P0-2 | `context-layer/specs/project-spec.md` | 项目约束运行时契约 |
| P0-3 | `bridges/context-hydration.md` | 上下文灌入协议（hydration） |

### 优先级 P1（推荐第二轮落地）

| 序号 | 文件路径 | 职责 |
|:----|:---------|:-----|
| P1-1 | `decision-layer/reviews/product-review.md` | 产品视角审议 |
| P1-2 | `decision-layer/reviews/risk-review.md` | 风险视角审议 |
| P1-3 | `decision-layer/reviews/tradeoff-review.md` | 方案权衡审议 |
| P1-4 | `context-layer/specs/architecture-spec.md` | 架构约束契约 |
| P1-5 | `context-layer/specs/constraints-spec.md` | 约束清单契约 |
| P1-6 | `context-layer/specs/domain-boundaries.md` | 领域边界契约 |
| P1-7 | `bridges/context-hydration.md` | 上下文加载协议 |
| P1-8 | `execution-layer/implementation.md` | 受约束执行规则 |
| P1-9 | `execution-layer/testing.md` | 测试执行规则 |
| P1-10 | `execution-layer/review.md` | 执行层审查规则 |
| P1-11 | `execution-layer/validation.md` | 执行层验证规则 |
| P1-12 | `bridges/decision-to-context.md` | 决策→上下文转换协议 |
| P1-13 | `governance/decision-freeze.md` | 决策冻结规则 |

### 优先级 P2（存量改造）

| 序号 | 文件路径 | 变更内容 |
|:----|:---------|:---------|
| P2-1 | `skils/hybrid/gs-hybrid-v3/SKILL.md` | 添加三层路由表、映射旧技能到新层 |
| P2-2 | `README.md` | 更新核心理念为三层架构 |

---

## 4. 边界条件与风险评估

| 风险 | 概率 | 缓解措施 |
|:----|:----|:---------|
| 新目录与旧 skill 目录产生歧义（AI 不知道该读哪个） | 中 | 在 SKILL.md 路由表中明确标注 old→new 映射 |
| 用户认为旧 skill 文件应直接删除 | 低 | 保持向后兼容，旧文件不删除，只标记为"deprecated" |
| 新文件内容与旧 skill 重复 | 中 | P0 文件聚焦"协议层"而非"prompt"，避免职责重叠 |
| 用户分批确认导致半成品状态 | 高 | P0 三个文件独立可交付，不依赖 P1 |

---

## 5. 回滚方案

如果三层结构造成混乱，回滚步骤：
1. 删除新增的 `decision-layer/`、`context-layer/`、`execution-layer/`、`bridges/`、`governance/` 目录
2. 回滚 SKILL.md 的路由表到 v3.7 版本
3. 回滚 README.md 到原版本

---

## 6. 本文档涉及的完整文件清单

```
可能会创建的文件：
decision-layer/
  reviews/
    architecture-review.md   (P0-1)
    product-review.md        (P1-1)
    risk-review.md           (P1-2)
    tradeoff-review.md       (P1-3)

context-layer/
  specs/
    project-spec.md          (P0-2)
    architecture-spec.md     (P1-4)
    constraints-spec.md      (P1-5)
    domain-boundaries.md     (P1-6)
  hydration/
    hydration.md             (P1-7)

execution-layer/
  implementation.md          (P1-8)
  testing.md                 (P1-9)
  review.md                  (P1-10)
  validation.md              (P1-11)

bridges/
  decision-to-context.md     (P1-12)
  context-hydration.md    (P0-3)

governance/
  decision-freeze.md         (P1-13)
```

---

## 7. 验收标准

- [ ] P0 三个文件创建完成且内容独立可交付
- [ ] 每个文件聚焦"职责系统"而非"prompt"
- [ ] 旧 skill 目录不受影响（向后兼容）
- [ ] P0 文件可直接挂载到 gs-hybrid-v3 路由表中