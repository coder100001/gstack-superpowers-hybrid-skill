# gs-hybrid-v4.1 治理加固实施计划（Plan）

> **版本**: v1.0 · **日期**: 2026-05-25 · **复杂度**: L3
> **范围**: 仅治理系统与流程资产（不改业务功能）

---

## 1. 背景与目标

当前 `gs-hybrid-v3` 已具备完整状态机、Hard Gate、技能路由和冻结机制，但关键规则仍以文档约束为主，存在“可读但不可强校验”的执行落差。

本计划目标：将 P0 规则转成可执行资产，优先消除运行期歧义与漏拦截风险。

**P0 成果定义（必须达成）**：
- 状态机与门禁规则拥有机器可读真相源
- 状态跃迁前可执行 Gate 校验
- 技能路由可自动做存在性健康检查

---

## 2. 优先级总览

### P0（本轮必做）

1. 状态机真相源统一（State Machine Canonicalization）
2. Hard Gate 可执行化（Gate Enforcement）
3. 技能路由健康检查（Route Health Check）

### P1（第二轮）

1. 命名统一与别名映射规范
2. 文档拆分 + 自动生成链路
3. 冻结变更审批工单化

### P2（第三轮）

1. 指标体系与趋势报告
2. L1/L2/L3 最小回放验收
3. 异常处理流程测试化

---

## 3. P0 详细实施步骤（逐步可执行）

### Task P0-1: 状态机真相源统一

**目标**: 把 `SKILL.md` 中状态与转换关系沉淀成机器可读配置，避免文档和实现分叉。  
**依赖**: 无  
**预计耗时**: 0.5 天

**文件变更**:
- Create: `governance/state-machine.yaml`
- Create: `scripts/validate-state-machine.sh`
- Modify: `skills/hybrid/gs-hybrid-v3/SKILL.md`（改为引用说明，不重复维护表格细节）

- [ ] **Step 1: 盘点状态清单与转换关系**
  - 从 `SKILL.md` 提取全部状态（含 `ABORTED`）
  - 标记正常流、回滚流、异常流
  - 产出规范枚举（统一为大写机器名）

- [ ] **Step 2: 设计 `state-machine.yaml` 结构**
  - 顶层字段：`version`、`states`、`transitions`
  - 每条 transition 必含：`from`、`to`、`precondition`、`complexity_scope`、`change_flow_required`
  - 为 `* -> ABORTED`、`* -> IDEA` 这类规则定义 wildcard 语义

- [ ] **Step 3: 填充完整转换矩阵**
  - 覆盖主链：`IDEA -> ... -> RETRO`
  - 覆盖回退链：`SELF_REVIEW -> IMPLEMENTATION`、`QA -> SELF_REVIEW`、`SHIP_REVIEW -> QA`
  - 覆盖变更链：`IMPLEMENTATION -> ARCH_REVIEW`、`IMPLEMENTATION -> TASK_DECOMPOSITION`

- [ ] **Step 4: 编写校验脚本 `validate-state-machine.sh`**
  - 校验状态唯一性
  - 校验转换引用合法性（from/to 状态必须存在）
  - 校验必需状态不缺失（IDEA、IMPLEMENTATION、ABORTED 等）
  - 校验是否存在不可达状态（除 IDEA 外）

- [ ] **Step 5: 修改 SKILL 文档引用方式**
  - 在 `SKILL.md` 保留“可读摘要”
  - 指向 `governance/state-machine.yaml` 作为唯一真相源
  - 标注“禁止在多个文档重复维护转换表”

- [ ] **Step 6: 验收**
  - `scripts/validate-state-machine.sh` 返回 0
  - 手工 spot-check 3 条主链 + 2 条回滚链一致

---

### Task P0-2: Hard Gate 可执行化

**目标**: 让 Gate 规则从“描述性条款”升级为“可执行阻断”。  
**依赖**: P0-1  
**预计耗时**: 0.5~1 天

**文件变更**:
- Create: `governance/gates.yaml`
- Create: `governance/check-gates.sh`
- Create: `governance/gates/`（若不存在则创建）
- Create/Modify: `governance/gates/*.sh`（按 gate 拆分）

- [ ] **Step 1: 定义 Gate 元数据模型**
  - 字段：`id`、`applies_to`、`severity`、`script`、`exemptions`、`fail_message`
  - 约定错误码：统一 `GATE_FAILED:<gate-id>`
  - 定义 L1 豁免位（如 `arch-review-lock` 对 L1 豁免）

