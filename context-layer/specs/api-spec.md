---
hydration:
  asset: "api-spec"
  version: "1.0.0"
  updated: "2026-05-19"
  adr_ref: "ADR-001"
---

# API Constraints

> **层**: Context Layer · **职责**: API 契约运行时约束
> **生命周期**: 项目级别，持续生效
> **更新条件**: 仅通过 Decision Layer 审议后更新
> **与 project-spec.md 的关系**: project-spec §4 定义 API 设计原则，本文件定义具体的契约约束

---

## 1. 路由定义规范

### 1.1 路由命名

| 规则 | 约束 | 示例 |
|:-----|:-----|:-----|
| 路径格式 | kebab-case，全小写 | `/api/v1/user-profile` |
| 版本前缀 | 必须，格式 `/api/v{N}/` | `/api/v1/`, `/api/v2/` |
| 资源命名 | 使用名词复数 | `/api/v1/users` |
| 嵌套资源 | 最多 2 层 | `/api/v1/users/{id}/orders` |
| 动作端点 | 仅用于非 CRUD 操作 | `/api/v1/users/{id}/activate` |

### 1.2 HTTP 方法映射

| 方法 | 用途 | 幂等性 | 请求体 | 响应 |
|:-----|:-----|:-------|:-------|:-----|
| GET | 查询资源 | 是 | 无 | 200 + 资源 |
| POST | 创建资源 / 触发动作 | 否 | 资源数据 | 201 + Location |
| PUT | 全量替换资源 | 是 | 完整资源 | 200 + 资源 |
| PATCH | 部分更新资源 | 否 | 部分字段 | 200 + 资源 |
| DELETE | 删除资源 | 是 | 无 | 204 无内容 |

### 1.3 路由注册约束

- 所有路由必须在实现前定义在 API spec 中
- 禁止实现时自行添加未在 spec 中声明的路由
- 路由变更属于 API 契约变更，冻结期间需走 Decision Layer 变更流程

---

## 2. 请求/响应 Schema

### 2.1 请求 Schema 模板

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["data"],
  "properties": {
    "data": {
      "type": "object",
      "description": "请求体数据，字段由具体 API 定义"
    },
    "meta": {
      "type": "object",
      "properties": {
        "requestId": { "type": "string", "format": "uuid" },
        "timestamp": { "type": "string", "format": "date-time" }
      }
    }
  }
}
```

### 2.2 响应 Schema 模板

#### 成功响应

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["data", "meta"],
  "properties": {
    "data": {
      "type": "object",
      "description": "响应体数据，结构由具体 API 定义"
    },
    "meta": {
      "type": "object",
      "required": ["requestId", "timestamp", "version"],
      "properties": {
        "requestId": { "type": "string", "format": "uuid" },
        "timestamp": { "type": "string", "format": "date-time" },
        "version": { "type": "string", "pattern": "^v\\d+$" },
        "pagination": {
          "type": "object",
          "properties": {
            "page": { "type": "integer", "minimum": 1 },
            "pageSize": { "type": "integer", "minimum": 1, "maximum": 100 },
            "total": { "type": "integer", "minimum": 0 },
            "hasMore": { "type": "boolean" }
          }
        }
      }
    }
  }
}
```

#### 错误响应

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["error"],
  "properties": {
    "error": {
      "type": "object",
      "required": ["code", "message"],
      "properties": {
        "code": { "type": "string", "description": "机器可读错误码，见 §3" },
        "message": { "type": "string", "description": "人类可读错误描述" },
        "details": {
          "type": "array",
          "items": {
            "type": "object",
            "properties": {
              "field": { "type": "string" },
              "issue": { "type": "string" },
              "suggestion": { "type": "string" }
            }
          }
        },
        "docUrl": { "type": "string", "format": "uri", "description": "错误文档链接" }
      }
    },
    "meta": {
      "type": "object",
      "properties": {
        "requestId": { "type": "string", "format": "uuid" },
        "timestamp": { "type": "string", "format": "date-time" }
      }
    }
  }
}
```

### 2.3 Schema 约束规则

| 规则 | 约束 | 理由 |
|:-----|:-----|:-----|
| 禁止 `any` 类型 | 所有字段必须有明确类型 | 类型安全 |
| 必须定义 required | 每个 Schema 必须声明 required 字段 | 防止部分数据 |
| 字符串必须限制长度 | `maxLength` / `minLength` | 防止超长输入 |
| 数值必须限制范围 | `minimum` / `maximum` | 防止越界 |
| 枚举必须穷举 | 不允许开放字符串表示有限选项 | 防止非法值 |
| 嵌套深度 ≤ 4 | Schema 嵌套不超过 4 层 | 可读性和性能 |
| 禁止 `$ref` 循环 | Schema 引用不能形成环 | 解析安全 |

---

## 3. 错误码枚举

### 3.1 错误码格式

```
{DOMAIN}_{SEVERITY}{NUMBER}

