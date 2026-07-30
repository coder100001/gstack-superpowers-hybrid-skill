# gs-hybrid-v7-simplify - Work Plan (v2 / adversarial-reviewed)

## TL;DR (For humans)

**What you'll get:** 把模型加载的 workflow 定义从 ~2,759 行降到 ~1,200 行。引入"双名协议"：SKILL.md 用 5 个业务态 (DEFINE/PLAN/IMPLEMENT/VALIDATE/SHIP) 让模型思考，每个产物**同时标注 governance 13 个状态名**让 CI 门禁继续工作。治理基础设施零改动。

**Why this approach:** 对抗性审查上一版计划后发现：原计划的中心假设——"SKILL.md 和 governance/ 服务不同消费者、可以接受不一致"——是错的。`governance/gates/requirement-lock.sh` `plan-confirm.sh` `verification-evidence.sh` `decision-freeze.sh` 实测按 governance 状态名匹配模型产物。原计划让 SKILL.md 用新名、governance 用旧名，**门禁永远不会触发**——锁还在门上，但钥匙换了形状。

新方案：模型按 5 态业务名思考（人类友好），但产物标记同时挂 governance 名（机器可校验）。例：DEFINE 阶段完成时产出 `.omo/state/REQUIREMENT_LOCK.passed`（governance 名，门禁认）+ SKILL 内部说"DEFINE 已锁需求"。模型从 SKILL.md 顶部对照表读到这一对应关系，分开记两种名。门禁继续工作，模型简化受用。

**What it will NOT do:** 不改 governance/、不改 schema/、不改 CI、不改 gate 脚本、不改 transition.sh、不改 state-manager.sh、不改 README 状态名表、不删 governance JSON 备份。governance 100% 静止。

**Effort:** Short-Medium（6-8 小时，比上一版 4-6h 多出"对照表 + dry-run + L0 调停"的工作）
**Risk:** Low-Medium——只改模型读的文件 + 增量验证；唯一破坏性操作 (.backups/ 删除) 被 dry-run 包住
**Decisions to sanity-check:** v7 业务名↔governance 名对照表设计；L0 的 REQUIREMENT_LOCK/PLAN_CONFIRM 显式豁免条款来自 governance/state-machine.yaml

---

> TL;DR (machine): Short-Medium effort, Low-Medium risk. 4 todos ordered. Rewrite SKILL.md (~110 lines incl. dual-name mapping table), compress 9 modules→5 (~1,200 lines, evidence-based ceiling), safe-delete .backups/ with dry-run first, untrack binary. Final wave: sync state-machine validate + 3 pressure tests + L2 walkthrough.

## 调查基准（对抗于上一版"接受不一致"）

实测证据：
- `governance/state-machine.yaml` 定义 **13 个状态**：IDEA, DISCOVERY, REQUIREMENT_LOCK, ARCH_REVIEW, TASK_DECOMPOSITION, PLAN_CONFIRM, CONTEXT_HYDRATION, IMPLEMENTATION, SELF_REVIEW, QA, SHIP_REVIEW, RETRO, ABORTED（12 + ABORTED terminal）
- 实测 **4 个 `hard_gate: true` 状态**（不是 "3 个 hard gate"，也不是"7 条 HARD-GATE"）：REQUIREMENT_LOCK, TASK_DECOMPOSITION, PLAN_CONFIRM, CONTEXT_HYDRATION
- `governance/gates.yaml` 共 **15 个 gate rules**：5 个硬门禁 + 10 个普通 gate
- `governance/gates/*.sh` 实测按 governance 状态名匹配产物：`requirement-lock.sh` 查 `REQUIREMENT_LOCK` 通过记录，`plan-confirm.sh` 查 `PLAN_CONFIRM` 通过记录，`verification-evidence.sh` 查 `SHIP_REVIEW` 证据，`decision-freeze.sh` 查 `IMPLEMENTATION` 冻结状态
- L0 路径在 state-machine.yaml 显式定义 `IDEA → IMPLEMENTATION` 跃迁 `complexity_scope: [L0]`——L0 跳过决策层门禁是治理层明文豁免，不是"hard gate 漏掉"
- modules 9 文件实际 2,590 行分布（按大→小）：

