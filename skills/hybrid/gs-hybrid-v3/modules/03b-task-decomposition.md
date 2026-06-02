# 03b — Decision Layer: TASK_DECOMPOSITION

> **Context Load**: 任务拆解阶段，无需额外框架文件。完全委托给 `writing-plans` 技能。

## TASK_DECOMPOSITION 状态

**触发条件**: L2/L3 在 ARCH_REVIEW 用户确认 ADR 后进入；L1 在 REQUIREMENT_LOCK 确认后直接进入 | **适用级别**: ✅ 所有级别必须

**调用 Skill**: `writing-plans`

> TASK_DECOMPOSITION 状态完全委托给 Superpowers 的 `writing-plans` 技能。
> gs-hybrid 只在此之上增加：Spec→Task 分解方法、Task 模板分类、依赖图、跨切面处理、风险评估增强、回滚策略、Plan 验证确认。

---

### TASK_DECOMPOSITION 执行流程

```
ARCH_REVIEW / REQUIREMENT_LOCK 确认
  │
  ▼
┌──────────────────────────────────────────────────────────────┐
│  TASK_DECOMPOSITION: writing-plans + gs-hybrid 任务拆解增强   │
│                                                              │
│  1. Scope Check (最终防线)                                    │
│  2. File Structure (文件映射)                                 │
│  3. Spec→Task 分解 (从需求到任务的结构化映射) ← NEW           │
│  4. Task 类型分类与模板选择 ← NEW                             │
│  5. Task 依赖图 (依赖/并行/阻塞) ← NEW                        │
│  6. 跨切面关注点处理 ← NEW                                    │
│  7. Bite-Sized Tasks (2-5min TDD 五步)                       │
│  8. No Placeholders                                          │
│  9. Self-Review                                              │
│  10. Execution Handoff                                       │
└──────────────────────────────────────────────────────────────┘
  │
  ▼
Plan 产出: `specs/plans/YYYY-MM-DD-<feature>.md`（L1 可退化为对话摘要 + `workflow-state/context` 记录）
  │
  ▼
┌──────────────────────────────────────────────────────────────┐
│  gs-hybrid 增强: 风险评估/边界条件/回滚策略 追加到 Plan 末尾   │
└──────────────────────────────────────────────────────────────┘
  │
  ▼
┌──────────────────────────────────────────────────────────────┐
│  Plan 验证确认 (gs-hybrid 专属)                              │
│  范围/风险/验收/回滚 验证 → 用户硬阻断确认                     │
└──────────────────────────────────────────────────────────────┘
  │
  ▼ L1: IMPLEMENTATION
    L2/L3: Context Hydration → IMPLEMENTATION
    → SELF_REVIEW → QA → SHIP_REVIEW → RETRO
```

---

## writing-plans 核心流程 + gs-hybrid 任务拆解增强

### 1. Scope Check (最终防线)

ARCH_REVIEW 状态已用结构化标准做过多子系统检测。L1 场景则沿用 REQUIREMENT_LOCK 的范围判断。这里作为**最后防线**：

- 如果 spec 仍覆盖多个独立子系统 → **在此提出拆**，不继续
- 一个 plan 只产出可独立运行、可测试的软件
- 一旦此阶段仍检测到多子系统，回退到 ARCH_REVIEW 状态重新拆解

**参考判定标准** (与 ARCH_REVIEW 一致):
- 独立数据模型 / 独立用户界面 / 独立部署单元 / 独立用户角色 / 独立外部依赖
- 满足任意 2 项 → 独立子系统

---

### 2. File Structure (文件映射)

在写 task 之前，先映射出哪些文件会被创建或修改，每个文件负责什么。

- 设计单元有清晰边界和良好定义的接口。每个文件一个职责。
- 偏好小而聚焦的文件。一起变的文件放在一起。按职责分，不按技术层分。
- 在已有代码库中遵循现有模式。但要修改的臃肿文件可在 plan 中合理拆分。

---

### 3. Spec→Task 分解 (NEW)

这是 plan 最核心的环节——从 spec 的需求列表映射到可执行的 task 列表。

**前提**: 先提取 spec 中全部 `REQ-*` / `NFR-*` / `OUT-*` 标识，plan 必须对这些标识建立显式追踪关系。

#### 分解步骤

