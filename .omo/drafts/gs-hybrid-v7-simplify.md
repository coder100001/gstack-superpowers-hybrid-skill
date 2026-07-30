---
slug: gs-hybrid-v7-simplify
status: plan-written-final
intent: clear
review_required: false
pending-action: execute .omo/plans/gs-hybrid-v7-simplify.md
approach: 真正从第一性原理简化——只改模型读的文件，不改基础设施。3 个 todo，接受 SKILL.md 与 governance/ 不一致
---

# Draft: gs-hybrid-v7-simplify (FINAL)

## 修正点

**第一版（13 todos）**：试图让全仓一致——改 SKILL.md、改 transition.sh、删 JSON、迁移 workflow-state、同步 CI。13 个 todo，方案本身就不简单。

**最终版（3 todos）**：承认 governance/ 和 SKILL.md 可以不一致。模型读 SKILL.md（5 态），CI 读 governance/（11 态）。只改模型读的东西。

## 核心假设
SKILL.md 是模型行为真相源，governance/ 是 CI 辅助工具。消费者不同，不需要同步。
