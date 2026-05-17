# Common Rules (All Languages)

> **模块**: 编码规则 · **ID 前缀**: `SEC-*` / `DOC-*` / `ORG-*`
> **跨语言通用** — 适用于所有技术栈

---

## Module Overview

| Category | ID Range | Count | Severity Mix |
|:---------|:---------|:-----:|:-------------|
| 安全编码 | SEC-001 ~ SEC-006 | 6 | 6 error / 0 warning / 0 info |
| 文档规范 | DOC-001 ~ DOC-004 | 4 | 0 error / 2 warning / 2 info |
| 代码组织 | ORG-001 ~ ORG-004 | 4 | 0 error / 3 warning / 1 info |

---

## Security

| ID | Rule | Severity | Rationale |
|:---|:-----|:---------|:----------|
| SEC001 | **Do not hardcode secrets, keys, tokens, or passwords in source code** | `error` | Credential leak is a critical security incident |
| SEC002 | **Do not log sensitive data (passwords, tokens, PII)** | `error` | Logs are not secure storage |
| SEC003 | **Validate all external input at the boundary** | `error` | Injection attacks start at system entry points |
| SEC004 | **Do not use `eval()` or equivalent dynamic code execution** | `error` | Arbitrary code execution vulnerability |
| SEC005 | **Use parameterized queries for database operations** | `error` | SQL injection prevention |
| SEC006 | **Do not construct file paths from user input without validation** | `error` | Path traversal attacks |

---

## Documentation

| ID | Rule | Severity | Rationale |
|:---|:-----|:---------|:----------|
| DOC001 | **All exported/public types, functions, and methods must have doc comments** | `warning` | Public API documentation is a contract |
| DOC002 | **Doc comments must explain "why", not "what"** | `info` | Code itself shows "what" |
| DOC003 | **Complex business logic must have inline comments** | `info` | Reduces cognitive overhead |
| DOC004 | **Do not leave dead code (commented-out blocks)** | `warning` | Dead code becomes misleading over time |

---

## Code Organization

| ID | Rule | Severity | Rationale |
|:---|:-----|:---------|:----------|
| ORG001 | **One primary concern per file** | `info` | SRP at file level |
| ORG002 | **Function length <= 50 lines** | `warning` | Long functions are hard to reason about |
| ORG003 | **File length <= 500 lines** | `warning` | Large files indicate poor cohesion |
| ORG004 | **Cyclomatic complexity <= 10 per function** | `warning` | Low complexity is correlated with fewer bugs |

---

**关联**: [index.md](./index.md) · [ai-red-lines.md](./ai-red-lines.md)