# Coding Standards

> **层**: Context Layer · **职责**: 编码规则契约，约束 AI 编码行为
> **生命周期**: 项目级别，持续生效
> **更新条件**: 仅通过 Decision Layer 审议后更新
> **当前覆盖**: TypeScript / Go
> **扩展机制**: 见 [extension-guide.md](./extension-guide.md)

---

## Preamble

Code review is not "verification passes." Existing mechanisms (TDD, self-review, multi-role deliberation) verify behavioral correctness — they do not check code readability, maintainability, style consistency, performance traps, or security vulnerabilities.

This system fills that gap. It defines **programmatic rules** that the AI must check itself against during and after coding. These rules are loaded into context via Hydration before any implementation begins, and enforced during SELF_REVIEW and QA.

**Violating a rule in this document is a code review failure.** The implementation cannot proceed until the violation is resolved.

---

## Module Index

| # | Module | File | Status | File | Rule Count | Scope |
|:--|:------------- |:-----|:----------:|:------|
| 1 | ✅ 活跃 | [ai-red-lines.md](./ai-red-lines.md) | 8 | AI 行为红线（所有语言通用） |
| 2 | ✅ 活跃 | [typescript.md](./typescript.md) | 20 | TypeScript 编码规范 |
| 3 | ✅ 活跃 | [go.md](./go.md) | 16 | Go 编码规范 |
| 4 | ✅ 活跃 | [common.md](./common.md) | 14 | 跨语言通用规则（安全/文档/组织） |
| 5 |  | [extension-guide.md](./extension-guide.md) | 模块定义 | 扩展框架 + 语言/框架预留槽位 |
| 6 | 📌 预留 | python.md | — | Python 编码规范 |
| 7 | 📌 预留 | rust.md | — | Rust 编码规范 |
| 8 | 📌 预留 | java.md | — | Java 编码规范 |
| 9 | 📌 预留 | fwk-react.md | — | React 框架规范 |
| 10 | 📌 预留 | fwk-vue.md | — | Vue 编码规范 |

> **添加新模块**: 在目录下新建文件，按照 [extension-guide.md](./extension-guide.md) 的步骤编写规则，然后在 index.md 中注册。

---

## Rule Check Output Format

During SELF_REVIEW, the AI must generate a rule check summary covering all active modules:

```markdown
## Rule Check Summary

### Errors (must fix)
| Rule ID | Module | File | Line | Description |
|:--------|:-------|:-----|:----:|:------------|

### Warnings (should fix)
| Rule ID | Module | File | Line | Description |
|:--------|:-------|:-----|:----:|:------------|

### AI Behavior Check
| Rule ID | Status | Description |
|:--------|:-------|:------------|
| AI-R001 | ✅ | No architecture redesign |
| AI-R002 | ✅ | No scope creep |
| AI-R003 | ✅ | All code has tests |
| AI-R004 | ✅ | No new dependencies |
| AI-R005 | ✅ | No unrelated refactoring |
| AI-R006 | ✅ | No TODO/FIXME left |
| AI-R007 | ✅ | No silenced errors |
| AI-R008 | ✅ | No hardcoded configs |
```

---

## Change History

| Version | Date | Change | Author |
|:--------|:-----|:-------|:-------|
| 1.0 | 2026-05-17 | Initial creation — AI Red Lines + TS/Go rules | gs-hybrid-v3 |
| 1.1 | 2026-05-17 | Modular restructure — split into per-language files | gs-hybrid-v3 |