```
Step A: 列出 spec 中每个可验证的需求
  ↓
Step B: 为每个需求保留原始 ID（REQ/NFR/OUT）
  ↓
Step C: 对每个需求判断性质
  ├─ 纯函数/类实现 → Feature Task
  ├─ Bug 修复       → Bugfix Task
  ├─ 配置/常量      → Config Task
  ├─ 重构/移动      → Refactor Task
  ├─ 多组件集成     → Integration Task
  └─ 项目初始化     → Setup Task
  ↓
Step D: 判断边界
  ├─ 单文件可实现？→ 1 个 Task
  ├─ 多文件但紧密耦合？→ 1 个 Task，列出所有文件
  └─ 多文件且可独立？→ 拆为多个 Task
  ↓
Step E: 排序
  ├─ 识别依赖：Task X 必须在 Task Y 之前完成
  ├─ 识别并行：Task A 和 Task B 可同时进行
  └─ 识别阻塞：Task C 必须等所有前置 Task 完成
```

#### 分解原则

| 原则 | 说明 |
|------|------|
| **每个 Task 可独立验证** | 完成后有明确的通过/失败标准 |
| **Task 间接口显式化** | Task 3 需要的类型/签名由哪个 Task 定义，必须明确 |
| **向前兼容** | Task 5 修改 Task 2 的签名 → 不合理，应在 Task 2 就定义好 |
| **最小上下文** | 每个 Task 的实现者只需理解该 Task 涉及的文件 |
| **自然的原子性** | 一个 Task 应该是一个完整的功能增量，不是随意切分的碎片 |
| **需求可追踪** | 每个 `REQ-*` / `NFR-*` / `OUT-*` 都能在 plan 中定位到对应 Task 或边界说明 |

#### Requirement→Task Mapping 表

在正式 task 列表前，必须先写一个映射表：

```markdown
## Requirement Mapping

| Requirement ID | Summary | Covered By | Notes |
|---------------|---------|------------|-------|
| REQ-001 | 用户可重试失败操作 | Task 1, Task 3 | Task 1 实现重试接口；Task 3 覆盖集成流 |
| REQ-002 | 成功后展示最终状态 | Task 2 | UI 状态更新 |
| NFR-001 | p95 <= 800ms | Task 4 | 压测与缓存策略 |
| OUT-001 | 不修改批处理导入流程 | No task | Scope boundary only |
```

规则：
- `Covered By` 必须引用实际存在的 Task 编号
- `OUT-*` 也必须出现，且通常标记为 `No task`
- 若一个 requirement 由多个 Task 共同完成，必须全部列出

---

### 4. Task 类型分类与模板 (NEW)

不同任务类型使用不同模板。TDD 五步是 Feature Task 的默认模板，不是万能模板。

#### 4a. Feature Task (新增功能 — TDD 五步)

**适用**: 新增函数、类、模块、API 端点

````markdown
### Task N: [Component Name] [Feature]

**Dependencies:** [Task X, Task Y] | **Parallel with:** [Task Z] | **Estimate:** ~10min
**Covers:** REQ-001, NFR-001

**Files:**
- Create: `src/path/to/component.ext`
- Test: `tests/path/to/component_test.ext`

- [ ] **Step 1: Write the failing test**

```<language>
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `<test_command> tests/path/test.ext::test_name`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```<language>
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `<test_command> tests/path/test.ext::test_name`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.ext src/path/file.ext
git commit -m "feat(scope): add specific feature"
```
````

#### 4b. Bugfix Task (Bug 修复)

**适用**: 修复已有功能的 Bug

````markdown
### Task N: [Bug Description] [Bugfix]

**Dependencies:** None | **Estimate:** ~8min
**Covers:** REQ-001

**Files:**
- Modify: `src/path/to/buggy.ext:45-67`
- Test: `tests/path/to/regression_test.ext` (新增)

- [ ] **Step 1: Write regression test reproducing the bug**

```<language>
def test_bug_description():
    result = buggy_function(input_that_triggers_bug)
    assert result == correct_behavior  # Currently fails
```

- [ ] **Step 2: Run test to confirm bug exists**

Run: `<test_command> tests/path/test.ext::test_bug_description`
Expected: FAIL — confirms the bug

- [ ] **Step 3: Fix the root cause**

```<language>
# Before (buggy):
def buggy_function(x):
    return x  # Missing validation

# After (fixed):
def buggy_function(x):
    if x is None:
        raise ValueError("x must not be None")
    return x
