# 06 - 专用流程指令

> **Context Load**: 指令触发，无需框架文件。根据指令类型加载对应阶段模块。

## 指令概览

| 指令 | 功能 | 适用场景 |
|------|------|---------|
| `/plan` | 规划流程 | 新功能开发前的完整规划 |
| `/review` | 代码审查 | 代码完成后的质量审查 |
| `/test` | 测试驱动 | TDD 开发流程 |
| `/qa` | 质量保证 | 功能完成后的验证 |
| `/debug` | 调试助手 | 问题诊断与修复 |
| `/refactor` | 重构建议 | 代码改进与优化 |

---

## 状态机映射

### 主状态流程

```
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION
    → [Context Hydration] → IMPLEMENTATION → SELF_REVIEW → QA
    → SHIP_REVIEW → RETRO
```

### 层归属

| 状态 | 层归属 | 说明 |
|------|--------|------|
| **IDEA** | Decision Layer | 任务接收 |
| **DISCOVERY** | Decision Layer | 需求澄清 |
| **REQUIREMENT_LOCK** | Decision Layer | 需求确认 |
| **ARCH_REVIEW** | Decision Layer | 多角色架构审议 |
| **TASK_DECOMPOSITION** | Decision Layer | 任务拆解 |
| **Context Hydration** | Context Bridge | 加载 Spec 契约 |
| **IMPLEMENTATION** | Execution Layer | TDD 编码（决策冻结） |
| **SELF_REVIEW** | Execution Layer | 对照契约自审 |
| **QA** | Execution Layer | 质量验证 |
| **SHIP_REVIEW** | Governance | 发布检查 |
| **RETRO** | Governance | 复盘记录 |

---

## /plan - 规划流程

### 触发方式

```
用户: /plan 我要开发一个新功能
或
用户: hybrid plan 开发用户认证模块
```

### 执行流程

```
IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → TASK_DECOMPOSITION
```

### 输出

- 复杂度评估报告
- Design Doc (L2+)
- PLAN.md
- ADR（架构决策记录）
- 用户确认记录

### Decision Layer 活动

1. **DISCOVERY** - 需求澄清 (brainstorming)
2. **REQUIREMENT_LOCK** - 需求确认 (强制用户确认)
3. **ARCH_REVIEW** - 多角色架构审议 (5个维度)
4. **TASK_DECOMPOSITION** - 任务拆解

---

## /review - 代码审查

### 触发方式

```
用户: /review 请审查这段代码
或
用户: hybrid review [文件路径]
```

### 执行流程

```
SELF_REVIEW → QA → SHIP_REVIEW
```

### 审查维度

1. **契约对照** - 与 Context Layer Spec 一致性
2. **工程规范** - 代码风格、最佳实践
3. **架构边界** - 模块职责、依赖方向
4. **测试覆盖** - 测试策略、边界条件

### 输出

- 自审报告 (SELF_REVIEW)
- QA 评审报告 (QA)
- 发布检查清单 (SHIP_REVIEW)

---

## /test - 测试驱动

### 触发方式

```
用户: /test 帮我写测试
或
用户: hybrid test [功能描述]
```

### 执行流程

```
Context Hydration → IMPLEMENTATION → SELF_REVIEW
```

### TDD 循环（决策冻结期间）

```
加载 Spec 契约 → 测试失败（TDD 红）→ 最简实现（TDD 绿）→ 约束内重构
```

### 输出

- 测试代码
- 实现代码
- 测试报告
- 覆盖率报告

### 注意事项

- **决策冻结**: IMPLEMENTATION 期间架构/需求/契约不得自行更改
- **上下文注水**: 必须在编码前加载所有 Spec 契约
- **禁止跳步**: 不能在没有注水的情况下直接编码

---

## /qa - 质量保证

### 触发方式

```
用户: /qa 进行质量检查
或
用户: hybrid qa [功能范围]
```

### 执行流程

```
QA → SHIP_REVIEW
```

### 检查内容

1. **功能测试** - 场景覆盖、边界条件
2. **契约验证** - 与 Spec 一致性检查
3. **回归测试** - 现有功能影响
4. **安全扫描** - 漏洞检测、敏感信息

### 输出

- QA 评审报告
- 测试报告
- 问题清单
- SHIP_REVIEW 发布检查清单

---

## /debug - 调试助手

### 触发方式

```
用户: /debug 这个 bug 怎么解决
或
用户: hybrid debug [问题描述]
```

### 执行流程

```
问题理解 → 信息收集 → 根因分析 → 方案制定 → 修复验证
```

### 调用的组件

- `Decision Layer` - 理解问题
- `Systematic Debugging` - 根因调查
- `Execution Layer` - 修复实现
- `QA` - 修复验证

### 输出

- 问题分析报告
- 根因定位
- 修复方案
- 验证结果

---

## /refactor - 重构建议

### 触发方式

```
用户: /refactor 这段代码可以优化吗
或
用户: hybrid refactor [代码范围]
```

### 执行流程

```
代码分析 → 识别坏味道 → 提出方案 → 用户确认 → 执行重构 → 验证
```

### 重构类型

1. **提取函数** - 过长函数拆分
2. **合并重复** - 消除重复代码
3. **重命名** - 提高可读性
4. **简化条件** - 简化复杂逻辑
5. **约束内优化** - 仅在 Spec 约束范围内重构

### 输出

- 代码分析报告
- 重构建议
- 重构后的代码
- 验证结果

### 注意事项

- **决策冻结**: 重构不能改变已冻结的架构/需求/契约
- **边界检查**: 重构不能突破领域边界

---

## 指令组合使用

### 完整开发流程

```
/plan → /test → /review → /qa → SHIP_REVIEW → RETRO
```

### 快速修复流程

```
/debug → /test → /qa
```

### 代码优化流程

```
/review → /refactor → /test → /qa
```

### 决策冻结变更流程

如果在 IMPLEMENTATION 期间需要变更冻结项，必须走以下流程：

```
记录变更请求 → 暂停实现 → 退回 Decision Layer → 更新 Context Layer → 重新注水 → 恢复实现
```
