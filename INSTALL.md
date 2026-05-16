# 安装指南

本文档提供详细的安装和配置说明。

## 前提条件

- macOS 或 Linux 系统
- Bash shell (4.0+)
- Git (可选，用于版本控制)

## 项目架构

本项目采用**三层架构**（v4.0）：

```
gstack--superpowers--hybrid-skill/
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

## 安装步骤

### 方法 1：在 Trae 中使用（推荐）

1. 将本项目复制到 Trae 的工作目录：

```bash
# 假设您在 Trae 中打开了一个项目
cd /path/to/your/project

# 复制技能包（包含三层架构）
cp -r /path/to/gstack--superpowers--hybrid-skill ~/.trae-cn/superpowers
```

2. 重启 Trae，技能将自动加载

3. 验证安装：

```bash
# 检查技能文件是否存在
ls ~/.trae-cn/superpowers/skills/

# 检查三层架构目录
ls ~/.trae-cn/superpowers/decision-layer/
ls ~/.trae-cn/superpowers/context-layer/
ls ~/.trae-cn/superpowers/execution-layer/
```

### 方法 2：手动安装到 Claude Code

```bash
# 1. 创建插件目录
mkdir -p ~/.claude/skills/gstack-hybrid

# 2. 复制所有技能
cp -r skills/* ~/.claude/skills/gstack-hybrid/

# 3. 复制三层架构
cp -r decision-layer context-layer execution-layer bridges governance ~/.claude/

# 4. 复制配置文件
cp CLAUDE.md ~/.claude/
```

### 方法 3：本地开发模式

如果您想在本项目上开发和测试：

```bash
# 1. 克隆项目
git clone &lt;repo-url&gt;
cd gstack--superpowers--hybrid-skill

# 2. 给脚本添加执行权限
chmod +x scripts/*.sh

# 3. 同步上游技能（如果本地有安装）
./scripts/sync-upstream.sh

# 4. 验证技能文件
ls skills/*/SKILL.md

# 5. 验证三层架构
ls decision-layer/ context-layer/ execution-layer/
```

## 验证安装

### 1. 检查核心文件

```bash
# 检查关键技能是否存在
echo "检查核心技能..."
for skill in brainstorming writing-plans test-driven-development gs-hybrid-v3; do
    if [[ -f "skills/$skill/SKILL.md" ]]; then
        echo "✅ $skill: 存在"
    else
        echo "❌ $skill: 缺失"
    fi
done

# 检查三层架构目录
echo ""
echo "检查三层架构..."
for dir in decision-layer context-layer execution-layer bridges governance; do
    if [[ -d "$dir" ]]; then
        echo "✅ $dir: 存在"
    else
        echo "❌ $dir: 缺失"
    fi
done
```

### 2. 检查脚本权限

```bash
# 检查脚本是否有执行权限
ls -la scripts/*.sh
```

如果没有执行权限，运行：

```bash
chmod +x scripts/*.sh
```

### 3. 测试同步脚本

```bash
# 测试检查功能
./scripts/sync-upstream.sh --check

# 测试 dry-run 模式
./scripts/sync-upstream.sh --dry-run
```

## 首次使用

### 1. 同步上游技能

```bash
# 同步所有上游技能
./scripts/sync-upstream.sh

# 或分别同步
./scripts/sync-upstream.sh --superpowers
./scripts/sync-upstream.sh --gstack
```

### 2. 验证版本

```bash
# 查看当前追踪的上游版本
cat .upstream-versions.json
```

### 3. 创建备份（可选）

```bash
# 创建当前状态的备份（包含三层架构）
./scripts/sync-upstream.sh --backup
```

### 4. 测试 gs-hybrid-v3 技能

在 Trae 或 Claude Code 中使用：

```
# 简单测试 L1 任务
gs-hybrid-v3 修改一个小问题

# 完整测试 L3 任务
gs-hybrid-v3 开发一个新功能
```

## 常见问题

### Q1: 脚本提示 "Permission denied"

**解决方案**：

```bash
chmod +x scripts/sync-upstream.sh
```

### Q2: 同步时提示上游路径不存在

**解决方案**：

确认您已安装了对应的上游项目：

```bash
# 检查 superpowers
ls ~/.trae-cn/superpowers

# 检查 gstack
ls ~/.claude/skills/gstack
```

如果不存在，请先安装上游项目。

### Q3: 三层架构目录缺失

**解决方案**：

重新同步或手动复制：

```bash
# 从备份恢复
./scripts/sync-upstream.sh --rollback

# 或手动复制（如果在开发模式）
cd /path/to/gstack--superpowers--hybrid-skill
cp -r decision-layer context-layer execution-layer bridges governance ~/.trae-cn/superpowers/
```

### Q4: gs-hybrid-v3 技能版本不正确

**解决方案**：

```bash
# 检查当前版本
cat .upstream-versions.json | grep hybrid

# 确保 SKILL.md 是 v4.0
cat skills/hybrid/gs-hybrid-v3/SKILL.md | head -20
```

## 下一步

- 阅读 [MAINTENANCE.md](MAINTENANCE.md) 了解如何维护和更新
- 阅读 README.md 了解项目结构和使用方法
- 查看 `docs/getting-started.md` 了解快速入门
- 查看 `skills/custom/README.md` 了解如何创建自定义技能
- 查看 `decision-layer/reviews/README.md` 了解如何使用多角色审议
