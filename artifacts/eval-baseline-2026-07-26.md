# gs-hybrid-v6 Baseline Eval — Phase 0 Pressure Test

> **文件状态**: TEMPLATE — 所有记录标记为 MANUAL，待人工补跑  
> **日期**: 2026-07-26  
> **场景**: P1 (L0 Typo), P2 (Skip Requirement Lock), P3 (Ship Without Evidence)  
> **模型**: 2 capable models (TBD)  
> **记录格式**: `artifacts/eval-baseline-2026-07-26.json`

---

## 尚未执行 — 待人工补跑

本评估需要在 **干净会话**（new session）中逐个场景执行，由人工操作并记录结果。

### 执行步骤

1. 打开一个新会话（确保无历史上下文残留）
2. 从对应的 scenario 文件复制 `user_prompt` 作为第一条消息
3. 观察模型行为，记录：
   - 是否遵守 gate
   - 是否跳步
   - rationalization 原文
   - 最终结果 pass/fail
4. 填写 `artifacts/eval-baseline-2026-07-26.json` 中的对应记录
5. 更新本文件的摘要表格

### 建议执行顺序

| 序号 | 场景 | 模型 | 文件 |
|------|------|------|------|
| 1 | P1: L0 Typo | Model 1 | `scenarios/P1-l0-typo.md` |
| 2 | P1: L0 Typo | Model 2 | `scenarios/P1-l0-typo.md` |
| 3 | P2: Skip Req Lock | Model 1 | `scenarios/P2-skip-requirement-lock.md` |
| 4 | P2: Skip Req Lock | Model 2 | `scenarios/P2-skip-requirement-lock.md` |
| 5 | P3: Ship No Evidence (Phase 2 前) | Model 1 | `scenarios/P3-ship-without-evidence.md` |
| 6 | P3: Ship No Evidence (Phase 2 前) | Model 2 | `scenarios/P3-ship-without-evidence.md` |

> P3 需在 Phase 2 后再补跑一轮（验证 verification-evidence gate 生效）

---

## 结果摘要（待填写）

| 场景 | 模型 | Phase | 结果 | 关键观察 |
|------|------|-------|------|---------|
| P1 | — | 2 前 | ⏳ MANUAL | — |
| P1 | — | 2 前 | ⏳ MANUAL | — |
| P2 | — | 2 前 | ⏳ MANUAL | — |
| P2 | — | 2 前 | ⏳ MANUAL | — |
| P3 | — | 2 前 | ⏳ MANUAL | 预期失败 |
| P3 | — | 2 前 | ⏳ MANUAL | 预期失败 |

> Phase 2 完成后需补跑 P3 以验证 verification-evidence gate 生效。

---

## 环境说明

| 项目 | 值 |
|------|-----|
| Harness | Trae CN |
| 治理版本 | gs-hybrid-v6 (Phase 0 baseline) |
| Gate 状态 | P1/P2 不依赖 Phase 2；P3 依赖 |
| 会话要求 | 每次测试必须用 **干净会话** |
