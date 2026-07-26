# gs-hybrid-v6 Task Breakdown

> **父计划**: [2026-07-26-gs-hybrid-v6-capable-model-plan.md](./2026-07-26-gs-hybrid-v6-capable-model-plan.md)
> **版本**: v1.0 · **日期**: 2026-07-26
> **总预估**: 12–16 人天（可并行压缩至 8–10 日历日）

---

## 任务总览

| ID | 任务 | Phase | 优先级 | 预估 | 依赖 | 状态 |
|----|------|-------|--------|------|------|------|
| V6-0-1 | 提交上游同步变更 | 0 | P0 | 0.5h | — | ⬜ |
| V6-0-2 | Skill token 基线 | 0 | P0 | 1h | — | ⬜ |
| V6-0-3 | Pressure scenario 脚手架 | 0 | P0 | 2h | — | ⬜ |
| V6-0-4 | Baseline eval 首轮 | 0 | P0 | 3h | V6-0-3 | ⬜ |
| V6-1-1 | 瘦身 SKILL.md | 1 | P1 | 3h | V6-0-1 | ⬜ |
| V6-1-2 | 对齐 inline self-review | 1 | P1 | 4h | V6-0-1 | ⬜ |
| V6-1-3 | 模块加载表下沉 | 1 | P1 | 2h | V6-1-1 | ⬜ |
| V6-2-1 | verification-evidence gate | 2 | P1 | 1d | V6-0-3 | ⬜ |
| V6-2-2 | L1 对话确认 gate 强化 | 2 | P2 | 4h | V6-2-1 | ⬜ |
| V6-2-3 | model_tier 契约扩展 | 2 | P2 | 1d | V6-1-2 | ⬜ |
| V6-2-4 | SHIP_REVIEW 路由收敛 | 2 | P2 | 2h | V6-2-1 | ⬜ |
| V6-3-1 | 新 GStack 技能 eval | 3 | P3 | 2d | V6-0-4 | ⬜ |
| V6-3-2 | hybrid eval CI | 3 | P3 | 1d | V6-0-3, V6-2-1 | ⬜ |
| V6-3-3 | 周更同步 SOP + ADR-010 | 3 | P3 | 4h | V6-3-2 | ⬜ |

**并行建议**：
- V6-0-2 / V6-0-3 可与 V6-0-1 并行
- V6-1-1 / V6-1-2 可与 V6-0-4 并行（eval 跑的同时改文档）
- V6-2-2 / V6-2-3 / V6-2-4 可在 V6-2-1 完成后并行

---

## Phase 0：基线固化

### V6-0-1：提交上游同步变更

**目标**: 冻结 GStack 1.58.5.0 同步结果，作为 v6 改造起点。

**依赖**: 无  
**预估**: 0.5h

**文件变更**:
- Modify: `.upstream-versions.json`
- Modify: `skills/gstack/**`
- Modify: `gstack-skills/**`

- [ ] **Step 1**: `git status` 确认变更范围（应仅为 gstack + upstream 版本）
- [ ] **Step 2**: 运行 `./scripts/check-skill-routes.sh` → 0 error
- [ ] **Step 3**: 运行 `./scripts/validate-state-machine.sh` → 通过
- [ ] **Step 4**: 提交，message 含 `GStack 1.58.5.0` 与 sync 日期

**验收**:
- [ ] commit 仅含上游同步相关文件
- [ ] 两份校验脚本绿

---

### V6-0-2：Skill token 基线

**目标**: 记录改造前各 skill 体积，供 v6 瘦身对比。

**依赖**: 无  
**预估**: 1h

**文件变更**:
- Create: `artifacts/skill-baseline-2026-07-26.json`
- Create: `scripts/measure-skill-baseline.sh`（可选，便于复跑）

- [ ] **Step 1**: 统计 `skills/superpowers/*/SKILL.md` 行数
- [ ] **Step 2**: 统计 `skills/gstack/*/SKILL.md` 行数
- [ ] **Step 3**: 统计 `skills/hybrid/gs-hybrid-v3/SKILL.md` + `modules/*.md` 行数
- [ ] **Step 4**: 写入 JSON，字段：`path`, `lines`, `bytes`, `category`, `recorded_at`
- [ ] **Step 5**: 在 JSON 中记录合计与 Top 5 最大 skill

**验收**:
- [ ] JSON 可被 `jq` 解析
- [ ] 含 hybrid SKILL.md 当前 472 行基线

---

### V6-0-3：Pressure scenario 脚手架

