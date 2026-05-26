# 文档收敛维护说明（v4.1）

## 目标

确保文档始终与当前治理实现一致，避免出现“文档描述正确但脚本行为已变化”的漂移。

## 真相源

以下文件是唯一事实来源：
- `skills/hybrid/gs-hybrid-v3/SKILL.md`（入口、路由、加载策略）
- `governance/state-machine.yaml`（状态机）
- `governance/gates.yaml`（Gate 定义）

规则：任何说明文档与上述文件冲突时，以真相源为准。

## 维护流程（每次改动后执行）

1. 修改真相源文件（不要先改说明文档）。
2. 重新生成自动文档：
   - `./scripts/generate-skills-reference.sh`
3. 运行一致性校验：
   - `./scripts/validate-state-machine.sh`
   - `./governance/check-gates.sh --from TASK_DECOMPOSITION --to PLAN_CONFIRM --level L2`
   - `./scripts/check-skill-routes.sh`
   - `./scripts/yaml2json.sh --check`
4. 最后再更新说明文档：
   - `README.md`
   - `docs/getting-started.md`
   - `docs/architecture.md`

## 写作约束

- `SKILL.md` 保持薄层，不复制状态/Gate 大表。
- 说明文档不硬编码易漂移统计（如固定数量、固定检查结果样例）。
- 对流程细节使用“以 YAML 真相源为准”的表述。
- `docs/route-health.md` 视为生成物，不手动编辑。

## 最小验收标准

满足以下条件才可认为文档已收敛：
- 校验命令全部返回 0。
- 自动生成文档已刷新。
- README/Getting Started/Architecture 与当前脚本入口一致。
- 无旧术语残留（例如把 `CONTEXT_HYDRATION` 写成旧命名）。
