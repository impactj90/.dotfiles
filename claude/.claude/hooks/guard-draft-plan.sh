#!/usr/bin/env bash
# PreToolUse / Edit|Write|MultiEdit guard.
#
# If the plan referenced in this session is still `status: draft`, ask before
# writing code. The point is the approval gate: a draft plan has not been read
# and signed off yet, and code written against it is the expensive kind of
# mistake to unwind.
#
# Decision is "ask", not "deny" - the plan-detection is a heuristic, so you get
# a prompt you can wave through rather than a wall. It stops firing as soon as
# the plan's frontmatter says `status: ready`.
#
# Fails open: any unexpected condition exits 0 (edit allowed silently).
set -uo pipefail

# Escape hatch for non-interactive runs (headless `claude -p`, grind phases,
# cron). Nobody is there to answer an "ask", so the gate would deadlock the
# run instead of guarding it. Export PLAN_GATE_OFF=1 in those wrappers.
if [ "${PLAN_GATE_OFF:-}" = "1" ]; then
  exit 0
fi

input=$(cat)

transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""' 2>/dev/null) || exit 0
if [ -z "$transcript" ] || [ ! -f "$transcript" ]; then
  exit 0
fi

target=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""' 2>/dev/null) || exit 0

# Never gate the documents themselves - you must be able to edit the plan.
case "$target" in
  */thoughts/*|thoughts/*) exit 0 ;;
esac

# Most recently mentioned plan document in this session.
plan=$(grep -oE 'thoughts/[A-Za-z0-9_/.-]*plans/[A-Za-z0-9_.-]+\.md' "$transcript" 2>/dev/null | tail -1)
if [ -z "$plan" ]; then
  exit 0
fi

cwd=$(printf '%s' "$input" | jq -r '.cwd // ""' 2>/dev/null) || exit 0
if [ -n "$cwd" ] && [ -f "$cwd/$plan" ]; then
  plan="$cwd/$plan"
fi
if [ ! -f "$plan" ]; then
  exit 0
fi

# First `status:` inside the leading frontmatter block.
status=$(awk '
  /^---[[:space:]]*$/ { n++; next }
  n == 1 && /^status:/ { sub(/^status:[[:space:]]*/, ""); print; exit }
' "$plan" 2>/dev/null)

case "$status" in
  draft)
    jq -n --arg p "$plan" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "ask",
        permissionDecisionReason: ("The plan for this session is still status: draft - " + $p + ". Approve it and set status: ready in its frontmatter before implementing, or confirm this edit is unrelated to that plan.")
      }
    }'
    ;;
esac

exit 0
