# 架构说明（v4.1.1）

> 本文档描述 gs-hybrid-v3 当前生效架构。详细状态和 Gate 以 YAML 真相源为准。

## 1. 架构总览

系统由五个部分组成：
- Decision Layer：需求澄清、方案审议、计划确认
- Context Layer：Spec 契约沉淀与注水
- Execution Layer：受约束实现、自审、QA、交付检查
- Bridges：Decision -> Context -> Execution 的层间传递
- Governance：状态机 + Gate + 冻结规则

## 2. 三层职责

### Decision Layer

职责：
- 明确需求与边界
- 完成架构审议
- 输出可执行计划并确认

关键状态：
- `DISCOVERY`
- `REQUIREMENT_LOCK`
- `ARCH_REVIEW`
- `TASK_DECOMPOSITION`
- `PLAN_CONFIRM`

### Context Layer

职责：
- 将决策转化为契约上下文
- 在进入实现前完成上下文注水

关键状态：
- `CONTEXT_HYDRATION`

### Execution Layer

职责：
- 在冻结决策前提下实现
- 完成自审、QA、交付检查与复盘

关键状态：
- `IMPLEMENTATION`
- `SELF_REVIEW`
- `QA`
- `SHIP_REVIEW`
- `RETRO`

## 3. 治理模型

治理层不产出业务代码，只负责流程准入：
- 状态是否合法流转
- 进入状态前 Gate 是否通过
- 冻结规则是否被破坏

### 真相源

- 状态机：`governance/state-machine.yaml`
- Gate：`governance/gates.yaml`
- 路由：`schema/skill-routes.yaml`
- 运行时上下文契约：`governance/context-contract.yaml`

### 执行入口

- 状态机校验：`scripts/validate-state-machine.sh`
- Gate 校验：`governance/check-gates.sh`
- 路由解析：`scripts/resolve-skill-routes.sh`
- 路由摘要检查：`scripts/check-skill-routes.sh`

## 4. 状态机与 Gate 的关系

- 每个状态可配置 `entry_gate`
- `check-gates.sh --from --to --level [--context]` 根据目标状态触发 Gate
- Gate 脚本返回：
  - `0` 通过
  - `1` 阻断
  - `2` 基础设施/执行错误

## 5. 路由与上下文策略

### 路由策略

- 机器路由表只在 `schema/skill-routes.yaml` 维护
- `scripts/resolve-skill-routes.sh` 消费 `detect` 规则并输出实际命中技能
- `skills/hybrid/gs-hybrid-v3/SKILL.md` 只保留可读摘要
- `scripts/check-skill-routes.sh` 核对摘要引用与本地技能目录
- 未注册技能记录为信息项（Info），不阻断

### 上下文策略

- `SKILL.md` 保持薄层，避免重复大表
- 进入下一阶段后释放前序细节，仅保留契约摘要
- 细节由模块文档与治理 YAML 承担
- Gate 读取优先级：`context > workflow-state（secondary source） > fallback`
- `L1` 可在 `context/workflow-state` 中记录对话式确认，不强制独立 spec/plan 文件

## 6. 设计约束

- 单一真相源：状态/Gate 只在 YAML 定义
- 文档不复制机器规则，避免双写漂移
- 任何流程描述冲突时，以脚本行为和 YAML 为准
- 单一设计产物：ADR 是唯一设计决策载体；plan 只承担执行拆解，不维护平行设计文档
- spec 只回答需求与约束，不承载最终设计决策；ADR 回答方案对比、trade-off 与最终决策
- `DISCOVERY` 只探索候选方向与问题证据，不做最终定稿；`ARCH_REVIEW` 才对这些候选方向做正式多方案比较并落 ADR
- 需求追踪使用显式 ID：spec 中的 `REQ/NFR/OUT` 必须在 ADR 与 plan 中出现，避免依赖弱关键词匹配
- 增强策略：优先增强既有 Superpowers 产物（spec/ADR/plan）的质量审查，不新增产物类型
- 提交信息规范：在 `SHIP_REVIEW` 通过 `commit-message-format` gate 进行格式一致性检查（Phase A 为 soft）

## 7. 相关文件

- `skills/hybrid/gs-hybrid-v3/SKILL.md`
- `governance/state-machine.yaml`
- `governance/gates.yaml`
- `governance/check-gates.sh`
- `scripts/validate-state-machine.sh`
- `scripts/resolve-skill-routes.sh`
- `scripts/check-skill-routes.sh`
- `schema/skill-routes.yaml`
