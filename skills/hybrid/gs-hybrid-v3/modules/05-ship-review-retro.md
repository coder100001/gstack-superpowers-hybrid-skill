# 05 — Governance: SHIP_REVIEW → RETRO

> **Context Load**: 加载 `governance/decision-freeze.md`（SHIP_REVIEW/RETRO 阶段）。

## SHIP_REVIEW 阶段

**触发条件**: QA 验证通过后

**流程**: 运行 verification-evidence gate → 通过后调用 `gstack:ship` 执行发布检查
- `gstack:ship` 内置 pre-landing review（版本号/CHANGELOG/发布检查清单）
- 详细检查项见 `gstack:ship` 技能定义

## RETRO 复盘阶段

**触发条件**: SHIP_REVIEW 完成后

**流程**: 调用 `gstack:retro`（L3 任务）记录经验教训与改进措施。

## 流程结束

完成 RETRO 后，整个 Execution Layer + Governance 流程结束。