```

- [ ] **Step 4: Run regression test and existing tests**

Run: `<test_command>`
Expected: ALL PASS — regression test passes, no existing tests broken

- [ ] **Step 5: Commit**

```bash
git add tests/path/regression_test.ext src/path/buggy.ext
git commit -m "fix(scope): describe the bug fix"
```
````

#### 4c. Config Task (配置/常量/基础设施)

**适用**: 添加配置项、常量、环境变量、项目初始化

````markdown
### Task N: [Config Description] [Setup]

**Dependencies:** None | **Parallel with:** [Any unrelated Task] | **Estimate:** ~5min
**Covers:** NFR-001

**Files:**
- Create: `config/xxx.yaml`
- Modify: `src/path/to/consumer.ext:12-15` (引用新配置)

- [ ] **Step 1: Add configuration**

```yaml
# config/xxx.yaml
feature:
  enabled: true
  timeout: 30s
  max_retries: 3
```

- [ ] **Step 2: Add config loading code**

```<language>
config = load_config("config/xxx.yaml")
timeout = config.get("feature.timeout", 30)
```

- [ ] **Step 3: Verify config loads correctly**

Run: `<command to verify config>`
Expected: Config loaded without errors

- [ ] **Step 4: Commit**

```bash
git add config/xxx.yaml src/path/consumer.ext
git commit -m "feat(scope): add feature configuration"
```
````

#### 4d. Refactor Task (重构/代码移动)

**适用**: 代码移动、重命名、提取函数、文件拆分

````markdown
### Task N: [Refactor Description] [Refactor]

**Dependencies:** [Task X (定义原代码的 Task)] | **Estimate:** ~10min
**Covers:** REQ-002

**Files:**
- Move from: `src/path/old_location.ext:100-150`
- Move to: `src/path/new_location.ext`
- Update imports in: `src/path/caller1.ext`, `src/path/caller2.ext`

- [ ] **Step 1: Run existing tests to establish baseline**

Run: `<test_command>`
Expected: ALL PASS (N tests)

- [ ] **Step 2: Move code to new location**

```<language>
// new_location.ext — exact copy, no logic changes
def moved_function(...):
    // identical to original
```

- [ ] **Step 3: Update all call sites**

```<language>
// Before:
from old_location import moved_function
// After:
from new_location import moved_function
```

- [ ] **Step 4: Run tests to confirm nothing broken**

Run: `<test_command>`
Expected: SAME N tests pass, no new failures

- [ ] **Step 5: Commit**

```bash
git add src/path/new_location.ext src/path/caller1.ext src/path/caller2.ext
git rm src/path/old_location.ext  # If fully moved
git commit -m "refactor(scope): move function to new location"
```
````

#### 4e. Integration Task (多组件集成)

**适用**: 连接多个已有组件，端到端流程

````markdown
### Task N: [Integration Description] [Integration]

**Dependencies:** [Task A, Task B, Task C (被集成的组件)] | **Estimate:** ~15min
**Covers:** REQ-001, REQ-003

**Files:**
- Create: `src/path/integration.ext`
- Modify: `src/path/component_a.ext:80-85` (暴露接口)
- Test: `tests/path/integration_test.ext`

- [ ] **Step 1: Define integration interface**

```<language>
# 明确 Component A → Component B → Component C 的数据流
def integrate(a_output, b_config):
    intermediate = component_b.process(a_output, b_config)
    return component_c.finalize(intermediate)
```

- [ ] **Step 2: Write integration test**

```<language>
def test_integration_flow():
    a_output = component_a.execute(test_input)
    result = integrate(a_output, test_config)
    assert result == expected_final_output
```

- [ ] **Step 3: Run integration test to verify fail**

Run: `<test_command> tests/path/integration_test.ext`
Expected: FAIL — integration not yet wired

- [ ] **Step 4: Wire components together**

```<language>
# 实现 integrate() — 可能需要调整 Component A/B/C 的接口
```

- [ ] **Step 5: Verify integration test and unit tests**

Run: `<test_command>`
Expected: ALL PASS

- [ ] **Step 6: Commit**

```bash
git add tests/path/integration_test.ext src/path/integration.ext src/path/component_a.ext
git commit -m "feat(scope): integrate component A, B, C for feature"
```
````

---

### 5. Task 依赖图 (NEW)

每个 Task 必须在头部声明三项关系：

| 字段 | 说明 | 示例 |
|------|------|------|
| **Dependencies** | 本 Task 开始前必须完成的前置 Task | `Task 1, Task 3` |
| **Parallel with** | 可同时进行的 Task（无冲突文件） | `Task 4` |
| **Blocks** | 被本 Task 阻塞的后续 Task | `Task 5, Task 6` |

**依赖图示例**:

```
Task 1: Config (无依赖, 可并行)
  ├─→ Task 2: Core Model (依赖 Task 1)
  │     ├─→ Task 4: API Handler (依赖 Task 2)
  │     └─→ Task 5: Service Layer (依赖 Task 2)
  │           └─→ Task 7: Auth Middleware (依赖 Task 5)
  ├─→ Task 3: DB Migration (依赖 Task 1)
  │     └─→ (Task 2-7 共享基础设施)
  ├─→ Task 6: Validation (依赖 Task 2, 并行于 Task 4 + Task 5)
  └─→ Task 8: Integration Test (依赖 Task 1-7 全部)
  └─→ Task 9: SELF_REVIEW (依赖 Task 1-8 全部)
