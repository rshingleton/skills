#!/usr/bin/env bash
# Test for check-skill-calls.sh against a scratch repo.
#
# Usage:
#   bash scripts/check-skill-calls.test.sh
#
# Exits 0 if every check passes, 1 otherwise.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
CHECK="$REPO_ROOT/scripts/check-skill-calls.sh"

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT

fails=0
check() {
  local desc="$1"
  shift
  if "$@"; then
    echo "PASS: $desc"
  else
    echo "FAIL: $desc"
    fails=$((fails + 1))
  fi
}
contains() { [[ "$1" == *"$2"* ]]; }
lacks() { [[ "$1" != *"$2"* ]]; }

root="$SCRATCH/repo"
mkdir -p "$root/.claude-plugin" "$root/skills/engineering/caller" \
  "$root/skills/engineering/shipped" "$root/skills/engineering/unlisted" \
  "$root/skills/productivity/second"
cat >"$root/.claude-plugin/plugin.json" <<'EOF'
{ "skills": [
  "./skills/engineering/caller",
  "./skills/engineering/shipped",
  "./skills/productivity/second"
] }
EOF
cat >"$root/skills/engineering/caller/SKILL.md" <<'EOF'
Call the Skill tool with "shipped".
Then call the Skill tool twice, for "second" and
"unlisted", and keep going.
calling the Skill tool with `ghost` here.
1. Merge, calling the Skill tool with
   `shipped` on conflict.
EOF

set +e
out="$(bash "$CHECK" "$root" 2>"$SCRATCH/err")"
status=$?
set -e
err="$(cat "$SCRATCH/err")"

check "exits 1 when a called skill is missing" test "$status" -eq 1
check "lowercase call with backticks: ghost missing under skills/" \
  contains "$err" "MISSING under skills/: ghost"
check "second name of a wrapped twice-for call: unlisted not in plugin.json" \
  contains "$err" "MISSING from plugin.json: unlisted"
check "missing names go to stderr, not stdout" lacks "$out" "MISSING"
check "shipped skill passes" lacks "$err" ": shipped "
check "first name of twice-for passes" lacks "$err" ": second "
check "counts all five calls, indented wrap included" contains "$out" "5 calls checked, 2 missing."

mkdir -p "$root/skills/misc/ghost"
more='"./skills/productivity/second", "./skills/engineering/unlisted", "./skills/misc/ghost"'
sed -i.bak "s|\"./skills/productivity/second\"|$more|" "$root/.claude-plugin/plugin.json"
check "exits 0 when every called skill ships" bash "$CHECK" "$root"

if [ "$fails" -ne 0 ]; then
  echo "$fails check(s) failed."
  exit 1
fi
echo "All checks passed."
