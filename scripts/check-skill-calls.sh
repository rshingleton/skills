#!/usr/bin/env bash
# Check that every skill a shipped skill calls also ships (ADR-0010 decision 4).
#
# Usage:
#   bash scripts/check-skill-calls.sh [repo-root]
#
# Scans the Markdown files of every skill listed in .claude-plugin/plugin.json
# for "call the Skill tool with X" and "call the Skill tool twice, for X and Y"
# (any case, calls/calling too, names quoted or backticked, wrapped across
# lines). Each named skill must exist as a directory under skills/ and be
# listed in plugin.json. Prints each missing name; exits 1 if any, else 0.

set -euo pipefail

ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)}"
PLUGIN="$ROOT/.claude-plugin/plugin.json"

shipped="$(grep -oE '"\./skills/[^"]+"' "$PLUGIN" | tr -d '"' | sed 's|^\./||')"

NAME="[\"\`][a-z0-9:-]+[\"\`]"
CALL="call(s|ing)? the skill tool (twice, )?(with|for) $NAME( and $NAME)?"

called=""
while IFS= read -r skill_dir; do
  [ -n "$skill_dir" ] || continue
  while IFS= read -r -d '' file; do
    # Join wrapped lines and squeeze indentation so a call split across lines still matches.
    names=()
    while IFS= read -r name; do
      [ -n "$name" ] && names+=("$name")
    done < <(tr '\n\t' '  ' <"$file" | tr -s ' ' | grep -oiE "$CALL" |
      grep -oE "$NAME" | tr -d "\"\`" || true)
    for name in "${names[@]+"${names[@]}"}"; do
      called="$called$name $skill_dir/${file#"$ROOT/$skill_dir/"}"$'\n'
    done
  done < <(find "$ROOT/$skill_dir" -name '*.md' -print0)
done <<<"$shipped"

missing=0
checked=0
while IFS=' ' read -r name where; do
  [ -n "$name" ] || continue
  checked=$((checked + 1))
  dir="$(find "$ROOT/skills" -mindepth 2 -maxdepth 2 -type d -name "$name" \
    -not -path '*/deprecated/*' | head -n 1)"
  if [ -z "$dir" ]; then
    echo "MISSING under skills/: $name (called from $where)" >&2
    missing=$((missing + 1))
  elif ! grep -qx "${dir#"$ROOT/"}" <<<"$shipped"; then
    echo "MISSING from plugin.json: $name (called from $where)" >&2
    missing=$((missing + 1))
  fi
done <<<"$called"

echo "$checked calls checked, $missing missing."
[ "$missing" -eq 0 ]
