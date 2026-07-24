#!/usr/bin/env bash
# PreToolUse / Bash guard.
#
# Blocks whole-project builds, lints and typechecks. These exhaust memory on
# this machine and take the desktop down with them; CI and the deploy platform
# verify them instead.
#
# Escape hatch: put ALLOW_HEAVY=1 anywhere in the command to run it anyway.
#
# Fails open: any unexpected condition exits 0 (command allowed).
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""' 2>/dev/null) || exit 0

if [ -z "$cmd" ]; then
  exit 0
fi

# Explicit override
case "$cmd" in
  *ALLOW_HEAVY=1*) exit 0 ;;
esac

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

matches() {
  printf '%s' "$cmd" | grep -qE "$1"
}

SEP='(^|[[:space:];&|(])'
PM='(pnpm|npm|yarn|bun|make)'
END='([[:space:]]|$|[;&|)])'

if matches "${SEP}${PM}([[:space:]]+run)?[[:space:]]+build${END}"; then
  deny "Blocked: whole-project build. It exhausts memory on this machine (the desktop goes down with it). The build is verified by CI / the deploy platform, not locally. If you genuinely need it here, re-run with ALLOW_HEAVY=1 as a prefix."
fi

if matches "${SEP}${PM}([[:space:]]+run)?[[:space:]]+lint${END}"; then
  deny "Blocked: whole-project lint. Lint only what you changed: npx eslint <file> [<file> ...]. If you genuinely need the full run, re-run with ALLOW_HEAVY=1 as a prefix."
fi

if matches "${SEP}${PM}([[:space:]]+run)?[[:space:]]+(typecheck|type-check)${END}"; then
  deny "Blocked: whole-project typecheck. It OOMs. Typecheck the diff via a scratch tsconfig instead: NODE_OPTIONS=--max-old-space-size=4096 npx tsc --noEmit -p <scratch-tsconfig>. Exclude files that pull in the full router/hooks type graph - those are verified by CI. If you genuinely need the full run, re-run with ALLOW_HEAVY=1 as a prefix."
fi

# Bare `tsc --noEmit` (no -p/--project) walks the whole project.
if matches "${SEP}(npx[[:space:]]+)?tsc${END}" && matches '[-][-]noEmit' \
   && ! matches '([-]p[[:space:]]|[-][-]project[[:space:]])'; then
  deny "Blocked: unscoped 'tsc --noEmit' typechecks the entire project and OOMs. Point it at a scratch tsconfig with -p <file>. Override with ALLOW_HEAVY=1 as a prefix."
fi

if matches "${SEP}(npx[[:space:]]+)?next[[:space:]]+build${END}"; then
  deny "Blocked: 'next build' exhausts memory on this machine. Let the deploy platform build. Override with ALLOW_HEAVY=1 as a prefix."
fi

exit 0
