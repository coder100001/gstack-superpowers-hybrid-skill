# 维护与更新指南

本文档说明如何在 superpowers 和 gstack 上游更新时，同步更新这个混合技能包，以及如何维护 v4.0 三层架构。

## 项目架构说明（v4.0）

本项目采用**三层架构**，便于维护和更新：

```
gstack--superpowers--hybrid-skill/
├── decision-layer/        # 决策层（本地维护，多角色审议）
├── context-layer/         # 上下文层（本地维护，契约、注水）
├── execution-layer/       # 执行层（本地维护，受约束实现）
├── bridges/               # 桥接层（本地维护）
├── governance/            # 治理层（本地维护，决策冻结）
├── skills/                # 技能包目录
│   ├── superpowers/       # 来自 superpowers（上游同步）
│   ├── gstack/            # 来自 gstack（上游同步）
│   ├── hybrid/            # 混合流程技能（本地维护）
│   └── custom/            # 自定义扩展技能（本地维护）
├── gstack-skills/         # GStack 工具脚本（上游同步）
├── overrides/             # 覆盖配置（本地维护）
└── scripts/               # 维护脚本
    └── sync-upstream.sh   # 上游同步脚本
```

### 目录维护策略

| 目录 | 维护方式 | 说明 |
|------|----------|------|
| `skills/superpowers/` | 上游同步 | 完全来自 superpowers，定期覆盖 |
| `skills/gstack/` | 上游同步 | 完全来自 gstack，定期覆盖 |
| `skills/hybrid/` | 本地维护 | gs-hybrid-v3 技能，保留本地修改 |
| `decision-layer/` | 本地维护 | 决策层协议，v4.0 新增 |
| `context-layer/` | 本地维护 | 上下文层契约，v4.0 新增 |
| `execution-layer/` | 本地维护 | 执行层规则，v4.0 新增 |
| `bridges/` | 本地维护 | 桥接层，v4.0 新增 |
| `governance/` | 本地维护 | 治理层，v4.0 新增 |

## 版本追踪

当前追踪的上游版本记录在 `.upstream-versions.json`：

```json
{
  "superpowers": {
    "repo": "https://github.com/obra/superpowers",
    "version": "5.1.0",
    "last_sync": "2026-05-16"
  },
  "gstack": {
    "path": "~/.claude/skills/gstack",
    "version": "1.39.0.0",
    "last_sync": "2026-05-16"
  },
  "hybrid": {
    "description": "AI Engineering Governance System - 三层架构",
    "version": "v4.0"
  }
}
```

## 更新策略

### 策略 1: 直接同步（推荐）

适用于：上游更新后，直接拉取最新内容，覆盖本地。

```bash
# 运行同步脚本（会自动备份三层架构）
./scripts/sync-upstream.sh

# 或分别同步
./scripts/sync-upstream.sh --superpowers  # 仅同步 superpowers
./scripts/sync-upstream.sh --gstack       # 仅同步 gstack
```

**注意**：同步脚本会自动备份：
- `skills/superpowers/`
- `skills/gstack/`
- `skills/hybrid/`
- `decision-layer/`
- `context-layer/`
- `execution-layer/`
- `bridges/`
- `governance/`

### 策略 2: 选择性合并

适用于：您对上游内容有自定义修改，需要手动合并。

```bash
# 查看上游更新内容
./scripts/sync-upstream.sh --dry-run

# 手动选择要合并的文件
git diff --name-only upstream/superpowers/main...HEAD
```

### 策略 3: 扩展模式（推荐用于自定义）

适用于：您想在保留上游内容的同时添加自定义扩展。

**创建自定义技能**：
```
skills/
├── brainstorming/          # 来自 superpowers（上游同步）
├── custom/                 # 自定义扩展目录
│   ├── my-brainstorming/   # 自定义版本
│   │   └── SKILL.md        # 可以继承并扩展上游
│   └── my-workflow/
│       └── SKILL.md
└── overrides/              # 覆盖配置
    └── skill-overrides.json
```

**覆盖配置示例** (`overrides/skill-overrides.json`)：
```json
{
  "replacements": {
    "brainstorming": "custom/my-brainstorming"
  },
  "extensions": {
    "gs-hybrid-v3": {
      "additional_phases": ["custom-phase-1", "custom-phase-2"],
      "custom_rules": ["rules/custom-rule.md"]
    }
  }
}
```

## 如何扩展三层架构

### 扩展 Decision Layer（决策层）

在 `decision-layer/reviews/` 下添加新的审议协议：

```
decision-layer/reviews/
├── architecture-review.md  # 架构审议（已有）
├── product-review.md       # 产品审议（已有）
├── risk-review.md          # 风险审议（已有）
├── tradeoff-review.md      # 权衡审议（已有）
└── security-review.md      # 新增：安全专项审议
```

### 扩展 Context Layer（上下文层）

在 `context-layer/specs/` 下添加新的规范契约：

```
context-layer/specs/
├── project-spec.md         # 项目规范（已有）
├── architecture-spec.md    # 架构规范（已有）
├── constraints-spec.md     # 约束规范（已有）
├── domain-boundaries.md    # 领域边界（已有）
└── security-policy.md      # 新增：安全策略规范
```

### 扩展 Execution Layer（执行层）

在 `execution-layer/` 下添加新的执行规则：

```
execution-layer/
├── implementation.md       # 实现规则（已有）
├── testing.md              # 测试规则（已有）
├── review.md               # 审查规则（已有）
├── validation.md           # 验证规则（已有）
└── performance.md          # 新增：性能验证规则
```

## v4.0 状态机工作流

