#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# test_governance-runtime.sh — regression tests for executable governance paths

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

passed=0
failed=0

make_fixture() {
  local tmp
  tmp="$(mktemp -d /tmp/gstack-governance-test.XXXXXX)"
  mkdir -p "$tmp/repo"
  (
    cd "$PROJECT_ROOT"
    tar \
      --exclude .git \
      --exclude .history \
      --exclude .backups \
      --exclude node_modules \
      -cf - .
  ) | (cd "$tmp/repo" && tar -xf -)
  printf '%s\n' "$tmp/repo"
}

assert_json_field() {
  local file="$1" expr="$2" expected="$3"
  python3 - "$file" "$expr" "$expected" <<'PY'
import json
import sys

path, expr, expected = sys.argv[1:4]
with open(path, encoding="utf-8") as f:
    data = json.load(f)

value = data
for part in expr.split("."):
    if part:
        value = value[part]

if str(value) != expected:
    raise SystemExit(f"expected {expr}={expected!r}, got {value!r}")
PY
}

test_case() {
  local name="$1"
  shift
  if "$@"; then
    echo "  ✓ $name"
    passed=$((passed + 1))
  else
    echo "  ✗ $name"
    failed=$((failed + 1))
  fi
}

test_transition_json_without_gate() {
  local repo out
  repo="$(make_fixture)"
  out="$repo/out.json"

  (cd "$repo" && ./governance/transition.sh IDEA DISCOVERY --level L2 --reason "json smoke" --json >"$out")
  assert_json_field "$out" "status" "success"
  assert_json_field "$out" "from" "IDEA"
  assert_json_field "$out" "to" "DISCOVERY"
  python3 - "$out" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as f:
    data = json.load(f)
if "gate_result" in data:
    raise SystemExit("gate_result should be omitted when no gate applies")
PY
}

