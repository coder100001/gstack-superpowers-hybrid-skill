# 快速开始（v4.1.1）

> 面向 gs-hybrid-v3 当前版本的最小可用指南。

## 1. 安装

```bash
git clone <repo-url>
cd gstack-superpowers-hybrid-skill
chmod +x scripts/*.sh governance/*.sh governance/gates/*.sh
```

## 2. 先跑校验

```bash
./scripts/validate-state-machine.sh
./governance/check-gates.sh --from TASK_DECOMPOSITION --to PLAN_CONFIRM --level L2
./scripts/resolve-skill-routes.sh --category gstack --state QA --level L3 --json
./scripts/check-skill-routes.sh
./scripts/yaml2json.sh --check
```

预期：以上命令返回 `0`。

## 3. 核心概念

- 薄入口：`skills/hybrid/gs-hybrid-v3/SKILL.md`
- 真相源：
  - `governance/state-machine.yaml`
  - `governance/gates.yaml`
  - `schema/skill-routes.yaml`
  - `governance/context-contract.yaml`
- 脚本入口：
  - `scripts/validate-state-machine.sh`
  - `governance/check-gates.sh`
  - `scripts/resolve-skill-routes.sh`
  - `scripts/check-skill-routes.sh`
- Gate 上下文优先级：`context > workflow-state（secondary） > fallback`
- `L1` 快速通道可以把确认写进 `workflow-state/context`，不强制独立 spec/plan 文件
- `REQ/NFR/OUT` 是需求追踪主键，`PLAN_CONFIRM` 会展示 Requirement Mapping 摘要
- `DISCOVERY` 负责用 brainstorming 方法探索候选方向；`ARCH_REVIEW` 负责对候选方向做正式多方案对比并落 ADR 决策
- 提交信息格式建议：`type(scope): summary`（由 `SHIP_REVIEW` 的 soft gate 提示一致性）

## 4. 主流程

`IDEA -> DISCOVERY -> REQUIREMENT_LOCK -> ARCH_REVIEW -> TASK_DECOMPOSITION -> PLAN_CONFIRM -> CONTEXT_HYDRATION -> IMPLEMENTATION -> SELF_REVIEW -> QA -> SHIP_REVIEW -> RETRO`

说明：
- 进入目标状态时会触发对应 Gate（由 YAML 定义）
- 若 Gate 失败，`check-gates.sh` 会返回非 0，并带失败 Gate 名称

## 5. 常用操作

### 校验某次跃迁是否可通过

```bash
./governance/check-gates.sh --from DISCOVERY --to REQUIREMENT_LOCK --level L1
```

### 解析实际路由

```bash
./scripts/resolve-skill-routes.sh --category gstack --state QA --level L3 --json
```

### 生成路由摘要健康报告

```bash
./scripts/check-skill-routes.sh
# 输出到 docs/route-health.md（建议作为生成物，不手改）
```

### 检查 YAML/JSON 漂移

```bash
./scripts/yaml2json.sh --check
```

## 6. 排错建议

- `plan-confirm` 失败：先确认计划文档中有明确确认标记，或检查 `workflow-state/context` 是否写入 `plan_confirmed: true`
- `decision-freeze` 失败：实现阶段不要改 ADR/spec，需回退决策层
- 路由解析异常：优先检查 `schema/skill-routes.yaml` 和 `scripts/resolve-skill-routes.sh`
- 路由摘要检查报错：检查 `SKILL.md` 摘要是否引用了不存在技能

## 7. 参考文档

- [README](../README.md)
- [架构说明](./architecture.md)
- [主技能入口](../skills/hybrid/gs-hybrid-v3/SKILL.md)