**目标**: 建立 3 个最小 pressure test，后续 gate 改动有对照组。

**依赖**: 无  
**预估**: 2h

**文件变更**:
- Create: `tests/hybrid-pressure/README.md`
- Create: `tests/hybrid-pressure/scenarios/P1-l0-typo.md`
- Create: `tests/hybrid-pressure/scenarios/P2-skip-requirement-lock.md`
- Create: `tests/hybrid-pressure/scenarios/P3-ship-without-evidence.md`
- Create: `tests/hybrid-pressure/scenarios/_template.md`

每个 scenario 文件必含：
- `user_prompt`（精确用户输入）
- `expected_level`（L0/L1/L2）
- `expected_blocked_states`（应被阻断的跃迁）
- `expected_skills`（应触发的 skill）
- `failure_rationalizations`（强模型常见借口表）
- `pass_criteria`（通过判定）

- [ ] **Step 1**: 写 `_template.md`
- [ ] **Step 2**: 写 P1（L0 typo → 不得走完整 DISCOVERY）
- [ ] **Step 3**: 写 P2（跳过 REQUIREMENT_LOCK → 必须阻断 IMPLEMENTATION）
- [ ] **Step 4**: 写 P3（无 verification 证据 → 必须阻断 SHIP_REVIEW）
- [ ] **Step 5**: README 说明手动 eval 流程（模型、会话清洁度、记录格式）

**验收**:
- [ ] 3 个 scenario 文件结构一致
- [ ] P3 明确标注「Phase 2 前预期失败，Phase 2 后预期通过」

---

### V6-0-4：Baseline eval 首轮

**目标**: 用当前 v5 治理跑一轮 pressure test，记录 before 数据。

**依赖**: V6-0-3  
**预估**: 3h（含 2 个模型各跑 3 scenario）

**文件变更**:
- Create: `artifacts/eval-baseline-2026-07-26.json`
- Create: `artifacts/eval-baseline-2026-07-26.md`（人类可读摘要）

- [ ] **Step 1**: 在干净会话中跑 P1/P2/P3（模型 1，如 GPT 5.6）
- [ ] **Step 2**: 同场景再跑（模型 2，如 Fable 5）
- [ ] **Step 3**: 记录：是否遵守 gate、跳步行为、rationalization 原文
- [ ] **Step 4**: 写入 JSON：`scenario_id`, `model`, `passed`, `violations[]`, `rationalizations[]`, `notes`
- [ ] **Step 5**: 摘要 markdown：通过率、高频违规、建议优先修的 gate

**验收**:
- [ ] 6 条记录（3 scenario × 2 model）
- [ ] P3 在 Phase 2 前应记录为「预期失败」

---

## Phase 1：文档去重 + 审查对齐

### V6-1-1：瘦身 `gs-hybrid-v3/SKILL.md`

**目标**: SKILL.md < 200 行，消除与 YAML 的双写。

**依赖**: V6-0-1  
**预估**: 3h

**文件变更**:
- Modify: `skills/hybrid/gs-hybrid-v3/SKILL.md`
- Modify: `docs/skills-reference.md`（若自动生成则跑生成脚本）

**删除清单**:
- [ ] **Step 1**: 删除状态转换明细表（→ 指向 `governance/state-machine.yaml`）
- [ ] **Step 2**: 压缩流程 ASCII 图为 ≤10 行摘要
- [ ] **Step 3**: 删除 Superpowers/GStack 完整路由表（→ 指向 `schema/skill-routes.yaml`）
- [ ] **Step 4**: 删除 Gate 细则重复（→ 指向 `governance/gates.yaml`）
- [ ] **Step 5**: 保留：启动语、L0–L3 表、HARD-GATE 7 条、模块索引、真相源指针
- [ ] **Step 6**: `wc -l SKILL.md` 确认 < 200
- [ ] **Step 7**: `./scripts/check-skill-routes.sh` 仍通过

**验收**:
- [ ] 行数 < 200
- [ ] 路由健康检查 0 error
- [ ] 无与 YAML 冲突的独立规则定义

---

### V6-1-2：对齐 inline self-review

**目标**: L1/L2 用 inline checklist；L3 才跨模型审查；SDD 仅用于并行执行。

**依赖**: V6-0-1  
**预估**: 4h

**文件变更**:
- Modify: `skills/hybrid/gs-hybrid-v3/modules/04b-self-review.md`
- Modify: `skills/hybrid/gs-hybrid-v3/SKILL.md`（路由摘要段）
- Modify: `schema/skill-routes.yaml`（SELF_REVIEW 段）
- Modify: `skills/hybrid/gs-hybrid-v3/modules/03b-task-decomposition.md`（若引用 SDD review loop）

