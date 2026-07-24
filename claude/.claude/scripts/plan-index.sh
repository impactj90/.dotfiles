#!/usr/bin/env bash
# Index of implementation plans, grouped by status.
#
#   plan-index.sh                 # everything, grouped
#   plan-index.sh ready           # only one status
#   plan-index.sh none            # only plans with no status yet
#   plan-index.sh -d <dir>        # a different plans directory
#
# Statuses: draft -> ready -> implementing -> implemented (or abandoned).
# Legacy spellings (done, complete, completed, ready-for-implementation, ...)
# fold into the canonical set, so old plans land in the right group without
# being rewritten.
set -uo pipefail

dir=""
filter=""
while [ $# -gt 0 ]; do
  case "$1" in
    -d|--dir)  dir="${2:-}"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *)         filter="$1"; shift ;;
  esac
done

if [ -z "$dir" ]; then
  root=$(git rev-parse --show-toplevel 2>/dev/null) || root="$PWD"
  dir="$root/thoughts/shared/plans"
fi

if [ ! -d "$dir" ]; then
  echo "No plans directory found at: $dir" >&2
  exit 1
fi

shopt -s nullglob
files=("$dir"/*.md)
shopt -u nullglob
if [ ${#files[@]} -eq 0 ]; then
  echo "No plans in $dir"
  exit 0
fi

# One awk pass over every plan: status, date, title, filename.
raw=$(awk '
  function flush(   base) {
    if (prev == "") return
    base = prev; sub(/^.*\//, "", base)
    if (dt == "") {
      if (match(base, /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) dt = substr(base, 1, 10)
      else dt = "----------"
    }
    if (ti == "") { ti = base; sub(/\.md$/, "", ti) }
    gsub(/["]/, "", st); gsub(/["]/, "", dt)
    sub(/[[:space:]].*$/, "", st)          # "implemented (Phasen 1-6)" -> "implemented"
    # "-" placeholder: a leading empty field would be swallowed by read, since
    # tab counts as IFS whitespace.
    print (st == "" ? "-" : tolower(st)) "\t" dt "\t" ti "\t" base
  }
  FNR == 1 {
    flush()
    prev = FILENAME; fm = 0; st = ""; dt = ""; ti = ""
    if ($0 ~ /^---[[:space:]]*$/) { fm = 1 }
    next
  }
  FNR > 40 { nextfile }
  fm && /^---[[:space:]]*$/       { fm = 0; next }
  fm && /^status:/ && st == ""    { s = $0; sub(/^status:[[:space:]]*/, "", s); st = s; next }
  fm && /^date:/   && dt == ""    { d = $0; sub(/^date:[[:space:]]*/, "", d);   dt = d; next }
  !fm && /^# / && ti == ""        { t = $0; sub(/^#[[:space:]]*/, "", t);       ti = t }
  END { flush() }
' "${files[@]}")

normalize() {
  case "$1" in
    draft)                                              echo draft ;;
    ready|ready-for-implementation|ready-for-review|approved) echo ready ;;
    implementing|in-progress|wip)                       echo implementing ;;
    implemented*|done*|complete*|completed*|released*|shipped*) echo implemented ;;
    abandoned|dropped|superseded|obsolete)              echo abandoned ;;
    -|"")                                               echo none ;;
    *)                                                  echo other ;;
  esac
}

rows=""
while IFS=$'\t' read -r st dt ti base; do
  [ -n "$base" ] || continue
  rows+="$(normalize "$st")"$'\t'"$dt"$'\t'"$ti"$'\t'"$base"$'\n'
done <<< "$raw"

echo "Plans in $dir  (${#files[@]} total)"

shown=0
for group in draft ready implementing implemented abandoned other none; do
  if [ -n "$filter" ] && [ "$filter" != "$group" ]; then
    continue
  fi
  block=$(printf '%s' "$rows" | awk -F'\t' -v g="$group" '$1 == g' | sort -t$'\t' -k2,2r)
  [ -n "$block" ] || continue
  count=$(printf '%s\n' "$block" | grep -c . || true)
  shown=$((shown + count))
  echo
  echo "-- ${group} (${count})"
  printf '%s\n' "$block" | awk -F'\t' '{ printf "   %s  %s\n              %s\n", $2, $3, $4 }'
done

if [ -n "$filter" ] && [ "$shown" -eq 0 ]; then
  echo
  echo "-- ${filter} (0)"
fi

if [ -z "$filter" ]; then
  echo
  echo "Filter: plan-index.sh <draft|ready|implementing|implemented|abandoned|other|none>"
fi