DOMAIN:    资源域缩写（3-5 字母）
SEVERITY:  E (Error) / W (Warning)
NUMBER:    3 位数字（001-999）
```

### 3.2 通用错误码

| 错误码 | HTTP 状态 | 含义 | 触发条件 |
|:-------|:----------|:-----|:---------|
| `GEN_E001` | 400 | 请求参数无效 | 请求体不符合 Schema |
| `GEN_E002` | 401 | 未认证 | 缺少或无效的认证凭据 |
| `GEN_E003` | 403 | 无权限 | 认证通过但无操作权限 |
| `GEN_E004` | 404 | 资源不存在 | 请求的资源 ID 无对应记录 |
| `GEN_E005` | 409 | 资源冲突 | 创建时唯一约束冲突 |
| `GEN_E006` | 422 | 语义错误 | 参数格式正确但语义无效 |
| `GEN_E007` | 429 | 请求过多 | 超过速率限制 |
| `GEN_E008` | 500 | 内部错误 | 未预期的服务端异常 |
| `GEN_E009` | 503 | 服务不可用 | 依赖服务不可达 |

### 3.3 域特定错误码

各域必须定义自己的错误码前缀：

| 域 | 前缀 | 示例 |
|:---|:-----|:-----|
| Context | `CTX_` | `CTX_E001` — Spec 文件格式无效 |
| Orchestration | `ORC_` | `ORC_E001` — 无效的状态转换 |
| Execution | `EXE_` | `EXE_E001` — 测试覆盖率未达标 |
| Skills | `SKL_` | `SKL_E001` — 技能加载失败 |
| Tools | `TOL_` | `TOL_E001` — 工具执行超时 |

### 3.4 错误码管理规则

- 错误码一旦发布不可复用（即使废弃也不回收编号）
- 新增错误码必须在 API spec 中注册
- 废弃错误码标记 `deprecated` 并保留至少 2 个版本周期
- 禁止在错误消息中暴露内部实现细节（堆栈、SQL、文件路径）

---

## 4. 认证与授权规范

### 4.1 认证方式

| 方式 | 适用场景 | 凭据位置 | 格式 |
|:-----|:---------|:---------|:-----|
| Bearer Token | API 调用 | `Authorization: Bearer {token}` | JWT |
| API Key | 服务间调用 | `X-API-Key: {key}` | 32 字符 hex |
| 无认证 | 只读公开端点 | — | — |

### 4.2 认证约束

- 所有写操作必须认证（POST/PUT/PATCH/DELETE）
- 读操作（GET）默认要求认证，除非在路由定义中标记 `public: true`
- 禁止在 URL 中传递认证凭据（`?token=xxx`）
- 禁止在日志中记录完整认证凭据

### 4.3 授权模型

```
角色层级:
  admin    → 全部操作
  editor   → 读写操作（不含系统配置）
  viewer   → 只读操作

权限检查:
  1. 认证通过 → 检查角色
  2. 角色匹配 → 检查资源权限
  3. 资源权限匹配 → 允许操作
  4. 任一步失败 → 返回 GEN_E003
