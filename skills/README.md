# Skills 目录结构说明

本目录包含所有技能，按来源和用途分为四类，便于维护和更新。

## 目录结构

```
skills/
├── superpowers/          # Superpowers 官方技能 (14个)
├── gstack/               # GStack 工程技能 (16个)
├── hybrid/               # 混合流程技能 (1个)
└── custom/               # 自定义扩展技能
```

## 分类说明

### 1. superpowers/ - 核心方法论技能

来自 [Superpowers](https://github.com/obra/superpowers) 官方的技能，提供成熟的方法论指导。

**包含技能 (14个)**:
- `brainstorming` - 需求澄清、方案对比
- `writing-plans` - 编写实施计划
- `executing-plans` - 批量执行计划
- `subagent-driven-development` - 子代理驱动开发
- `test-driven-development` - TDD 编码
- `systematic-debugging` - 系统调试
- `requesting-code-review` - 代码审查请求
- `receiving-code-review` - 响应审查反馈
- `using-git-worktrees` - Git worktree 管理
- `finishing-a-development-branch` - 分支收尾
- `dispatching-parallel-agents` - 并行代理
- `verification-before-completion` - 完成前验证
- `writing-skills` - 创建新技能
- `using-superpowers` - 系统介绍

**更新方式**:
```bash
./scripts/sync-upstream.sh --superpowers
```

### 2. gstack/ - 工程工具技能

来自 GStack 的工程工具技能，提供丰富的开发和审查工具。

**包含技能 (16个)**: 涵盖规划审查、设计、QA、安全、部署、调试、文档、工具等类别。完整列表请参考 [skills-reference.md](../docs/skills-reference.md)。

**更新方式**:
```bash
./scripts/sync-upstream.sh --gstack
```

### 3. hybrid/ - 混合流程技能

结合 Superpowers 和 GStack 优势的混合流程技能。

**包含技能 (1个)**:
- `gs-hybrid-v3` - 完整混合流程 (主入口)

**特点**:
- 模块化设计，按需加载
- 复杂度分级 (L1/L2/L3)，L1 快速通道合并确认点
- 多角色评审 (L2→2维度，L3→5维度)
- GStack 技能显式激活（满足条件时调用）
- 强制确认机制

**主入口**: [gs-hybrid-v3/SKILL.md](./hybrid/gs-hybrid-v3/SKILL.md)

**使用方式**:
```bash
# 完整流程
hybrid 帮我开发新功能

# 专用指令
/plan    # 规划流程
/review  # 代码审查
/test    # 测试驱动
/ship    # 发布准备
/qa      # 质量保证
/debug   # 调试助手
/refactor # 重构建议
```

**文档维护规则**: 本目录下所有技能的详细定义以其各自的 SKILL.md 为唯一真相源。本文档仅提供索引，禁止重复定义。

### 4. custom/ - 自定义扩展

用户自定义的技能扩展，不会被同步脚本覆盖。

**用途**:
- 项目特定技能
- 个人工作流定制
- 实验性技能

**更新保护**:
同步脚本会跳过此目录，确保自定义内容不会被覆盖。

---

## 更新策略

### 自动同步

```bash
# 同步所有上游更新
./scripts/sync-upstream.sh

# 仅同步 superpowers
./scripts/sync-upstream.sh --superpowers

# 仅同步 gstack
./scripts/sync-upstream.sh --gstack

# 同步前备份
./scripts/sync-upstream.sh --backup

# 回滚到上一个备份
./scripts/sync-upstream.sh --rollback
```

### 避免冲突

1. **Superpowers 技能**: 完全由上游同步，不要手动修改
2. **GStack 技能**: 完全由上游同步，不要手动修改
3. **Hybrid 技能**: 以 [SKILL.md](./hybrid/gs-hybrid-v3/SKILL.md) 为唯一真相源，修改后同步相关索引文档
4. **Custom 技能**: 完全自由，不受同步影响

### 扩展方式

如需修改或扩展现有技能，建议在 `custom/` 目录创建扩展版本：

```
custom/
└── gs-hybrid-v3-extended/
    └── SKILL.md
```

然后在配置中指定使用扩展版本。

---

## 版本追踪

版本信息保存在 `.upstream-versions.json`:

```json
{
  "superpowers": {
    "version": "x.x.x",
    "last_sync": "2026-05-15",
    "skill_count": 14,
    "path": "skills/superpowers/"
  },
  "gstack": {
    "version": "x.x.x.x",
    "last_sync": "2026-05-15",
    "skill_count": 16,
    "skill_path": "skills/gstack/"
  },
  "hybrid": {
    "skill_count": 1,
    "path": "skills/hybrid/"
  }
}
```

---

## 文档维护规则

| 文档 | 角色 | 同步方式 |
|:-----|:-----|:---------|
| [SKILL.md](./hybrid/gs-hybrid-v3/SKILL.md) | 唯一真相源 | 手动维护 |
| [README.md](../README.md) | 项目索引 | 链接引用 |
| [getting-started.md](../docs/getting-started.md) | 快速开始 | 链接引用 |
| [architecture.md](../docs/architecture.md) | 架构设计 | 链接引用 |
| [skills-reference.md](../docs/skills-reference.md) | 技能列表 | 自动生成 |

**原则**: 所有详细规则以 SKILL.md 为准。其他文档仅提供索引和链接，禁止重复定义。

---

## 最佳实践

1. **定期同步**: 建议每周运行一次同步脚本
2. **同步前备份**: 使用 `--backup` 参数创建备份
3. **验证后提交**: 同步后在测试环境验证
4. **自定义隔离**: 所有自定义内容放在 `custom/` 目录
5. **文档更新**: 修改 SKILL.md 后，同步更新相关索引文档（README.md, getting-started.md, architecture.md）
