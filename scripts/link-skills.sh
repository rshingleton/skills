#!/usr/bin/env bash
set -euo pipefail

# Links all skills in this repo to ~/.agents/skills for OpenCode, Cursor, Copilot, Claude Code.
# Canonical remote: https://github.com/rshingleton/skills.git

REPO="$(cd "$(dirname "$0")/.." && pwd)"
link_to() {
  local dest="$1"
  local label="$2"

  if [ -L "$dest" ]; then
    resolved="$(readlink -f "$dest")"
    case "$resolved" in
      "$REPO"|"$REPO"/*)
        echo "error: $dest is a symlink into this repo ($resolved)." >&2
        echo "Remove it (rm \"$dest\") and re-run." >&2
        exit 1
        ;;
    esac
  fi

  mkdir -p "$dest"

  find "$REPO/skills" -name SKILL.md \
    -not -path '*/node_modules/*' \
    -not -path '*/deprecated/*' \
    -not -path '*/in-progress/*' \
    -not -path '*/personal/*' \
    -print0 |
  while IFS= read -r -d '' skill_md; do
    src="$(dirname "$skill_md")"
    name="$(basename "$src")"
    target="$dest/$name"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      rm -rf "$target"
    fi

    ln -sfn "$src" "$target"
    echo "  [$label] linked $name"
  done
}

link_to "$HOME/.agents/skills" "agents"
link_to "$HOME/.claude/skills" "claude"
