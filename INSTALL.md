# 安装指南

本文档提供详细的安装和配置说明。

## 前提条件

- macOS 或 Linux 系统
- Bash shell (4.0+)
- Git (可选，用于版本控制)

## 项目架构

本项目采用**三层架构**（v4.1）：

```
gstack-superpowers-hybrid-skill/
├── decision-layer/        # 决策层（多角色审议）
├── context-layer/         # 上下文层（契约、注水）
├── execution-layer/       # 执行层（受约束的实现）
├── bridges/               # 桥接层
├── governance/            # 治理层（决策冻结）
├── skills/
│   ├── superpowers/       # Superpowers 技能（上游同步）
│   ├── gstack/            # GStack 技能（上游同步）
│   ├── hybrid/            # 混合流程技能（本地维护）
│   └── custom/            # 自定义扩展
└── scripts/               # 维护脚本
```

## 快速开始

### 方法 1：使用安装脚本（推荐）

```bash
cd /path/to/gstack-superpowers-hybrid-skill

./scripts/install.sh install
```

这个脚本会：
- 检查前置条件
- 备份现有安装（如果有）
- 复制所有文件到 `~/.trae-cn/superpowers`
- 设置正确的权限
- 验证安装

### 方法 2：手动安装

```bash
cp -r /path/to/gstack-superpowers-hybrid-skill ~/.trae-cn/superpowers
```

## 安装脚本详细说明

### 命令

```bash
./scripts/install.sh <命令> [选项]
```

| 命令 | 说明 |
|:-----|:-----|
| `install` | 安装到目标目录（默认） |
| `uninstall` | 卸载 |
| `rollback` | 回滚到上一个版本 |
| `validate` | 验证安装 |
| `status` | 显示安装状态 |
| `backups` | 列出所有备份 |

### 选项

| 选项 | 说明 |
|:-----|:-----|
| `--target DIR` | 目标目录（默认: `~/.trae-cn/superpowers`） |
| `--no-backup` | 安装时不创建备份 |
| `--dry-run` | 预览模式，不执行实际操作 |
| `--force` | 强制安装，覆盖现有文件 |
| `--verbose` | 详细输出 |
| `-y, --yes` | 跳过确认提示 |
| `-h, --help` | 显示帮助信息 |

### 示例

```bash
./scripts/install.sh install
./scripts/install.sh install --target ~/.claude/skills/gstack-hybrid
./scripts/install.sh install --dry-run
./scripts/install.sh uninstall
./scripts/install.sh rollback
./scripts/install.sh validate
./scripts/install.sh status
./scripts/install.sh backups
```

## 安装到不同平台

### 安装到 Trae（默认）

```bash
./scripts/install.sh install
```

目标目录：`~/.trae-cn/superpowers`

### 安装到 Claude Code

```bash
./scripts/install.sh install --target ~/.claude/skills/gstack-hybrid
```

### 安装到自定义位置

```bash
./scripts/install.sh install --target /path/to/custom/location
```

## 验证安装

### 使用脚本验证

```bash
./scripts/install.sh validate
```

### 手动验证

```bash
ls ~/.trae-cn/superpowers/skills/
ls ~/.trae-cn/superpowers/decision-layer/
ls ~/.trae-cn/superpowers/context-layer/
ls ~/.trae-cn/superpowers/execution-layer/
```

### 检查核心文件

```bash
for skill in brainstorming writing-plans test-driven-development gs-hybrid-v3; do
    found=false
    for dir in ~/.trae-cn/superpowers/skills/superpowers/"$skill" ~/.trae-cn/superpowers/skills/hybrid/"$skill"; do
        if [[ -f "$dir/SKILL.md" ]]; then
            found=true
            break
        fi
    done
    if [[ "$found" == "true" ]]; then
        echo "✅ $skill: 存在"
    else
        echo "❌ $skill: 缺失"
    fi
done
```

## 备份和回滚

### 查看备份

```bash
./scripts/install.sh backups
```

### 回滚到上一个版本

```bash
./scripts/install.sh rollback
```

### 备份位置

所有备份存储在：`~/.trae-cn/superpowers-backups/`

## 开发模式

如果您想在本项目上开发和测试：

```bash
git clone <repo-url>
cd gstack-superpowers-hybrid-skill

chmod +x scripts/*.sh

./scripts/sync-upstream.sh

./scripts/install.sh install
```

## 同步上游技能

安装后，您可以同步上游技能：

```bash
./scripts/sync-upstream.sh
./scripts/sync-upstream.sh --superpowers
./scripts/sync-upstream.sh --gstack
```

## 常见问题

### Q1: 脚本提示 "Permission denied"

```bash
chmod +x scripts/*.sh
```

### Q2: 目标目录已存在

使用 `--force` 选项强制安装：

```bash
./scripts/install.sh install --force
```

或先卸载再安装：

```bash
./scripts/install.sh uninstall
./scripts/install.sh install
```

### Q3: 如何查看当前安装状态

```bash
./scripts/install.sh status
```

### Q4: 如何预览安装操作

```bash
./scripts/install.sh install --dry-run --verbose
```

### Q5: 三层架构目录缺失

重新安装或手动复制：

```bash
./scripts/install.sh install --force
```

## 下一步

- 阅读 [MAINTENANCE.md](MAINTENANCE.md) 了解如何维护和更新
- 阅读 README.md 了解项目结构和使用方法
- 查看 `docs/getting-started.md` 了解快速入门
- 查看 `skills/custom/README.md` 了解如何创建自定义技能
- 查看 `decision-layer/reviews/README.md` 了解如何使用多角色审议
