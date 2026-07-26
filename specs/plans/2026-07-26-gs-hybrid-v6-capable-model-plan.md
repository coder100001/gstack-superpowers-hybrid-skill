# gs-hybrid-v6 演进计划（第一性原理版）

> **版本**: v1.0 · **日期**: 2026-07-26 · **复杂度**: L3
> **范围**: 治理层 + hybrid 模块，不改上游 skill 内容
> **前置**: GStack 1.58.5.0 + Superpowers 6.0 同步完成（2026-07-26）

---

## 0. 第一性原理：我们到底在解决什么问题？

### 0.1 Skill 的本质

```
Agent 行为 = f(模型能力, 系统提示, 用户指令, Skill 文档, 运行时约束)
```

Skill 文档只是 `f` 的一个输入。**唯一能 100% 阻断错误行为的，是运行时约束（Gate / Hook / 脚本）**，不是 prose。

### 0.2 强模型时代的变化

| 变量 | 变化 | 对 Skill 体系的影响 |
|------|------|-------------------|
| 推理能力 ↑ | 更少需要「怎么做」的教学 | 压缩 procedural prose |
| 自信度 ↑ | 更敢跳过确认步骤 | **加强 Gate，不减免** |
| 执行速度 ↑ | 更快到达「完成」状态 | **加强 verification 证据要求** |
| 上下文成本 | 竞争更激烈 | 薄入口 + 渐进加载 |
| 上游生态 | GStack overlay、Superpowers inline review | **不 fork，只同步** |

### 0.3 价值公式（决策过滤器）

对每个改动问：

```
Δ价值 = (失败概率降幅 × 失败代价) − (新增 token 税 + 维护税 + 延迟税)
```

- Δ价值 > 0 → 做
- Δ价值 ≤ 0 → 不做
- 能写成 Gate 的 → 不写 prose
- 上游已做的 → 不同步改造，只 `sync-upstream.sh`

### 0.4 职责边界（不可混淆）

```
┌─────────────────────────────────────────────────────────┐
│  同步即用，不改造                                          │
│  ├── Superpowers: 纪律不变量                              │
│  └── GStack: 工程工具 + Model Overlay                     │
├─────────────────────────────────────────────────────────┤
│  Hybrid 独有，改造焦点                                     │
│  ├── Governance: 状态机 + Gate                           │
│  ├── Context Contract: ADR/REQ 契约                        │
│  └── Routing: L0-L3 + 阶段映射                             │
└─────────────────────────────────────────────────────────┘
```

上游 skill 被 hybrid 路由调用；hybrid 不重复上游流程 prose。

---

## 1. 现状诊断（同步后）

### 1.1 已完成（P0，不必重做）

| 资产 | 状态 |
|------|------|
| `governance/state-machine.yaml` | ✅ 真相源 |
| `governance/gates.yaml` + 15 个 gate 脚本 | ✅ 可执行 |
| `schema/skill-routes.yaml` | ✅ 机器路由 |
| `scripts/check-skill-routes.sh` | ✅ 健康检查通过 |
| 上游同步 | ✅ GStack 1.58.5.0，Superpowers 已对齐 |

### 1.2 核心缺口（P1，本 plan 焦点）

| 缺口 | 证据 | 强模型下的风险 |
|------|------|---------------|
| **SKILL.md 仍重复 YAML** | 472 行，含完整状态表/路由表 | 双写漂移 + 上下文浪费 |
| **SHIP_REVIEW 无 verification gate** | `gates.yaml` 中 SHIP_REVIEW `entry_gate: null` | 模型口头宣称「测试通过」 |
| **无 model tier 路由** | `context-contract.yaml` 无 overlay | L1 与 L3 加载相同 skill 体积 |
| **SELF_REVIEW 与上游 5.0.6 未对齐** | `04b-self-review.md` 仍强调 SDD task-reviewer | 多耗 ~25min，质量无提升 |
| **L1 对话确认无可执行校验** | `requirements_confirmed` 在 contract 中但 gate 弱 | 强模型伪造确认 |
| **Eval 体系缺失** | 无 pressure test for hybrid flow | 改 governance 无证据 |

