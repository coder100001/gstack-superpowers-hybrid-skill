---
hydration:
  asset: "test-spec"
  version: "1.0.0"
  updated: "2026-05-19"
  adr_ref: "ADR-001"
---

# Test Constraints

> **层**: Context Layer · **职责**: 测试契约运行时约束
> **生命周期**: 项目级别，持续生效
> **更新条件**: 仅通过 Decision Layer 审议后更新
> **与 execution-layer/testing.md 的关系**: 本文件定义"必须达到什么标准"（契约层），testing.md 定义"如何执行测试"（执行层）。覆盖率指标的单一真相源为本文件。

---

## 1. 测试分层要求

### 1.1 分层定义

| 层级 | 范围 | 隔离性 | 执行速度 | 触发条件 |
|:-----|:-----|:-------|:---------|:---------|
| 单元测试 | 单个函数/类/模块 | 完全独立，无外部依赖 | < 10ms/测试 | 所有变更 |
| 集成测试 | 模块间交互/API 契约 | 最小化外部依赖（mock/stub） | < 100ms/测试 | L2+ 变更 |
| E2E 测试 | 完整用户流程 | 使用测试环境 | 按需运行 | L3 变更 |

### 1.2 按复杂度级别的测试要求

| 测试类型 | L1 | L2 | L3 |
|:---------|:---|:---|:---|
| 单元测试 | 必须 | 必须 | 必须 |
| 集成测试 | 可选 | 必须 | 必须 |
| E2E 测试 | 不要求 | 可选 | 必须 |
| 性能测试 | 不要求 | 性能敏感时 | 必须 |
| 安全测试 | 不要求 | 安全相关时 | 必须 |

---

## 2. 覆盖率硬指标

> **单一真相源**: 本节定义的覆盖率指标是全项目唯一标准。execution-layer/testing.md 及其他文件引用本节。

### 2.1 单元测试覆盖率

| 指标 | 最低阈值 | 目标值 | 测量工具 |
|:-----|:---------|:-------|:---------|
| 行覆盖率 | ≥ 80% | ≥ 90% | 覆盖率工具（项目配置定义） |
| 分支覆盖率 | ≥ 70% | ≥ 80% | 覆盖率工具 |
| 函数覆盖率 | ≥ 90% | ≥ 95% | 覆盖率工具 |

### 2.2 集成测试覆盖率

| 指标 | 最低阈值 | 目标值 | 测量工具 |
|:-----|:---------|:-------|:---------|
| 行覆盖率 | ≥ 60% | ≥ 70% | 覆盖率工具 |
| 分支覆盖率 | ≥ 50% | ≥ 60% | 覆盖率工具 |
| 函数覆盖率 | ≥ 70% | ≥ 80% | 覆盖率工具 |

### 2.3 E2E 测试覆盖率

| 指标 | 最低阈值 | 测量方式 |
|:-----|:---------|:---------|
| 核心用户路径覆盖 | 100% 函数覆盖 | 人工定义核心路径清单 |
| 关键业务流程 | 100% 场景覆盖 | 业务需求文档映射 |

### 2.4 覆盖率执行规则

- **未达最低阈值的代码不得合并** — 这是硬阻断，不是建议
- 覆盖率以合并后的全量结果为准，不按单次 PR 计算
- 排除项（如第三方适配器、生成的代码）必须在配置文件中显式声明，禁止隐式排除
- 覆盖率下降的 PR 必须在 PR 描述中说明原因

---

## 3. 测试命名约定

### 3.1 文件命名

| 测试类型 | 命名规则 | 示例 |
|:---------|:---------|:-----|
| 单元测试 | `{source}.test.{ext}` | `user-service.test.ts`, `handler_test.go` |
| 集成测试 | `{source}.integration.test.{ext}` | `api.integration.test.ts` |
| E2E 测试 | `{feature}.e2e.test.{ext}` | `login.e2e.test.ts` |

### 3.2 测试函数命名

| 风格 | 格式 | 示例 |
|:-----|:-----|:-----|
| 行为描述 | `should{行为}When{条件}` | `shouldReturnUserWhenValidId` |
| Go 风格 | `Test{功能}_{条件}_{期望}` | `TestUserService_ValidId_ReturnsUser` |
| BDD 风格 | `describe/it` 嵌套 | `describe('UserService') → it('should return user when valid id')` |