| 文件 | 行数 | 大致用途 |
|---|---|---|
| 03b-task-decomposition | 780 | Spec→Task 分解、依赖图、验收映射 |
| 03a-discovery-arch | 478 | 需求澄清、架构评审、ADR |
| 04b-self-review | 335 | 自审清单、QA 流程 |
| 07-handling | 316 | 异常路径、回退流程 |
| 04a-execution-hydration | 248 | 注水、TDD、决策冻结 |
| 02-complexity | 194 | L0-L3 分级标准 |
| 01-intro | 157 | 总览、路由表 |
| 06-workflows | 61 | L0/L1/L2/L3 路径汇总 |
| 05-ship-review-retro | 21 | 发布检查 |
| **total** | **2,590** | |

为压到 ~900 行需要砍 65%（1,600+ 行），但保留 L0-L3 分级、Spec→Task 分解、依赖图规则、验收映射、异常恢复路径——这五项是硬内容非冗余。诚实上限 **~1,200 行（砍 55%）**，给安全边际；若压缩时发现冗余确实更高，可向 ~1,000 收，但不强压到 900。

- `.backups/` 不在 git（`git ls-files .backups/` = 0）、已在 `.gitignore`。3 份完整项目快照（20260518_154914、20260518_161652、20260726_105234），每份 ~68MB，含完整 governance/skills/。`latest` 文件指向最近一份。**全部 7 个顶层目录与现有仓库同名——快照是覆盖式，删后无任何 git/外部恢复路径。**
- `gstack-skills/bin/gstack-global-discover` 实测 68MB（不是 65），编译 Mach-O。
- `tests/hybrid-pressure/scenarios/` 硬编码 governance 状态名断言：
  - **P1** `["IDEA", "IMPLEMENTATION", "SHIP_REVIEW"]`，断言不应进入 DISCOVERY/REQUIREMENT_LOCK/PLAN_CONFIRM/CONTEXT_HYDRATION/SELF_REVIEW
  - **P2** 标题 "Skip REQUIREMENT_LOCK — Model Must Block at Gate"，全程断言 `REQUIREMENT_LOCK gate 必须阻断`
  - **P3** 断言 `SHIP_REVIEW 阶段不放行 no-evidence ship`
  - 双名协议下这些测试**不需要改断言**——模型产物同时含 governance 名，断言仍然命中

## Scope

### Must have
1. 重写 `gs-hybrid-v3/SKILL.md` 为 5 态工作流 + 顶部 v7 业务名↔governance 名对照表
2. 压缩 modules 9 → 5 文件，~1,200 行 (ceiling 不强压到 900)；每个模块顶部含"本 v7 态对应 governance 子状态及门禁"子表
3. 安全清理 `.backups/` + untrack 68MB 二进制
4. 验证 governance 治理链未脱钩（gate 脚本仍能识别 v7 SKILL.md 教模型输出的产物名）

### Must NOT have (guardrails, anti-slop, scope boundaries)
- 不修改 governance/ 下的任何文件（state-machine.yaml、gates.yaml、gate 脚本、transition.sh、state-manager.sh、JSON 备份）
- 不修改 schema/skill-routes.yaml
- 不修改 CI 配置
- 不修改 README 状态名表（双名协议让 README 仍按 governance 名理解）
- 不改动 skills/superpowers/ 和 skills/gstack/
- 不写新的 transition.sh / state-manager.sh 替代品
- 不在 SKILL.md/modules 内复制上游 skill 内容（复述是上一版 modules 体积膨胀的主因）

## Verification strategy

- Test decision: 测试 + 静态校验双管齐下
- Evidence: `.omo/evidence/gs-hybrid-v7-simplify/`
- 关键验证四件：
  1. `scripts/validate-state-machine.sh` 通过（治理合规）
  2. `tests/hybrid-pressure/` P1/P2/P3 三场景行为符合断言（双名下断言仍命中）
  3. L2 完整路径走查：v7 业务名 ↔ governance 名在每个跃迁同时被触发
  4. `.backups/` 删除前 dry-run 留存清单