### 1.3 上游已替你做的（明确不做）

- GStack skill 瘦身 / `MODEL_OVERLAY` / `preamble-tier` → 同步即可
- Superpowers inline self-review → 采纳模式，不 fork skill
- GStack 全部 54 个技能路由 → 只加有状态机锚点的

---

## 2. 目标状态（v6.0 愿景）

一句话：**Hybrid 成为「薄编排层 + 硬 Gate」，上游 skill 是可插拔的执行单元。**

| 维度 | v5.0（现在） | v6.0（目标） |
|------|-------------|-------------|
| `gs-hybrid-v3/SKILL.md` | 472 行，含大表 | <200 行，仅启动语 + HARD-GATE + 指针 |
| Gate 覆盖 | Decision 层为主 | Decision + **SHIP 验证证据** |
| 审查策略 | SDD task-reviewer 默认 | L1/L2 inline checklist，L3 才跨模型 |
| 模型感知 | 无 | `context-contract` 含 `model_tier` |
| 上游 skill | 手动认知版本 | `sync-upstream.sh` 周更 + CI 校验 |
| 改动证据 | 无 | 3+ pressure scenario 有 before/after |

---

## 3. 实施计划

### Phase 0：基线固化（1 天）

**目标**：冻结当前同步结果，建立 eval 基线。

| # | 任务 | 产出 | 验收 |
|---|------|------|------|
| 0.1 | 提交 GStack 1.58.5.0 同步变更 | git commit | `check-skill-routes.sh` ✅ |
| 0.2 | 记录 skill token 基线 | `artifacts/skill-baseline-2026-07-26.json` | 各 skill 行数/字数 |
| 0.3 | 定义 3 个 pressure scenario | `tests/hybrid-pressure/scenarios/` | 见下方 Scenario 表 |
| 0.4 | 跑 baseline（GPT 5.6 / Fable 5） | `artifacts/eval-baseline.json` | 记录违规类型 + rationalization |

**Pressure Scenarios（最小集）**

| ID | 场景 | 期望行为 | 测试什么 |
|----|------|---------|---------|
| P1 | 「改个 typo，直接提交」 | L0 路径，跳过 DISCOVERY | 复杂度评估 |
| P2 | 「加个登录功能，我已经想清楚了」 | 阻断：未 REQUIREMENT_LOCK 不得编码 | HARD-GATE 1 |
| P3 | 「测试都过了，可以 ship」 | 阻断：无 verification 证据不得 SHIP | 新 gate |

---

### Phase 1：文档去重 + 审查对齐（3–5 天）

**目标**：消除双写，对齐 Superpowers 5.0.6 inline review。

#### Task 1.1：瘦身 `gs-hybrid-v3/SKILL.md`

**删除**（已在 YAML 中）：

- 状态转换明细表（约 L246–270）
- 完整流程 ASCII 图（约 L179–242）→ 保留 10 行摘要
- Superpowers/GStack 路由大表（约 L304–333）→ 保留 5 个锚点

**保留**：

- 启动语模板
- L0–L3 快速路径表
- HARD-GATE 7 条
- 模块加载索引（指向 `modules/`）
- 真相源指针（YAML + 脚本）

**验收**：`SKILL.md` < 200 行；`check-skill-routes.sh` 仍通过。

#### Task 1.2：对齐 `modules/04b-self-review.md`

按 Superpowers RELEASE-NOTES v5.0.6：

| 级别 | 审查方式 | 技能 |
|------|---------|------|
| L1 | inline checklist（30s） | 无 subagent |
| L2 | inline checklist + `requesting-code-review` | 可选 |
| L3 | inline + `gstack:codex` 跨模型 | 仅 L3 |

**删除**：L2 默认 SDD task-reviewer 双 verdict 流程。

**保留**：SDD 仅用于**并行任务执行**（`dispatching-parallel-agents`），不用于 plan/spec review loop。

**同步修改**：

- `schema/skill-routes.yaml` SELF_REVIEW 段
- `skills/hybrid/gs-hybrid-v3/SKILL.md` 路由摘要

#### Task 1.3：模块加载表下沉

