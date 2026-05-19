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

| # | Status | Module | File | Rule Count | Scope |
|:--|:-------|:-------|:-----|----------:|:------|
| 1 | ✅ 活跃 | AI 行为红线 | [ai-red-lines.md](./ai-red-lines.md) | 8 | AI 行为红线（所有语言通用） |
| 2 | ✅ 活跃 | TypeScript 规范 | [typescript.md](./typescript.md) | 20 | TypeScript 编码规范 |
| 3 | ✅ 活跃 | Go 规范 | [go.md](./go.md) | 16 | Go 编码规范 |
| 4 | ✅ 活跃 | 通用规则 | [common.md](./common.md) | 14 | 跨语言通用规则（安全/文档/组织） |
| 5 | | 扩展框架 | [extension-guide.md](./extension-guide.md) | — | 扩展框架 + 语言/框架预留槽位 |
| 6 | 📌 预留 | Python 规范 | python.md | — | Python 编码规范 |
| 7 | 📌 预留 | Rust 规范 | rust.md | — | Rust 编码规范 |
| 8 | 📌 预留 | Java 规范 | java.md | — | Java 编码规范 |
| 9 | 📌 预留 | React 规范 | fwk-react.md | — | React 框架规范 |
| 10 | 📌 预留 | Vue 规范 | fwk-vue.md | — | Vue 编码规范 |

### AI 行为红线速查（AI-R001 ~ AI-R008）

> 详细定义见 [ai-red-lines.md](./ai-red-lines.md)，此处为审查速查摘要。

| ID | 摘要 | Severity | 关键词 |
|:---|:-----|:---------|:-------|
| AI-R001 | 实现期间禁止重新设计架构 | `error` | `redesign`, `architecture`, `refactor-arch` |
| AI-R002 | 禁止添加任务分解外的功能 | `error` | `nice-to-have`, `scope-creep`, `extra-feature` |
| AI-R003 | 禁止跳过测试 | `error` | `skip-test`, `no-test`, `untested` |
| AI-R004 | 禁止未经批准引入新依赖 | `error` | `new-dep`, `npm-install`, `go-get` |
| AI-R005 | 禁止重构无关代码 | `error` | `unrelated-refactor`, `side-effect` |
| AI-R006 | 禁止提交 TODO/FIXME/HACK | `warning` | `TODO`, `FIXME`, `HACK` |
| AI-R007 | 禁止吞没错误 | `error` | `empty-catch`, `ignore-err`, `silence-error` |
| AI-R008 | 禁止硬编码配置值 | `error` | `hardcode`, `magic-number`, `config-inline` |

### 通用规则速查（SEC / DOC / ORG）

> 详细定义见 [common.md](./common.md)，此处为审查速查摘要。

| ID | 摘要 | Severity | 关键词 |
|:---|:-----|:---------|:-------|
| SEC001 | 禁止硬编码密钥/令牌/密码 | `error` | `secret`, `token`, `password`, `api-key` |
| SEC002 | 禁止日志输出敏感数据 | `error` | `log-password`, `log-token`, `log-PII` |
| SEC003 | 外部输入必须验证 | `error` | `unvalidated-input`, `injection` |
| SEC004 | 禁止 eval/动态代码执行 | `error` | `eval`, `exec`, `dynamic-code` |
| SEC005 | 数据库操作必须参数化 | `error` | `raw-query`, `sql-concat` |
| SEC006 | 禁止拼接用户输入构建路径 | `error` | `path-traversal`, `user-path` |
| DOC001 | 公开 API 必须有文档注释 | `warning` | `undocumented-export` |
| DOC002 | 文档注释解释"为什么"而非"什么" | `info` | `doc-what-not-why` |
| DOC003 | 复杂逻辑必须有行内注释 | `info` | `uncommented-complex` |
| DOC004 | 禁止注释掉的死代码 | `warning` | `dead-code`, `commented-code` |
| ORG001 | 每个文件一个主要关注点 | `info` | `multi-concern` |
| ORG002 | 函数长度 ≤ 50 行 | `warning` | `long-function` |
| ORG003 | 文件长度 ≤ 500 行 | `warning` | `large-file` |
| ORG004 | 圈复杂度 ≤ 10 | `warning` | `high-complexity` |

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