## Key design decisions（上一版未明确，本版补）

### Decision A: Dual-name protocol（核心设计）

SKILL.md 顶部嵌入对照表（5 行 v7 业务名 ↔ 13 governance 状态名，明确 layering 保留）：

```
| v7 业务态 |  governance 子状态（按发生序）                  | layer   | 门禁                                  |
|----------|----------------------------------------------|---------|----------------------------------------|
| DEFINE   | IDEA → DISCOVERY → REQUIREMENT_LOCK         | decision| requirement-lock (hard)               |
| PLAN     | ARCH_REVIEW → TASK_DECOMPOSITION → PLAN_CONFIRM | decision | arch-review-lock, task-decomposition-lock (hard), plan-confirm (hard) |
| IMPLEMENT| CONTEXT_HYDRATION → IMPLEMENTATION           | bridge → execution | context-hydration (hard), decision-freeze |
| VALIDATE | SELF_REVIEW → QA                             | execution | test-presence, acceptance-check        |
| SHIP     | SHIP_REVIEW → RETRO                          | execution| verification-evidence                  |
| ABORTED  | ABORTED                                      | terminal | —                                   |
```

意图：模型按 5 态思考业务流程；跨越 v7 态边界时必须产出对应 governance 名的产物文件（让 gate 脚本能识别）。例：DEFINE 完成 → 产出 `.omo/state/REQUIREMENT_LOCK.passed` 才能进 PLAN。

### Decision B: L0 豁免显式（修复 P2 冲突）

治理 YAML 在 `IDEA → IMPLEMENTATION` 跃迁标 `complexity_scope: [L0]`，是层架构明文豁免而不是 hard gate 漏。

SKILL.md L0 路由条目必须明写：
```
L0: DEFINE(极简：仅评估=IDEA→L0) → IMPLEMENT → SHIP
    L0 不触发 REQUIREMENT_LOCK、PLAN_CONFIRM、CONTEXT_HYDRATION、SELF_REVIEW。
    这是 governance/state-machine.yaml 的显式豁免，不是"跳过门禁"。
```

避免模型在 P2（用户想从 IDEA 直接写实现）情境误判："L0 可跳 = 这里也可跳"。

### Decision C: 压缩 ceiling 取证后的 ~1,200 行

不硬压 900——03b (780)、03a (478)、04b (335)、07-handling (316) 四份合计 1,909 行是决策指引主体，砍到 900 需删该四份 50%+ 硬内容，破坏决策指引。诚实上限 ~1,200（每模块 200-250 行）。压不到时优先保证：异常恢复路径不丢、关键决策指引不丢、L0-L3 分级表不丢。

## Execution strategy

### Single wave - 顺序执行

```
顺序: Todo 3 (dry-run 删备份) → Todo 1 (SKILL.md) → Todo 2 (modules) → 验证波
```

Todo 3 先做不再因为"零风险"——而是先**dry-run 留清单**、留恢复窗口、然后真删，把不可逆操作隔离在准备就绪后。Todo 1+2 是同步设计（对照表与模块子表必须一致），1 先写大方向、2 复用 1 的对照表。

### Dependency matrix
| Todo | Depends on | Blocks | Can parallelize with |
| --- | --- | --- | --- |
| 3 | — | — | — |
| 1 | 3 | 2 | — |
| 2 | 1 | 验证 | — |

## Todos

