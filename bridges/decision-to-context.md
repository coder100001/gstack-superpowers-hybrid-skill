# Decision-to-Context Bridge

> **层**: Bridges · **方向**: Decision Layer → Context Layer
> **触发条件**: 架构审议完成并产生 ADR 时
> **强制产出**: 审议结论必须转化为可执行的上下文契约

---

## 1. 职责

本桥接协议负责将 Decision Layer 的审议产出转化为 Context Layer 的可消费契约。审议的输出是"判断"，而执行的输入必须是"规则"。

```
Decision Layer                 Context Layer
─────────────────────────────────────────────
审议结论             ──→      project-spec 更新
ADR                  ──→      architecture-spec 更新
否决方案 + 理由      ──→      constraints-spec 补充
识别风险 + 缓解策略   ──→      domain-boundaries 补充
回滚策略             ──→      ADR 记录
```

---

## 2. 转化规则

### 2.1 ADR → Architecture Spec

| ADR 内容 | 转化为 | 示例 |
|:---------|:-------|:-----|
| 技术选型 | architecture-spec 中"技术栈"章节 | ADR-003: 使用 PostgreSQL → architecture-spec 数据库章节更新 |
| 模块划分 | domain-boundaries 中的域定义 | ADR-004: 用户域独立 → domain-boundaries 新增 identity 域 |
| 依赖方向 | project-spec 中"依赖方向"规则 | ADR-005: domain 层不依赖 infrastructure → project-spec 依赖方向章节更新 |

### 2.2 否决方案 → Constraints

被否决的替代方案必须记录在 constraints-spec 中作为"已确认不采用的方案"：

```
Rejected Alternatives (from Architecture Deliberation [date]):

1. [方案 A]
   ├─ 否决理由: [理由]
   ├─ 决策者: [决策维度]
   └─ 条件变化后可重新考虑: [是/否]

2. [方案 B]
   ├─ 否决理由: [理由]
   ├─ 决策者: [决策维度]
   └─ 条件变化后可重新考虑: [是/否]
```

### 2.3 风险 → 约束规则

识别的风险转化为可执行的约束规则：

| 风险 | 转化为 | 存放位置 |
|:-----|:-------|:---------|
| 数据库连接泄漏 | "所有数据库操作必须使用连接池" | constraints-spec |
| 越权访问 | "所有 API 端点必须通过权限中间件" | project-spec 安全章节 |
| 缓存穿透 | "热点数据必须预加载，禁止空值缓存" | constraints-spec |

### 2.4 回滚策略 → ADR

每个 ADR 必须包含回滚策略章节，确保决策是可逆的：

```
## Rollback Strategy

- 回滚条件: [什么情况下触发回滚]
- 回滚步骤: [1. 2. 3. ...]
- 回滚影响: [回滚会影响哪些模块/用户]
- 回滚验证: [如何确认回滚成功]
```

---

## 3. 转化检查清单

每次桥接完成后，必须逐项检查：

```
□ 所有 Approved 方案已写入 Architecture Spec
□ 所有 Rejected 方案已记录到 Constraints Spec（含理由）
□ 每个 ADR 包含完整的回滚策略
□ 识别的风险已转化为约束规则
□ 审议中提到的边界条件已补充到 Domain Boundaries
□ 所有 Artifact 的版本号已更新
□ 旧版本 Artifact 已存档（非删除）
```

---

## 4. 输出示例

```
Architecture Deliberation [2026-05-16] - User Auth Module
├── 状态: Conditional Approved
├── 条件: 解决 Security Reviewer 提出的 token 刷新风险

转化结果:
├── 新增 ADR-010: JWT + Refresh Token 双 Token 方案
│   ├── 写入: architecture-spec.md §认证模块
│   └── 回滚: 切回 Session 方案，需迁移现有 token
├── 否决记录: Session 方案
│   ├── 理由: 扩展性不足，多服务需共享 session store
│   └── 写入: constraints-spec.md §已否决方案
├── 风险 → 约束:
│   ├── "token 刷新竞态" → constraints-spec 新增并发刷新防护规则
│   └── "access token 泄露" → project-spec 新增令牌最短有效期规则
└── 边界补充:
    └── "第三方 OAuth 集成属于身份域" → domain-boundaries 确认

桥接状态: ✅ Complete
```

---

## 5. 完整性校验

验证决策层的输出是否完整转化为上下文契约：

| 校验项 | 标准 | 失败处理 |
|:-------|:-----|:---------|
| 所有 ADR 已写入 | 每个 ADR 对应一个契约变更 | 补充遗漏的 ADR |
| 所有否决有记录 | constraints-spec 与审议结论一致 | 补充否决记录 |
| 风险已转化约束 | 每个风险对应一个约束规则 | 补充转化 |
| 回滚策略完整 | 每个 ADR 有回滚章节 | 补充回滚策略 |

---

**关联文件**: [architecture-review](../decision-layer/reviews/architecture-review.md) · [context-hydration](../bridges/context-to-execution.md) · [decision-freeze](../governance/decision-freeze.md)