```

### 4.4 Token 生命周期

| 参数 | 值 | 说明 |
|:-----|:---|:-----|
| Access Token 有效期 | 15 分钟 | 短期凭据 |
| Refresh Token 有效期 | 7 天 | 长期凭据，仅用于刷新 |
| Token 签名算法 | RS256 | 非对称签名 |
| Token 刷新窗口 | 有效期最后 5 分钟 | 避免并发刷新 |

---

## 5. 版本化策略

### 5.1 版本规则

| 变更类型 | 版本动作 | 示例 |
|:---------|:---------|:-----|
| 新增可选字段 | MINOR（不升级 API 版本） | 响应增加 `meta.debugInfo` |
| 新增端点 | MINOR | 新增 `/api/v1/reports` |
| 删除字段 | MAJOR（升级 API 版本） | `/api/v2/` 移除 `legacyId` |
| 修改字段类型 | MAJOR | `id: string` → `id: number` |
| 修改语义（不改结构） | MAJOR | 排序方向从 ASC 改为 DESC |

### 5.2 兼容性保证

- 同一 MAJOR 版本内必须向后兼容
- 废弃端点必须标记 `deprecated: true` 并在响应头添加 `Sunset` 头
- 废弃端点保留至少 2 个 MAJOR 版本周期
- 迁移指南必须作为 ADR 的一部分记录

### 5.3 版本协商

| 方式 | 优先级 | 示例 |
|:-----|:-------|:-----|
| URL 路径前缀 | 1（最高） | `/api/v1/users` |
| Accept Header | 2 | `Accept: application/vnd.api+json; version=1` |
| 自定义 Header | 3 | `X-API-Version: 1` |

同一请求中多种方式冲突时，按优先级取最高。

---

## 6. 速率限制

### 6.1 限制规则

| 端点类型 | 限制 | 窗口 |
|:---------|:-----|:-----|
| 读操作 | 100 次 | 每分钟 |
| 写操作 | 30 次 | 每分钟 |
| 批量操作 | 10 次 | 每分钟 |
| 认证端点 | 5 次 | 每分钟 |

### 6.2 限制响应

超限时返回 `GEN_E007` (429)，并包含以下响应头：

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1716123456
Retry-After: 30
```

---

## 7. 禁止模式

### API 设计禁止

- 禁止在 GET 请求中使用请求体传递参数
- 禁止返回裸数组作为顶层响应（必须包裹在对象中）
- 禁止使用动词作为资源名（`/getUsers` → `/users`）
- 禁止在响应中暴露内部 ID（数据库自增 ID 等）
- 禁止无分页的列表端点

### 安全禁止

- 禁止在错误响应中暴露堆栈跟踪
- 禁止在 URL 中传递敏感参数
- 禁止跨域传递认证凭据（除非 CORS 显式配置）
- 禁止明文传输认证信息

---

## 8. 项目适配指南

> 本文件中的约束基于通用 RESTful API 最佳实践。使用 gs-hybrid-v3 治理其他项目时，必须按以下流程适配。

### 适配流程

1. **复制本文件**为项目专属的 `api-spec.md`
2. **替换以下章节**以匹配目标项目：
   - §1 路由定义 — 替换为项目的路由表
   - §3 错误码 — 替换为项目的错误码体系
   - §4 认证授权 — 替换为项目的认证方案（如 OAuth2、API Key 等）
   - §5 版本化 — 替换为项目的版本策略（如 gRPC 不用 URL 前缀）
   - §6 速率限制 — 替换为项目的限流配置
3. **保留 §2 Schema 约束和 §7 禁止模式** — 这些是通用约束
4. **通过 Decision Layer 审议**确认适配后的 spec

### 必须保留的通用约束

无论项目如何不同，以下约束不可删除：
- 所有字段必须有明确类型（禁止 `any`）
- 错误响应必须包含 `code` + `message`
- 写操作必须认证
- 版本化策略必须定义
- 禁止在错误响应中暴露内部实现细节

---

## 9. 契约更新历史

| 日期 | 变更内容 | 变更人 | ADR 引用 |
|:----|:---------|:-------|:---------|
| 2026-05-19 | 初始创建 | AI | ADR-001 |

---

**关联文件**: [project-spec](./project-spec.md) · [architecture-spec](./architecture-spec.md) · [constraints-spec](./constraints-spec.md) · [domain-boundaries](./domain-boundaries.md)
