# AI Engineering Governance System

> gs-hybrid-v3 v4.1.1（治理收敛版）
> 三层架构：Decision / Context / Execution + Bridges + Governance

## 这是什么

这是一个把 AI 开发流程治理化的技能工程：
- Decision Layer：做什么、为什么做
- Context Layer：把决策沉淀为可执行契约
- Execution Layer：在约束内实现、验证、交付
- Governance：用状态机和 Gate 阻断违规流程

## 当前设计原则（v4.1.1）

- `SKILL.md` 是薄入口，不重复大表
- `governance/state-machine.yaml` 是状态机真相源
- `governance/gates.yaml` 是 Gate 真相源
- `schema/skill-routes.yaml` 是机器路由真相源
- `governance/context-contract.yaml` 是运行时 context 契约真相源
- Gate 读取优先级：`context > workflow-state（secondary） > fallback`
- `L1` 快速通道可在 `workflow-state/context` 中记录对话式确认，不强制独立 spec/plan 文件
- spec 只承载需求、约束、验收与候选方向；最终设计决策只写入 ADR
- `DISCOVERY` 负责候选方向探索，`ARCH_REVIEW` 负责方案对比与最终决策
- `REQ/NFR/OUT` 是需求追踪主键，ADR / plan / PLAN_CONFIRM 围绕它做显式映射
- 文档描述若与 YAML 冲突，以 YAML 为准

## 快速开始

```bash
git clone <repo-url>
cd gstack-superpowers-hybrid-skill
chmod +x scripts/*.sh governance/*.sh governance/gates/*.sh
```

### 核心校验命令

```bash
# 状态机一致性
./scripts/validate-state-machine.sh

# Gate 校验（支持 from/to/level/context）
./governance/check-gates.sh --from TASK_DECOMPOSITION --to PLAN_CONFIRM --level L2

# 路由解析（消费 schema/skill-routes.yaml）
./scripts/resolve-skill-routes.sh --category gstack --state QA --level L3 --json

# 路由摘要健康检查（核对 SKILL.md 摘要与本地技能）
./scripts/check-skill-routes.sh

# YAML/JSON 同步检查
./scripts/yaml2json.sh --check
```

## 主流程

`IDEA -> DISCOVERY -> REQUIREMENT_LOCK -> ARCH_REVIEW -> TASK_DECOMPOSITION -> PLAN_CONFIRM -> CONTEXT_HYDRATION -> IMPLEMENTATION -> SELF_REVIEW -> QA -> SHIP_REVIEW -> RETRO`

回退与异常流转请以状态机 YAML 为准。

补充说明：
- `L1` 默认走快速通道：需求确认和计划确认可在对话中完成，并写入 `workflow-state/context`
- `PLAN_CONFIRM` 会展示 Requirement Mapping 摘要，确认 `REQ/NFR/OUT` 是否都已被任务或边界说明接住

## 关键目录

```text
skills/hybrid/gs-hybrid-v3/SKILL.md          # 主入口（薄层）
governance/state-machine.yaml                # 状态机真相源
governance/gates.yaml                        # Gate 真相源
governance/check-gates.sh                    # Gate 检查入口
scripts/validate-state-machine.sh            # 状态机校验
scripts/resolve-skill-routes.sh              # 机器路由解析
scripts/check-skill-routes.sh                # 路由健康检查
schema/skill-routes.yaml                     # 机器路由真相源
docs/getting-started.md                      # 上手说明
docs/architecture.md                         # 架构说明
docs/skills-reference.md                    # 自动生成的技能索引
```

## 文档

- [快速开始](./docs/getting-started.md)
- [架构说明](./docs/architecture.md)
- [技能参考](./docs/skills-reference.md)
- [文档维护](./docs/documentation-maintenance.md)

## 版本

- Skill: `gs-hybrid-v3`
- 架构版本: `v4.1.1`
- 更新时间: `2026-05-29`