- [ ] 1. 重写 gs-hybrid-v3/SKILL.md 为 5 态工作流 + 双名对照表
  What to do: 重写 `skills/hybrid/gs-hybrid-v3/SKILL.md`。核心内容（按序布局）：
    1. 顶部"v7 业务态 ↔ governance 状态"对照表（Decision A 的 5 行表，~10 行）
    2. 5 个业务态定义 + 每态 1 行：负责做什么、对应 governance 子状态序列
    3. 3 个 v7 态间跃迁的 hard gate：
       - DEFINE→PLAN: governance REQUIREMENT_LOCK.passed 产物必须存在（用户确认需求）
       - PLAN→IMPLEMENT: governance PLAN_CONFIRM.passed 产物必须存在（用户确认执行计划）
       - VALIDATE→SHIP: governance SHIP_REVIEW 阶段需 verification-evidence.sh 通过的产物（验证证据）
    4. IMPLEMENT 冻结规则：进入 IMPLEMENT 时 governance `decision-freeze` 未 conflict，架构/需求/API 契约不得自行更改
    5. L0/L1/L2/L3 路由表（按 Decision B，L0 行明写"治理显式豁免，非跳过门禁"）：
       - L0: DEFINE(极简：仅 IDEA→L0 评估) → IMPLEMENT → SHIP
       - L1: DEFINE → PLAN(轻量；跳过 CONTEXT_HYDRATION 实体但隐式检查) → IMPLEMENT → SHIP
       - L2: DEFINE → PLAN → IMPLEMENT → VALIDATE → SHIP 全流程
       - L3: 全流程 + 多轮 SELF_REVIEW→QA
    6. 模块引用：每个 v7 态指向 `modules/0X-{name}.md`
    7. 异常处理一句话 + 指向 `modules/04-validate.md` 异常恢复路径小节
    8. 时代码示意伪流程：v7 业务名 + 括号内 governance 名标注，例如 `DEFINE → PLAN (must pass REQUIREMENT_LOCK gate)`
  Must NOT do:
    - 不改 governance/ 状态机
    - 不改 schema/skill-routes.yaml
    - 不改任何 gate 脚本
    - 不在 SKILL.md 复述 brainstorming/writing-plans 等上游 skill 内容
    - 不重新引入 7 hard-gate / 3 hard-gate 这种与 YAML 不符的数字
  目标：新 SKILL.md ≤ 120 行（含对照表）。
  Parallelization: Wave 1 | Blocked by: 3 | Blocks: 2
  References: 当前 `skills/hybrid/gs-hybrid-v3/SKILL.md`（169 行 v6.0.0）；`governance/state-machine.yaml`（13 状态、4 个 hard_gate）；4 路对抗性审查共识建议的 DEFINE/PLAN/IMPLEMENT/VALIDATE/SHIP 命名。
  Acceptance criteria:
    - 新 SKILL.md ≤ 120 行（含对照表）
    - 顶部含 5 行 v7↔governance 对照表（每行 governance 子状态完整、layer 准确、门禁名对应 gates.yaml）
    - 3 个 v7 态间 hard gate 跃迁条件显式含 governance 产物名（如 `REQUIREMENT_LOCK.passed`）
    - L0/L1/L2/L3 路由表与 state-machine.yaml 的 complexity_scope 数组完全匹配
    - L0 路由行明文标注"治理显式豁免 ≠ 跳门禁"
  QA scenarios:
    - happy — 按 L2 路径走遍：DEFINE→PLAN→IMPLEMENT→VALIDATE→SHIP，每个跃迁同时触发 v7 业务检查 + governance 名门禁记录。人工读取能从对照表反查到 governance 脚本查的产物名。
    - failure — 对照表缺失某 governance 子状态（如漏写 CONTEXT_HYDRATION）→ IMPLEMENT 时 governance context-hydration.sh 永不通过（模型不知道产什么）。在验收时用 `grep -c "CONTEXT_HYDRATION" SKILL.md` 应返回 ≥1。
  Evidence: `.omo/evidence/gs-hybrid-v7-simplify/task-1-skillmd.md`
  Commit: Y | feat(hybrid): gs-hybrid-v7 - 5-state workflow + dual-name mapping (DEFINE/PLAN/IMPLEMENT/VALIDATE/SHIP)

