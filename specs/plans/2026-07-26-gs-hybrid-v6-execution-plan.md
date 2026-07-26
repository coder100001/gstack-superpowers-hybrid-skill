# gs-hybrid-v6 执行计划

> **版本**: v1.0 · **日期**: 2026-07-26
> **父计划**: [2026-07-26-gs-hybrid-v6-capable-model-plan.md](./2026-07-26-gs-hybrid-v6-capable-model-plan.md)
> **任务拆分**: [2026-07-26-gs-hybrid-v6-task-breakdown.md](./2026-07-26-gs-hybrid-v6-task-breakdown.md)
> **执行模式**: subagent-driven-development (SDD) + TDD
> **复杂度**: L3

---

## 1. 范围

本执行计划覆盖 gs-hybrid-v6 演进计划的实施。基于现有任务分解（14 个任务，4 个 Phase），按依赖顺序执行。

### 关键边界

- **范围**: 治理层 + hybrid 模块的代码/文档/脚本变更
- **不涉及**: `skills/superpowers/` 内容改造（上游维护）、`skills/gstack/` 内容改造（GStack overlay）
- **不涉及**: 引入第三方依赖

---

## 2. 执行顺序

### 依赖图

```
Phase 0: 基线固化
  V6-0-1 (提交上游同步) ─┬─→ V6-0-2 (token 基线)
                          └─→ V6-0-3 (pressure 脚手架)
                                  └─→ V6-0-4 (baseline eval)

Phase 1: 文档去重+审查对齐
  V6-0-1 ──→ V6-1-1 (SKILL.md 瘦身) ──→ V6-1-3 (加载表下沉)
          └─→ V6-1-2 (inline review)       ↑

Phase 2: Gate 硬化
  V6-0-3 ──→ V6-2-1 (verification gate) ──┬─→ V6-2-2 (L1 确认强化)
                                            ├─→ V6-2-4 (SHIP 路由收敛)
                                            └─→ V6-2-3 (model_tier)
                                                      ↑
                                              V6-1-2 ─┘

Phase 3: 路由扩展+Eval
  V6-0-4 + V6-2-1 ──→ V6-3-1 (候选技能 eval)
  V6-0-3 + V6-2-1 ──→ V6-3-2 (hybrid eval CI) ──→ V6-3-3 (SOP+ADR)
```

### 当前 Session 执行范围

鉴于本次 session 的全部任务量（14 个任务，预估 12-16 人天），本执行计划聚焦 **Phase 0 ~ Phase 2 的 11 个任务**，覆盖基线固化、文档去重、审查对齐和 Gate 硬化的全部工作。

---

## 3. Task 执行清单

### Phase 0: 基线固化

#### V6-0-1：提交上游同步变更

**状态**: ⬜  
**依赖**: 无  
**预估**: 0.5h

- [ ] Step 1: `git status` 确认变更范围
- [ ] Step 2: 运行 `./scripts/check-skill-routes.sh`
- [ ] Step 3: 运行 `./scripts/validate-state-machine.sh`
- [ ] Step 4: 提交变更

**验收**: commit 仅含上游同步文件；校验脚本 0 error

---

#### V6-0-2：Skill token 基线

**状态**: ⬜  
**依赖**: 无（可并行）  
**预估**: 1h

- [ ] Step 1: 统计 `skills/superpowers/*/SKILL.md` 行数
- [ ] Step 2: 统计 `skills/gstack/*/SKILL.md` 行数
- [ ] Step 3: 统计 hybrid SKILL.md + modules 行数
- [ ] Step 4: 写入 `artifacts/skill-baseline-2026-07-26.json`
- [ ] Step 5: 记录合计与 Top 5 最大 skill

**验收**: JSON 可被 `jq` 解析；含 hybrid SKILL.md 472 行基线

---

#### V6-0-3：Pressure scenario 脚手架

**状态**: ⬜  
**依赖**: 无（可并行）  
**预估**: 2h

- [ ] Step 1: 写 `tests/hybrid-pressure/scenarios/_template.md`
- [ ] Step 2: 写 P1 (L0 typo → 不得走完整 DISCOVERY)
- [ ] Step 3: 写 P2 (跳过 REQUIREMENT_LOCK → 阻断)
- [ ] Step 4: 写 P3 (无 verification 证据 → 阻断 SHIP)
- [ ] Step 5: 创建 `tests/hybrid-pressure/README.md`
- [ ] Step 6: 创建 `tests/hybrid-pressure/scenarios/` 目录

**验收**: 3 个 scenario 文件结构一致；P3 标注 Phase 2 前后预期

---

#### V6-0-4：Baseline eval 首轮

**状态**: ⬜  
**依赖**: V6-0-3  
**预估**: 3h

- [ ] Step 1: 干净会话中跑 P1/P2/P3
- [ ] Step 2: 记录：遵守 gate、跳步行为、rationalization
- [ ] Step 3: 写入 `artifacts/eval-baseline-2026-07-26.json`
- [ ] Step 4: 摘要 `artifacts/eval-baseline-2026-07-26.md`

**验收**: 3 scenario 记录；P3 记录为「预期失败」

---

### Phase 1: 文档去重 + 审查对齐

#### V6-1-1：瘦身 SKILL.md

**状态**: ⬜  
**依赖**: V6-0-1  
**预估**: 3h

**TDD 方式**: 先写 `check-skill-routes.sh` 基线测试 → 修改 SKILL.md → 验证路由不断