```

**执行顺序** (由依赖图自动推导):
1. 并行启动: Task 1, Task 3
2. Task 1 完成 → 并行启动: Task 2
3. Task 2 完成 → 并行启动: Task 4, Task 5, Task 6
4. Task 4+5+6 完成 → Task 7
5. Task 3 完成 → (等待其他)
6. 全部完成 → Task 8 (Integration Test)

---

### 6. 跨切面关注点处理 (NEW)

当多个 Task 共享基础设施时：

#### 6a. Shared Utility / Base Class

**谁负责定义？**

- 第一个使用它的 Task 负责定义
- 后续 Task 在 Dependencies 中声明对该 Task 的依赖
- 如果多个 Task 都需要但都不适合"首定义"→ 创建独立的 Setup/Foundation Task

```
Task 0: Foundation (共享类型/工具函数/基类) [Setup]
Task 1: Component A (Dependencies: Task 0)
Task 2: Component B (Dependencies: Task 0, Parallel with: Task 1)
```

#### 6b. 前向兼容原则

Task N 修改 Task M (M < N) 中定义的接口 → **是 plan 设计缺陷**

- 接口定义 Task 需要考虑到所有消费者的需求
- 如果 Task 5 需要新字段 → 在 Task 1（定义者）中就设计好
- 如果确实需要后补 → 单独新增 Refactor Task，排在所有消费者之前

#### 6c. 集成测试放置

- 跨 3+ Task 的集成测试 → 独立的 Integration Task，放在所有被集成 Task 之后
- 仅涉及 2 个 Task 的集成测试 → 放在后一个 Task 中

---

### 7. Bite-Sized Tasks (2-5min TDD 五步)

**每个 step 是一个动作（2-5 分钟）**。适用于 Feature Task，其他模板参考各自的 Step 结构。

```
Task: Write the failing test         ← 2min
Task: Run it to make sure it fails   ← 1min
Task: Implement minimal code         ← 3min
Task: Run tests, make sure they pass ← 1min
Task: Commit                         ← 1min
```

**复杂任务处理**：当一个功能天然需要超过 5 分钟时，不要强制切碎——保持逻辑完整性，在一个 Task 内用更多 Step 表达：

```
Step 1: Define data structures       ← 5min
Step 2: Write tests for core logic   ← 5min
Step 3: Implement core logic         ← 8min
Step 4: Add error handling           ← 5min
Step 5: Add edge case tests          ← 5min
Step 6: Run full test suite          ← 3min
Step 7: Commit                       ← 1min
```

---

### 8. Plan Document Header

每个 plan 必须以这个 header 开头：

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [一句话描述目标]

**Architecture:** [2-3 句话描述架构方法]

**Tech Stack:** [关键技术/库]

**ADR:** `decision-layer/adr/ADR-NNN-title.md` (if applicable)
**Complexity:** L1 / L2 / L3

---
```

---

### 9. No Placeholders 铁律

以下在 plan 中**永远不允许出现**——出现即 plan 失败：

- `"TBD"`, `"TODO"`, `"implement later"`, `"fill in details"`
- `"Add appropriate error handling"` / `"add validation"` / `"handle edge cases"`（不说具体怎么处理）
- `"Write tests for the above"`（没有实际测试代码）
- `"Similar to Task N"`（没有重复代码——执行者可能按任意顺序读 task）
- 只描述"做什么"、不展示"怎么做"的步骤（代码步骤必须有 code block）
- 引用任何 task 中未定义的类型、函数或方法

---

### 10. Self-Review

写完完整 plan 后，用全新眼光检查：

1. **Spec coverage**: 逐个浏览 spec 的每个章节/需求。能否指出一个 task 实现了它？列出任何缺口。
   优先按 `REQ-*` / `NFR-*` / `OUT-*` 逐条核对，而不是只按自然语言大意核对。
