# Extension Guide

> **模块**: 编码规则 · **职责**: 定义如何向系统添加新语言/框架/技术栈
> **约束**: 新增模块须通过 Decision Layer 审议

---

## 1. Rule ID Namespace Convention

```
<LANG_PREFIX>-<CATEGORY_LETTER><SEQUENCE_NUMBER>
```

| Part | Format | Example |
|:-----|:-------|:--------|
| LANG_PREFIX | 2-3 uppercase letters | `PY`, `RS`, `JV`, `FWK-REACT` |
| CATEGORY_LETTER | 1 uppercase letter | `N` (naming), `T` (types), `E` (errors), `C` (concurrency), `A` (architecture) |
| SEQUENCE_NUMBER | 3 digits, zero-padded | `001`, `002`, ... |

---

## 2. Shared Category Letters

| Letter | Category | Applies To |
|:-------|:---------|:-----------|
| `N` | Naming conventions | All languages |
| `T` | Type system / Safety | Languages with type systems |
| `E` | Error handling | All languages |
| `C` | Concurrency / Async | Languages with concurrency models |
| `A` | Architecture / Imports | All languages |
| `M` | Memory management | Rust, C/C++ |
| `O` | Ownership / Borrowing | Rust |
| `P` | Performance | All languages |
| `S` | State management | Frameworks (React, Vue) |
| `H` | Hooks / Lifecycle | Frameworks (React) |
| `B` | Beans / Wiring | Frameworks (Spring) |

---

## 3. Reserved  Prefix Registry

Before adding a new language or framework, ensure its prefix is not already taken:

| Prefix | Assigned To | Module File | Status |
|:-------|:------------|:------------|:-------|
| `AI-*` | AI Behavior Red Lines | [ai-red-lines.md](./ai-red-lines.md) | 🔒 系统保留 |
| `SEC-*` | Security (cross-language) | [common.md](./common.md) | 🔒 系统保留 |
| `DOC-*` | Technology (cross-language) | [common.md](./common.md) | 🔒 系统保留 |
| `ORG-*` | Code Organization (cross-language) | [common.md](./common.md) | 🔒 系统保留 |
| `TS-*` | TypeScript | [typescript.md](./typescript.md) | ✅ 活跃 |
| `GO-*` | Go | [go.md](./go.md) | ✅ 活跃 |
| `PY-*` | Python | python.md | 📌 预留 |
| `RS-*` | Rust | rust.md | 📌 预留 |
| `JV-*` | Java | java.md | 📌 预留 |
| `CC-*` | C/C++ | c-cpp.md | 📌 预留 |
| `RB-*` | Ruby | ruby.md | 📌 预留 |
| `PH-*` | PHP | php.md | 📌 预留 |
| `SW-*` | Swift | swift.md | 📌 预留 |
| `KT-*` | Kotlin | kotlin.md | 📌 预留 |
| `FWK-*` | Framework rules (all) | — | 🔒 系统保留 |
| `FWK-REACT-*` | React | fwk-react.md | 📌 预留 |
| `FWK-VUE-*` | Vue | fwk-vue.md | 📌 预留 |
| `FWK-SPRING-*` | Spring Boot | fwk-spring.md | 📌 预留 |
| `FWK-NEXT-` | Next.js | fwk-next.md | 📌 预留 |
| `FWK-GIN-*` | Gin / Echo | fwk-gin.md | 📌 预留 |
| `FWK-DJANGO-*` | Django | fwk-django.md | 📌 预留 |
| `FWK-FASTAPI-*` | FastAPI | fwk-fastapi.md | 📌 预留 |
| `FWK-FLUTTER-*` | Flutter | fwk-flutter.md | 📌 预留 |

---

## 4. Language Extension Slots

All slots are reserved for future languages. When a new language needs coding rules, follow the namespace convention above and create a new module file.

### Python (Reserved)

> Slot for Python coding rules. File: `python.md`
>
> Expected categories:
> - PY-N* (naming: snake_case, CapWords)
> - PY-T* (typing: type hints, Optional vs None)
> - PY-E* (error handling: try/except patterns)
> - PY-C* (concurrency: asyncio, GIL awareness)
> - PY-A* (architecture: imports, __init__)

### Rust (Reserved)

> Slot for Rust coding rules. File: `rust.md`
>
> Expected categories:
> - RS-N* (naming: snake_case, PascalCase)
> - RS-O* (ownership: borrowing, lifetimes)
> - RS-E* (error handling: Result, Option, unwrap)
> - RS-C* (concurrency: Send, Sync, Arc)
> - RS-A* (architecture: module system, trait bounds)

