# Agent Enforcement Governance System — Design Spec

> **复杂度**: L3 | **状态**: Approved (ARCH_REVIEW 5 维全票通过)
> **层**: Governance (新增，与 Decision/Context/Execution 平行)

## 背景与问题

gstack-superpowers-hybrid-skill 定义了 7 条 HARD-GATE（需求锁定、任务确认、Context Hydration、决策冻结、状态跳步禁止等），但全部是自然语言文本——agent 读到决定遵守就遵守，不遵守也没有东西拦截。

现有的约束机制：
- **Superpowers 层**: 纯文本（HARD-GATE、MUST、Red Flags tables），零可执行约束
- **GStack 层**: PreToolUse hook（`check-freeze.sh` / `check-careful.sh`），运行时拦截 tool 调用
- **CI 层**: schema 校验、链接检查、项目完整性验证——不验证流程合规性

**缺口**: 缺少 process 级别的可执行约束——不验证 agent 走完 DISCOVERY 再编码、不检测决策冻结是否被违反。

## 设计

新增 `governance/` 层，与现有三层平行，为流程合规提供可执行约束。

### 架构概览

```
governance/
├── machine.json               # 状态机拓扑定义
├── gates.json                  # 门禁规则定义
├── gates/
│   ├── requirement-lock.sh     # Gate 1: 需求是否锁定
│   ├── context-hydration.sh    # Gate 2: Context 是否注水
│   ├── decision-freeze.sh      # Gate 3: 决策是否冻结
│   └── test-presence.sh        # Gate 4: 测试是否存在
├── transition.sh               # 跃迁调度入口 ← 唯一入口
└── state-journal/              # 审计日志目录（gitignored）

scripts/
├── guard-decision-freeze.sh    # CI 硬守卫：ADR+实现同 PR → 阻断
├── guard-test-presence.sh      # CI 软检查：无测试代码变更 → 警告
└── aggregate-journal.sh        # 聚合 journal 输出流程时间线
```

### 核心流程

```
agent 在任何状态下调用 transition.sh <from> <to>
  → 读 machine.json 校验跃迁合法性
  → 读 gates.json 检查目标状态是否有 gate
  → 调用对应 gates/<gate>.sh
  → 写入 state-journal/ 记录
```

### 状态机拓扑

9 个状态 + ABORTED/回退：

```
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW
  → TASK_DECOMPOSITION → CONTEXT_HYDRATION → IMPLEMENTATION
  → SELF_REVIEW → QA → SHIP_REVIEW → RETRO
```

绑定 gate 的关键跃迁点：
- → CONTEXT_HYDRATION: gate=context-hydration
- → IMPLEMENTATION: gate=decision-freeze
- → SELF_REVIEW: gate=test-presence
- → REQUIREMENT_LOCK: gate=requirement-lock

### 门禁定义（4 gates）

| Gate | 触发点 | 检查内容 | 失败处理 |
|------|--------|---------|---------|
| requirement-lock | → REQUIREMENT_LOCK | spec 文件存在且含用户确认标记 | exit 1 + fix 建议 |
| context-hydration | → CONTEXT_HYDRATION | 4 个 P0 spec 文件是否存在 | exit 1 + 缺失清单 |
| decision-freeze | → IMPLEMENTATION | ADR/specs 自 ARCH_REVIEW 后未修改 | exit 1 + 违规文件列表 |
| test-presence | → SELF_REVIEW | 新增代码有对应测试文件 | exit 1 + 缺失测试列表 |

### CI 守卫

| 守卫 | 级别 | 阻断 | 检测逻辑 |
|------|------|------|---------|
| guard-decision-freeze.sh | CI | **是** | ADR/specs + 实现代码同 PR → error |
| guard-test-presence.sh | CI | 否 | 实现文件 > 0 且测试文件 = 0 → warning |

### 审计日志

- state-journal/ 目录下每个 session 独立文件
- 每条记录: timestamp, from, to, level, gates_passed, reason
- gitignored，零 merge 冲突

## 边界与不做的

- 不做 PreToolUse hook（不拦截 tool 调用）
- 不做运行时 gate 强制（agent 可跳过 transition.sh，但有 CI 兜底）
- journal 不 git 追踪
- 不修改现有三层结构

## 确认 (Approved by user on 2026-05-19)

## 成功标准

1. transition.sh 能正确校验跃迁并调用 gate → exit 0/1
2. guard-decision-freeze.sh 能阻断 ADR+实现同 PR → CI error
3. 4 个 gate 脚本均可独立运行 → exit 0/1
4. aggregate-journal.sh 能输出格式化时间线
