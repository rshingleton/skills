#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Internal Skills Installer
# ============================================================================
# Clones from Bitbucket (VPN or on-site; no auth for read) and symlinks skills
# into ~/.agents/skills.
#
# Canonical repo: https://github.com/rshingleton/skills.git
#
# One-liner (VPN or on-site):
#   bash <(curl -fsSL 'https://raw.githubusercontent.com/rshingleton/skills/main/scripts/skills.sh')
#
# From a clone:
#   git clone https://github.com/rshingleton/skills.git
#   bash ai-skills/scripts/skills.sh
# ============================================================================

REPO_URL="https://github.com/rshingleton/skills.git"
RAW_INSTALL_URL="https://raw.githubusercontent.com/rshingleton/skills/main/scripts/skills.sh"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
SKILLS_DEST="${SKILLS_DEST:-$HOME/.agents/skills}"
CLONE_DIR="${SKILLS_CLONE_DIR:-$HOME/.local/share/ai-skills}"

echo "==> Internal Skills Installer"
echo "    Install target: $SKILLS_DEST"
echo "    Clone cache:    $CLONE_DIR"
echo ""

mkdir -p "$(dirname "$CLONE_DIR")"

if [ -d "$CLONE_DIR/.git" ]; then
  echo "==> Updating clone at $CLONE_DIR (branch: $DEFAULT_BRANCH)..."
  git -C "$CLONE_DIR" fetch --depth 1 origin "$DEFAULT_BRANCH"
  git -C "$CLONE_DIR" checkout -B "$DEFAULT_BRANCH" "origin/$DEFAULT_BRANCH"
else
  echo "==> Cloning $REPO_URL (branch: $DEFAULT_BRANCH)..."
  git clone --depth 1 -b "$DEFAULT_BRANCH" "$REPO_URL" "$CLONE_DIR"
fi

mkdir -p "$SKILLS_DEST"

find "$CLONE_DIR/skills" -name SKILL.md \
  -not -path '*/node_modules/*' \
  -not -path '*/deprecated/*' \
  -not -path '*/in-progress/*' \
  -not -path '*/personal/*' \
  -print0 |
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
echo "    Source clone:        $CLONE_DIR"
echo ""
echo "==> Next steps:"
echo "  1. Set Jira env vars required by the skills:"
echo "       export JIRA_BASE_URL=https://jira.example.com"
echo "       export JIRA_API_TOKEN=<your-jira-pat>"
echo "       export JIRA_PROJECT_KEY=MT"
echo "  2. Run /setup-internal-skills in your agent to configure the issue tracker"
echo "     and triage labels for this repo."
echo "  3. Re-run this script anytime to refresh skills from $DEFAULT_BRANCH."
