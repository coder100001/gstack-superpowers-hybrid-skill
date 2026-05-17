# Go Coding Standards

> **模块**: 编码规则 · **ID 前缀**: `GO-*`
> **适用**: Go / Golang

---

## Module Overview

| Category | ID Range | Count | Severity Mix |
|:---------|:---------|:-----:|:-------------|
| 命名规范 | GO-N001 ~ GO-N006 | 6 | 3 error / 0 warning / 3 info |
| 错误处理 | GO-E001 ~ GO-E005 | 5 | 2 error / 2 warning / 1 info |
| 并发 | GO-C001 ~ GO-C005 | 5 | 3 error / 1 warning / 1 info |

---

## Naming Conventions

| ID | Rule | Severity | Example |
|:---|:-----|:---------|:--------|
| GO-N001 | **Use `camelCase` for unexported, `PascalCase` for exported** | `error` | `func getUser()`, `type User struct{}` |
| GO-N002 | **Acronyms are all-uppercase** | `error` | `HTTP`, `URL`, `API`, `ID` |
| GO-N003 | **Single-letter variable names only for short scopes (< 5 lines)** | `info` | `for i := 0; ...` |
| GOGO-N004 | **Package names are lowercase, single word, no underscores** | `error` | `package model` not `package user_model` |
| GO-N005 | **File names are `snake_case.go`** | `error` | `user_service.go` |
| GO-N006 | **Receiver names are 1-3 letter abbreviation of type** | `info` | `func (u *User) GetName() string` |

---

## Error Handling

| ID | Rule | Severity | Rationale |
|:---|:-----|:---------|:----------|
| GO-E001 | **Do not use `_ = err` to silence errors** | `error`** | Silently discards error information |
| GO-E002 | **Always check returned error immediately, not later** | `warning` | Delayed checking leads to missed handling |
| GO-E003 | **Wrap errors with context using `fmt.Errorf("...: %w", err)`** | `warning` | Enables `errors.Is()` / `errors.As()` |
| GO-E004 | **Do not `panic()` in library code — return errors** | `error` | Panic cannot be recovered reliably |
| GO-E005 | **Use `errors.Is()` / `errors.As()` for sentinel/type errors** | `info` | Encourages composable error handling |

---

## Concurrency

| ID | Rule | Severity | Rationale |
|:---|:-----|:---------|:----------|
| GO-C001 | **Do not use `sync.Mutex` by value — always use pointer** | `error` | Value copy does not share lock state |
| GO-C002 | **Do not launch goroutines without a completion mechanism (WaitGroup/channel/context)** | `error` | Goroutine leaks cause resource exhaustion |
| GO-C003 | **Use `context.Context` as first parameter for blocking/async functions** | `warning` | Enables cancellation and deadlines |
| GO-C004 | **Do not use `time.Sleep` for synchronization** | `error` | Flaky and inefficient |
| GO-C005 | **Channel direction should be specified whenever possible (send-only/receive-only)** | `info` | Clearer contract |

---

**关联**: [index.md](./index.md) · [common.md](./common.md)