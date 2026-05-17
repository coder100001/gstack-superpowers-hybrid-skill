# 02 - 复杂度分级、适用矩阵

> **Context Load**: Step 0 评估，无需框架文件。评估后根据级别决定后续加载内容。

## 任务复杂度分级

根据变更范围、影响面和风险等级，将任务分为三级：

### 判定标准

| 维度 | L1 简单 | L2 中等 | L3 复杂 |
|------|---------|---------|---------|
| 变更文件数 | < 3 | 3-8 | > 8 |
| 新增代码行 | < 100 | 100-500 | > 500 |
| 接口变更 | 无 | 新增 | 修改/删除 |
| 架构影响 | 无 | 局部 | 全局 |
| 依赖变更 | 无 | 新增依赖 | 替换核心依赖 |
| 风险等级 | 低 | 中 | 高 |

### 复杂度判定决策树

```
开始
  │
  ├─ 是否涉及架构重构？
  │   ├─ 是 → L3
  │   └─ 否 ↓
  │
  ├─ 是否涉及安全或性能关键路径？
  │   ├─ 是 → L3
  │   └─ 否 ↓
  │
  ├─ 修改文件数 > 8？
  │   ├─ 是 → L3
  │   └─ 否 ↓
  │
  ├─ 新增代码 > 500 行？
  │   ├─ 是 → L3
  │   └─ 否 ↓
  │
  ├─ 修改文件数 >= 3？
  │   ├─ 是 ↓
  │   │   ├─ 新增接口或模块？ → L2
  ��   │   └─ 影响现有功能？ → L2
  │   └─ 否 ↓
  │
  └─ L1 (简单任务)
```

---

## 各级别流程定义

### L1 - 简单任务 (轻量级流程)

**判定标准** (满足任一):
- 修改文件 < 3 个
- 新增代码 < 100 行
- 纯 bug 修复，无架构变更
- 文档更新

**简化流程**:
```
Step 0 → DISCOVERY → REQUIREMENT_LOCK → TASK_DECOMPOSITION → IMPLEMENTATION → SHIP_REVIEW
```

**要求**:
- DISCOVERY 与 REQUIREMENT_LOCK 合并为单次确认（见 03a-discovery-arch.md L1 快速通道）
- TASK_DECOMPOSITION 与 PLAN 验证合并为单次确认（见 03b-task-decomposition.md L1 快速通道）
- 可跳过 ARCH_REVIEW（无架构变更时）
- 可跳过 SELF_REVIEW/QA（编码后直接进入 SHIP_REVIEW）
- 不产出独立 ADR

### L2 - 中等任务 (标准流程)

**判定标准** (满足任一):
- 修改文件 3-8 个
- 新增代码 100-500 行
- 新增接口或模块
- 影响现有功能

**标准流程**:
```
Step 0 → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION → Context Hydration → IMPLEMENTATION → SELF_REVIEW → SHIP_REVIEW
```

**要求**:
- REQUIREMENT_LOCK 与 TASK_DECOMPOSITION 确认分离（两次硬阻断）
- ARCH_REVIEW 启用 2 维度审议（Product + Architect，见 03a-discovery-arch.md）
- 可跳过 QA（L2 不强制）
- 产出简要 ADR

### L3 - 复杂任务 (完整流程)

**判定标准** (满足任一):
- 修改文件 > 8 个
- 新增代码 > 500 行
- 架构重构
- 涉及安全或性能关键路径

**完整流程**:
```
Step 0 → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION → Context Hydration → IMPLEMENTATION → SELF_REVIEW → QA → SHIP_REVIEW → RETRO
```

**要求**:
- 所有硬阻断点必须执行（REQUIREMENT_LOCK、TASK_DECOMPOSITION 确认）
- ARCH_REVIEW 启用全 5 维度审议
- QA 强制（调用 gstack:qa）
- RETRO 强制产出复盘记录
- 产出完整 ADR

---

## 流程阶段适用矩阵

| 状态 | 名称 | L1 | L2 | L3 | 说明 |
|:-----:|------|:--:|:--:|:--:|------|
| Step 0 | 复杂度评估 | ✅ | ✅ | ✅ | 所有任务必须 |
| DISCOVERY | 需求澄清 | ⚪ | 🔴 | 🔴 | L1 可选，L2+ 必须 |
| REQUIREMENT_LOCK | 需求确认 | 🔴(合并) | 🔴 | 🔴 | L1 与 DISCOVERY 合并确认 |
| ARCH_REVIEW | 架构审议 | ⚪ | 🟡 | 🔴 | L1 跳过，L2→2维度，L3→5维度 |
| TASK_DECOMPOSITION | 任务拆解 | ✅ | ✅ | ✅ | 所有级别必须 |
| PLAN_CONFIRM | Plan 确认 | 🔴(合并) | 🔴 | 🔴 | L1 与 TASK_DECOMPOSITION 合并确认 |
| Context Hydration | 上下文注水 | ⚪ | 🟡 | 🔴 | L1 简化，L2+ 必须 |
| IMPLEMENTATION | 编码实现 | ✅ | ✅ | ✅ | 所有级别必须 |
| SELF_REVIEW | 自审 | ⚪ | 🟡 | 🔴 | L1 跳过，L2+ 必须 |
| QA | 质量验证 | ⚪ | ⚪ | 🔴 | 仅 L3 强制（调用 gstack:qa） |
| SHIP_REVIEW | 发布检查 | ✅ | ✅ | ✅ | 所有级别必须 |
| RETRO | 复盘记录 | ⚪ | ⚪ | 🔴 | 仅 L3 强制 |

> 图例：✅ 必须 | 🟡 L2+ 必须 | 🔴 必须 | ⚪ 可选 | 🔴(合并) L1 合并确认

---

## 评估输出模板

### 复杂度评估报告

```markdown
## 复杂度评估报告

### 变更统计
- 新增文件: X 个
- 修改文件: X 个
- 删除文件: X 个
- 预估代码行: XXX 行

### 影响分析
- [ ] 影响现有 API
- [ ] 影响数据库结构
- [ ] 影响配置文件
- [ ] 影响部署流程

### 评估结论
**复杂度级别**: L1 / L2 / L3
**流程选择**: 简化流程 / 标准流程 / 完整流程
```
