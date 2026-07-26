# AI Engineering Governance System

让 AI 编程助手（Claude Code、Codex 等）按规范流程工作，而不是直接写代码。

[![CI](https://github.com/coder100001/gstack-superpowers-hybrid-skill/actions/workflows/ci.yml/badge.svg)](https://github.com/coder100001/gstack-superpowers-hybrid-skill/actions/workflows/ci.yml)

---

## 解决的问题

AI 编程助手很强大，但在实际工程中会反复出现三个问题：

| 问题 | 表现 | 本系统的处理方式 |
|------|------|------------------|
| **跳过程序直接编码** | AI 拿到需求就开始写，写完发现理解错了 | 强制需求确认（`REQUIREMENT_LOCK`）和执行计划确认（`PLAN_CONFIRM`），不确认不准编码 |
| **边写边改架构** | 写到一半觉得"这里换个方案更好"，结果越改越乱 | 进入实现阶段后锁定架构决策（`decision-freeze`），要改必须先走变更流程 |
| **跨会话失忆** | 每次新对话 AI 不记得项目约定，反复踩坑 | 进入实现前自动注入项目契约（`CONTEXT_HYDRATION`），包括架构规范、API 约定、测试策略 |

如果你遇到过上述任何一个问题，这个项目就是为你准备的。

---

## 快速开始

```bash
# 克隆 + 装依赖 + 一键校验
git clone https://github.com/coder100001/gstack-superpowers-hybrid-skill.git
cd gstack-superpowers-hybrid-skill
chmod +x scripts/*.sh governance/*.sh governance/gates/*.sh governance/lib/*.sh
pip3 install pyyaml 2>/dev/null || true
./scripts/validate-project.sh
```

全部退出码为 `0` 即验证通过。

---

## 工作原理

三个层次，一个目标：**让 AI 在正确的约束下做正确的事。**

```
决策层（做什么） → 上下文层（共识是什么） → 执行层（如何做好）
     ↕                       ↕                       ↕
  需求确认              契约沉淀                 冻结实现
  方案审议              注水加载                 质量验证
  计划确认                                        交付检查
```

- **决策层**：确定要做什么、为什么这么做、怎么做。产出：需求文档、架构决策记录（ADR）、执行计划。
- **上下文层**：把决策层的产出转化为 AI 可加载的契约文件，进入实现前一次性注入。
- **执行层**：在冻结的决策约束下实现、自审、测试、交付。不允许修改已确认的架构和需求。

每层之间通过 Gate（门禁）强制校验——不满足条件就不允许进入下一阶段。

### 复杂度自适应

系统根据任务大小自动适配流程深度，小任务不折腾：

| 级别 | 典型场景 | 流程长度 |
|------|----------|----------|
| L0 | 改一行配置、修复拼写 | 3 步（IDEA → 实现 → 发布） |
| L1 | 加个小功能、修个 bug | 5 步，跳过架构审议 |
| L2 | 新模块、中等功能 | 9 步，标准流程 |
| L3 | 跨模块重构、复杂功能 | 12 步，完整流程含 QA |

---

## 一个典型的开发流程

假设你要给一个 Web 应用加"用户导出 CSV"功能（L2 复杂度）：

```
1. AI 接到需求，进入 DISCOVERY
   → 澄清：导出范围？权限？格式？性能要求？
   
2. 需求确认（REQUIREMENT_LOCK）
   → Gate 检查：用户确认了需求清单吗？→ 没有就阻断
   
3. 架构审议（ARCH_REVIEW）
   → 方案对比：后端生成 vs 前端流式写入
   → 产出 ADR：记录选型理由和 trade-off
   
4. 任务拆解 + 计划确认（TASK_DECOMPOSITION → PLAN_CONFIRM）
   → 产出执行计划，用户确认后才放行
   
5. 上下文注水（CONTEXT_HYDRATION）
   → 注入项目已有的架构规范、API 风格、测试要求
   
6. 编码实现（IMPLEMENTATION）
   → 约束：不能修改已确认的 ADR 和 Spec（decision-freeze）
   → AI 在约束内写代码
   
7. 自审 → 发布检查（SELF_REVIEW → SHIP_REVIEW）
   → 检查：测试存在？验收项有证据？提交信息合规？
   
8. 复盘（RETRO）
   → 记录：这次哪里做得好？下次怎么改进？
```

每个阶段如果失败，AI 会被引导回退到上一个可修正的阶段，而不是直接报错终止。

---

## 项目结构

```
├── governance/              # 治理规则（核心）
│   ├── state-machine.yaml   #   状态机：定义所有状态和跃迁
│   ├── gates.yaml           #   Gate：定义所有门禁条件
│   ├── check-gates.sh       #   Gate 检查入口
│   └── gates/               #   每个 Gate 的校验脚本
├── schema/skill-routes.yaml # 技能路由表
├── skills/                  # AI 技能（按场景分类）
│   ├── gstack/qa/           #   QA 测试 → 修复 → 验证
│   ├── gstack/ship/         #   发布检查
│   ├── gstack/design-review/#   设计审查
│   └── superpowers/         #   通用开发技能
├── scripts/                 # 校验和工具脚本
├── tests/claude-code/       # 集成测试
└── docs/                    # 文档
    ├── getting-started.md
    ├── architecture.md
    └── glossary.md          # 术语表
```

---

## 下一步

- [快速开始](docs/getting-started.md)——详细的安装和操作指南
- [架构说明](docs/architecture.md)——三层 + 治理的完整设计
- [术语表](docs/glossary.md)——ADR、Gate、注水、冻结……一次性搞懂

---

提交 PR 前请阅读 [AGENTS.md](AGENTS.md)（PR 拒绝率 94%）。