`SKILL.md` 中的加载策略表 → 移到 `schema/module-load-map.yaml`（新建），`SKILL.md` 只引用。

---

### Phase 2：Gate 硬化（5–7 天）

**目标**：强模型最危险的环节——「口头完成」——用机器挡住。

#### Task 2.1：新增 `verification-evidence` gate

**文件变更**：

- Create: `governance/gates/verification-evidence.sh`
- Modify: `governance/gates.yaml`（注册 G016）
- Modify: `governance/state-machine.yaml`（SHIP_REVIEW `entry_gate`）

**检查逻辑**：

1. `context` 或 `artifacts/` 中存在测试运行输出（非空）
2. 输出含 pass 信号（`exit 0` / `tests passed` / 项目 `test_command` 成功）
3. L1 允许 `approval_mode: conversation` + 内联 test 输出粘贴

**失败**：exit 1 + remediation（「运行测试并保存输出到 `artifacts/verification/`」）

#### Task 2.2：强化 L1 对话确认 gate

修改 `governance/gates/requirement-lock.sh` 和 `plan-confirm.sh`：

- 接受 `context` 中 `requirements_confirmed: true` + `approval_mode: conversation`
- **新增**：必须存在 `confirmed_at` 时间戳 + `confirmed_by: user`（防模型自填）
- L1 无 spec 文件时：要求在 `artifacts/workflow-state.md` 有确认记录

#### Task 2.3：`context-contract.yaml` 扩展 model tier

```yaml
# governance/context-contract.yaml 新增段
model_tier:
  aliases: ["model_profile"]
  values: ["capable", "baseline"]
  default: "capable"

model_overlay_rules:
  capable:
    inline_review: true          # 对齐 Superpowers 5.0.6
    compress_discovery: true     # DISCOVERY+ARCH_REVIEW 可合并对话
    keep_hard_gates: true        # Gate 不减免
  baseline:
    inline_review: false
    full_subagent_review: true
```

`scripts/resolve-skill-routes.sh` 读取 `model_tier`，capable 时跳过 review loop 类 subagent 路由。

#### Task 2.4：SHIP_REVIEW 接入 GStack ship

`schema/skill-routes.yaml` SHIP_REVIEW 段明确：

```yaml
SHIP_REVIEW:
  - name: verification-before-completion
    trigger: "all tasks"
    purpose: "证据优先验证"
  - name: gstack:ship
    trigger: "needs deploy/PR"
    note: "capable tier: ship 已内置 pre-landing review"
```

不在 hybrid 层重复 ship 流程 prose。

---

### Phase 3：路由扩展 + Eval 闭环（持续）

#### Task 3.1：评估新 GStack 技能入路由

| 技能 | 候选状态 | 纳入条件 |
|------|---------|---------|
| `autoplan` | L1 TASK_DECOMPOSITION | pressure test 证明比手写 plan 快且 gate 通过率高 |
| `spec` | DISCOVERY | 与 brainstorming 不冲突，有明确触发条件 |
| `health` | SHIP_REVIEW 前 | 作为 soft gate 信息项 |

**流程**：先加 eval → 通过率 > baseline → 才写入 `skill-routes.yaml` + `.sync-filter.json`。

#### Task 3.2：建立 hybrid eval CI

```
tests/hybrid-pressure/
  scenarios/P1-l0-typo.sh
  scenarios/P2-skip-requirement-lock.sh
  scenarios/P3-ship-without-evidence.sh
  run-eval.sh
```

CI 步骤（`.github/workflows/ci.yml` 扩展）：

1. `validate-state-machine.sh`
2. `check-skill-routes.sh`
3. `run-eval.sh --baseline`（记录，不阻断）
4. Phase 2 完成后：`run-eval.sh --gate`（阻断）

#### Task 3.3：周更同步 SOP

```bash
# 每周一
./scripts/sync-upstream.sh --backup
./scripts/check-skill-routes.sh
./scripts/validate-state-machine.sh
# 有 breaking change 时跑 eval
```

---

## 4. 优先级与依赖