### Java (Reserved)

> Slot for Java coding rules. File: `java.md`
>
> Expected categories:
> - JV-N* (naming: camelCase, PascalCase)
> - JV-T* (type system: generics, Optional)
> - JV-E* (error handling: checked vs unchecked)
> - JV-C* (concurrency: synchronized, CompletableFuture)
> - JV-A* (architecture: package structure, DI)

### C/C++ (Reserved)

> Slot for C/C++ coding rules. File: `c-cpp.md`
>
> Expected categories:
> - CC-N* (naming: snake_case, PascalCase)
> - CC-M* (memory: RAII, raw pointers, smart pointers)
> - CC-E* (error handling: error codes, exceptions)
> - CC-C* (concurrency: mutex, atomics)
> - CC-P* (preprocessor: macros, constexpr)

---

## 5. Framework Extension Slots

Framework-specific rules cover framework conventions, component patterns, and ecosystem-specific best practices. They should not duplicate language-level rules.

| Framework | Prefix | Module File | Status |
|:----------|:-------|:------------|:-------|
| React | `FWK-REACT-*` | fwk-react.md | 📌 预留 |
| Vue | `FWK-VUE-*` | fwk-vue.md | 📌 预留 |
| Spring Boot | `FWK-SPRING-*` | fwk-spring.md | 📌 预留 |
| Next.js | `FWK-NEXT-*` | fwk-next.md | 📌 预留 |
| Gin / Echo | `FWK-GIN-*` | fwk-gin.md | 📌 预留 |
| Django | `FWK-DJANGO-*` | fwk-django.md | 📌 预留 |
| FastAPI | `FWK-FASTAPI-*` | fwk-fastapi.md | 📌 预留 |
| Flutter | `FWK-FLUTTER-*` | fwk-flutter.md | 📌 预留 |

### React (Reserved)

> File: `fwk-react.md`
>
> Expected categories:
> - FWK-REACT-H* (hooks rules: deps, rules-of-hooks)
> - FWK-REACT-C* (component patterns: composition, props)
> - FWK-REACT-S* (state management: zustand, redux patterns)
> - FWK-REACT-P* (performance: memo, useMemo, useCallback)

### Vue (Reserved)

> File: `fwk-vue.md`
>
> Expected categories:
> - FWK-VUE-C* (composition API vs options API)
> - FWK-VUE-P* (props/emit patterns)
> - FWK-VUE-S* (state: pinia/vuex patterns)
> - FWK-VUE-P* (performance: computed watchers)

### Spring Boot (Reserved)

> File: `fwk-spring.md`
>
> Expected categories:
> - FWK-SPRING-B* (bean wiring: constructor injection)
> - FWK-SPRING-T* (transactional boundaries)
> - FWK-SPRING-C* (controller patterns: REST conventions)
> - FWK-SPRING-S* (security: annotation-based auth)

---

## 6. Step-by-Step: Adding a New Module

### Adding a New Language

1. **Check prefix** — Ensure no conflicts in the Reserved Prefix Registry
2. **Register prefix** — Update the registry and add an entry to the Language Slots
3. **Create module file** — `coding-standards/<language>.md`
4. **Choose categories** — Determine which category letters apply
5. **Write rules** — Follow the existing table pattern (ID, Rule, Severity, Rationale/Example)
6. **Register in index.md** — Add a row to the Module Index table
7. **Update Change History** — Record what was added

### Adding a New Framework

1. **Create prefix** — `FWK-<FRAMEWORK>-*`
2. **Register prefix** — Update the registry and the Framework Slots table
3. **Create module file** — `coding-standards/fwk-<framework>.md`
4. **Define categories** — Use shared category letters; add framework-specific ones if needed
5. **Scope the rules** — Framework rules should not duplicate language rules; they cover framework-specific conventions only
6. **Registerhin Register in index.md**
7. **Update Change History**

---

## 7. Rule Quality Requirements

Each new rule MUST have:
- **Clear ID** following namespace convention
- ** description** — AI can deterministically check for violation
- **Specific severity** — error / warning / info
- **Rationale** — explains why this rule exists (prevents cargo-culting)
- **Example** (for naming/style rules) — shows correct vs incorrect

Rules that are subjective, non-deterministic, or tool-dependent (e.g. specific linter configs) should reference external tooling rather than be encoded here.

---

## 8. Change History

| Version | Date | Change | Author |
|:--------|:-----|:-------|:-------|
| 1.1 | 2026-05-17 | created — modular extension framework | gs-hybrid-v3 |