- [ ] **Step 1**: 在 `04b-self-review.md` 增加「按级别审查策略」表（L1/L2/L3）
- [ ] **Step 2**: 将 SDD task-reviewer 降级为「仅并行任务执行时」
- [ ] **Step 3**: L1/L2 增加 inline checklist（对齐 Superpowers 5.0.6：placeholder、一致性、范围、歧义）
- [ ] **Step 4**: L3 保留 `gstack:codex` 触发条件
- [ ] **Step 5**: 更新 `skill-routes.yaml` SELF_REVIEW：
  - `subagent-driven-development` → `manual: true`，note 改为「并行执行专用」
  - `requesting-code-review` → L2+ optional
- [ ] **Step 6**: 更新 SKILL.md 路由摘要（5 个锚点内）
- [ ] **Step 7**: `./scripts/check-skill-routes.sh`

**验收**:
- [ ] 文档不再写「L2 默认 SDD task-reviewer」
- [ ] 路由表与 module 描述一致

---

### V6-1-3：模块加载表下沉

**目标**: 加载策略机器可读，SKILL.md 只引用。

**依赖**: V6-1-1  
**预估**: 2h

**文件变更**:
- Create: `schema/module-load-map.yaml`
- Modify: `skills/hybrid/gs-hybrid-v3/SKILL.md`
- Create: `scripts/validate-module-load-map.sh`（可选）
- Modify: `scripts/validate-module-load.sh`（若已存在则对接）

- [ ] **Step 1**: 从 SKILL.md 提取「加载策略速查表」→ `module-load-map.yaml`
- [ ] **Step 2**: YAML 结构：`state → module → framework_files[]`
- [ ] **Step 3**: SKILL.md 改为单行引用 + `scripts/validate-module-load.sh` 入口
- [ ] **Step 4**: 校验脚本：每个 state 在 map 中有条目；framework 文件路径存在
- [ ] **Step 5**: 接入 CI（`.github/workflows/ci.yml`）或文档注明手动跑法

**验收**:
- [ ] SKILL.md 不再含完整加载表
- [ ] `module-load-map.yaml` 与 modules 头部声明一致

---

## Phase 2：Gate 硬化

### V6-2-1：verification-evidence gate

**目标**: SHIP_REVIEW 前必须有可机器检查的测试证据。

**依赖**: V6-0-3  
**预估**: 1d

**文件变更**:
- Create: `governance/gates/verification-evidence.sh`
- Modify: `governance/gates.yaml`（G016）
- Modify: `governance/gates.json`（若由 yaml 同步则跑 `yaml2json.sh`）
- Modify: `governance/state-machine.yaml`（SHIP_REVIEW `entry_gate`）
- Modify: `governance/machine.json`（同上）
- Modify: `governance/context-contract.yaml`（`verification_evidence_path` key）
- Create: `artifacts/verification/.gitkeep`

- [ ] **Step 1**: 设计证据格式（`artifacts/verification/latest.txt` 或 context key）
- [ ] **Step 2**: 实现 `verification-evidence.sh`：
  - 读 `common-context.sh`
  - L1：`approval_mode: conversation` + 非空证据文件
  - L2+：证据含 pass 信号（可配置 `test_command` 输出匹配）
  - 返回 0/1/2
- [ ] **Step 3**: 注册 `gates.yaml` id G016，`applies_to: [SHIP_REVIEW]`，`severity: hard`
- [ ] **Step 4**: `state-machine.yaml` SHIP_REVIEW `entry_gate: verification-evidence`
- [ ] **Step 5**: 失败场景测试：`check-gates.sh --from IMPLEMENTATION --to SHIP_REVIEW` 无证据 → block
- [ ] **Step 6**: 通过场景测试：有证据文件 → pass
- [ ] **Step 7**: 更新 P3 scenario 预期为「Phase 2 后应 pass」

**验收**:
- [ ] gate 脚本独立可执行
- [ ] `validate-state-machine.sh` 通过
- [ ] P3 手动 eval 可阻断无证据 ship

---

### V6-2-2：L1 对话确认 gate 强化

**目标**: 防止模型自填 `requirements_confirmed` / `plan_confirmed`。

**依赖**: V6-2-1  
**预估**: 4h

**文件变更**:
- Modify: `governance/gates/requirement-lock.sh`
- Modify: `governance/gates/plan-confirm.sh`
- Modify: `governance/context-contract.yaml`
- Modify: `governance/gates/common-context.sh`（若需新 key 解析）