- [ ] 2. 压缩 modules/：9 文件 → 5 文件，~1,200 行（诚实 ceiling）
  What to do: 将 `skills/hybrid/gs-hybrid-v3/modules/` 压缩为 5 个文件，对应 5 个 v7 态：
    - `01-define.md`：复杂度自评 + 需求澄清 + ADR 要点（合并 01-intro + 02-complexity + 03a 的 DISCOVERY/REQUIREMENT_LOCK 部分）。顶部含 governance 子状态子表：IDEA, DISCOVERY, REQUIREMENT_LOCK 的 entry_gate、layer、hard_gate 标记。
    - `02-plan.md`：架构评审要点 + 任务拆解 + 验收映射（合并 03a 的 ARCH_REVIEW 部分 + 03b 全部 780 行）。顶部含 ARCH_REVIEW, TASK_DECOMPOSITION, PLAN_CONFIRM 子表。
    - `03-implement.md`：注水清单 + TDD 要点 + 决策冻结边界（合并 04a + 06-workflows 部分）。顶部含 CONTEXT_HYDRATION, IMPLEMENTATION 子表。
    - `04-validate.md`：自审清单 + QA 流程 + **异常处理恢复路径**（合并 04b + 05 + 07-handling）。顶部含 SELF_REVIEW, QA 子表。
    - `05-ship.md`：发布检查 + 复盘要点（合并 05-ship-review-retro 的剩余部分 + 06-workflows 的 L0-L3 路径汇总）。顶部含 SHIP_REVIEW, RETRO 子表。
  可以删除的内容（明确清单）：
    - 上游 skill（brainstorming/writing-plans/test-driven-development 等）的逐字复述——只保留一句 references 链接
    - 每个模块中重复的 ASCII 流程图（统一一份在 02-plan 主体流程已够）
    - "为什么需要这个阶段"的说服性散文（模型不需要被说服，只需要规则）
    - governance/ 已定义的 gate 规则的复述（只保留"本态对应 governance 名"的一行指向）
  必须保留的硬内容（不允许为压行数砍）：
    - L0-L3 分级判定条件表（02-complexity 的核心）
    - Spec→Task 分解方法（03b 的核心决策指引）
    - 依赖图规则（03b 的核心）
    - 验收标准映射算法（03b）
    - 异常恢复路径（07-handling 的 IMPLEMENTATION→ARCH_REVIEW 回退、QA 失败回退）
    - 各模块顶部 governance 子状态子表（Decision A 的延续）
  Must NOT do:
    - 不删除异常恢复路径任何分支
    - 不从外部 skill 复制内容进来
    - 不在模块内重新声明 hard gate 规则细节（这是 governance 的 SSOT）
    - 不在模块顶部子表中省略任何 governance 子状态的 entry_gate（如 CONTEXT_HYDRATION 必须列 context-hydration）
  目标：每模块 ≤ 250 行，总计 ~1,000-1,200 行；不强行压到 900。
  Parallelization: Wave 1 | Blocked by: 1 | Blocks: 验证
  References: 当前 modules/ 9 文件 2,590 行（分布见上"调查基准"表）；Agent 2 提示 500 行不现实、建议 800-1,000；本版再上调到 1,200 留安全边际。
  Acceptance criteria:
    - modules/ 下只有 5 个 .md 文件命名与 5 个 v7 态对应
    - 总行数 1,000-1,200 行
    - 每个模块顶部 5 行子表覆盖该 v7 态对应的所有 governance 子状态 + entry_gate 名
    - `grep -c "ARCH_REVIEW" modules/02-plan.md` ≥ 1
    - `grep -c "异常\|回退\|restore\|rollback" modules/04-validate.md` ≥ 3（异常恢复路径保留）
    - `grep -lE "brainstorming|writing-plans" modules/*.md` 半数以上文件不应出现该名（除 references 行）
  QA scenarios:
    - happy — 5 文件顶部子表与 SKILL.md 对照表一一对应；异常路径在 04-validate.md 仍可被人工追到。
    - failure — 03b 的 Spec→Task 分解被压到只剩"参考 upstream writing-plans"一句 → 模型碰到 L2 任务分裂时无决策指引、靠猜。检查方法：模块含"输入 X → 步骤 Y → 产物 Z"式算法描述 ≥ 3 处。
  Evidence: `.omo/evidence/gs-hybrid-v7-simplify/task-2-modules.txt`
  Commit: Y | refactor(hybrid): compress 9 modules to 5 (~1,200 lines incl. dual-name mapping sub-tables)

