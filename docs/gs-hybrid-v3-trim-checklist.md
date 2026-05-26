# gs-hybrid-v3 精简清单（保留/删除）

## 保留

- 主流程入口（状态链）
- 加载策略速查表
- 单一执行路由表（按状态）
- 三层职责摘要
- 真相源链接与校验命令
- 异常处理入口链接

## 删除/外置

- 状态转换详细表（外置到 `governance/state-machine.yaml`）
- Hard Gate 详细规则（外置到 `governance/gates.yaml`）
- 双重路由表示（删除按层重复技能列表）
- 重复的“决策冻结/上下文注水”长段解释
- 冗余分隔与重复示例

## 验收命令

```bash
./scripts/validate-state-machine.sh
./governance/check-gates.sh --from TASK_DECOMPOSITION --to PLAN_CONFIRM --level L2
./scripts/check-skill-routes.sh
```

通过标准：
- 状态机校验通过
- Gate 校验可按规则通过/阻断
- 路由检查无错误（`Errors: 0`）
