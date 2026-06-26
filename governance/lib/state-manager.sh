#!/bin/bash
# state-manager.sh — 统一的 workflow-state.md 文件管理器
# 消除 transition.sh（完全重写）和 gate 脚本（追加）之间的写入策略冲突
#
# 用法:
#   source "$(dirname "${BASH_SOURCE[0]}")/state-manager.sh"
#
# 函数:
#   state_manager_init <state_file> [session]
#   state_manager_set_current <state_file> status=<val> level=<val> previous=<val> gate_passed=<val> route_skills=<val> reason=<val>
#   state_manager_add_history <state_file> <from> <to> <level> [gate] [routes]
#   state_manager_record_gate <state_file> <gate_name> <status> [detail1] [detail2] ...
#   state_manager_read_current <state_file> <key>
#   state_manager_get_timestamp

set -euo pipefail

_STATE_MANAGER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── 内部工具 ──────────────────────────────────────────────────────

# 获取 ISO UTC 时间戳
state_manager_get_timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00"
}

# 使用 python3 更新文件中的 YAML 值（在 ```yaml ... ``` 块内）
# $1=file $2=key $3=value
_state_mgr_set_yaml_value() {
  local file="$1" key="$2" value="$3"
  python3 - "$file" "$key" "$value" << 'PYEOF'
import sys, re

file_path, key, value = sys.argv[1], sys.argv[2], sys.argv[3]

with open(file_path, 'r') as f:
    content = f.read()

# Find the ```yaml ... ``` block inside "## Current State"
pattern = r'(## Current State\s*\n```yaml\n)(.*?)(```)'


def replace_yaml(match):
    prefix = match.group(1)
    yaml_block = match.group(2)
    suffix = match.group(3)

    # Update or add the key
    lines = yaml_block.split('\n')
    found = False
    new_lines = []
    for line in lines:
        if line.startswith(f'{key}:'):
            new_lines.append(f'{key}: {value}')
            found = True
        elif line.strip():
            new_lines.append(line)
    if not found:
        new_lines.append(f'{key}: {value}')

    return prefix + '\n'.join(new_lines) + '\n' + suffix

new_content = re.sub(pattern, replace_yaml, content, flags=re.DOTALL)

with open(file_path, 'w') as f:
    f.write(new_content)
PYEOF
}

# 使用 python3 更新文件中的 > **Last Updated**: ... 行
_state_mgr_set_timestamp() {
  local file="$1" ts="$2"
  python3 - "$file" "$ts" << 'PYEOF'
import sys, re

file_path, ts = sys.argv[1], sys.argv[2]

with open(file_path, 'r') as f:
    content = f.read()

content = re.sub(
    r'(\*\*Last Updated\*\*:\s*).*',
    r'\g<1>' + ts,
    content,
    count=1
)

with open(file_path, 'w') as f:
    f.write(content)
PYEOF
}

# ─── 公开 API ──────────────────────────────────────────────────────