- [ ] 3. 文件级清理：.backups/ 与 68MB 二进制
  What to do（**强制 dry-run 后真删**，不可省略 dry-run 步骤）:
    a) **Dry-run 阶段**（Todo 3.1）：执行 `du -sh .backups/*` + `ls -la .backups/latest` + 确认 `.backups/` 下 7 个顶层目录均与仓库现有顶层目录同名（无快照独有产物）。把输出落盘到 `.omo/evidence/gs-hybrid-v7-simplify/task-3-dryrun.txt`。
    b) **二次确认**：确认当前 git 工作区无未提交变更（`git status --porcelain` 为空或仅含本次计划正在做的改动）。`.backups/latest` 内容指向 20260726_105234，删除 == 与最新一次完整快照说再见。**确认仓库当前状态是健康的、不需要从快照恢复。**
    c) **真删**：`rm -rf .backups/20260518_154914 .backups/20260518_161652 .backups/20260726_105234 .backups/latest .backups/`（精准列出每份快照再 rm -rf 顶层，便于事后审计谁删的）
    d) **Untrack 二进制**：`git rm --cached gstack-skills/bin/gstack-global-discover`
    e) **更新 .gitignore**：在文件中添加 `gstack-skills/bin/gstack-global-discover`
    f) **确认**：`git status` 显示 `.backups/` 已不在工作区、二进制不再跟踪、磁盘文件仍在
  Must NOT do:
    - 不要删除 `gstack-skills/bin/` 下其他任何文件
    - 不要在 dry-run 发现异常时直接跳过 dry-run 步骤真删
    - 不要把 dry-run 的产物清单和真删命令混在一次提交
  Parallelization: Wave 1 | Blocked by: — | Blocks: —
  References:
    - `.backups/` 实测 3 份快照（非上一版说的"两份"）：`20260518_154914`(68MB)、`20260518_161652`(68MB)、`20260726_105234`(68MB, =latest)
    - `~/.backups/latest` 指向 20260726_105234
    - `.backups/` 不在 git（`git ls-files .backups/` = 0），已在 `.gitignore` 第 27 行
    - `gstack-skills/bin/gstack-global-discover` 实测 68MB（不是 65MB），Mach-O
  Acceptance criteria:
    - `.omo/evidence/gs-hybrid-v7-simplify/task-3-dryrun.txt` 存在且含快照清单 + git 干净态确认
    - `.backups/` 不存在
    - `git ls-files --error-unmatch gstack-skills/bin/gstack-global-discover` 返回非零
    - 磁盘上 `gstack-skills/bin/gstack-global-discover` 文件仍存在（`ls` 能找到）
    - `.gitignore` 含该路径
  QA scenarios:
    - happy — git status 显示 .backups/ 真正消失、二进制 untrack、.gitignore 更新；还原 check：从未在 dry-run 阶段看到过任何"快照独有产物"。
    - failure — dry-run 发现 `.backups/20260726_105234/` 下有当前仓库没有的文件 → **暂停删除**，让用户决定该独有产物是否需要先合并进仓库。Evidence 留存清单。
  Evidence: `.omo/evidence/gs-hybrid-v7-simplify/task-3-cleanup.txt`
  Commit: Y | chore: remove .backups/ (3 snapshots, ~204MB) and untrack 68MB compiled binary

