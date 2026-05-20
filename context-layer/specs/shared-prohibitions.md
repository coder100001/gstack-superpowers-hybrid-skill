---
hydration:
  asset: "shared-prohibitions"
  version: "1.0.0"
  updated: "2026-05-20"
  adr_ref: "ADR-001, ADR-007"
---

# Shared Prohibitions (共享禁止模式)

> **层**: Context Layer · **职责**: 通用禁止模式定义
> **生命周期**: 项目级别，持续生效
> **更新条件**: 仅通过 Decision Layer 审议后更新

> **单一真相源声明**: 本文件是所有禁止模式的统一定义源。各 spec 文件（project-spec、architecture-spec、constraints-spec、domain-boundaries、api-spec）引用本文件，不得重复定义。

---

## 1. 代码级禁止

适用于所有代码变更，由 constraints-spec 和 coding-standards 强制执行。

| 编号 | 禁止项 | 说明 | 严重级别 |
|------|--------|------|---------|
| CP-001 | 禁止循环依赖 | 模块间不得形成循环调用链 | error |
| CP-002 | 禁止使用 `any` / `interface{}` 作为公开 API | 公开接口必须有明确类型定义 | error |
| CP-003 | 禁止吞没错误 | 所有错误必须显式处理或向上传递 | error |
| CP-004 | 禁止硬编码配置值 | 配置必须通过环境变量或配置文件管理 | warning |
| CP-005 | 禁止在构造函数中执行 IO | 构造函数应仅做初始化，不执行副作用操作 | warning |
| CP-006 | 禁止使用魔法数字 | 常量必须有命名和注释 | info |

---

## 2. 架构级禁止

适用于架构变更，由 architecture-spec 强制执行。

| 编号 | 禁止项 | 说明 | 严重级别 |
|------|--------|------|---------|
| AP-001 | 禁止跨层直接访问 | 必须通过层间接口通信 | error |
| AP-002 | 禁止基础设施层依赖业务层 | 依赖方向必须正确 | error |
| AP-003 | 禁止模块间共享内部状态 | 模块必须保持封装性 | error |
| AP-004 | 禁止隐式模块依赖 | 所有依赖必须显式声明 | warning |
| AP-005 | 禁止绕过接口直接调用 | 必须通过公开接口访问模块功能 | error |

---

## 3. 安全级禁止

适用于所有涉及安全的变更，由 constraints-spec 和 api-spec 强制执行。

| 编号 | 禁止项 | 说明 | 严重级别 |
|------|--------|------|---------|
| SP-001 | 禁止硬编码密钥/令牌/密码 | 敏感信息必须通过环境变量或密钥管理服务获取 | error |
| SP-002 | 禁止在日志中输出 PII | 个人身份信息不得出现在日志中 | error |
| SP-003 | 禁止执行未经验证的动态代码 | 防止代码注入攻击 | error |
| SP-004 | 禁止错误响应暴露内部细节 | 错误信息不得包含堆栈跟踪、内部路径等 | error |
| SP-005 | 禁止使用不安全的加密算法 | 必须使用 AES-256、RSA-2048+ 等行业标准 | error |
| SP-006 | 禁止写操作无需认证 | 所有写操作必须有身份验证 | error |

---

## 4. 流程级禁止

适用于变更流程，由 constraints-spec 强制执行。

| 编号 | 禁止项 | 说明 | 严重级别 |
|------|--------|------|---------|
| PP-001 | 禁止绕过 Decision Layer 直接执行 L2+ 变更 | L2+ 变更必须经过审议 | error |
| PP-002 | 禁止跳过用户确认环节 | <HARD-GATE> 标记的环节必须等待用户确认 | error |
| PP-003 | 禁止未测试就合并到主分支 | 所有变更必须通过测试 | error |
| PP-004 | 禁止破坏已有契约 | 接口变更必须向后兼容或版本化 | error |

---

## 5. 跨域级禁止

适用于跨领域边界的变更，由 domain-boundaries 强制执行。

| 编号 | 禁止项 | 说明 | 严重级别 |
|------|--------|------|---------|
| XP-001 | 禁止跨域直接调用内部函数 | 必须通过域间接口通信 | error |
| XP-002 | 禁止共享数据库 schema 作为跨服务契约 | 服务间必须通过 API 通信 | error |
| XP-003 | 禁止破坏已有契约 | 领域接口变更必须向后兼容 | error |

---

## 6. 协作级禁止

适用于团队协作，由 constraints-spec 强制执行。

| 编号 | 禁止项 | 说明 | 严重级别 |
|------|--------|------|---------|
| CL-001 | 禁止未沟通就进行架构变更 | 架构变更必须提前讨论 | warning |
| CL-002 | 禁止忽略代码审查意见 | 审查意见必须回应 | warning |
| CL-003 | 禁止提交不完整的功能 | 功能必须完整可用 | error |
| CL-004 | 禁止删除他人代码未沟通 | 删除代码前必须与原作者确认 | warning |

---

## 使用方式

各 spec 文件在"禁止模式"章节中引用本文件：

```markdown
## 禁止模式

> 通用禁止模式见 [shared-prohibitions.md](./shared-prohibitions.md)。
> 本文件仅列出项目/领域特有的禁止项：

- [项目特有禁止项]
```

---

## 契约更新历史

| 日期 | 变更内容 | 变更人 | ADR 引用 |
|:----|:---------|:-------|:---------|
| 2026-05-20 | 初始创建，收敛自 project-spec/architecture-spec/constraints-spec/domain-boundaries | AI | ADR-001, ADR-007 |

---

**关联文件**: [project-spec](./project-spec.md) · [architecture-spec](./architecture-spec.md) · [constraints-spec](./constraints-spec.md) · [domain-boundaries](./domain-boundaries.md) · [api-spec](./api-spec.md)