# 初始化 workflow-state.md（仅在文件不存在时创建骨架）
# state_manager_init <state_file> [session]
state_manager_init() {
  local state_file="$1"
  local session="${2:-agent-enforcement}"
  local ts
  ts="$(state_manager_get_timestamp)"

  mkdir -p "$(dirname "$state_file")"

  if [[ -f "$state_file" ]]; then
    return 0
  fi

  cat > "$state_file" << EOF
# Workflow State

> **Last Updated**: $ts
> **Session**: $session

## Current State

\`\`\`yaml
status: IDEA
level: L3
previous: none
gate_passed: none
route_skills: none
route_resolution: ok
route_resolution_error: none
reason: initialization
\`\`\`

## State History

| Timestamp | From | To | Level | Gate | Routes |
|-----------|------|-----|-------|------|--------|

## Gate Results

| Timestamp | Gate | Status | Details |
|-----------|------|--------|---------|

---
*This file is managed by state-manager.sh*
EOF
}

# 更新 Current State 中的多个字段（原子性：读取一次、修改、写回）
# state_manager_set_current <state_file> key1=val1 key2=val2 ...
state_manager_set_current() {
  local state_file="$1"
  shift

  if [[ ! -f "$state_file" ]]; then
    state_manager_init "$state_file"
  fi

  local ts
  ts="$(state_manager_get_timestamp)"
  _state_mgr_set_timestamp "$state_file" "$ts"

  local pair key value
  for pair in "$@"; do
    key="${pair%%=*}"
    value="${pair#*=}"
    _state_mgr_set_yaml_value "$state_file" "$key" "$value"
  done
}

# 向 State History 表格追加一行（幂等：相同 from/to/ts+level 不重复追加）
# state_manager_add_history <state_file> <from> <to> <level> [gate] [routes]
state_manager_add_history() {
  local state_file="$1" from="$2" to="$3" level="$4"
  local gate="${5:---}" routes="${6:-none}"

  if [[ ! -f "$state_file" ]]; then
    state_manager_init "$state_file"
  fi

  local ts
  ts="$(state_manager_get_timestamp)"

  python3 - "$state_file" "$ts" "$from" "$to" "$level" "$gate" "$routes" << 'PYEOF'
import sys

file_path = sys.argv[1]
ts, from_state, to_state, level, gate, routes = sys.argv[2:8]

with open(file_path, 'r') as f:
    content = f.read()

new_row = f"| {ts} | {from_state} | {to_state} | {level} | {gate} | {routes} |"

# Find the State History section
marker = "## State History"
if marker not in content:
    content += f"\n{marker}\n\n| Timestamp | From | To | Level | Gate | Routes |\n|-----------|------|-----|-------|------|--------|\n"

idx = content.index(marker)
section = content[idx:]

# Find the last row in the table to check for duplicates
lines = section.split('\n')
table_rows = [l for l in lines if l.startswith('|') and 'Timestamp' not in l and '---' not in l]
if table_rows:
    last_row = table_rows[-1]
    # Check duplicate: same from, to, level, gate, routes
    last_parts = [p.strip() for p in last_row.split('|') if p.strip()]
    new_parts = [ts, from_state, to_state, level, gate, routes]
    if len(last_parts) >= 5:
        if last_parts[1] == from_state and last_parts[2] == to_state and last_parts[3] == level and last_parts[4] == gate:
            # Duplicate, skip
            print("skip", file=sys.stderr)
            sys.exit(0)

# Insert new row before the closing --- or next section
# Find insertion point: after last table row
insert_idx = -1
for i, line in enumerate(lines):
    if line.startswith('|') and 'Timestamp' not in line and '---' not in line:
        insert_idx = i
    elif insert_idx >= 0 and not line.startswith('|') and line.strip():
        break

if insert_idx >= 0:
    lines.insert(insert_idx + 1, new_row)
else:
    # No rows yet, find the header separator line
    for i, line in enumerate(lines):
        if '---' in line and '|' in line:
            lines.insert(i + 1, new_row)
            break

content_before = content[:idx]
new_section = '\n'.join(lines)
with open(file_path, 'w') as f:
    f.write(content_before + new_section)

print("appended", file=sys.stderr)
PYEOF
}

# 向 Gate Results 表格追加一条记录（幂等：同名 gate + 相同 status 在 1s 内不重复）
# state_manager_record_gate <state_file> <gate_name> <status> [detail1] [detail2] ...
state_manager_record_gate() {
  local state_file="$1" gate_name="$2" status="$3"
  shift 3
  local details="$*"

  if [[ ! -f "$state_file" ]]; then
    state_manager_init "$state_file"
  fi

  local ts
  ts="$(state_manager_get_timestamp)"
  _state_mgr_set_timestamp "$state_file" "$ts"

  python3 - "$state_file" "$ts" "$gate_name" "$status" "$details" << 'PYEOF'
import sys

file_path = sys.argv[1]
ts, gate_name, status, details = sys.argv[2:6]

with open(file_path, 'r') as f:
    content = f.read()

new_row = f"| {ts} | {gate_name} | {status} | {details} |"

# Ensure Gate Results section exists
if "## Gate Results" not in content:
    # Insert before the final --- or at end
    if "\n---\n" in content:
        content = content.replace("\n---\n", "\n## Gate Results\n\n| Timestamp | Gate | Status | Details |\n|-----------|------|--------|---------|\n\n---\n")
    else:
        content += "\n## Gate Results\n\n| Timestamp | Gate | Status | Details |\n|-----------|------|--------|---------|\n"

# Find the Gate Results section
idx = content.index("## Gate Results")
section = content[idx:]

# Check for duplicate (same gate + status, within same second)
lines = section.split('\n')
for line in lines:
    if line.startswith('|') and gate_name in line and status in line:
        parts = [p.strip() for p in line.split('|') if p.strip()]
        if len(parts) >= 3 and parts[0] == ts and parts[1] == gate_name and parts[2] == status:
            print("skip", file=sys.stderr)
            sys.exit(0)

# Find insertion point in Gate Results table
gate_lines = section.split('\n')
last_row_idx = -1
for i, line in enumerate(gate_lines):
    if line.startswith('|') and 'Timestamp' not in line and '---' not in line:
        last_row_idx = i

if last_row_idx >= 0:
    gate_lines.insert(last_row_idx + 1, new_row)
else:
    # Find the separator line
    for i, line in enumerate(gate_lines):
        if '---' in line and '|' in line:
            gate_lines.insert(i + 1, new_row)
            break

content_before = content[:idx]
new_section = '\n'.join(gate_lines)
with open(file_path, 'w') as f:
    f.write(content_before + new_section)

print("recorded", file=sys.stderr)
PYEOF
}

# 从 Current State YAML 块读取一个值
# state_manager_read_current <state_file> <key>
state_manager_read_current() {
  local state_file="$1" key="$2"
  if [[ ! -f "$state_file" ]]; then
    return 0
  fi
  python3 - "$state_file" "$key" << 'PYEOF'
import sys, re

file_path, key = sys.argv[1], sys.argv[2]
with open(file_path, 'r') as f:
    content = f.read()

m = re.search(r'## Current State\s*\n```yaml\n(.*?)```', content, re.DOTALL)
if not m:
    sys.exit(0)

for line in m.group(1).split('\n'):
    if line.startswith(f'{key}:'):
        val = line.split(':', 1)[1].strip()
        # Strip quotes
        if val and val[0] in ('"', "'") and val[-1] == val[0]:
            val = val[1:-1]
        print(val)
        break
PYEOF
}
