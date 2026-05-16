# Project Constraints

> **层**: Context Layer · **职责**: 项目约束运行时契约
> **生命周期**: 项目级别，持续生效
> **更新条件**: 仅通过 Decision Layer 审议后更新

---

## 1. 架构风格

- **架构模式**: [Architecture pattern, e.g., Clean Architecture / Hexagonal / Layered / Event-Driven / Microservices]
- **模块组织方式**: [Module organization, e.g., by feature / by layer / by domain]
- **依赖方向**: [Dependency direction rules, e.g., outer → inner, domain is independent]
- **状态管理**: [State management approach, e.g., centralized / distributed / event sourcing]
- **进程模型**: [Process model, e.g., single-process / multi-process / serverless]

---

## 2. 允许的依赖

### 核心依赖（必须使用）
- **运行时**: [Runtime / framework]
- **测试框架**: [Test framework]
- **构建工具**: [Build tool]

### 允许引入的条件
- 新增依赖必须经过架构审议
- 间接依赖需检查许可证兼容性
- 禁止 GPL 类许可证的运行时依赖
- 禁止引入已有替代的内部实现

### 依赖管理规则
- 依赖版本必须锁定（lockfile）
- 定期安全扫描（依赖漏洞）
- 重大版本升级视为 L2+ 变更

---

## 3. 领域边界

```
[Domain Map - describe each bounded context and its responsibilities]

Domain A: [description]
  ├─ 职责: [core responsibilities]
  ├─ 对外接口: [exposed interfaces]
  ├─ 依赖: [depends on]
  └─ 禁止: [forbidden access patterns]

Domain B: [description]
  ├─ 职责: [core responsibilities]
  ├─ 对外接口: [exposed interfaces]
  ├─ 依赖: [depends on]
  └─ 禁止: [forbidden access patterns]
```

### 跨域通信规则
- 域间通信必须通过定义好的接口
- 禁止跨域直接访问数据库
- 禁止跨域共享内部模型
- 域间依赖必须单向

---

## 4. API 标准

### 设计规范
- API 命名风格: [Convention, e.g., RESTful / RPC / GraphQL]
- 版本化策略: [Versioning strategy]
- 错误格式: [Error response format]
- 分页规范: [Pagination rules]

### 兼容性
- 所有 API 变更必须向后兼容
- 不兼容变更必须通过 API 版本化
- 废弃端点至少保留 [N] 个版本周期

---

## 5. 事务规则

### 事务边界
- 一个事务跨越 [N] 个聚合根为上限
- 跨服务事务使用 [Saga / Outbox / 2PC]
- 不支持分布式事务的场景必须文档化

### 一致性
- 关键路径: 强一致性
- 非关键路径: 最终一致性（[N]s 内）
- 一致性策略必须在 ADR 中记录

---

## 6. 并发规则

### 并发模型
- **并发原语**: [e.g., goroutine + channel / async-await / thread pool]
- **共享状态**: 必须通过 [lock / actor / channel] 保护
- **竞态防护**: 所有共享可变状态必须加锁

### 限制
- 每个请求的并发上限: [N]
- 后台任务并行度上限: [N]
- 禁止裸启动协程/线程（必须通过池管理）

---

## 7. 命名规则

### 代码
- **文件命名**: [Convention, e.g., snake_case / kebab-case / PascalCase]
- **类型命名**: [Convention]
- **函数命名**: [Convention]
- **变量命名**: [Convention]

### 资源
- **API 路径**: [Convention]
- **数据库表**: [Convention]
- **配置键**: [Convention]

---

## 8. 禁止模式

### 代码级禁止
- 禁止使用 `any` / `interface{}` 作为公开 API 参数类型
- 禁止吞没错误（empty catch / `_ = err`）
- 禁止硬编码配置值（必须通过配置系统）
- 禁止循环依赖
- 禁止在构造函数中执行 IO 操作

### 架构级禁止
- 禁止基础设施层依赖业务层
- 禁止共享数据库 schema 作为跨服务契约
- 禁止隐式分布式事务
- 禁止绕过领域层直接操作持久化

### 安全级禁止
- 禁止将密钥/令牌硬编码在代码库中
- 禁止在日志中输出密码、令牌、PII
- 禁止使用不安全的加密算法
- 禁止前端直接操作数据库

---

## 9. 契约更新历史

| 日期 | 变更内容 | 变更人 | ADR 引用 |
|:----|:---------|:-------|:---------|
| [date] | [initial creation] | [author] | ADR-000 |

---

**关联文件**: [architecture-spec](./architecture-spec.md) · [constraints-spec](./constraints-spec.md) · [domain-boundaries](./domain-boundaries.md)