### 3.3 命名约束

- 测试名称必须描述期望行为，禁止使用无意义名称（`test1`, `testFunction`）
- 禁止在测试名称中使用"not"双重否定（`shouldNotFailWhenValid` → `shouldSucceedWhenValid`）
- 测试名称长度不超过 80 字符

---

## 4. 目录结构

### 4.1 推荐结构

```
project-root/
├── src/                          # 源代码
│   ├── module-a/
│   │   ├── index.ts              # 模块入口
│   │   ├── service.ts            # 业务逻辑
│   │   └── service.test.ts       # 单元测试（同目录）
│   └── module-b/
│       ├── index.ts
│       ├── handler.ts
│       └── handler.test.ts
├── tests/                        # 测试根目录
│   ├── integration/              # 集成测试
│   │   ├── api.integration.test.ts
│   │   └── db.integration.test.ts
│   ├── e2e/                      # E2E 测试
│   │   ├── login.e2e.test.ts
│   │   └── checkout.e2e.test.ts
│   └── fixtures/                 # 测试数据
│       ├── mock-data.json
│       └── seed.sql
├── coverage/                     # 覆盖率报告（gitignore）
└── test-config/                  # 测试配置
    ├── jest.config.ts
    └── setup.ts
```

### 4.2 Go 项目结构

```
project-root/
├── internal/
│   ├── service/
│   │   ├── user.go
│   │   └── user_test.go          # 单元测试（同包）
│   └── handler/
│       ├── handler.go
│       └── handler_test.go
├── tests/
│   ├── integration/              # 集成测试
│   │   └── api_test.go
│   └── e2e/                      # E2E 测试
│       └── login_test.go
└── testdata/                     # 测试数据（Go 惯例）
    └── fixture.json
```

### 4.3 目录约束

- 单元测试必须与源文件同目录（或同包）
- 集成测试和 E2E 测试必须放在独立目录
- 测试数据必须放在 `fixtures/` 或 `testdata/` 目录，禁止硬编码
- 覆盖率报告目录必须加入 `.gitignore`

---

## 5. Mock/Stub 策略

### 5.1 Mock 使用原则

| 原则 | 说明 |
|:-----|:-----|
| Mock 边界，不 Mock 内部 | 只 mock 外部依赖（数据库、API、文件系统），不 mock 同模块内部函数 |
| Mock 接口，不 Mock 实现 | mock 依赖的接口定义，而非具体实现类 |
| 最小化 Mock 范围 | 每个 mock 只模拟必要的行为，禁止"万能 mock" |
| Mock 验证交互 | 对关键调用验证调用次数和参数，不仅验证返回值 |

### 5.2 Mock 放置规则

| Mock 类型 | 放置位置 | 命名 |
|:----------|:---------|:-----|
| 通用 Mock | `tests/fixtures/mocks/` | `mock-{dependency}.ts` |
| 测试专用 Mock | 测试文件内 | `createMock{Dependency}()` 工厂函数 |
| Go Mock | 同包或 `mock/` 子目录 | `mock_{interface}.go`（由 mockgen 生成） |

### 5.3 Mock 禁止模式

- 禁止 mock 被测函数本身（这等于没测）
- 禁止 mock 返回真实数据库查询结果（用固定测试数据）
- 禁止在 E2E 测试中使用 mock（E2E 测试必须使用真实或容器化依赖）
- 禁止 mock 链式调用超过 2 层（`a.b().c()` — 说明依赖过深）

---

## 6. 测试数据管理

### 6.1 数据来源

| 数据类型 | 来源 | 示例 |
|:---------|:-----|:-----|
| 固定测试数据 | `fixtures/` 或 `testdata/` 目录 | `users.json`, `orders.sql` |
| 动态测试数据 | 工厂函数生成 | `createTestUser(overrides)` |
| 边界值数据 | 显式定义在测试用例中 | `{ value: 0 }`, `{ value: MAX_INT }` |
| 随机数据 | 仅用于压力测试，不用于功能测试 | `fuzz testing` |

### 6.2 数据管理约束

