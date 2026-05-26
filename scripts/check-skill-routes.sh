#!/bin/bash
set -euo pipefail

# check-skill-routes.sh — 技能路由健康检查脚本
# 默认从 gs-hybrid-v3 的 SKILL.md 提取路由技能并与本地 skills/ 对比
# 用法:
#   ./scripts/check-skill-routes.sh
#   ./scripts/check-skill-routes.sh --skill-md path/to/SKILL.md --output docs/route-health.md
# 依赖: python3

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILL_MD="$PROJECT_ROOT/skills/hybrid/gs-hybrid-v3/SKILL.md"
OUTPUT_FILE="$PROJECT_ROOT/docs/route-health.md"
SKILLS_DIR="$PROJECT_ROOT/skills"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill-md) SKILL_MD="$2"; shift 2 ;;
    --output) OUTPUT_FILE="$2"; shift 2 ;;
    --help)
      echo "用法: check-skill-routes.sh [--skill-md path] [--output path]"
      exit 0
      ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

echo "=========================================="
echo "Skill Routes Health Check"
echo "=========================================="
echo ""
echo "路由来源: $SKILL_MD"
echo "技能目录: $SKILLS_DIR"
echo "输出文件: $OUTPUT_FILE"
echo ""

if [[ ! -f "$SKILL_MD" ]]; then
  echo "✗ 错误: SKILL.md 不存在: $SKILL_MD"
  exit 1
fi

if ! command -v python3 &>/dev/null; then
  echo "✗ 错误: 需要 python3"
  exit 1
fi

python3 - "$SKILL_MD" "$OUTPUT_FILE" "$SKILLS_DIR" << 'PYEOF'
import re
import sys
from pathlib import Path
from datetime import datetime, timezone

skill_md_file = Path(sys.argv[1])
output_file = Path(sys.argv[2])
skills_dir = Path(sys.argv[3])

errors = 0
warnings = 0
unregistered_info = 0
info_count = 0

errors_list = []
warnings_list = []
unregistered_list = []
info_list = []
skill_inventory = []

print("-------------------------------------------")
print("Step 1: 扫描本地技能目录")
print("-------------------------------------------")

skill_paths = {}
for skill_md in skills_dir.rglob("SKILL.md"):
    skill_name = skill_md.parent.name
    rel = skill_md.relative_to(skills_dir.parent)
    skill_paths[skill_name] = str(rel)

print(f"✓ 发现 {len(skill_paths)} 个技能")

print("")
print("-------------------------------------------")
print("Step 2: 从 SKILL.md 提取路由技能")
print("-------------------------------------------")

content = skill_md_file.read_text(encoding="utf-8")
route_skills = set()

# 提取单行 `xxx` token，并过滤非技能 token（避免跨行代码块误匹配）
for token in re.findall(r"`([^`\n]+)`", content):
    t = token.strip()
    if not t:
        continue
    if "/" in t or ".md" in t or t.startswith("[") or t.endswith("]"):
        continue
    if t in {"L0", "L1", "L2", "L3", "IDEA", "DISCOVERY", "ARCH_REVIEW", "TASK_DECOMPOSITION", "PLAN_CONFIRM", "CONTEXT_HYDRATION", "IMPLEMENTATION", "SELF_REVIEW", "QA", "SHIP_REVIEW", "RETRO", "ABORTED"}:
        continue
    # 仅保留看起来像 skill id 的 token
    if re.match(r"^[a-z0-9][a-z0-9:-]*[a-z0-9]$", t):
        route_skills.add(t)

print(f"✓ 从 SKILL.md 提取到 {len(route_skills)} 个技能引用")

print("")
print("-------------------------------------------")
print("Step 3: 执行一致性检查")
print("-------------------------------------------")

