# Agent Enforcement Governance System — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add executable process-level governance to hybrid workflow — state machine, gate checks, CI guard, audit journal.

**Architecture:** New `governance/` layer parallel to existing three layers. `transition.sh` is the single entry point, driven by `machine.json` and `gates.json`. CI guards in `scripts/` run in PR pipeline.

**Tech Stack:** bash + JSON, zero external dependencies.

---

### Task 1: State Machine + Gate Definitions

**Dependencies:** None | **Estimate:** ~10min

**Files:**
- Create: `governance/machine.json`
- Create: `governance/gates.json`

- [ ] **Step 1: Create machine.json**

```json
{
  "version": "4.0",
  "states": {
    "IDEA": { "entry_gate": null },
    "DISCOVERY": { "entry_gate": null },
    "REQUIREMENT_LOCK": { "entry_gate": "requirement-lock" },
    "ARCH_REVIEW": { "entry_gate": null },
    "TASK_DECOMPOSITION": { "entry_gate": null },
    "CONTEXT_HYDRATION": { "entry_gate": "context-hydration" },
    "IMPLEMENTATION": { "entry_gate": "decision-freeze" },
    "SELF_REVIEW": { "entry_gate": "test-presence" },
    "QA": { "entry_gate": null },
    "SHIP_REVIEW": { "entry_gate": null },
    "RETRO": { "entry_gate": null },
    "ABORTED": { "entry_gate": null }
  },
  "transitions": [
    { "from": "IDEA", "to": "DISCOVERY" },
    { "from": "DISCOVERY", "to": "REQUIREMENT_LOCK" },
    { "from": "REQUIREMENT_LOCK", "to": "ARCH_REVIEW" },
    { "from": "ARCH_REVIEW", "to": "TASK_DECOMPOSITION" },
    { "from": "TASK_DECOMPOSITION", "to": "CONTEXT_HYDRATION" },
    { "from": "CONTEXT_HYDRATION", "to": "IMPLEMENTATION" },
    { "from": "IMPLEMENTATION", "to": "SELF_REVIEW" },
    { "from": "SELF_REVIEW", "to": "QA" },
    { "from": "QA", "to": "SHIP_REVIEW" },
    { "from": "SHIP_REVIEW", "to": "RETRO" },
    { "from": "*", "to": "ABORTED" },
    { "from": "*", "to": "IDEA", "reason": "decision_freeze_rollback" }
  ]
}
```

- [ ] **Step 2: Create gates.json**

```json
{
  "version": "4.1",
  "gates": [
    {
      "name": "requirement-lock",
      "script": "governance/gates/requirement-lock.sh",
      "applies_to": ["REQUIREMENT_LOCK"],
      "check": "用户是否明确确认了需求清单",
      "fail_message": "REQUIREMENT_LOCK 未通过：用户未确认需求"
    },
    {
      "name": "context-hydration",
      "script": "governance/gates/context-hydration.sh",
      "applies_to": ["CONTEXT_HYDRATION"],
      "check": "所有 P0 Spec 文件是否存在",
      "fail_message": "CONTEXT_HYDRATION 未通过：缺少上下文契约文件"
    },
    {
      "name": "decision-freeze",
      "script": "governance/gates/decision-freeze.sh",
      "applies_to": ["IMPLEMENTATION"],
      "check": "自上次 ARCH_REVIEW 后 ADR/specs 是否未被修改",
      "fail_message": "决策冻结违规：IMPLEMENTATION 期间不得修改 ADR 或 Specs"
    },
    {
      "name": "test-presence",
      "script": "governance/gates/test-presence.sh",
      "applies_to": ["SELF_REVIEW"],
      "check": "本次变更是否包含对应测试文件",
      "fail_message": "没有对应测试的代码不能进入 SELF_REVIEW"
    }
  ]
}
```

- [ ] **Step 3: Commit**

```bash
git add governance/machine.json governance/gates.json
git commit -m "feat(governance): add state machine and gate definitions"
```

---

### Task 2: requirement-lock Gate

**Dependencies:** Task 1 | **Estimate:** ~5min

**Files:**
- Create: `governance/gates/requirement-lock.sh`