2. **Placeholder scan**: 搜索 plan 中的占位符模式。修复。
3. **Type consistency**: 后文 task 中使用的类型、方法签名、属性名是否与前文 task 定义的完全一致？`clearLayers()` 在 Task 3 但 `clearFullLayers()` 在 Task 7 就是 bug。
4. **依赖完整性**: 每个 Task 的 Dependencies 中引用的 Task 是否都存在？是否有循环依赖？
5. **跨切面完整性**: 共享基础设施是否由明确的 Task 负责？集成测试是否覆盖？
6. **模板正确性**: 每个 Task 是否使用了正确的模板类型？
7. **Requirement mapping 完整性**: `Requirement Mapping` 表中的每个 ID 是否都指向真实 Task 或明确边界说明？

发现问题 → 立即修复 → 无需重复审查。发现 spec 需求无对应 task → 添加 task。

---

### 11. Execution Handoff

Plan 写入文件后，提供执行方式选择：

**"Plan 已保存到 `specs/plans/<filename>.md`。两种执行方式：**

**1. Subagent-Driven（推荐）** — 每个 task 独立 subagent，task 间 review，快速迭代。可按依赖图并行启动不冲突的 Task。

**2. Inline Execution** — 在本 session 中执行，批量执行 + checkpoint 审查

**选择哪种？"**

---

### 12. 必须记住

- 始终使用精确文件路径
- 每个步骤都有完整代码——如果步骤涉及代码变更，展示代码
- 精确命令 + 预期输出
- DRY, YAGNI, TDD, 频繁提交
- 每个 Task 选正确的模板，不要所有 Task 都用 Feature 模板

---

## gs-hybrid 增强：追加到 Plan 末尾

writing-plans 产出标准 plan 后，gs-hybrid 追加以下章节：

### A. 风险评估

| 风险 | 概率 | 影响 | 缓解措施 | 关联 Task |
|------|------|------|---------|:---------:|
| 性能瓶颈 | 中 | 高 | 提前做基准测试 | Task N |
| 向后不兼容 | 低 | 高 | 保留旧接口 | Task M |
| 数据迁移失败 | 低 | 高 | 先备份再迁移 | Task K |

### B. 边界条件

| 场景 | 输入 | 预期输出 | 处理方式 | 关联 Task |
|-----|------|---------|---------|:---------:|
| 正常情况 | ... | ... | ... | — |
| 空值/零值 | null/empty/0 | 错误提示 | 参数校验 | Task N |
| 超大输入 | max boundary | 拒绝或截断 | 长度限制 | Task N |
| 并发访问 | 同时写入 | 数据一致 | 加锁/事务 | Task M |

### C. 回滚策略

- [ ] 数据库迁移可回滚（如有）
- [ ] 配置变更可回滚（如有）
- [ ] 功能开关控制（建议）

### D. 变更记录

| 日期 | 变更内容 | 来源 |
|------|---------|------|
| YYYY-MM-DD | 初始版本 | TASK_DECOMPOSITION writing-plans |

---

## Plan 验证确认 (PLAN_CONFIRM 状态)

**触发条件**: TASK_DECOMPOSITION 状态 plan 完成后 | **适用级别**: 🔴 所有级别必须执行

<HARD-GATE>
**这是强制阻断点！** 用户必须明确确认 PLAN，AI 才能继续。

**L1 快速通道规则**: L1 任务通过对话确认即可，不强制产出独立 plan 文件。AI 必须在对话中向用户展示变更摘要（涉及文件、预估耗时、验收标准、回滚方式），获得用户明确回复后，在 `context` 或 `workflow-state` 中记录 `plan_summary_confirmed: true`、`plan_confirmed: true`、`approval_mode: conversation` 后方可继续。
</HARD-GATE>

### 验证清单（按级别分级）

#### L1 快速验证（合并确认）
- [ ] 变更文件数量符合预期？
- [ ] 验收标准清晰？
- [ ] 回滚方案可行？

#### L2 标准验证
- [ ] `Requirement Mapping` 是否列出全部 `REQ-*` / `NFR-*` / `OUT-*`？
- [ ] 每个 `REQ-*` / `NFR-*` 是否映射到真实 Task？
- [ ] 每个 `OUT-*` 是否明确标记为边界而非 Task？
- [ ] 文件清单是否准确（每个 task 的 Files 段）？
- [ ] 每个 Task 是否使用了正确的模板类型？
- [ ] 验收标准清晰可测？
- [ ] 回滚方案可行？

