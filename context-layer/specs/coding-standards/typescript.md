# TypeScript Coding Standards

> **模块**: 编码规则 · **ID 前缀**: `TS-*`
> **适用**: TypeScript / Node.js / Deno / Bun

---

## Module Overview

| Category | ID Range | Count | Severity Mix |
|:---------|:---------|:-----:|:-------------|
| 命名规范 | TS-N001 ~ TS-N006 | 6 | 0 error / 3 warning / 1 info |
| 类型安全 | TS-T001 ~ TS-T006 | 6 | 1 error / 4 warning / 1 info |
| 错误处理 | TS-E001 ~ TS-E004 | 4 | 2 error / 1 warning / 1 info |
| 架构与导入 | TS-A001 ~ TS-A004 | 4 | 1 error / 2 warning / 1 info |

---

## Naming Conventions

| ID | Rule | Severity | Example |
|:---|:-----|:---------|:--------|
| TS-N001 | **Interface names start with `I` prefix** OR use PascalCase consistently — choose one per project | `warning` | `IUserRepo` or `UserRepo` |
| TS-N002 | **Type names are PascalCase** | `error` | `type UserProfile = ...` |
| TS-N003 | **Function/Variable names are camelCase** | `error` | `function getUser()` |
| TS-N004 | **Constants (compile-time-known) are UPPER_SNAKE_CASE** | `info` | `const MAX_RETRIES = 3` |
| TS-N005 | **File names match the primary export, kebab-case** | `warning` | `user-service.ts` |
| TS-N006 | **Boolean variables use positive prefixes: `is`, `has`, `should`** | `warning` | `isActive`, `hasPermission` |

---

## Type Safety

| ID | Rule | Severity | Rationale |
|:---|:-----|:---------|:----------|
| TS-T001 | **Do not use `any` in exported/public API signatures** | `error` | Breaks type safety for consumers |
| TS-T002 | **Prefer `unknown` over `any` when type is genuinely unknown** | `warning` | `unknown` forces type narrowing |
| TS-T003 | **Use `as const` for literal types and enums** | `warning` | Preserves type precision |
| TS-T004 | **Use `satisfies` operator instead of type cast where possible** | `info` | Catches structural mismatches |
| TS-T005 | **Do not use type assertions (`as`) unless narrowing from external API boundary** | `warning` | Type assertions bypass compiler checks |
| TS-T006 | **All public functions must have explicit return type annotations** | `warning` | Enables caller-side type checking |

---

## Error Handling

| ID | Rule | Severity | Rationale |
|:---|:-----|:---------|:----------|
| TS-E001 | **Do not use empty `catch {}` blocks** | `error` | Silently swallows errors |
| TS-E002 | **Prefer custom Error classes** | `warning` | Enables programmatic error handling |
| TS-E003 | **Use Either/Option monads or Result types for expected failures, throw for unexpected** | `info` | Distinguishes expected vs unexpected errors |
| TS-E004 | **Ensure async errors are caught at the top level** | `error` | Prevents unhandled promise rejections |

---

## Architecture & Imports

| ID | Rule | Severity | Rationale |
|:---|:-----|:---------|:----------|
| TS-A001 | **No barrel/index.ts re-exports for deep module trees** | `warning` | Creates circular dependency risks and slow builds |
| TS-A002 | **Imports must be in dependency order (external → internal → relative)** | `info` | Readability convention |
| TS-A003 | **Do not import from sibling directories — import from the public API layer only** | `warning` | Prevents bypassing module boundaries |
| TS-A004 | **Application layers must only depend inward** | `error` | Preserves layer isolation |

---

**关联**: [index.md](./index.md) · [common.md](./common.md)