- [ ] **Step 1: Create requirement-lock.sh**

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# requirement-lock.sh — 检查 REQUIREMENT_LOCK 是否已通过
# 验证条件：context-layer/specs/ 下有当天 spec 文件，且包含 ## Approval 标记

SPEC_DIR="context-layer/specs"
today=$(date +%Y-%m-%d)

specs=$(ls "$SPEC_DIR"/"$today"-*-spec.md 2>/dev/null || true)
if [[ -z "$specs" ]]; then
  echo "REQUIREMENT_LOCK 未通过：未找到 spec 文件 ($SPEC_DIR/$today-*-spec.md)"
  exit 1
fi

latest=$(echo "$specs" | tail -1)
if grep -q "^##.*确认\|^##.*Approval\|^##.*approved" "$latest" 2>/dev/null; then
  exit 0
else
  echo "REQUIREMENT_LOCK 未通过：$latest 缺少确认标记"
  exit 1
fi
```

- [ ] **Step 2: Make executable**

```bash
chmod +x governance/gates/requirement-lock.sh
```

- [ ] **Step 3: Commit**

```bash
git add governance/gates/requirement-lock.sh
git commit -m "feat(governance): add requirement-lock gate"
```

---

### Task 3: context-hydration Gate

**Dependencies:** Task 1 | **Estimate:** ~5min

**Files:**
- Create: `governance/gates/context-hydration.sh`

- [ ] **Step 1: Create context-hydration.sh**

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# context-hydration.sh — 检查 CONTEXT_HYDRATION 是否已通过
# 验证条件：所有 P0 上下文契约文件存在

required=("project-spec" "architecture-spec" "constraints-spec" "domain-boundaries")
missing=()

for asset in "${required[@]}"; do
  if [[ ! -f "context-layer/specs/$asset.md" ]]; then
    missing+=("context-layer/specs/$asset.md")
  fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "CONTEXT_HYDRATION 未通过：缺少上下文契约文件"
  printf '  - %s\n' "${missing[@]}"
  exit 1
fi

exit 0
```

- [ ] **Step 2: Make executable**

```bash
chmod +x governance/gates/context-hydration.sh
```

- [ ] **Step 3: Commit**

```bash
git add governance/gates/context-hydration.sh
git commit -m "feat(governance): add context-hydration gate"
```

---

### Task 4: decision-freeze Gate

**Dependencies:** Task 1 | **Estimate:** ~8min

**Files:**
- Create: `governance/gates/decision-freeze.sh`

- [ ] **Step 1: Create decision-freeze.sh**

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# decision-freeze.sh — 检查 IMPLEMENTATION 期间决策冻结
# 验证条件：ADR 和 specs 在进入 IMPLEMENTATION 后未被修改
# 通过 HEAD~1 的 git diff 检测冻结区变更

FROZEN_PATTERNS="^decision-layer/adr/|^context-layer/specs/"

if ! git rev-parse --git-dir &>/dev/null; then
  exit 0
fi

if git diff HEAD~1 --name-only 2>/dev/null | grep -qE "$FROZEN_PATTERNS"; then
  echo "决策冻结违规：IMPLEMENTATION 期间修改了以下冻结文件："
  git diff HEAD~1 --name-only | grep -E "$FROZEN_PATTERNS" | sed 's/^/  - /'
  echo ""
  echo "修复：退回 Decision Layer 重新审议后再修改"
  exit 1
fi