- [ ] **Step 1**: `context-contract.yaml` 增加：
  - `confirmed_at`（ISO8601）
  - `confirmed_by`（枚举：`user`）
- [ ] **Step 2**: `requirement-lock.sh`：L1 对话模式需三者齐全：`requirements_confirmed` + `confirmed_at` + `confirmed_by: user`
- [ ] **Step 3**: `plan-confirm.sh`：同上，针对 `plan_confirmed`
- [ ] **Step 4**: 无 spec 文件时：fallback 检查 `artifacts/workflow-state.md` 含确认记录
- [ ] **Step 5**: 构造失败：仅 `requirements_confirmed: true` 无 timestamp → block
- [ ] **Step 6**: 构造通过：完整三元组 → pass
- [ ] **Step 7**: 更新 P2 scenario 的 pass/fail 判定说明

**验收**:
- [ ] 模型自填确认无法通过 gate
- [ ] L1 快路径仍可用（用户对话确认后写入 context）

---

### V6-2-3：model_tier 契约扩展

**目标**: capable 模型走压缩流程，hard gate 不减免。

**依赖**: V6-1-2  
**预估**: 1d

**文件变更**:
- Modify: `governance/context-contract.yaml`
- Modify: `scripts/resolve-skill-routes.sh`
- Modify: `schema/skill-routes.yaml`（可选 `tier_filter` 字段）
- Modify: `skills/hybrid/gs-hybrid-v3/modules/02-complexity.md`
- Modify: `hooks/session-start` 或 `hooks/session-start-codex`（注入默认 `model_tier: capable`）

- [ ] **Step 1**: `context-contract.yaml` 增加 `model_tier` + `model_overlay_rules`（见父 plan）
- [ ] **Step 2**: `resolve-skill-routes.sh` 读 context 中 tier，capable 时：
  - 跳过 `full_subagent_review` 类路由
  - 保留所有 hard gate
- [ ] **Step 3**: `02-complexity.md` 说明 capable tier 可合并 DISCOVERY+ARCH_REVIEW 对话，但不跳过 REQUIREMENT_LOCK
- [ ] **Step 4**: session-start 写入默认 tier（可环境变量 `HYBRID_MODEL_TIER` 覆盖）
- [ ] **Step 5**: 文档：与 GStack `MODEL_OVERLAY` 的关系（互补，不冲突）

**验收**:
- [ ] `resolve-skill-routes.sh --level L1 --json` capable vs baseline 输出不同
- [ ] gate 校验结果不因 tier 减免

---

### V6-2-4：SHIP_REVIEW 路由收敛

**目标**: SHIP 阶段明确「证据优先 + gstack:ship 执行」，hybrid 不重复 prose。

**依赖**: V6-2-1  
**预估**: 2h

**文件变更**:
- Modify: `schema/skill-routes.yaml`
- Modify: `skills/hybrid/gs-hybrid-v3/modules/05-ship-review-retro.md`
- Modify: `skills/hybrid/gs-hybrid-v3/SKILL.md`（SHIP 路由摘要）

- [ ] **Step 1**: `skill-routes.yaml` SHIP_REVIEW 顺序：`verification-before-completion` → `gstack:ship`
- [ ] **Step 2**: `05-ship-review-retro.md` 删除与 gstack ship 重复的步骤清单
- [ ] **Step 3**: 明确：先过 `verification-evidence` gate，再 invoke ship skill
- [ ] **Step 4**: `check-skill-routes.sh`

**验收**:
- [ ] SHIP 模块 < 原行数 30%
- [ ] 路由与 module 一致

---

## Phase 3：路由扩展 + Eval 闭环

### V6-3-1：新 GStack 技能 eval

**目标**: 用证据决定是否将 `autoplan` / `spec` / `health` 纳入路由。

**依赖**: V6-0-4  
**预估**: 2d

**文件变更**:
- Create: `tests/hybrid-pressure/scenarios/P4-autoplan-l1.md`
- Create: `tests/hybrid-pressure/scenarios/P5-spec-discovery.md`
- Create: `artifacts/eval-gstack-candidates-2026-07.json`

- [ ] **Step 1**: 为 autoplan / spec / health 各写 1 个 scenario
- [ ] **Step 2**: 各跑 2 模型 × 1 次，记录 gate 通过率、耗时、缺陷
- [ ] **Step 3**: 决策表：纳入 / 暂缓 / 拒绝（需写明原因）
- [ ] **Step 4**: 若纳入：更新 `skill-routes.yaml` + `.sync-filter.json`（单独 commit）

