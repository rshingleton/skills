#!/usr/bin/env bash
# Integration test for the stale-link prune in link-skills.sh.
#
# Usage:
#   bash scripts/link-skills.test.sh
#
# Runs link-skills.sh against a temporary HOME, never the real ~/.claude or
# ~/.agents. Exits 0 if every check passes, 1 otherwise.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
LINKER="$REPO_ROOT/scripts/link-skills.sh"

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

is_link() { [ -L "$1" ]; }
is_gone() { [ ! -e "$1" ] && [ ! -L "$1" ]; }
is_dir() { [ -d "$1" ] && [ ! -L "$1" ]; }
contains() { [[ "$1" == *"$2"* ]]; }
lacks() { [[ "$1" != *"$2"* ]]; }

test_home="$SCRATCH/home"
external="$SCRATCH/other-checkout/skills/in-progress/outside-skill"
mkdir -p "$external"

for dest in "$test_home/.claude/skills" "$test_home/.agents/skills"; do
  mkdir -p "$dest/real-dir"
  ln -s "$REPO_ROOT/skills/engineering/no-such-skill" "$dest/dead-skill"
  ln -s "$REPO_ROOT/skills/deprecated/diagnose" "$dest/diagnose"
  ln -s "$REPO_ROOT/skills/engineering/tdd" "$dest/tdd"
  ln -s "$external" "$dest/outside-skill"
done

first="$(HOME="$test_home" bash "$LINKER")"

for dest in "$test_home/.claude/skills" "$test_home/.agents/skills"; do
  check "dead link pruned ($dest)" is_gone "$dest/dead-skill"
  check "deprecated link pruned ($dest)" is_gone "$dest/diagnose"
  check "live link kept ($dest)" is_link "$dest/tdd"
  check "external link kept ($dest)" is_link "$dest/outside-skill"
  check "real directory kept ($dest)" is_dir "$dest/real-dir"
  check "dead link reported ($dest)" contains "$first" "pruned dead-skill ($dest)"
  check "deprecated link reported ($dest)" contains "$first" "pruned diagnose ($dest)"
done
check "external link not reported" lacks "$first" "pruned outside-skill"
check "real directory not reported" lacks "$first" "pruned real-dir"

second="$(HOME="$test_home" bash "$LINKER")"
check "second run prunes nothing" lacks "$second" "pruned "

if [ "$fails" -gt 0 ]; then
  echo "$fails check(s) failed"
  exit 1
fi
echo "all checks passed"
