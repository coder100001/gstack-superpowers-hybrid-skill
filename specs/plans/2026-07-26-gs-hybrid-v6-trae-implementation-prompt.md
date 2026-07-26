# gs-hybrid-v6 — Trae IMPLEMENTATION 执行 Prompt

> **用途**: 在 Trae CN 中粘贴下方「执行块」启动 Phase 0–2 实施。  
> **前置**: execution-plan §6 已确认（PLAN_CONFIRM + CONTEXT_HYDRATION + 决策冻结）。

---

## 执行块（复制以下内容到 Trae）

```text
hybrid 进入 IMPLEMENTATION，执行已确认计划。

## Plan（SSOT，按此顺序读）

1. specs/plans/2026-07-26-gs-hybrid-v6-execution-plan.md
2. specs/plans/2026-07-26-gs-hybrid-v6-task-breakdown.md
3. 父计划只读：specs/plans/2026-07-26-gs-hybrid-v6-capable-model-plan.md

## 前置（执行前 60 秒核对）

- PLAN_CONFIRM：execution-plan §6 已勾选 → 视为用户已确认
- CONTEXT_HYDRATION：P0 spec/ADR/约束已加载；决策冻结生效
- 显式 Read：skills/superpowers/using-superpowers/SKILL.md（Trae session-start 路径可能失效，勿依赖自动 bootstrap）
- 进入 IMPLEMENTATION 前运行：
  ./governance/check-gates.sh --from CONTEXT_HYDRATION --to IMPLEMENTATION --level L3
  若 gate 失败 → BLOCKED，汇报原因，不猜测绕过

## 冻结项（IMPLEMENTATION 期间不得改）

- 已冻结的需求范围、架构决策、API 契约、领域边界
- 若必须变更 → 停止 IMPLEMENTATION，退回 Decision Layer，等用户确认

## 范围

- 仅 Phase 0–2：V6-0-1 ~ V6-2-4（11 个 task）
- 不改：skills/superpowers/**、skills/gstack/** 内容（上游维护）
- 不启动 Phase 3（V6-3-*）除非用户另行要求

## V6-0-4 特殊规则（避免伪造）

- 本 session：完成 eval 记录结构（JSON/MD 模板 + README 说明）
- 6 条跨模型实测（3 scenario × 2 model）标为 MANUAL，写入 artifacts 并注明「待人工会话补跑」
- 禁止编造 passed/violations 数据

## 执行方式：subagent-driven-development（本 session）

1. 加载 superpowers:subagent-driven-development，严格按该 skill 流程
2. 启动时检查断点：
   cat .superpowers/sdd/progress.md 2>/dev/null || echo "(无 ledger，从 V6-0-1 开始)"
   已完成 ledger 中的 task 不得重跑
3. 每个 task：
   a. scripts/task-brief <plan文件> <task序号或ID>
   b. dispatch implementer（brief 路径 + report 路径 + 全局约束）
   c. 按 task-breakdown 该 task 的 Step/验收执行（不是每个 task 都 TDD；仅写明 TDD 的 task 先失败测试）
   d. scripts/review-package → dispatch task-reviewer（brief + report + review 包）
   e. reviewer 不通过 → 一次 fix dispatch → 再 review
   f. 通过后更新 .superpowers/sdd/progress.md：
      Task V6-x-x: complete (commits <base>..<head>, review clean)
4. 依赖顺序：按 task-breakdown 依赖图；V6-0-2 / V6-0-3 可与 V6-0-1 并行
5. 有 YAML/脚本/路由变更的 task 后必须跑：
   ./scripts/check-skill-routes.sh
   ./scripts/validate-state-machine.sh

## Git 提交策略

- 每个 task review 通过后：git add 相关文件，写好 commit message，在汇报中列出拟提交内容与 message
- 不要自动 git commit / git push，等我明确说「提交」或「commit」再执行
- V6-0-1 的 commit 仅含上游同步相关文件（见 task-breakdown V6-0-1）

## 收尾（全部 task 完成后）

1. SELF_REVIEW（L3）：对照 plan 与冻结项全面自审
2. QA（L3 必须）：测试/校验汇总
3. superpowers:verification-before-completion：证明验收项满足
4. 最终汇报必须包含：
   - 完成的 task 列表与 ledger 摘要
   - 改了哪些文件（按 task 分组）
   - 跑了哪些命令/测试及结果
   - 哪些未验证 / MANUAL / BLOCKED
   - 待我确认的 commit 列表（若有）

## 行为规则

- 严格按 plan 步骤，不跳过验收
- 遇到 blocker：立即停止，给出证据（命令输出 / gate 结果 / 缺失文件），不要猜测
- 不要停在「是否继续？」——除非真的 BLOCKED 且需要我决策
- MCP 状态 Errored 不阻断本计划；用 Trae 原生 Read/Shell/Glob
```

---

## 使用说明

| 步骤 | 操作 |
|------|------|
| 1 | 在 Trae 打开本仓库 `gstack-superpowers-hybrid-skill` |
| 2 | 新会话或续跑会话，粘贴上方执行块 |
| 3 | 模型建议：capable 档（execution plan 为 L3） |
| 4 | V6-0-4 的 6 条 eval 需另开干净会话人工补跑 |

## 与 execution-plan 的关系

- 本 prompt 是 execution-plan 的 **Trae 启动封装**，不替代 plan 正文
- task 细节、验收标准以 task-breakdown 为准
- 冲突时：task-breakdown > execution-plan > 本 prompt

## 变更历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2026-07-26 | 初版：范围、SDD 交接、V6-0-4 MANUAL、gate、提交策略 |
