---
hydration:
  asset: "project-spec"
  version: "1.2.0"
  updated: "2026-05-16"
  adr_ref: "ADR-001, ADR-003"
---

# Project Constraints

> **层**: Context Layer · **职责**: 项目约束运行时契约
> **生命周期**: 项目级别，持续生效
> **更新条件**: 仅通过 Decision Layer 审议后更新

---

## 1. 架构风格

- **架构模式**: Layered Architecture + Hybrid Integration Pattern
- **模块组织方式**: 按功能域（Domain-oriented）组织
- **依赖方向**: 外层依赖内层，领域层独立，实现依赖抽象
- **状态管理**: 分布式状态，各层维护自身状态，通过契约传递
- **进程模型**: 单进程多阶段编排，按需加载模块

---

## 2. 允许的依赖

### 核心依赖（必须使用）
- **运行时**: Node.js >= 18 / Deno >= 1.30
- **测试框架**: Jest / Playwright / Mocha
- **构建工具**: 按需选择，无强制要求
- **配置格式**: JSON / YAML
- **文档格式**: Markdown

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
Domain Map — see domain-boundaries.md for full details

Context Domain:     context-layer/    — 上下文契约（只读，无业务逻辑）
Orchestration Domain: gs-hybrid-v3    — 流程编排（复杂度评估/阶段调度/技能路由）
Execution Domain:   execution-layer/  — 代码实现/测试执行/文档生成
Skills Domain:      skills/           — Superpowers/GStack/Hybrid/Custom 技能集
Tools Domain:       gstack-skills/bin/, scripts/ — 底层工具
```

### 跨域通信规则
- 域间通信必须通过定义好的接口
- 禁止跨域直接访问数据库
- 禁止跨域共享内部模型
- 域间依赖必须单向

---

## 4. API 标准

### 设计规范
- API 命名风格: 统一通过 SKILL.md 入口
- 版本化策略: 语义化版本（MAJOR.MINOR.PATCH）
- 错误格式: 非零退出码 + JSON 错误消息
- 接口契约: 结构化 JSON 优先

### 兼容性
- 所有公开 API 必须向后兼容
- 不兼容变更必须通过版本化
- 废弃端点至少保留 2 个版本周期

---

## 5. 事务规则

### 事务边界
- 单次技能调用无持久化事务要求
- 跨技能编排无分布式事务

### 一致性
- 核心约取得强一致性（文件落地）
- 非关键路径: 最终一致性
- 一致性策略必须在 ADR 中记录

---

## 6. 并发规则

### 并发模型
- **并发原语**: 单线程异步（Node.js）/ 协程（Deno）
- **共享状态**: 通过文件系统或环境变量传递
- **竞态防护**: 无共享可变状态

### 限制
- 普通任务串行执行
- 后台任务无并行
- 工具调用并发按具体工具限制

---

## 7. 命名规则

### 代码
- **文件命名**: PascalCase（技能目录）, kebab-case（配置文件）
- **类型命名**: PascalCase
- **函数命名**: camelCase
- **变量命名**: camelCase

### 资源
- **技能路径**: `skills/<category>/<skill-name>/SKILL.md`
- **配置键**: kebab-case
- **ADR 路径**: `decision-layer/adr/ADR-NNN-title.md`

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

## 9. 项目适配指南

> 本文件中的约束示例基于 Superpowers 项目自身。使用 gs-hybrid-v3 治理其他项目时，必须按以下流程适配。

### 适配流程

1. **复制本文件**为项目专属的 `project-spec.md`
2. **替换以下章节**以匹配目标项目：
   - §1 架构风格 — 替换为目标项目的架构模式（如 Clean Architecture / Microservices / Monolith）
   - §2 允许的依赖 — 替换为目标项目的语言/框架/工具链
   - §3 领域边界 — 替换为目标项目的域划分
   - §6 并发规则 — 替换为目标项目的并发模型（如 goroutine / async-await / thread pool）
   - §7 命名规则 — 替换为目标项目的命名约定（如 snake_case / camelCase）
3. **审查禁止模式**（§8）— 保留通用禁止项，添加项目特定的禁止项
4. **通过 Decision Layer 审议**确认适配后的 spec

### 必须保留的通用约束

无论项目如何不同，以下约束不可删除：
- 依赖版本必须锁定
- 禁止吞没错误
- 禁止硬编码密钥/令牌
- 禁止循环依赖
- 公开 API 必须向后兼容
- 不兼容变更必须版本化

---

## 10. 契约更新历史

| 日期 | 变更内容 | 变更人 | ADR 引用 |
|:----|:---------|:-------|:---------|
| 2026-05-17 | 从模板填充实际内容 | AI | ADR-001, ADR-002, ADR-003, ADR-004 |

---

**关联文件**: [architecture-spec](./architecture-spec.md) · [constraints-spec](./constraints-spec.md) · [domain-boundaries](./domain-boundaries.md)
