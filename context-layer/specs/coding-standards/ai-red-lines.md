# AI Behavior Red Lines

> **模块**: 编码规则 · **ID 前缀**: `AI-*`
> **所有语言通用** — 这些约束适用于任何技术栈

---

## Rules

| ID | Rule | Severity | Rationale |
|:---|:--------------- |:---------|:----------|
| AI-R001 | **Do not redesign architecture during implementation.** If you discover a better approach, freeze work and return to Decision Layer. | `error` | Decision freezing is a core governance principle |
| AI-R002 | **Do not add "nice-to-have" features.** Only implement what is specified in the task decomposition. | `error` | Scope creep undermines the contract |
| AI-R003 | **Do not skip tests.** Every implementation must have corresponding tests before being considered complete. | `error` | TDD is the mandated workflow |
| AI-R003 | **Do not skip tests.** Every implementation must have corresponding tests before being considered complete. | `error` | TDD is the mandated workflow |
| AI-R004 | **Do not introduce new dependencies without approval.** If a dependency would help, flag it and stop. | `error` | Dependency decisions belong in Decision Layer |
| AI-R005 | **Do not refactor unrelated code.** Change only the files that are part of the current task. | `error` | Side-effect refactoring introduces risk |
| AI-R006 | **Do not leave TODO/FIXME/HACK comments in committed code.** Either implement it now or create a task for it. | `warning` | Incomplete code is a quality debt |
| AI-R007 | **Do not silence errors with empty catch / `_ = err`.** Every error must be handled or explicitly propagated. | `error` | Silent errors are a primary source of production bugs |
| AI-R008 | **Do not hardcode configuration values.** All environment-specific values must come from config system. | `error` | Config hardcoding is a security and ops risk |

---

## Violation Handling

If any AI-R rule is violated during implementation:
1. The AI must stop and self-report the violation
2. Record the violation in the implementation report
3. Revert the violating code
4. Only then proceed

---

**关联**: [index.md](./index.md) · [common.md](./common.md) · [extension-guide.md](./extension-guide.md)