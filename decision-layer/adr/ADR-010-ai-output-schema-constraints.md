# ADR-010: AI 输出格式约束系统

## 状态

已接受 (2026-05-25)

## 背景

在 AI Engineering Governance System 中，AI 的输出格式缺乏标准化约束。这导致：

1. **输出不可预测**: AI 在不同阶段返回的格式不一致
2. **难以自动化处理**: 脚本无法可靠地解析 AI 输出
3. **集成困难**: 外部工具难以与治理系统集成

## 决策

引入 **JSON Schema 约束系统**，定义 AI 输出的标准格式：

### Schema 文件

| Schema | 用途 | 文件 |
|--------|------|------|
| `gate-result` | Gate 检查结果 | `governance/schemas/gate-result.schema.json` |
| `transition-result` | 状态转换结果 | `governance/schemas/transition-result.schema.json` |
| `task-output` | 任务产出物 | `governance/schemas/task-output.schema.json` |
| `ai-response` | AI 响应 | `governance/schemas/ai-response.schema.json` |

### 约束范围

1. **Gate 检查结果**: `check-gates.sh` 输出必须符合 `gate-result.schema.json`
2. **状态转换输出**: `transition.sh` 输出必须符合 `transition-result.schema.json`
3. **任务产出物**: 任务完成后的输出必须符合 `task-output.schema.json`
4. **AI 响应**: AI 在任何阶段的响应应符合 `ai-response.schema.json`

### 校验机制

- **脚本自动校验**: `scripts/validate-schema.sh` 提供自动校验
- **集成点**: 在 `check-gates.sh` 和 `transition.sh` 中输出 JSON 格式

## 理由

### 为什么选择 JSON Schema？

1. **标准化**: JSON Schema 是 JSON 数据验证的行业标准
2. **工具支持**: 广泛的语言和工具支持
3. **可读性**: Schema 本身是 JSON，易于阅读和维护
4. **扩展性**: 可以定义复杂的数据结构和验证规则

### 为什么存放在 `governance/schemas/`？

1. 与 `state-machine.yaml`、`gates.yaml` 同级，保持治理文件的一致性
2. 便于 `check-gates.sh` 和 `transition.sh` 引用
3. 清晰的职责划分：治理规则和 Schema 定义在同一目录

## 后果

### 正向

- AI 输出可预测、可解析
- 脚本可以自动化处理 AI 输出
- 外部工具可以可靠地集成

### 负向

- 需要维护 Schema 定义
- AI 输出需要符合 Schema，可能增加输出复杂度
- 现有脚本需要修改以输出 JSON 格式

### 风险

- Schema 定义不完整可能导致校验失败
- Schema 变更可能影响现有输出

## 替代方案

### 方案 A: TypeScript Interface

- **优点**: 类型检查更严格
- **缺点**: 需要 TypeScript 环境，不适合 Shell 脚本

### 方案 B: YAML 结构

- **优点**: 更易读
- **缺点**: 工具支持不如 JSON Schema 广泛

### 方案 C: 不约束

- **优点**: 无需维护
- **缺点**: 输出不可预测，难以自动化

## 实施

1. 创建 `governance/schemas/` 目录
2. 定义 4 个 Schema 文件
3. 创建 `scripts/validate-schema.sh` 校验脚本
4. 修改 `check-gates.sh` 输出 JSON 格式
5. 修改 `transition.sh` 输出 JSON 格式
6. 更新 `SKILL.md` 添加 Schema 约束说明

## 参考

- [JSON Schema Specification](https://json-schema.org/specification.html)
- [JSON Schema Draft 2020-12](https://json-schema.org/draft/2020-12/json-schema-validation.html)
