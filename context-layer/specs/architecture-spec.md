# Architecture Constraints

> **层**: Context Layer · **职责**: 架构约束运行时契约
> **生命周期**: 项目级别，持续生效
> **更新条件**: 仅通过 Decision Layer 审议后更新

---

## 1. 架构风格

- **架构模式**: Layered Architecture + Hybrid Integration Pattern
- **模块组织方式**: 按功能域（Domain-oriented）组织
- **依赖方向**: 外层依赖内层，领域层独立，实现依赖抽象
- **状态管理**: 分布式状态，各层维护自身状态，通过契约传递
- **进程模型**: 单进程多阶段编排，按需加载模块

---

## 2. 分层架构定义

### Context Layer
- **职责**: 提供项目约束和上下文契约
- **位置**: `context-layer/`
- **对外接口**: Hydration 接口
- **依赖**: 无外部运行时依赖
- **禁止**: 包含业务逻辑

### Decision Layer
- **职责**: 审议决策、架构评审、变更控制
- **位置**: `decision-layer/`
- **对外接口**: Review 接口
- **依赖**: Context Layer
- **禁止**: 直接执行实现

### Execution Layer
- **职责**: 执行计划、实现代码、交付成果
- **位置**: `execution-layer/`
- **对外接口**: Implementation 接口
- **依赖**: Context Layer + Decision Layer
- **禁止**: 绕过约束直接执行

---

## 3. 模块划分规则

### 技能模块分类
- **Superpowers**: `skills/superpowers/` - 原生 AI 工程技能
- **GStack**: `skills/gstack/` - 浏览器自动化和 QA 技能
- **Hybrid**: `skills/hybrid/` - 混合编排技能
- **Custom**: `skills/custom/` - 用户自定义技能

### 工具模块分类
- **GStack Tools**: `gstack-skills/bin/` - 底层工具脚本
- **Scripts**: `scripts/` - 项目管理脚本
- **Hooks**: `hooks/` - 事件钩子

### 文档模块分类
- **Design Docs**: `docs/design-docs/` - 设计文档
- **Plans**: `docs/plans/` - 实现计划
- **Specs**: `context-layer/specs/` - 契约规范

---

## 4. 依赖方向约束

### 单向依赖原则
- Context → Decision → Execution 单向依赖
- 禁止 Execution 直接依赖 Decision
- 禁止 Decision 绕过 Context

### 抽象依赖原则
- 实现依赖接口而非具体实现
- 领域模型不依赖基础设施
- 基础设施依赖领域定义

### 依赖注入原则
- 依赖通过构造函数或参数注入
- 禁止硬编码依赖路径
- 配置驱动依赖选择

---

## 5. 技术选型标准

### 必须使用的技术
- **运行时**: Node.js / Deno
- **配置**: JSON / YAML
- **文档**: Markdown

### 允许的技术
- **前端**: HTML5, CSS3, JavaScript, TypeScript
- **工具**: Shell, Python, Go
- **测试**: Jest, Playwright, Mocha

### 禁止的技术
- 闭源专有框架
- 未经验证的实验性技术
- 与项目架构冲突的技术

---

## 6. 接口标准

### 技能接口标准
- 统一入口点: `SKILL.md`
- 元数据: 名称、描述、参数、输出
- 执行模式: 同步/异步声明

### 工具接口标准
- 命令行接口: `--help` 必须支持
- 输入输出: 结构化 JSON 优先
- 错误处理: 非零退出码 + 错误消息

### 内部通信标准
- 数据格式: JSON
- 契约版本: 语义化版本
- 兼容性: 向后兼容保证

---

## 7. 架构演进规则

### 变更类型
- **L1**: 单一文件修改，无架构影响
- **L2**: 多文件修改，局部架构影响
- **L3**: 跨模块修改，全局架构影响

### 演进流程
- L1: 直接执行，事后记录
- L2: 设计评审 → 确认 → 执行
- L3: 完整流程 → 多轮评审 → 确认 → 执行

### 架构冻结
- 重大变更前需 Decision Layer 审批
- 冻结期间禁止架构级改动
- 解冻需明确记录原因

---

## 8. 禁止架构模式

### 分层禁止
- 禁止跨层直接访问
- 禁止循环依赖
- 禁止基础设施依赖业务

### 模块禁止
- 禁止模块间共享内部状态
- 禁止隐式模块依赖
- 禁止绕过接口直接调用

### 技术禁止
- 禁止引入未批准的依赖
- 禁止修改核心架构未经审议
- 禁止破坏已有契约

---

## 9. 契约更新历史

| 日期 | 变更内容 | 变更人 | ADR 引用 |
|:----|:---------|:-------|:---------|
| 2026-05-16 | 初始创建 | AI | ADR-001 |

---

**关联文件**: [project-spec](./project-spec.md) · [constraints-spec](./constraints-spec.md) · [domain-boundaries](./domain-boundaries.md)