```
IDEA
  ↓
DISCOVERY (Decision Layer)
  ↓
REQUIREMENT_LOCK (强制用户确认)
  ↓
ARCH_REVIEW (Decision Layer, L2+ 必须)
  ├─ 产品审议
  ├─ 架构审议
  ├─ 性能审议
  ├─ 安全审议
  └─ 运维审议
  ↓
TASK_DECOMPOSITION (Decision Layer)
  ↓
Context Hydration (Context Layer, 强制)
  ├─ 加载项目规范
  ├─ 加载架构规范
  ├─ 加载约束规范
  ├─ 加载领域边界
  └─ 加载 ADR 历史
  ↓
IMPLEMENTATION (Execution Layer)
  ↓
SELF_REVIEW (Execution Layer)
  ↓
QA (Execution Layer)
  ↓
SHIP_REVIEW (Governance)
  ↓
RETRO (Governance)
  ↓
完成
```

## 复杂度分级响应

| 级别 | 状态 | 说明 |
|------|------|------|
| **L1 (小修复)** | IDEA → Context Hydration → IMPLEMENTATION → SELF_REVIEW → SHIP_REVIEW | 跳过决策层，直接实现 |
| **L2 (新功能/中等重构)** | IDEA → DISCOVERY → REQUIREMENT_LOCK → ARCH_REVIEW → ... | 必须经过架构审议 |
| **L3 (跨系统/安全敏感)** | 完整 9 状态流程 + 全部 5 个决策维度 | 必须全流程 |

## 更新工作流

### 定期更新流程

```bash
# 1. 检查上游更新
./scripts/sync-upstream.sh --check

# 2. 备份当前版本（包含三层架构）
./scripts/sync-upstream.sh --backup

# 3. 执行同步
./scripts/sync-upstream.sh

# 4. 应用自定义补丁
./scripts/apply-patches.sh

# 5. 验证更新
./scripts/verify-update.sh

# 6. 提交更改
git add .
git commit -m "chore: sync upstream updates + v4.0 maintenance"
```

### 回滚流程

如果更新出现问题，可以回滚：

```bash
# 回滚到上一个备份
./scripts/sync-upstream.sh --rollback
```

### 冲突解决

如果上游更新与本地修改冲突：

1. **保留本地修改**（三层架构目录始终保留）：
   ```bash
   git checkout --ours skills/hybrid/gs-hybrid-v3/SKILL.md
   git checkout --ours decision-layer/
   git checkout --ours context-layer/
   git checkout --ours execution-layer/
   ```

2. **使用上游版本**（仅用于 skills/superpowers/ 或 skills/gstack/）：
   ```bash
   git checkout --theirs skills/superpowers/brainstorming/SKILL.md
   ```

3. **手动合并**：
   ```bash
   git mergetool skills/hybrid/gs-hybrid-v3/SKILL.md
   ```

## 最佳实践

### 1. 分离关注点

- **上游内容**：放在 `skills/superpowers/` 和 `skills/gstack/`，定期同步覆盖
- **三层架构内容**：放在 `decision-layer/`、`context-layer/`、`execution-layer/`、`bridges/`、`governance/`，本地维护
- **自定义内容**：放在 `skills/custom/` 或 `overrides/` 目录
- **配置**：放在 `config/` 目录

### 2. 版本锁定

如果需要锁定特定版本：

```json
// .upstream-versions.json
{
  "superpowers": {
    "version": "5.1.0",
    "locked": true,
    "lock_reason": "v5.2.0 有破坏性变更，与 v4.0 三层架构不兼容"
  }
}
```

### 3. 变更日志

维护 `CHANGELOG.md` 记录 v4.0 的修改：

```markdown
# Change Log

## v4.0.0 (2026-05-16)

### Added
- 新增三层架构：Decision Layer / Context Layer / Execution Layer
- 新增 5 个决策维度的审议协议
- 新增 Context Hydration 强制机制
- 新增 Decision Freeze 治理机制
- 新增 9 状态状态机

### Changed
- 将 skills/hybrid/gs-hybrid-v3 从 v3.7 升级到 v4.0
- 重命名所有模块文件，移除 Phase 前缀
- 更新所有文档为三层架构

### Removed
- 移除 /cso 悬空引用
- 移除 /ship 悬空引用
```

### 4. 三层架构版本升级

当需要升级三层架构版本时：

1. 创建设计文档：`decision-layer/adr/ADR-NNN-title.md`
2. 更新 `skills/hybrid/gs-hybrid-v3/SKILL.md`
3. 更新相关模块文件
4. 更新文档（README, MAINTENANCE）
5. 更新 `.upstream-versions.json` 中的 hybrid 版本
6. 完整测试所有复杂度级别（L1/L2/L3）

## 快速参考

| 操作 | 命令 |
|------|------|
| 检查更新 | `./scripts/sync-upstream.sh --check` |
| 同步所有 | `./scripts/sync-upstream.sh` |
| 同步 superpowers | `./scripts/sync-upstream.sh --superpowers` |
| 同步 gstack | `./scripts/sync-upstream.sh --gstack` |
| 备份 | `./scripts/sync-upstream.sh --backup` |
| 回滚 | `./scripts/sync-upstream.sh --rollback` |
| 应用补丁 | `./scripts/apply-patches.sh` |
| 验证更新 | `./scripts/verify-update.sh` |

## 获取帮助

- **Superpowers 文档**: https://github.com/obra/superpowers
- **GStack 文档**: 查看本地 `docs/` 目录
- **v4.0 设计文档**: 查看 `decision-layer/adr/ADR-001-initial-architecture-framework.md`
- **问题反馈**: 在项目中创建 Issue