**验收**:
- [ ] 每个候选技能有书面 go/no-go 决策
- [ ] 无 eval 证据的技能不得入路由

---

### V6-3-2：hybrid eval CI

**目标**: 治理改动有自动化回归（先记录，后阻断）。

**依赖**: V6-0-3, V6-2-1  
**预估**: 1d

**文件变更**:
- Create: `tests/hybrid-pressure/run-eval.sh`
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 1**: `run-eval.sh --list` 列出 scenario
- [ ] **Step 2**: `run-eval.sh --gate-check` 仅跑 gate 脚本层面（不依赖 LLM）
- [ ] **Step 3**: `run-eval.sh --baseline` 输出 JSON artifact（CI upload）
- [ ] **Step 4**: CI 增加 job：`validate-state-machine` + `check-skill-routes` + `run-eval.sh --gate-check`
- [ ] **Step 5**: Phase 2 完成后：`--gate-check` 失败则 CI 红

**验收**:
- [ ] 本地 `./tests/hybrid-pressure/run-eval.sh --gate-check` 绿
- [ ] CI workflow 绿

---

### V6-3-3：周更 SOP + ADR-010

**目标**: 固化运维节奏与 v6 设计存档。

**依赖**: V6-3-2  
**预估**: 4h

**文件变更**:
- Create: `docs/upstream-sync-sop.md`
- Create: `decision-layer/adr/ADR-010-v6-capable-model-governance.md`
- Modify: `specs/plans/2026-07-26-gs-hybrid-v6-capable-model-plan.md`（勾选 DoD）

- [ ] **Step 1**: SOP：sync → validate → eval → commit 检查清单
- [ ] **Step 2**: ADR-010：问题、方案、eval 结果、不做清单
- [ ] **Step 3**: 父 plan v6.0 DoD 逐项勾选
- [ ] **Step 4**: `RELEASE-NOTES.md` 增加 v6.0 条目（若发布）

**验收**:
- [ ] ADR-010 含 before/after eval 摘要
- [ ] SOP 可被新人按步骤执行

---

## 里程碑检查点

### M1：基线就绪（Phase 0 完成）

- [ ] V6-0-1 ~ V6-0-4 全部 ✅
- [ ] `artifacts/skill-baseline-*.json` 存在
- [ ] `artifacts/eval-baseline-*.json` 存在

### M2：薄入口（Phase 1 完成）

- [ ] V6-1-1 ~ V6-1-3 全部 ✅
- [ ] SKILL.md < 200 行
- [ ] `module-load-map.yaml` 存在

### M3：硬 Gate（Phase 2 完成）

- [ ] V6-2-1 ~ V6-2-4 全部 ✅
- [ ] `verification-evidence` 阻断无证据 ship
- [ ] L1 确认三元组 enforced
- [ ] `model_tier` 可解析

### M4：v6.0 发布（Phase 3 完成）

- [ ] V6-3-1 ~ V6-3-3 全部 ✅
- [ ] CI eval job 绿
- [ ] ADR-010 合并

---

## 本周执行顺序（推荐）

| 日 | 任务 ID | 产出 |
|----|---------|------|
| D1 | V6-0-1, V6-0-2, V6-0-3 | commit + baseline JSON + scenario 文件 |
| D2 | V6-0-4, V6-1-1 | eval baseline + SKILL.md 瘦身 |
| D3 | V6-1-2, V6-1-3 | inline review + module-load-map |
| D4 | V6-2-1 | verification-evidence gate |
| D5 | V6-2-2, V6-2-4 | L1 确认 + SHIP 路由 |
| D6 | V6-2-3 | model_tier |
| D7 | V6-3-2, V6-3-3 | CI + ADR-010 |
| D8+ | V6-3-1 | 候选技能 eval（可延后） |

---

## 风险登记

| 风险 | 影响 | 缓解 | 关联任务 |
|------|------|------|---------|
| verification gate 过严阻断日常 L1 | 高 | L1 允许 conversation + 粘贴 test 输出 | V6-2-1 |
| SKILL 瘦身后路由摘要断裂 | 中 | 改后立即跑 check-skill-routes | V6-1-1 |
| model_tier 与 GStack overlay 冲突 | 中 | hybrid 只管 gate/路由，不改 gstack skill | V6-2-3 |
| eval 依赖特定模型不可用 | 低 | gate-check 层不依赖 LLM | V6-3-2 |

---

**版本**: v1.0  
**最后更新**: 2026-07-26
