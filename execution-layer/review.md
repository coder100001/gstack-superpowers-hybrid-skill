# Code Review Rules

> **层**: Execution Layer · **职责**: 质量把关 + 编码规则强制校验
> **前置条件**: 测试已通过（见 testing.md），编码规则已加载（见 coding-standards/index.md）
> **禁止**: 跳过审查、流于形式、个人偏好主导
> **v5.0 更新**: 对齐 Superpowers 6.0 SDD 单 task-reviewer 双 verdict 模式

---

## 0. SDD Task Review 模式（v5.0）

当通过 `subagent-driven-development` 执行时，审查采用单 task-reviewer 模式：

- **一次 diff 读取，两个 verdict**：spec compliance + code quality
- **文件化交接**：task brief 写入 `.superpowers/sdd/task-N-brief.md`，review diff 写入 `.superpowers/sdd/review-package-N.diff`
- **Progress Ledger**：审查结果记录到 `.superpowers/sdd/progress.md`，支持断点恢复
- **禁止干预**：controller 不能压制 reviewer 发现或预评级严重程度
- **证据要求**：每个结论必须用文件 + 行号支撑

> 详细模板：`skills/superpowers/subagent-driven-development/task-reviewer-prompt.md`
> 交接脚本：`skills/superpowers/subagent-driven-development/scripts/`

---

## 1. 规则驱动审查

审查不再依赖主观判断清单，而是**对照 [coding-standards/index.md](../context-layer/specs/coding-standards/index.md) 中的可编程规则逐条检查**。

审查流程：

```
Rule-Driven Review Flow
  ├── Step 1: 加载编码标准（coding-standards/index.md）
  ├── Step 2: 按严重级别扫描 changed files
  │     ├── error 级别 → 必须修复（阻断）
  │     ├── warning 级别 → 建议修复（非阻断，记录）
  │     └── info 级别 → 记录提示
  ├── Step 3: AI 行为红线检查（AI-R001 ~ AI-R008）
  ├── Step 4: 语言特定规则检查（TS-* / GO-*）
  ├── Step 5: 通用规则检查（SEC-* / DOC-* / ORG-*）
  ├── Step 6: 生成规则检查摘要
  └── Step 7: 如果有 error 违规 → 审查不通过
```

### 审查通过标准

- 所有 `error` 级别违规已修复
- 所有 `warning` 级别违规已记录（可接受延期，但必须注明原因）
- AI 行为红线（AI-R*）全部通过
- 测试全部通过（见 testing.md）

---

## 2. 审查清单

### 2.1 编码规则检查（必选）

| 检查域 | 规则来源 | 最低要求 |
|:-------|:---------|:---------|
| AI 行为红线 | AI-R001 ~ AI-R008 | 全部通过 |
| TypeScript 规则 | TS-* | 0 error |
| Go 规则 | GO-* | 0 error |
| 安全规则 | SEC-* | 全部 error 级 |
| 文档规则 | DOC-* | 全部通过 |
| 代码组织 | ORG-* | warning 及以下 |

### 2.2 上下文契约对照
- [ ] 是否遵循架构决策记录（ADR）
- [ ] 是否遵守领域边界约定
- [ ] 是否符合项目约束规范
- [ ] 是否保持与已有代码风格一致
- [ ] 是否引入未经批准的依赖

### 2.3 测试覆盖验证
- [ ] 新代码有对应的测试
- [ ] 测试覆盖了主要路径
- [ ] 测试覆盖了错误路径
- [ ] 测试清晰易读
- [ ] 测试可独立运行

### 2.4 架构合规性
- [ ] 模块划分合理
- [ ] 依赖关系清晰
- [ ] 无循环依赖
- [ ] 符合分层架构要求（TS-A004）
- [ ] 配置外部化（无硬编码）

---

## 3. 审查流程

### 3.1 自审（Self-Review）
```
提交前必须完成：
  ├─ 对照审查清单逐项检查
  ├─ 运行规则驱动检查（生成规则检查报告）
  ├─ 运行 lint 和类型检查
  ├─ 确保所有测试通过
  └─ 撰写清晰的提交信息
```

### 3.2 审查通过标准
- 编码规则检查：0 error
- AI 行为红线：全部通过
- 所有评论已解决
- CI 检查全通过
- 无阻塞性问题

---

## 4. 红线

### 4.1 绝对不能合并
- ❌ 违反编码规则（error 级别未修复）
- ❌ AI 行为红线违规
- ❌ 违反上下文契约
- ❌ 测试未通过
- ❌ 存在安全漏洞
- ❌ 引入未知风险
- ❌ 代码质量严重下降

### 4.2 必须整改
- ⚠️ 命名混乱（TS-N001/GO-N001）
- ⚠️ 逻辑复杂度过高（ORG004）
- ⚠️ 缺少测试
- ⚠️ 错误处理不当（TS-E001/GO-E001）
- ⚠️ 性能问题

---

**关联文件**: [coding-standards/index.md](../context-layer/specs/coding-standards/index.md) · [implementation.md](./implementation.md) · [testing.md](./testing.md) · [validation.md](./validation.md)