- [ ] 4. 双名协议闭环验证：治理链脱钩检查
  What to do: 写一个一次性 shell 脚本 `.omo/evidence/gs-hybrid-v7-simplify/validate-dual-name.sh`（不入仓），逐对验证：
    1. SKILL.md 顶部对照表每个 governance 子状态名都在 `governance/state-machine.yaml` 的 `states:` 节点定义过
    2. SKILL.md 顶部对照表每个 entry_gate 名都在 `governance/gates.yaml` 的 `gates:` 节点定义过
    3. modules/ 每个文件顶部子表的 governance 子状态都至少被 SKILL.md 顶部对照表覆盖一次（避免 module 写了 governance 名 SKILL.md 没教）
    4. 反向：`governance/gates/*.sh` 中 grep 出的状态名都在 SKILL.md/modules 内能被对应"输出 v7 态产物时标注这个 governance 名"
    5. 把不匹配项列成 markdown 报告，挂到 evidence dir
  Must NOT do:
    - 不修复 mismatch —— 只报告。修复在 todo 1/2 内做
    - 不修改 governance/ 任何文件
  Parallelization: 依赖 1+2 完成 | Blocked by: 2 | Blocks: 隐式作为 final 验证的前置
  References: 双名协议核心约束——避免上一版 reviewer 提出的"门禁脱钩"问题复发。
  Acceptance criteria:
    - 脚本运行退出码 0
    - 输出报告无 mismatch 行
    - 如有 mismatch：必须先修复 todo 1/2，不接受带 mismatch 验收
  QA scenarios:
    - happy — 0 mismatch，governance 链路完全闭环。
    - failure — 发现 SKILL.md 对照表漏了 `CONTEXT_HYDRATION`，导致 module 03-implement 顶部子表提到的 `context-hydration` 在 SKILL.md 主对照表无注释——但不致失败，因为模块子表已包含；列为告警。
  Evidence: `.omo/evidence/gs-hybrid-v7-simplify/validate-dual-name.report.md`
  Commit: N（验证脚本不入仓）

## Final verification wave

- [ ] F1. 治理合规: 执行 `scripts/validate-state-machine.sh`、`scripts/check-skill-routes.sh`、`scripts/resolve-skill-routes.sh`，全部 exit 0。任何非零都要在 evidence 报告原因，不可放过。
- [ ] F2. 双名闭环: 跑 Todo 4 的 `validate-dual-name.sh`，0 mismatch。
- [ ] F3. 压力测试: 运行 `tests/hybrid-pressure/` P1（L0 typo）、P2（skip REQUIREMENT_LOCK）、P3（ship without evidence）。预期 P1 走 L0 放行、P2 在 REQUIREMENT_LOCK 阻断、P3 在 SHIP_REVIEW 阻断。详细记录每场景下模型产物标注了哪个 governance 名，证明门禁因命中 governance 名而触发——不是"巧合对"。
- [ ] F4. L2 完整路径走查: 从用户输入"L2 新功能"开始，按 SKILL.md 5 态顺序走一遍，每个 v7 态边界同时记录：(a) v7 业务检查触发、(b) governance gate 触发、(c) 产物文件。3 个 hard gate 跃迁齐全：DEFINE→PLAN/PLAN→IMPLEMENT/VALIDATE→SHIP。
- [ ] F5. git 状态确认: 仅预期文件被修改（SKILL.md、modules/ 5 个、.backups/ 删除、二进制 untrack、.gitignore 更新），无意外文件。
- [ ] F6. 回归性 git 历史: 确认 3 个 commit 顺序（chore → feat → refactor），各自独立、消息前缀正确（chore/feat/refactor），每个 commit 单独 checkout 可编译/校验通过。

## Commit strategy

3 个 commit，按"不可逆操作在最前"原则：
1. `chore: remove .backups/ (3 snapshots, ~204MB) and untrack 68MB compiled binary`
2. `feat(hybrid): gs-hybrid-v7 - 5-state workflow + dual-name mapping`
3. `refactor(hybrid): compress 9 modules to 5 (~1,200 lines incl. dual-name mapping sub-tables)`

## Success criteria

1. SKILL.md ≤ 120 行（含对照表），含 5 业务态定义、3 个 hard gate 跃迁条件（每个含 governance 产物名）、L0-L3 路由表（L0 行明文标注显式豁免）、关联模块引用。
2. modules/ 5 个文件、总计 1,000-1,200 行、每模块顶部含完整 governance 子状态子表。
3. 双名闭环验证 0 mismatch —— `governance/gates/*.sh` 引用的每个治理名都在 SKILL.md/modules 教过怎么产出。
4. `scripts/validate-state-machine.sh` 退出 0。
5. P1 通过、P2 在 `requirement-lock.sh` 阻断、P3 在 `verification-evidence.sh` 阻断（实测可证门禁脚本因命中产物被触发）。
6. .backups/ 已删（dry-run 留存 evidence）、68MB 二进制 untrack 仍在磁盘。
7. governance/、schema/、CI、gate 脚本、transition.sh、README 全部零改动——但因双名协议，门禁**仍然工作**。