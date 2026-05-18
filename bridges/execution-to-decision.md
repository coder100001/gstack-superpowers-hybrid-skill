# Execution-to-Decision Bridge

> **层**: Bridges · **方向**: Execution Layer → Decision Layer
> **触发条件**: 实现过程中发现冻结项需要变更，或遇到决策无法覆盖的场景
> **强制产出**: 变更请求 + 影响评估 + 退回决策层

---

## 1. 职责

本桥接协议负责将 Execution Layer 的实现反馈转化为 Decision Layer 可处理的变更请求。执行过程中发现的问题不得在执行层自行解决——必须退回决策层。

```
Execution Layer                 Decision Layer
────────────────────────────────────────────────
实现受阻             ──→      变更请求 + 影响评估
发现遗漏约束         ──→      constraints-spec 补充
架构决策不可行       ──→      ADR 重新审议
领域边界违例         ──→      domain-boundaries 重新划定
```

---

## 2. 触发条件

| 触发场景 | 示例 | 严重程度 |
|:---------|:-----|:---------|
| 架构决策不可行 | ADR 选型的技术方案在实际实现中有未预见的障碍 | Major |
| 约束与实现冲突 | project-spec 规则导致合法需求无法实现 | Major |
| 发现遗漏约束 | 实现过程中发现需要但尚未定义的约束规则 | Minor |
| 领域边界模糊 | 两个域的职责划分在实现中出现灰色地带 | Major |
| 需求范围偏差 | 实现时发现用户实际需求与文档记录不一致 | Critical |
| 性能/安全违规 | 实现后发现某方案有性能或安全隐患 | Major |

---

## 3. 反馈流程

```
实现中发现需要变更
    │
    ▼
[1] 暂停实现
    ├─ 记录当前进度（已完成的文件/行）
    ├─ 冻结变更文件（标记 pending-review）
    └─ 保存当前测试状态
    │
    ▼
[2] 填写变更请求
    ├─ 变更项: [架构决策 / 需求范围 / API 契约 / 领域边界]
    ├─ 当前状态: 冻结项的内容
    ├─ 期望变更: 建议修改方案
    ├─ 变更理由: 实现中遇到的具体问题
    └─ 影响范围: 已完成的实现中哪些会受影响
    │
    ▼
[3] 退回 Decision Layer
    ├─ 将变更请求提交到 decision-layer/reviews/
    ├─ 触发对应维度的审议
    ├─ 变更超过原始范围 → 重新进入 DISCOVERY
    └─ 仅微调 → 触发增量审议
    │
    ▼
[4] Decision Layer 产出
    ├─ 新 ADR 或 ADR 修订
    ├─ 对应的 spec 更新指令
    └─ 变更影响评估
    │
    ▼
[5] 重新注水
    ├─ 加载更新后的上下文契约
    ├─ 评估已有实现需要重做的部分
    └─ 标记受影响文件
    │
    ▼
[6] 恢复实现
        └─ 从变更影响点继续
```

---

## 4. 变更请求模板

实现受阻时，必须使用以下模板创建变更请求：

```
## Execution Feedback - [日期]

### 触发场景
[描述实现中遇到了什么具体问题]

### 当前决策/约束
[引用具体的 ADR / spec 条款]

### 建议变更
[建议如何修改决策或约束]

### 变更理由
1. [理由 1: 具体的技术障碍]
2. [理由 2: 与实际的假设冲突]
3. ...

### 影响评估
- 已完成代码量: [文件/行数]
- 需重做代码量: [预估]
- 影响范围: [模块/文件列表]
- 建议方案: [重做 / 适配 / 仅向后修复]

### 严重程度
[Minor / Major / Critical]
```

---

## 5. 违规处理

执行层自行修改冻结项而不走桥接流程：

```
❌ 违规: 执行层自行修改架构决策
    - 文件: [路径]
    - 修改内容: [描述]
    - 违反: Execution-to-Decision Bridge Protocol

处理:
    1. 回滚违规修改
    2. 填写变更请求
    3. 退回决策层走正式流程
```

---

## 6. 与 Governance 的集成

本桥接与 [decision-freeze](../governance/decision-freeze.md) 协作：

- 冻结期内，所有超出例外条款的变更必须走本桥接协议
- decision-freeze 第 3 节"变更流程"的步骤 3 通过本桥接退回 Decision Layer
- 本桥接提供了 decision-freeze 中变更流程的实际执行协议

---

**关联文件**: [decision-freeze](../governance/decision-freeze.md) · [decision-to-context](../bridges/decision-to-context.md) · [context-to-execution](../bridges/context-to-execution.md)