- [ ] **Step 2: 建立 `gates.yaml` 完整清单**
  - 至少覆盖：
    - `requirement-lock`
    - `arch-review-lock`
    - `task-decomposition-lock`
    - `context-hydration`
    - `decision-freeze`
    - `test-presence`
  - 将“配置缺失”“评审不通过”映射为可执行检查项

- [ ] **Step 3: 编写 Gate 执行入口 `check-gates.sh`**
  - 入参：`--from`、`--to`、`--level`、`--context`
  - 行为：根据目标状态加载适用 gate 并逐个执行
  - 输出：通过摘要 / 失败 gate / 下一步动作

- [ ] **Step 4: 拆分 Gate 脚本职责**
  - 每个 gate 单脚本，单一职责
  - 禁止 gate 脚本内互相调用，避免循环依赖
  - 返回值规范：`0=pass`，`1=block`，`2=infra-error`

- [ ] **Step 5: 对接状态跃迁入口**
  - 在 `transition` 入口（已有或新增）接入 `check-gates.sh`
  - 保证先验状态合法，再跑 gate，最后写入状态

- [ ] **Step 6: 验收**
  - 构造 3 个失败场景（如无测试直接进 SELF_REVIEW）并确认被阻断
  - 构造 2 个通过场景并确认放行

---

### Task P0-3: 技能路由健康检查

**目标**: 提前发现路由表指向不存在技能、命名不一致或重复注册问题。  
**依赖**: 无（可并行）  
**预计耗时**: 0.5 天

**文件变更**:
- Create: `scripts/check-skill-routes.sh`
- Create: `docs/route-health.md`（产出报告）
- Modify: `skills/hybrid/gs-hybrid-v3/SKILL.md`（补充 route check 说明）

- [ ] **Step 1: 提取路由表技能名**
  - 提取 Superpowers 路由 + GStack 路由全部 skill id
  - 提取三层路由中引用的 skills

- [ ] **Step 2: 扫描本地技能目录**
  - 扫描 `skills/**/SKILL.md`
  - 建立 `name -> path` 映射

- [ ] **Step 3: 执行一致性检查**
  - 未命中：路由存在但技能不存在
  - 重名冲突：同名技能多路径
  - 命名漂移：`design` vs 实际 skill 名不一致

- [ ] **Step 4: 生成健康报告**
  - 输出 `docs/route-health.md`
  - 按 `error / warning / info` 分级
  - 给出修复建议（改路由 or 改技能名）

- [ ] **Step 5: 验收**
  - `scripts/check-skill-routes.sh` 可重复执行
  - 报告包含时间戳、扫描范围、问题清单、结论

---

## 4. 交付清单（P0）

- [ ] `governance/state-machine.yaml`
- [ ] `scripts/validate-state-machine.sh`
- [ ] `governance/gates.yaml`
- [ ] `governance/check-gates.sh`
- [ ] `governance/gates/*.sh`（按 gate 拆分）
- [ ] `scripts/check-skill-routes.sh`
- [ ] `docs/route-health.md`
- [ ] `SKILL.md` 同步为“引用真相源”模式

---

## 5. 风险与缓解

1. **风险**: 文档规则与脚本实现语义不一致  
   **缓解**: 统一从 YAML 生成文档摘要，禁止手工复制转换表

2. **风险**: Gate 过严导致日常任务阻断率过高  
   **缓解**: 增加 `severity` 与 `L1 exemption`，先 warning 后 hard-block

3. **风险**: 路由检查误报（别名/前缀差异）  
   **缓解**: 增加 alias 映射文件，分离 hard error 与 soft warning

---

## 6. 回滚策略

- 若 P0 任一子任务引发流程不可用：
1. 回退对应脚本和 YAML 文件提交
2. 暂时恢复以 `SKILL.md` 为主的手工检查模式
3. 保留失败样例，进入下一轮修复

---

## 7. 完成定义（Definition of Done）

- [ ] 状态机、Gate、路由三类规则均可通过脚本独立校验
- [ ] 至少 5 个样例场景验证（3 阻断、2 放行）
- [ ] `SKILL.md` 不再作为重复规则维护点，仅做入口与索引
- [ ] 新增文档可被团队成员按步骤直接执行

## Approval

- [x] User confirmed plan on 2026-05-25