#### L3 完整验证
- [ ] `Requirement Mapping` 是否列出全部 `REQ-*` / `NFR-*` / `OUT-*`？
- [ ] 每个 `REQ-*` / `NFR-*` 是否映射到真实 Task？
- [ ] 每个 `OUT-*` 是否明确标记为边界而非 Task？
- [ ] 文件清单是否准确（每个 task 的 Files 段）？
- [ ] 是否有遗漏的边界条件？
- [ ] 每个 Task 是否使用了正确的模板类型（Feature/Bugfix/Config/Refactor/Integration）？
- [ ] 每个 Task 是否有明确的 Dependencies / Parallel with 声明？
- [ ] Task 依赖图中是否有循环依赖或不存在的引用？
- [ ] 跨切面关注点是否由明确的 Task 负责？
- [ ] 所有风险点已识别？
- [ ] 风险缓解措施有效可行？
- [ ] 回滚方案完整且可执行？
- [ ] 验收标准具体、可量化？
- [ ] 是否有 "TBD" / "TODO" / 占位符？
- [ ] 每个 task 是否包含实际代码、命令、预期输出？

### 确认对话模板（L2/L3 标准版）

```markdown
## ✅ Plan 验证确认

### Plan 摘要
- **Plan 文件**: `specs/plans/YYYY-MM-DD-<feature>.md`
- **Task 数**: X 个
  - Feature: X | Bugfix: X | Config: X | Refactor: X | Integration: X
- **涉及文件**: X 个
- **复杂度**: L1 / L2 / L3

### Requirement Mapping 摘要
| 类型 | 总数 | 已覆盖 | 未覆盖 | 说明 |
|------|-----:|------:|------:|------|
| REQ | X | X | 0 | 功能需求全部映射到 Task |
| NFR | X | X | 0 | 非功能需求全部映射到 Task 或验证项 |
| OUT | X | X | 0 | 范围外边界全部标记为 No task |

### 未覆盖项
- 无

### 依赖图
[简要依赖图 — 关键路径 Task 序列]

### 风险摘要
- 高风险: X 个
- 中风险: X 个
- 低风险: X 个

### 验证清单
1. `Requirement Mapping` 是否完整覆盖 `REQ/NFR/OUT`？
2. 每个 `REQ/NFR` 是否都映射到真实 Task？
3. 每个 `OUT` 是否都作为范围边界保留？
4. 每个 Task 模板类型是否正确？
5. 依赖图是否完整且无循环依赖？
6. 边界条件是否充分？
7. 验收标准是否清晰可测？
8. 风险评估是否准确？
9. 回滚方案是否可行？
10. Plan 是否有占位符或模糊描述？

---

### 🚨 用户最终确认

请确认 Plan 完整无误，可以进入下一状态：
- [ ] 范围确认
- [ ] Requirement Mapping 覆盖确认
- [ ] Task 拆解方式认可
- [ ] 风险接受
- [ ] 验收标准认可
- [ ] 回滚方案确认

**确认后请回复**:
> "Plan 验证通过，请进入下一状态"

**⚠️ 阻断规则**: 未收到用户明确确认前，不得进入 Context Hydration 或 IMPLEMENTATION 状态
```

### 确认对话模板（L1 快速版）

```markdown
## ✅ 需求与 Plan 合并确认

### 变更摘要
- **需求覆盖**: REQ-001 -> 本次变更；OUT-001 -> 不涉及
- **涉及文件**: X 个
- **预估耗时**: X 分钟
- **验收标准**: [一句话]
- **回滚方式**: [一句话]

### 快速检查
- [ ] 变更范围符合预期？
- [ ] 需求覆盖关系清晰？
- [ ] 回滚方案可行？

**确认后请回复**:
> "确认，开始执行"

**⚠️ 阻断规则**: 未收到用户明确确认前，不得进入 IMPLEMENTATION
```

### 阻断规则

- ❌ 用户未回复 → 等待
- ❌ 用户要求修改 → 修改后重新验证
- ❌ 用户放弃 → 回到 TASK_DECOMPOSITION 状态
- ✅ 用户确认 → L1 进入 IMPLEMENTATION；L2/L3 进入 Context Hydration

### 输出要求

必须记录：
- 用户确认时间
- 确认时的 PLAN 版本
- 任何修改意见
- 风险接受声明
- Requirement Mapping 确认摘要
- **L1 快速通道**: 在对话中记录即可，不强制文件化；但必须写入 `plan_summary_confirmed: true`、`plan_confirmed: true`
