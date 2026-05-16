#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Internal Skills Installer — Private Bitbucket Fork
# ============================================================================
# Clones from the internal Bitbucket repo via HTTPS (VPN required, no auth).
#
# Canonical repo: https://github.com/rshingleton/skills.git
#
# Usage (from a clone):
#   git clone https://github.com/rshingleton/skills.git
#   bash ai-skills/scripts/skills.sh
# ============================================================================

REPO_URL="https://github.com/rshingleton/skills.git"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
SKILLS_DEST="${SKILLS_DEST:-$HOME/.agents/skills}"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "==> Internal Skills Installer"
echo "    Install target: $SKILLS_DEST"
echo ""

# --- Clone (VPN required, no auth needed) ---

echo "==> Cloning $REPO_URL (branch: $DEFAULT_BRANCH)..."
git clone --depth 1 -b "$DEFAULT_BRANCH" "$REPO_URL" "$TMPDIR/skills"

# --- Install ---

mkdir -p "$SKILLS_DEST"

find "$TMPDIR/skills/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -not -path '*/in-progress/*' -not -path '*/personal/*' -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$SKILLS_DEST/$name"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    rm -rf "$target"
  fi

  ln -sfn "$src" "$target"
  echo "  linked $name"
done

echo ""
echo "==> Install complete."
echo "    Skills installed to: $SKILLS_DEST"
echo ""
echo "==> Next steps:"
echo "  1. Set Jira env vars required by the skills:"
echo "       export JIRA_BASE_URL=https://jira.example.com"
echo "       export JIRA_API_TOKEN=<your-jira-pat>"
echo "       export JIRA_PROJECT_KEY=MT"
echo "  2. Run /setup-internal-skills in your agent to configure the issue tracker"
echo "     and triage labels for this repo."
echo "  3. The default primary branch is 'main'."