exit 0
```

- [ ] **Step 2: Make executable**

```bash
chmod +x governance/gates/decision-freeze.sh
```

- [ ] **Step 3: Commit**

```bash
git add governance/gates/decision-freeze.sh
git commit -m "feat(governance): add decision-freeze gate"
```

---

### Task 5: test-presence Gate

**Dependencies:** Task 1 | **Estimate:** ~8min

**Files:**
- Create: `governance/gates/test-presence.sh`

- [ ] **Step 1: Create test-presence.sh**

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# test-presence.sh — 检查 SELF_REVIEW 前是否有测试文件
# 验证条件：新增/修改的实现文件有对应的测试文件

if ! git rev-parse --git-dir &>/dev/null; then
  exit 0
fi

src_files=$(git diff --name-only --diff-filter=AM HEAD~1 -- \
  '*.py' '*.js' '*.ts' '*.go' '*.rs' '*.sh' 2>/dev/null || true)

if [[ -z "$src_files" ]]; then
  exit 0
fi

missing=()
while IFS= read -r src; do
  base="${src%.*}"
  ext="${src##*.}"
  # 查找 test 文件
  test_found=false
  for test_ext in py js ts go rs sh; do
    if ls "${base}_test.${test_ext}" "${base}.test.${test_ext}" 2>/dev/null | grep -q .; then
      test_found=true
      break
    fi
  done
  # 也检查 tests/ 目录下的对应文件
  test_path="tests/${src}"
  for test_ext in py js ts go rs sh; do
    if ls "${test_path%.*}_test.${test_ext}" "${test_path%.*}.test.${test_ext}" 2>/dev/null | grep -q .; then
      test_found=true
      break
    fi
  done
  if [[ "$test_found" == false ]]; then
    missing+=("$src")
  fi
done < <(echo "$src_files")

if [[ ${#missing[@]} -gt 0 ]]; then
  echo "test-presence 未通过：以下文件缺少测试："
  printf '  - %s\n' "${missing[@]}"
  exit 1
fi

exit 0
```

- [ ] **Step 2: Make executable**

```bash
chmod +x governance/gates/test-presence.sh
```

- [ ] **Step 3: Commit**

```bash
git add governance/gates/test-presence.sh
git commit -m "feat(governance): add test-presence gate"
```

---

### Task 6: transition.sh Entry Point

**Dependencies:** Task 1-5 | **Estimate:** ~15min

**Files:**
- Create: `governance/transition.sh`

- [ ] **Step 1: Create transition.sh**

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# transition.sh — 状态跃迁入口
# 用法: ./governance/transition.sh <from> <to> [--level L3] [--reason string]
# 示例: ./governance/transition.sh IDEA DISCOVERY --level L3 --reason "new feature"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MACHINE_FILE="$SCRIPT_DIR/machine.json"
GATES_FILE="$SCRIPT_DIR/gates.json"
JOURNAL_DIR="$SCRIPT_DIR/state-journal"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ $# -lt 2 ]]; then
  echo "用法: transition.sh <from> <to> [--level L1|L2|L3] [--reason <reason>]"
  exit 1
fi

FROM="$1"; shift
TO="$1"; shift
LEVEL="L3"
REASON=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --level) LEVEL="$2"; shift 2 ;;
    --reason) REASON="$2"; shift 2 ;;
    *) echo "未知参数: $1"; exit 1 ;;
  esac
done

# 1. 校验跃迁合法性
if [[ ! -f "$MACHINE_FILE" ]]; then
  echo "错误: machine.json 不存在"
  exit 1
fi

is_valid=false
while IFS= read -r line; do
  f=$(echo "$line" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('from',''))" 2>/dev/null || echo "")
  t=$(echo "$line" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('to',''))" 2>/dev/null || echo "")
  if { [[ "$f" == "$FROM" ]] || [[ "$f" == "*" ]]; } && [[ "$t" == "$TO" ]]; then
    is_valid=true
    break
  fi