test_transition_runs_gate_and_blocks() {
  local repo out code
  repo="$(make_fixture)"
  out="$repo/out.json"

  rm -f "$repo"/context-layer/specs/*-spec.md
  set +e
  (cd "$repo" && ./governance/transition.sh DISCOVERY REQUIREMENT_LOCK --level L2 --reason "missing spec" --json >"$out")
  code=$?
  set -e

  [[ "$code" -ne 0 ]]
  assert_json_field "$out" "status" "blocked"
  assert_json_field "$out" "error.code" "GATE_BLOCKED"
}

test_project_validation_checks_yaml_json_sync() {
  local repo
  repo="$(make_fixture)"

  python3 - "$repo/governance/gates.json" <<'PY'
import json
import sys
path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    data = json.load(f)
data["gates"]["decision-freeze"]["drift_probe"] = True
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
PY

  set +e
  (cd "$repo" && ./scripts/validate-project.sh >/tmp/gstack-validate-project.out 2>&1)
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
}

test_state_machine_matches_complexity_paths() {
  python3 - "$PROJECT_ROOT/governance/state-machine.yaml" <<'PY'
import sys
import yaml

with open(sys.argv[1], encoding="utf-8") as f:
    data = yaml.safe_load(f)

transitions = data["transitions"]

def scopes(src, dst):
    return [
        set(item.get("complexity_scope", []))
        for item in transitions
        if item.get("from") == src and item.get("to") == dst
    ]

def require_scope(src, dst, expected):
    actual = scopes(src, dst)
    if set(expected) not in actual:
        raise SystemExit(f"missing {src}->{dst} scope {expected}; got {actual}")

def forbid_levels(src, dst, forbidden):
    actual = set().union(*scopes(src, dst)) if scopes(src, dst) else set()
    overlap = actual & set(forbidden)
    if overlap:
        raise SystemExit(f"{src}->{dst} should not include {sorted(overlap)}")

require_scope("REQUIREMENT_LOCK", "TASK_DECOMPOSITION", ["L1"])
require_scope("PLAN_CONFIRM", "IMPLEMENTATION", ["L1"])
require_scope("IMPLEMENTATION", "SHIP_REVIEW", ["L0", "L1"])
require_scope("SELF_REVIEW", "SHIP_REVIEW", ["L1", "L2"])

forbid_levels("SELF_REVIEW", "QA", ["L1", "L2"])
forbid_levels("QA", "SHIP_REVIEW", ["L1", "L2"])
forbid_levels("SHIP_REVIEW", "RETRO", ["L1", "L2"])
require_scope("SHIP_REVIEW", "RETRO", ["L3"])
PY
}

test_presence_blocks_source_without_test() {
  local repo
  repo="$(make_fixture)"

  (
    cd "$repo"
    git init -q
    git config user.email "test@example.com"
    git config user.name "Test User"
    git checkout -q -b main
    git add .
    git commit -q -m "baseline"

    git checkout -q -b feature/no-test
    mkdir -p src
    printf 'print("missing test")\n' > src/new_feature.py
    git add src/new_feature.py
    git commit -q -m "add source without test"
  )

  set +e
  (cd "$repo" && ./governance/gates/test-presence.sh >/tmp/gstack-test-presence.out 2>&1)
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
}

test_plan_confirm_uses_context_plan_file() {
  local repo
  repo="$(make_fixture)"

  cat > "$repo/specs/plans/2000-01-01-unapproved.md" <<'MD'
# Unapproved Plan

## Tasks
- [ ] Do something
MD

  cat > "$repo/specs/plans/2099-01-01-approved.md" <<'MD'
# Approved Plan

## Tasks
- [ ] Do another thing

## Approval
- [x] User confirmed plan
MD

  cat > "$repo/context.yml" <<'YAML'
plan_file: specs/plans/2000-01-01-unapproved.md
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from TASK_DECOMPOSITION --to PLAN_CONFIRM --level L2 --context context.yml --json >/tmp/gstack-plan-confirm.out
  )
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
}

test_requirement_lock_uses_context_spec_file() {
  local repo
  repo="$(make_fixture)"

  cat > "$repo/context-layer/specs/2000-01-01-no-approval-spec.md" <<'MD'
# No Approval

## Requirements
- A
MD

  cat > "$repo/context-layer/specs/2099-01-01-approved-spec.md" <<'MD'
# Approved

## Requirements
- B

## Approval
- [x] confirmed
MD

  cat > "$repo/context.yml" <<'YAML'
spec_file: context-layer/specs/2000-01-01-no-approval-spec.md
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from DISCOVERY --to REQUIREMENT_LOCK --level L2 --context context.yml >/tmp/gstack-req-lock.out 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
}

test_task_decomposition_uses_context_plan_file() {
  local repo
  repo="$(make_fixture)"

  cat > "$repo/specs/plans/2000-01-01-bad.md" <<'MD'
# Bad Plan

## Tasks
- TBD finish this

## Approval
- [x] confirmed
MD

  cat > "$repo/specs/plans/2099-01-01-good.md" <<'MD'
# Good Plan

## Tasks
- [x] completed

## Approval
- [x] confirmed
MD

  cat > "$repo/context.yml" <<'YAML'
plan_file: specs/plans/2000-01-01-bad.md
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from ARCH_REVIEW --to TASK_DECOMPOSITION --level L2 --context context.yml >/tmp/gstack-task-lock.out 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
}

test_task_decomposition_blocks_todo_placeholder() {
  local repo
  repo="$(make_fixture)"

  cat > "$repo/specs/plans/2099-01-01-todo.md" <<'MD'
# TODO Plan

## Tasks
- TODO split into concrete tasks

## Approval
- [x] confirmed
MD

  cat > "$repo/context.yml" <<'YAML'
plan_file: specs/plans/2099-01-01-todo.md
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from ARCH_REVIEW --to TASK_DECOMPOSITION --level L2 --context context.yml >/tmp/gstack-task-todo.out 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
}

test_context_hydration_uses_context_level() {
  local repo
  repo="$(make_fixture)"

  mkdir -p "$repo/context-layer/specs"
  cat > "$repo/context-layer/specs/project-spec.md" <<'MD'
# project
MD
  cat > "$repo/context-layer/specs/architecture-spec.md" <<'MD'
# architecture
MD
  rm -f "$repo/context-layer/specs/api-spec.md"
  rm -f "$repo/context-layer/specs/test-spec.md"
  rm -f "$repo/context-layer/specs/constraints-spec.md"
  rm -f "$repo/context-layer/specs/domain-boundaries.md"

  cat > "$repo/context.yml" <<'YAML'
level: L2
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from PLAN_CONFIRM --to CONTEXT_HYDRATION --level L1 --context context.yml >/tmp/gstack-hydration.out 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
}

test_acceptance_check_uses_context_files() {
  local repo
  repo="$(make_fixture)"

  mkdir -p "$repo/specs/plans" "$repo/context-layer/specs"
  cat > "$repo/context-layer/specs/contract-summary.md" <<'MD'
# Contract Summary
MD

  cat > "$repo/specs/plans/2000-01-01-covered.md" <<'MD'
# Plan With Acceptance

## Acceptance Criteria
- Login works
MD

  cat > "$repo/specs/plans/2099-01-01-uncovered.md" <<'MD'
# Plan With Uncovered Acceptance

## Acceptance Criteria
- Payment works
MD

  mkdir -p "$repo/artifacts/acceptance-ok"
  touch "$repo/artifacts/acceptance-ok/login-works.txt"

  cat > "$repo/context.yml" <<'YAML'
plan_file: specs/plans/2000-01-01-covered.md
evidence_dir: artifacts/acceptance-ok
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from QA --to SHIP_REVIEW --level L2 --context context.yml >/tmp/gstack-acceptance.out 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -eq 0 ]]
}

test_check_gates_rejects_invalid_level() {
  local repo
  repo="$(make_fixture)"

  set +e
  (cd "$repo" && ./governance/check-gates.sh --from IDEA --to DISCOVERY --level LX >/tmp/gstack-invalid-level.out 2>&1)
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
}

test_check_gates_rejects_missing_context_file() {
  local repo
  repo="$(make_fixture)"

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from TASK_DECOMPOSITION --to PLAN_CONFIRM --level L2 --context missing-context.yml >/tmp/gstack-missing-context.out 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
}

test_plan_confirm_blocks_when_context_plan_missing() {
  local repo
  repo="$(make_fixture)"

  cat > "$repo/specs/plans/2099-01-01-approved.md" <<'MD'
# Approved Plan

## Tasks
- [ ] Do another thing

## Approval
- [x] User confirmed plan
MD

  cat > "$repo/artifacts/workflow-state.md" <<'MD'
plan_confirmed: true
MD

  cat > "$repo/context.yml" <<'YAML'
plan_file: specs/plans/not-exists.md
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from TASK_DECOMPOSITION --to PLAN_CONFIRM --level L2 --context context.yml >/tmp/gstack-plan-missing.out 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
}

test_requirement_lock_logs_fallback_when_context_missing_spec() {
  local repo out
  repo="$(make_fixture)"
  out="/tmp/gstack-req-fallback.out"

  cat > "$repo/context-layer/specs/2099-01-01-approved-spec.md" <<'MD'
# Approved

## Requirements
- A

## Approval
- [x] confirmed
MD

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from DISCOVERY --to REQUIREMENT_LOCK --level L2 >"$out" 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -eq 0 ]]
  grep -q "fallback used: spec_file not set; discovering latest spec" "$out"
}

test_acceptance_check_logs_fallback_when_plan_not_set() {
  local repo out
  repo="$(make_fixture)"
  out="/tmp/gstack-acceptance-fallback.out"

  mkdir -p "$repo/specs/plans" "$repo/context-layer/specs"
  cat > "$repo/context-layer/specs/contract-summary.md" <<'MD'
# Contract Summary
MD

  cat > "$repo/specs/plans/2099-01-01-covered.md" <<'MD'
# Plan

## Acceptance Criteria
- Login works
MD
  mkdir -p "$repo/artifacts/acceptance"
  touch "$repo/artifacts/acceptance/login-works.txt"

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from QA --to SHIP_REVIEW --level L2 >"$out" 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -eq 0 ]]
  grep -q "fallback used: plan_file not set; selecting newest plan file" "$out"
}

test_context_plan_overrides_workflow_state_plan() {
  local repo out
  repo="$(make_fixture)"
  out="/tmp/gstack-context-overrides-plan.out"

  cat > "$repo/specs/plans/2000-01-01-bad.md" <<'MD'
# Bad Plan

## Tasks
- TBD fill this

## Approval
- [x] confirmed
MD

  cat > "$repo/specs/plans/2099-01-01-good.md" <<'MD'
# Good Plan

## Tasks
- [x] done

## Approval
- [x] confirmed
MD

  cat > "$repo/artifacts/workflow-state.md" <<'MD'
plan_file: specs/plans/2000-01-01-bad.md
MD

  cat > "$repo/context.yml" <<'YAML'
plan_file: specs/plans/2099-01-01-good.md
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from ARCH_REVIEW --to TASK_DECOMPOSITION --level L2 --context context.yml >"$out" 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -eq 0 ]]
}

test_context_level_overrides_workflow_state_level() {
  local repo out
  repo="$(make_fixture)"
  out="/tmp/gstack-context-overrides-level.out"

  mkdir -p "$repo/context-layer/specs"
  cat > "$repo/context-layer/specs/project-spec.md" <<'MD'
# project
MD
  cat > "$repo/context-layer/specs/architecture-spec.md" <<'MD'
# architecture
MD
  rm -f "$repo/context-layer/specs/api-spec.md"
  rm -f "$repo/context-layer/specs/test-spec.md"
  rm -f "$repo/context-layer/specs/constraints-spec.md"
  rm -f "$repo/context-layer/specs/domain-boundaries.md"

  cat > "$repo/artifacts/workflow-state.md" <<'MD'
level: L2
MD

  cat > "$repo/context.yml" <<'YAML'
level: L1
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from PLAN_CONFIRM --to CONTEXT_HYDRATION --level L2 --context context.yml >"$out" 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -eq 0 ]]
}

test_requirement_structure_soft_gate_warns_but_passes() {
  local repo out
  repo="$(make_fixture)"
  out="/tmp/gstack-requirement-structure-soft.out"

  cat > "$repo/context-layer/specs/2099-01-01-approval-only-spec.md" <<'MD'
# Approval Only

## Requirements
- A

## Approval
- [x] confirmed
MD

  cat > "$repo/context.yml" <<'YAML'
spec_file: context-layer/specs/2099-01-01-approval-only-spec.md
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from DISCOVERY --to REQUIREMENT_LOCK --level L2 --context context.yml >"$out" 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -eq 0 ]]
  grep -q "GATE_WARN:requirement-structure" "$out"
}

test_requirement_structure_passes_with_option_template() {
  local repo out
  repo="$(make_fixture)"
  out="/tmp/gstack-requirement-structure-pass.out"

  cat > "$repo/context-layer/specs/2099-01-01-structured-spec.md" <<'MD'
# Structured Requirement

## Problem
- Current onboarding is slow.

## Scope
- Improve first-run flow.

## Non-Goals
- No billing changes.

## Acceptance Criteria
- New user reaches first success in under 2 minutes.

## Option Comparison
### Option A
- Pros: quick
- Cons: limited
### Option B
- Pros: scalable
- Cons: more dev effort

## Decision
- Chosen Option: B
MD

  cat > "$repo/context.yml" <<'YAML'
spec_file: context-layer/specs/2099-01-01-structured-spec.md
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from DISCOVERY --to REQUIREMENT_LOCK --level L2 --context context.yml >"$out" 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -eq 0 ]]
  ! grep -q "GATE_WARN:requirement-structure" "$out"
}

test_design_tradeoff_soft_gate_warns_but_passes() {
  local repo out
  repo="$(make_fixture)"
  out="/tmp/gstack-design-tradeoff-soft.out"

  cat > "$repo/decision-layer/adr/ADR-999-soft-gate-test.md" <<'MD'
# ADR-999 Soft Gate Test

Status: Approved
Decision: proceed
MD

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from REQUIREMENT_LOCK --to ARCH_REVIEW --level L2 >"$out" 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -eq 0 ]]
  grep -q "GATE_WARN:design-tradeoff" "$out"
}

test_design_tradeoff_blocks_on_l3() {
  local repo out
  repo="$(make_fixture)"
  out="/tmp/gstack-design-tradeoff-l3.out"

  cat > "$repo/decision-layer/adr/ADR-998-l3-hard-test.md" <<'MD'
# ADR-998 L3 Hard Test

Status: Approved
Decision: proceed
MD

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from REQUIREMENT_LOCK --to ARCH_REVIEW --level L3 >"$out" 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -ne 0 ]]
  grep -q "GATE_FAILED:design-tradeoff" "$out"
}

test_requirement_design_coverage_soft_gate_warns_but_passes() {
  local repo out
  repo="$(make_fixture)"
  out="/tmp/gstack-req-design-coverage-soft.out"

  cat > "$repo/context-layer/specs/2099-01-01-coverage-spec.md" <<'MD'
# Coverage Spec

## Requirements
- unicorn telemetry panel

## Approval
- [x] confirmed
MD

  cat > "$repo/specs/plans/2099-01-01-coverage-plan.md" <<'MD'
# Coverage Plan

## Tasks
- [x] implement dashboard endpoint

## Approval
- [x] confirmed
MD

  cat > "$repo/artifacts/workflow-state.md" <<'MD'
plan_confirmed: true
MD

  cat > "$repo/context.yml" <<'YAML'
spec_file: context-layer/specs/2099-01-01-coverage-spec.md
plan_file: specs/plans/2099-01-01-coverage-plan.md
YAML

  set +e
  (
    cd "$repo" &&
      ./governance/check-gates.sh --from TASK_DECOMPOSITION --to PLAN_CONFIRM --level L2 --context context.yml >"$out" 2>&1
  )
  local code=$?
  set -e
  [[ "$code" -eq 0 ]]
  grep -q "GATE_WARN:requirement-design-coverage" "$out"
}

echo "=== governance runtime tests ==="
test_case "transition --json succeeds without gate" test_transition_json_without_gate
test_case "transition executes gate and blocks on failure" test_transition_runs_gate_and_blocks
test_case "validate-project catches YAML/JSON drift" test_project_validation_checks_yaml_json_sync
test_case "state machine matches L0-L3 complexity paths" test_state_machine_matches_complexity_paths
test_case "test-presence blocks source changes without tests" test_presence_blocks_source_without_test
test_case "plan-confirm uses context plan_file" test_plan_confirm_uses_context_plan_file
test_case "requirement-lock uses context spec_file" test_requirement_lock_uses_context_spec_file
test_case "task-decomposition uses context plan_file" test_task_decomposition_uses_context_plan_file
test_case "task-decomposition blocks TODO placeholder" test_task_decomposition_blocks_todo_placeholder
test_case "context-hydration uses context level" test_context_hydration_uses_context_level
test_case "acceptance-check uses context plan/evidence" test_acceptance_check_uses_context_files
test_case "check-gates rejects invalid level" test_check_gates_rejects_invalid_level
test_case "check-gates rejects missing context file" test_check_gates_rejects_missing_context_file
test_case "plan-confirm blocks missing context plan" test_plan_confirm_blocks_when_context_plan_missing
test_case "requirement-lock logs fallback when spec missing in context" test_requirement_lock_logs_fallback_when_context_missing_spec
test_case "acceptance-check logs fallback when plan missing in context" test_acceptance_check_logs_fallback_when_plan_not_set
test_case "context plan overrides workflow-state plan_file" test_context_plan_overrides_workflow_state_plan
test_case "context level overrides workflow-state level" test_context_level_overrides_workflow_state_level
test_case "requirement-structure soft gate warns but passes" test_requirement_structure_soft_gate_warns_but_passes
test_case "requirement-structure passes with option template" test_requirement_structure_passes_with_option_template
test_case "design-tradeoff soft gate warns but passes" test_design_tradeoff_soft_gate_warns_but_passes
test_case "design-tradeoff blocks on L3" test_design_tradeoff_blocks_on_l3
test_case "requirement-design-coverage soft gate warns but passes" test_requirement_design_coverage_soft_gate_warns_but_passes

echo ""
echo "结果: $passed passed, $failed failed"
[[ $failed -eq 0 ]]