for skill_name in sorted(route_skills):
    actual_name = skill_name.replace("gstack:", "")
    if actual_name not in skill_paths:
        if skill_name.startswith("gstack:"):
            errors_list.append(f"[ERROR] 技能不存在: {skill_name} (查找: {actual_name})")
        else:
            errors_list.append(f"[ERROR] 技能不存在: {skill_name}")
        errors += 1
    else:
        info_list.append(f"[OK] {skill_name} -> {skill_paths[actual_name]}")
        info_count += 1

for name, path in sorted(skill_paths.items()):
    found = (name in route_skills) or (f"gstack:{name}" in route_skills)
    if not found:
        unregistered_list.append(f"[INFO] 技能未注册到 SKILL.md 路由表: {name}")
        unregistered_info += 1
    skill_inventory.append({
        "category": path.split("/")[1] if "/" in path else "unknown",
        "name": name,
        "path": path,
        "status": "✓" if found else "ℹ 未注册",
    })

print("")
print("-------------------------------------------")
print("Step 4: 生成健康报告")
print("-------------------------------------------")

ts = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

report = f"""# Skill Routes Health Report

> **Generated**: {ts}
> **Route Source**: `{skill_md_file}`
> **Skills Directory**: `skills/`

---

## Summary

| Metric | Count |
|--------|-------|
| Total Skills on Disk | {len(skill_paths)} |
| Skills in SKILL.md Routes | {len(route_skills)} |
| Errors | {errors} |
| Warnings | {warnings} |
| Info (Unregistered) | {unregistered_info} |

---

## Check Results

### Errors (Critical)

"""

if errors_list:
    report += "\n".join(f"- {e}" for e in errors_list) + "\n"
else:
    report += "None\n"

report += """
### Warnings (Should Fix)

"""

if warnings_list:
    report += "\n".join(f"- {w}" for w in warnings_list) + "\n"
else:
    report += "None\n"

report += """
### Info (Unregistered but present)

"""

if unregistered_list:
    report += "\n".join(f"- {w}" for w in unregistered_list) + "\n"
else:
    report += "None\n"

report += """
### Info (Passed)

"""

if info_list:
    shown = info_list[:20]
    report += "\n".join(f"- {i}" for i in shown) + "\n"
    if len(info_list) > 20:
        report += f"... and {len(info_list) - 20} more\n"
else:
    report += "None\n"

report += """
---

## Skills Inventory

| Category | Skill | Path | Status |
|----------|-------|------|--------|
"""

for item in skill_inventory:
    report += f"| {item['category']} | {item['name']} | `{item['path']}` | {item['status']} |\n"

report += """

---

## Recommendations

"""

if errors > 0:
    report += "1. **Critical**: 修复 SKILL.md 路由中不存在的技能名\n2. 选择：修正文档路由名或补充缺失技能\n"
elif warnings > 0:
    report += "1. **Warning**: 检查未注册技能是否应加入路由\n2. 若不应路由触发，可保留为未注册\n"
elif unregistered_info > 0:
    report += "1. **Info**: 存在未注册技能，这通常不阻断流程\n2. 如需自动触发可补充到 SKILL.md 路由表\n"
else:
    report += "All skill routes are healthy. No action required.\n"

report += """

---

*This report is auto-generated by `scripts/check-skill-routes.sh`*
"""

try:
    output_file.write_text(report, encoding="utf-8")
    print(f"✓ 报告已生成: {output_file}")
except (PermissionError, OSError) as e:
    fallback = Path("/tmp") / "route-health.md"
    fallback.write_text(report, encoding="utf-8")
    print(f"⚠ 权限不足，报告已写入: {fallback}")

print("")
print("==========================================")
print("校验结果")
print("==========================================")
print("")
print(f"错误: {errors}")
print(f"警告: {warnings}")
print(f"信息: {unregistered_info}")
print(f"通过: {info_count}")
print("")

if errors > 0:
    print(f"✗ 健康检查失败: 发现 {errors} 个错误")
    sys.exit(1)
else:
    print("✓ 健康检查通过")
    if warnings > 0:
        print(f"  (有 {warnings} 个警告，建议检查)")
    sys.exit(0)
PYEOF
