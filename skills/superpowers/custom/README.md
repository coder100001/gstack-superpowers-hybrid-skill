# Custom Skills

这个目录用于存放自定义扩展技能。

## 如何创建自定义技能

1. 在此目录下创建新的技能文件夹，例如 `my-workflow/`
2. 创建 `SKILL.md` 文件定义技能
3. 可选：创建 `extends.md` 说明如何扩展上游技能

## 示例结构

```
custom/
├── my-workflow/
│   ├── SKILL.md           # 技能定义
│   ├── extends.md         # 扩展说明（可选）
│   └── templates/         # 模板文件（可选）
└── gs-hybrid-v3-extended/
    ├── SKILL.md
    └── custom-phases/
        ├── phase-8.md
        └── phase-9.md
```

## 继承上游技能

在 SKILL.md 的 frontmatter 中添加 `extends` 字段：

```markdown
---
name: my-brainstorming
description: 自定义头脑风暴流程
extends: brainstorming
---
```

## 激活自定义技能

在 `overrides/skill-overrides.json` 中配置：

```json
{
  "replacements": {
    "brainstorming": "custom/my-brainstorming"
  }
}
```