done < <(python3 -c "
import json
with open('$MACHINE_FILE') as f:
    m = json.load(f)
for t in m['transitions']:
    print(json.dumps(t))
" 2>/dev/null)

if [[ "$is_valid" != true ]]; then
  echo "非法跃迁: $FROM → $TO"
  echo "合法跃迁:"
  python3 -c "
import json
with open('$MACHINE_FILE') as f:
    m = json.load(f)
for t in m['transitions']:
    f = t['from'] if t['from'] != '*' else 'ANY'
    print(f'  {f} → {t[\"to\"]} ${t.get(\"reason\",\"\")}')
" 2>/dev/null || echo "  (无法读取 machine.json)"
  exit 1
fi

# 2. 检查目标状态是否有 gate
gate_name=""
if [[ -f "$GATES_FILE" ]]; then
  gate_name=$(python3 -c "
import json
with open('$GATES_FILE') as f:
    g = json.load(f)
target = '$TO'
for gate in g['gates']:
    if target in gate['applies_to']:
        print(gate['name'])
        break
" 2>/dev/null || echo "")
fi

# 3. 如果有 gate，执行对应脚本
if [[ -n "$gate_name" ]]; then
  gate_script="$SCRIPT_DIR/gates/$gate_name.sh"
  if [[ -f "$gate_script" ]]; then
    echo "Gate: $gate_name"
    if ! bash "$gate_script"; then
      echo "跃迁被阻断: $FROM → $TO (gate: $gate_name)"
      exit 1
    fi
    echo "Gate 通过: $gate_name"
    gates_passed="$gate_name"
  else
    echo "Gate 脚本不存在: $gate_script（跳过）"
    gates_passed=""
  fi
else
  gates_passed=""
fi

# 4. 写入 journal
mkdir -p "$JOURNAL_DIR"
journal_file="$JOURNAL_DIR/$(date +%Y-%m-%d).json"
entry=$(cat <<EOF
{"timestamp":"$(date -Iseconds)","from":"$FROM","to":"$TO","level":"$LEVEL","gates_passed":${gates_passed:+["$gates_passed"]},"reason":"$REASON","session":"agent-enforcement"}
EOF
)
echo "$entry" >> "$journal_file"

# 5. 打印摘要
echo ""
echo "=== 状态跃迁完成 ==="
echo "跃迁: $FROM → $TO"
echo "级别: $LEVEL"
echo "Gate: ${gates_passed:-无}"
echo "Journal: $journal_file"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x governance/transition.sh
```

- [ ] **Step 3: Commit**

```bash
git add governance/transition.sh
git commit -m "feat(governance): add transition.sh entry point"
```

---

### Task 7: CI Guard Scripts

**Dependencies:** None | **Estimate:** ~12min

**Files:**
- Create: `scripts/guard-decision-freeze.sh`
- Create: `scripts/guard-test-presence.sh`

- [ ] **Step 1: Create guard-decision-freeze.sh**

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# guard-decision-freeze.sh — CI 硬守卫
# 在 PR pipeline 中执行，检测决策冻结是否被违反
# 违反条件：同一 PR 同时修改 ADR/specs 和实现代码

BASE="${1:-main}"

changed=$(git diff --name-only HEAD "$(git merge-base HEAD "$BASE" 2>/dev/null)" 2>/dev/null || \
         git diff --name-only HEAD~1 2>/dev/null || true)

if [[ -z "$changed" ]]; then
  echo "✅ No changes detected"
  exit 0
fi

adr_count=$(echo "$changed" | grep -cE "^decision-layer/adr/|^context-layer/specs/" || true)
impl_count=$(echo "$changed" | grep -cE "^skills/hybrid/|^skills/superpowers/|^scripts/" || true)

if [[ $adr_count -gt 0 && $impl_count -gt 0 ]]; then
  echo "❌ 决策冻结违规：同时变更了冻结区和执行区"
  echo ""
  echo "冻结区文件 ($adr_count):"
  echo "$changed" | grep -E "^decision-layer/adr/|^context-layer/specs/" | sed 's/^/  /'
  echo ""
  echo "执行区文件 ($impl_count):"
  echo "$changed" | grep -E "^skills/hybrid/|^skills/superpowers/|^scripts/" | sed 's/^/  /'
  echo ""
  echo "修复方案：将冻结变更拆到独立 PR，或用变更流程退回 Decision Layer"
  exit 1
fi

echo "✅ 决策冻结检查通过"
```

- [ ] **Step 2: Create guard-test-presence.sh**

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# guard-test-presence.sh — CI 软检查
# 在 PR pipeline 中执行，警告无测试的代码变更
# warning 不阻断，仅做记录

BASE="${1:-main}"

src_count=$(git diff --name-only --diff-filter=AM HEAD "$(git merge-base HEAD "$BASE" 2>/dev/null)" 2>/dev/null | \
  grep -cP '\.(py|js|ts|go|rs|sh)$' || true)

test_count=$(git diff --name-only --diff-filter=A HEAD "$(git merge-base HEAD "$BASE" 2>/dev/null)" 2>/dev/null | \
  grep -cP '_test\.(py|js|ts|go|rs|sh)$' || true)

if [[ $src_count -gt 0 && $test_count -eq 0 ]]; then
  echo "⚠️  $src_count 个文件变更但没有新增测试"
  echo "   建议补充测试后再合并"
fi

echo "✅ 测试存在检查完成"
```

- [ ] **Step 3: Make both executable**

```bash
chmod +x scripts/guard-decision-freeze.sh scripts/guard-test-presence.sh
```

- [ ] **Step 4: Commit**

```bash
git add scripts/guard-decision-freeze.sh scripts/guard-test-presence.sh
git commit -m "feat(governance): add CI guard scripts"
```

---

### Task 8: aggregate-journal.sh

**Dependencies:** None | **Estimate:** ~5min

**Files:**
- Create: `scripts/aggregate-journal.sh`

- [ ] **Step 1: Create aggregate-journal.sh**

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# aggregate-journal.sh — 聚合所有 journal 文件，输出流程时间线

JOURNAL_DIR="governance/state-journal"

if [[ ! -d "$JOURNAL_DIR" ]]; then
  echo "No journal files found"
  exit 0
fi

echo "=== 状态跃迁时间线 ==="
echo ""

for f in "$JOURNAL_DIR"/*.json; do
  [[ -f "$f" ]] || continue
  while IFS= read -r line; do
    ts=$(echo "$line" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('timestamp',''))" 2>/dev/null || echo "?")
    from=$(echo "$line" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('from',''))" 2>/dev/null || echo "?")
    to=$(echo "$line" | python3 -c "import sys,json; print(json.loads(sys.stdin.read()).get('to',''))" 2>/dev/null || echo "?")
    gates=$(echo "$line" | python3 -c "import sys,json; g=json.loads(sys.stdin.read()).get('gates_passed',[]); print(','.join(g) if g else 'none')" 2>/dev/null || echo "?")
    printf "  %s  %-20s → %-20s [gate: %s]\n" "$ts" "$from" "$to" "$gates"
  done < "$f"
done

echo ""
echo "=== 聚合完成 ==="
```

- [ ] **Step 2: Make executable**

```bash
chmod +x scripts/aggregate-journal.sh
```

- [ ] **Step 3: Commit**

```bash
git add scripts/aggregate-journal.sh
git commit -m "feat(governance): add journal aggregation script"
```

---

### Task 9: CI Integration

**Dependencies:** Task 7 | **Estimate:** ~8min

**Files:**
- Modify: `.github/workflows/ci.yml`

- [ ] **Step 1: Read current CI file**

```bash
cat .github/workflows/ci.yml
```

- [ ] **Step 2: Add guard steps to validate job**

In the `validate` job, after the "Project integrity validation" step, add:

```yaml
      - name: Decision freeze guard
        run: |
          bash scripts/guard-decision-freeze.sh

      - name: Test presence check
        run: |
          bash scripts/guard-test-presence.sh
```

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/ci.yml
git commit -m "ci(governance): add decision freeze and test presence guards"
```

---

## gs-hybrid 增强

### A. 风险评估

| 风险 | 概率 | 影响 | 缓解措施 | 关联 Task |
|------|------|------|---------|:---------:|
| CI guard 误拦合法 PR | 低 | 中 | guard-test-presence.sh 只 warning 不阻断 | Task 7 |
| transition.sh 中 python3 调用失败 | 低 | 中 | JSON 解析失败时 fallback 到错误提示 | Task 6 |
| test-presence.sh 匹配规则不准确 | 中 | 低 | 采用宽松匹配（多后缀多路径） | Task 5 |

### B. 边界条件

| 场景 | 预期 | 处理方式 | Task |
|-----|------|---------|:----:|
| machine.json 不存在 | transition.sh 报错退出 | 文件存在性检查 | Task 6 |
| gates.json 格式错误 | transition.sh 跳过 gate | python3 json.load 容错 | Task 6 |
| 不在 git 仓库中运行 gate | gate 跳过检测 | git rev-parse 检查 | Task 4, 5 |
| journal 目录不存在 | 自动创建 | mkdir -p | Task 6 |
| multiple journal 文件同一天 | 追加到同一文件 | >> 追加写入 | Task 6 |

### C. 回滚策略

- [ ] 所有文件新增，不影响现有结构
- [ ] 回滚方案：删除 `governance/` 目录，删除 3 个 guard/aggregate 脚本，回退 CI 变更
- [ ] 按 Task 顺序逐个提交，单个 Task 出问题可直接 revert 对应 commit

### D. 变更记录

| 日期 | 变更内容 | 来源 |
|------|---------|------|
| 2026-05-19 | 初始版本 | TASK_DECOMPOSITION writing-plans |