- [ ] Step 1: 删除状态转换明细表（→ 指向 state-machine.yaml）
- [ ] Step 2: 压缩流程 ASCII 图为 ≤10 行摘要
- [ ] Step 3: 删除 Superpowers/GStack 完整路由表（→ 指向 skill-routes.yaml）
- [ ] Step 4: 删除 Gate 细则重复（→ 指向 gates.yaml）
- [ ] Step 5: 保留：启动语、L0-L3 表、HARD-GATE 7 条、模块索引、真相源指针
- [ ] Step 6: `wc -l SKILL.md` 确认 < 200
- [ ] Step 7: `./scripts/check-skill-routes.sh` 通过

**验收**: 行数 < 200；路由健康检查 0 error

---

#### V6-1-2：对齐 inline self-review

**状态**: ⬜  
**依赖**: V6-0-1  
**预估**: 4h

- [ ] Step 1: 修改 `04b-self-review.md` → 增加级别审查策略表
- [ ] Step 2: SDD task-reviewer 降级为「仅并行执行」
- [ ] Step 3: L1/L2 增加 inline checklist
- [ ] Step 4: L3 保留 `gstack:codex` 触发条件
- [ ] Step 5: 更新 `skill-routes.yaml` SELF_REVIEW 段
- [ ] Step 6: 更新 SKILL.md 路由摘要
- [ ] Step 7: `check-skill-routes.sh`

**验收**: 文档无「L2 默认 SDD task-reviewer」；路由与 module 一致

---

#### V6-1-3：模块加载表下沉

**状态**: ⬜  
**依赖**: V6-1-1  
**预估**: 2h

- [ ] Step 1: 创建 `schema/module-load-map.yaml`
- [ ] Step 2: 从 SKILL.md 提取加载策略 → YAML
- [ ] Step 3: SKILL.md 改为单行引用
- [ ] Step 4: 创建校验脚本 `scripts/validate-module-load.sh`
- [ ] Step 5: 接入 CI

**验收**: SKILL.md 不再含完整加载表；YAML 与 modules 声明一致

---

### Phase 2: Gate 硬化

#### V6-2-1：verification-evidence gate

**状态**: ⬜  
**依赖**: V6-0-3  
**预估**: 1d

**TDD 方式**: 先写测试（无证据 → block；有证据 → pass）→ 实现 gate 脚本 → 验证

- [ ] Step 1: 设计证据格式（`artifacts/verification/latest.txt`）
- [ ] Step 2: 实现 `verification-evidence.sh`
- [ ] Step 3: 注册 `gates.yaml` G016
- [ ] Step 4: `state-machine.yaml` 设置 entry_gate
- [ ] Step 5: 失败场景测试
- [ ] Step 6: 通过场景测试
- [ ] Step 7: 更新 P3 scenario 预期

**验收**: gate 独立可执行；validate-state-machine 通过

---

#### V6-2-2：L1 对话确认 gate 强化

**状态**: ⬜  
**依赖**: V6-2-1  
**预估**: 4h

- [ ] Step 1: `context-contract.yaml` 增加 confirmed_at + confirmed_by
- [ ] Step 2: `requirement-lock.sh` 增加三元组检查
- [ ] Step 3: `plan-confirm.sh` 同上
- [ ] Step 4: 无 spec 时 fallback 检查 workflow-state
- [ ] Step 5: 构造失败/通过场景测试

**验收**: 模型自填确认无法通过 gate；L1 快路径仍可用

---

#### V6-2-3：model_tier 契约扩展

**状态**: ⬜  
**依赖**: V6-1-2  
**预估**: 1d

- [ ] Step 1: `context-contract.yaml` 增加 model_tier + overlay_rules
- [ ] Step 2: `resolve-skill-routes.sh` 读取 tier
- [ ] Step 3: `02-complexity.md` 说明合并路径
- [ ] Step 4: session-start 注入默认 tier

**验收**: resolve-skill-routes capable vs baseline 输出不同；gate 不减免费

---

#### V6-2-4：SHIP_REVIEW 路由收敛

**状态**: ⬜  
**依赖**: V6-2-1  
**预估**: 2h

- [ ] Step 1: `skill-routes.yaml` SHIP_REVIEW 顺序调整
- [ ] Step 2: `05-ship-review-retro.md` 删除重复步骤
- [ ] Step 3: 明确先过 verification gate 再 invoke ship
- [ ] Step 4: `check-skill-routes.sh`

**验收**: SHIP 模块 < 原行数 30%；路由与 module 一致

---

## 4. 验收标准

### 每个 Task 的通用 DoD

- [ ] YAML/脚本改动 + `validate-state-machine.sh` ✅
- [ ] `check-skill-routes.sh` ✅
- [ ] 相关文档更新（不重复 YAML 内容）
- [ ] Gate 行为改动：有测试场景验证

### Session 完成门槛

- [ ] Phase 0 完成（V6-0-1 ~ V6-0-4）
- [ ] Phase 1 完成（V6-1-1 ~ V6-1-3）
- [ ] Phase 2 完成（V6-2-1 ~ V6-2-4）
- [ ] SELF_REVIEW 全面审查完成
- [ ] verification-before-completion 最终验证

---

## 5. 风险登记

| 风险 | 影响 | 缓解 |
|------|------|------|
| verification gate 过严阻断日常 L1 | 高 | L1 允许 conversation + test 粘贴 |
| SKILL 瘦身后路由摘要断裂 | 中 | 改后立即跑 check-skill-routes |
| model_tier 与 GStack overlay 冲突 | 中 | hybrid 只管 gate/路由，不改 gstack skill |

---

## 6. Approval

- [x] Plan confirmed by user on 2026-07-26
- [x] Requirements frozen (per parent plan v6.0)
- [x] Context hydration complete (specs/ADR loaded)
- [x] Decision freeze active (IMPLEMENTATION phase)

---

## 7. 变更历史

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|---------|------|
| v1.0 | 2026-07-26 | 初始创建 | AI |