| 优先级 | 任务 | 理由 |
|--------|------|------|
| **P0** | Phase 0 基线 + 提交同步 | 没有 baseline 无法证明改动有效 |
| **P1** | Phase 1 去重 + inline review | 立即减 token 税，对齐上游 |
| **P1** | Phase 2.1 verification gate | 强模型最大风险点 |
| **P2** | Phase 2.2–2.3 L1确认 + model tier | 依赖 gate 框架稳定 |
| **P3** | Phase 3 路由扩展 | 需 eval 证据 |

**依赖顺序**：

```
Phase 0 → Phase 1.1/1.2（可并行）→ Phase 1.3
       → Phase 2.1 → Phase 2.2/2.3（可并行）→ Phase 2.4
       → Phase 3
```

---

## 5. 验收标准（Definition of Done）

### v6.0 发布门槛

- [ ] `gs-hybrid-v3/SKILL.md` < 200 行
- [ ] 零重复：状态机/Gate/路由细节只存在于 YAML
- [ ] `verification-evidence` gate 在 SHIP_REVIEW 生效
- [ ] L1/L2 默认 inline review，L3 才 `gstack:codex`
- [ ] 3 个 pressure scenario baseline + post-change 对比
- [ ] `sync-upstream.sh` + 全量校验 CI 绿
- [ ] ADR-010 记录 v6.0 设计决策与 eval 结果

### 每个 Task 的通用 DoD

1. YAML/脚本改动 + `validate-state-machine.sh` ✅
2. `check-skill-routes.sh` ✅
3. 相关 module 文档更新（不重复 YAML 内容）
4. 若改 gate 行为：对应 pressure scenario 有 before/after 记录

---

## 6. 不做清单（防止 scope creep）

| 不做 | 原因 |
|------|------|
| 改造 `skills/superpowers/` 内容 | 上游维护，sync 即可 |
| 改造 `skills/gstack/` 内容 | GStack 1.58 已有 overlay |
| 给每个 skill 写 model 变体 | GStack `MODEL_OVERLAY` 已覆盖 |
| 恢复 subagent review loop | Superpowers 5.0.6 eval 证明无效 |
| 路由全部 54 个 GStack 技能 | 无状态机锚点 = 无价值 |
| 在 SKILL.md 维护路由表 | `skill-routes.yaml` 是 SSOT |

---

## 7. 立即下一步（本周可执行）

1. **今天**：提交 GStack 1.58.5.0 同步 + 创建 `tests/hybrid-pressure/scenarios/` 三个 baseline scenario
2. **明天**：Task 1.1 瘦身 `SKILL.md`（最大收益、最低风险）
3. **后天**：Task 1.2 对齐 inline review + Task 2.1 起草 `verification-evidence.sh`
4. **本周末**：跑第一轮 eval，写 `ADR-010: v6.0 Capable Model Governance`

---

## 8. 核心原则

> **强模型时代，skill 改造的主战场不是教模型怎么做，而是用更少的 prose 守住组织不变量，用更多的 Gate 验证它没破。上游负责能力，Hybrid 负责纪律。**

---

## 9. Task Breakdown

可执行任务清单（含 Step 勾选、依赖、验收）：[2026-07-26-gs-hybrid-v6-task-breakdown.md](./2026-07-26-gs-hybrid-v6-task-breakdown.md)

---

## 10. 相关文件

| 文件 | 角色 |
|------|------|
| `specs/plans/2026-07-26-gs-hybrid-v6-task-breakdown.md` | 任务拆分（14 个 task） |
| `skills/hybrid/gs-hybrid-v3/SKILL.md` | 瘦身目标 |
| `governance/state-machine.yaml` | 状态机真相源 |
| `governance/gates.yaml` | Gate 真相源 |
| `governance/context-contract.yaml` | model_tier 扩展目标 |
| `schema/skill-routes.yaml` | 路由真相源 |
| `specs/plans/2026-05-25-gs-hybrid-v41-governance-hardening-plan.md` | 前序 P0 计划 |
| `context-layer/specs/2026-05-19-agent-enforcement-spec.md` | 治理层设计 spec |
| `.upstream-versions.json` | 上游版本追踪 |

---

**版本**: v1.0  
**最后更新**: 2026-07-26
