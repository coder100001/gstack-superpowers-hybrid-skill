# 维护与更新指南

本文档说明如何在 superpowers 和 gstack 上游更新时，同步更新这个混合技能包。

## 项目架构说明

本项目采用**分层架构**，便于维护和更新：

```
gstack--superpowers--hybrid-skill/
├── skills/                      # 技能包目录
│   ├── [superpowers-skills]/   # 来自 superpowers 的技能（上游同步）
│   ├── [gstack-skills]/        # 来自 gstack 的技能（上游同步）
│   └── custom/                  # 自定义扩展技能（本地维护）
├── gstack-skills/               # GStack 工具脚本（上游同步）
├── overrides/                   # 覆盖配置（本地维护）
└── scripts/                     # 维护脚本
    └── sync-upstream.sh         # 上游同步脚本
```

## 版本追踪

当前追踪的上游版本记录在 `.upstream-versions.json`：

```json
{
  "superpowers": {
    "repo": "https://github.com/obra/superpowers",
    "version": "5.0.7",
    "last_sync": "2026-05-15"
  },
  "gstack": {
    "path": "~/.claude/skills/gstack",
    "version": "检查 VERSION 文件",
    "last_sync": "2026-05-15"
  }
}
```

## 更新策略

### 策略 1: 直接同步（推荐）

适用于：上游更新后，直接拉取最新内容，覆盖本地。

```bash
# 运行同步脚本
./scripts/sync-upstream.sh

# 或分别同步
./scripts/sync-upstream.sh --superpowers  # 仅同步 superpowers
./scripts/sync-upstream.sh --gstack       # 仅同步 gstack
```

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

## 如何扩展 gs-hybrid-v3

### 方法 1: 创建扩展技能

在 `skills/custom/` 目录下创建扩展技能：

```
skills/custom/gs-hybrid-v3-extended/
├── SKILL.md              # 扩展后的技能定义
├── extensions.md         # 扩展内容
└── custom-phases/
    ├── phase-8-custom.md
    └── phase-9-custom.md
```

**SKILL.md 示例**：
```markdown
---
name: gs-hybrid-v3-extended
description: 扩展版 gs-hybrid-v3，包含自定义流程
extends: gs-hybrid-v3
---

# 继承 gs-hybrid-v3 并扩展

本技能继承自 gs-hybrid-v3，添加以下扩展：

## 新增 Phase

### Phase 8: 自定义检查
- 内容...

### Phase 9: 性能优化审查
- 内容...

## 修改的流程
- ...
```

### 方法 2: 使用配置扩展

创建 `config/gs-hybrid-config.json`：

```json
{
  "base_skill": "gs-hybrid-v3",
  "customizations": {
    "additional_phases": [
      {
        "name": "performance-review",
        "trigger": "after Phase 5",
        "checklist": [
          "性能基准测试通过",
          "内存泄漏检查",
          "响应时间达标"
        ]
      }
    ],
    "modified_phases": {
      "phase_0_5": {
        "additional_checks": [
          "检查与内部框架的兼容性"
        ]
      }
    }
  }
}
```

### 方法 3: 补丁模式

创建补丁文件，在同步后自动应用：

```
patches/
├── gs-hybrid-v3.patch     # 对 gs-hybrid-v3 的修改
└── brainstorming.patch    # 对 brainstorming 的修改
```

## 更新工作流

### 定期更新流程

```bash
# 1. 检查上游更新
./scripts/sync-upstream.sh --check

# 2. 备份当前版本
./scripts/sync-upstream.sh --backup

# 3. 执行同步
./scripts/sync-upstream.sh

# 4. 应用自定义补丁
./scripts/apply-patches.sh

# 5. 验证更新
./scripts/verify-update.sh

# 6. 提交更改
git add .
git commit -m "chore: sync upstream updates"
```

### 冲突解决

如果上游更新与本地修改冲突：

1. **保留本地修改**：
   ```bash
   git checkout --ours skills/gs-hybrid-v3/SKILL.md
   ```

2. **使用上游版本**：
   ```bash
   git checkout --theirs skills/gs-hybrid-v3/SKILL.md
   ```

3. **手动合并**：
   ```bash
   git mergetool skills/gs-hybrid-v3/SKILL.md
   ```

## 最佳实践

### 1. 分离关注点

- **上游内容**：放在标准目录，定期同步覆盖
- **自定义内容**：放在 `custom/` 或 `overrides/` 目录
- **配置**：放在 `config/` 目录

### 2. 版本锁定

如果需要锁定特定版本：

```json
// .upstream-versions.json
{
  "superpowers": {
    "version": "5.0.7",
    "locked": true,
    "lock_reason": "v5.1.0 有破坏性变更"
  }
}
```

### 3. 变更日志

维护 `CHANGELOG-custom.md` 记录本地修改：

```markdown
## 本地修改历史

### 2026-05-15
- 初始创建混合技能包
- 添加 gs-hybrid-v3 扩展配置

### 2026-05-10
- 自定义 brainstorming 技能
```

## 快速参考

| 操作 | 命令 |
|------|------|
| 检查更新 | `./scripts/sync-upstream.sh --check` |
| 同步所有 | `./scripts/sync-upstream.sh` |
| 同步 superpowers | `./scripts/sync-upstream.sh --superpowers` |
| 同步 gstack | `./scripts/sync-upstream.sh --gstack` |
| 应用补丁 | `./scripts/apply-patches.sh` |
| 验证更新 | `./scripts/verify-update.sh` |
| 回滚更新 | `./scripts/sync-upstream.sh --rollback` |

## 获取帮助

- Superpowers 文档: https://github.com/obra/superpowers
- GStack 文档: 查看本地 `docs/` 目录
- 问题反馈: 在项目中创建 Issue