- 测试数据必须可重复（相同输入必须产生相同结果）
- 禁止依赖外部服务的实时数据
- 测试间数据必须隔离（每个测试独立准备和清理）
- 敏感数据（密码、令牌）必须使用明显假值（`test-password-123`，不是真实密码）

---

## 7. CI 集成命令

### 7.1 命令模板

> 以下为通用模板，具体项目需在 `project-config.yml` 中配置实际命令。

```yaml
# project-config.yml 测试配置示例
test:
  unit:
    command: "npm test"                    # 或 go test ./...
    coverage_command: "npm run test:coverage"  # 或 go test -coverprofile=coverage.out ./...
    coverage_threshold:
      lines: 80
      branches: 70
      functions: 90
  integration:
    command: "npm run test:integration"
    trigger: "L2+"
  e2e:
    command: "npm run test:e2e"
    trigger: "L3"
  lint:
    command: "npm run lint"                # 或 golangci-lint run
  security:
    command: "npm audit"                   # 或 gosec ./...
    trigger: "安全相关变更"
```

### 7.2 CI 执行规则

| 触发条件 | 执行内容 | 阻断规则 |
|:---------|:---------|:---------|
| 每次提交 | 单元测试 + 覆盖率检查 | 覆盖率 < 最低阈值 → 阻断 |
| PR 创建 | 全量测试 + lint | 任何测试失败 → 阻断 |
| 合并到 main | 全量测试 + 安全扫描 | 安全漏洞 Critical → 阻断 |
| 发布前 | E2E 测试 + 性能测试 | E2E 失败 → 阻断 |

### 7.3 CI 命令约束

- 测试命令必须在 `project-config.yml` 中定义，禁止硬编码在 CI 配置中
- 覆盖率检查必须作为 CI 步骤独立执行，不可跳过
- 测试超时必须有明确配置（单元测试 5 分钟，集成测试 15 分钟，E2E 30 分钟）
- CI 失败必须生成可读的报告，禁止只输出退出码

---

## 8. 禁止模式

### 测试编写禁止

- 禁止测试与实现耦合过紧（测试内部实现细节而非公共行为）
- 禁止忽略边缘情况（空值、边界值、错误路径）
- 禁止测试依赖执行顺序
- 禁止硬编码测试数据在测试函数内（超过 3 行的数据必须提取到 fixtures）
- 禁止伪造测试覆盖（写空断言、测试不验证任何行为）
- 禁止 `skip` 或 `xit` 留在提交中（除非标注了 issue 编号和预计修复时间）

### 测试管理禁止

- 禁止删除失败的测试来"修复"CI
- 禁止降低覆盖率阈值来通过 CI
- 禁止在主分支上禁用测试
- 禁止提交 `only`/`focus` 标记（`describe.only`, `it.only`, `FIt` 等）

---

## 9. 项目适配指南

> 本文件中的约束基于通用测试最佳实践。使用 gs-hybrid-v3 治理其他项目时，必须按以下流程适配。

### 适配流程

1. **复制本文件**为项目专属的 `test-spec.md`
2. **替换以下章节**以匹配目标项目：
   - §2 覆盖率指标 — 根据项目成熟度调整阈值（新项目可降低 10%，但必须标注为临时）
   - §3 命名约定 — 替换为项目语言的习惯命名
   - §4 目录结构 — 替换为项目的目录布局
   - §7 CI 命令 — 填写实际的测试/覆盖率/lint 命令
3. **保留 §5 Mock 策略和 §8 禁止模式** — 这些是通用约束
4. **通过 Decision Layer 审议**确认适配后的 spec

### 必须保留的通用约束

无论项目如何不同，以下约束不可删除：
- 单元测试覆盖率最低阈值（行 ≥ 80%，分支 ≥ 70%，函数 ≥ 90%）
- 测试数据必须可重复
- 禁止伪造测试覆盖
- 禁止删除失败测试来"修复"CI
- 写操作变更必须有对应测试

---

## 10. 契约更新历史

| 日期 | 变更内容 | 变更人 | ADR 引用 |
|:----|:---------|:-------|:---------|
| 2026-05-19 | 初始创建 | AI | ADR-001 |

---

**关联文件**: [project-spec](./project-spec.md) · [architecture-spec](./architecture-spec.md) · [constraints-spec](./constraints-spec.md) · [domain-boundaries](./domain-boundaries.md)
