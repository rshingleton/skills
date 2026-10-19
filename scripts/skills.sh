#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Internal Skills Installer
# ============================================================================
# Clones the skills repo and symlinks skills into ~/.agents/skills
# (OpenCode/Cursor/Gemini) and ~/.claude/skills (Claude Code).
#
# Canonical repo: https://github.com/rshingleton/skills.git
#
# One-liner:
#   bash <(curl -fsSL 'https://raw.githubusercontent.com/rshingleton/skills/main/scripts/skills.sh')
#
# Installing from a mirror: set AI_SKILLS_REPO to its clone URL on the first
# run. Later runs update from the existing clone's origin. If the clone has an
# ORG.md, it documents the mirror's own install command.
#
# From a clone:
#   git clone https://github.com/rshingleton/skills.git
#   bash skills/scripts/skills.sh
#
# Every run prunes stale links after linking: a symlink in either target whose
# skill is gone or now sits under deprecated/ is removed and reported.
# --cleanup-legacy additionally removes the legacy folders named in
# scripts/legacy-skills.txt, real directories included.
# ============================================================================

REPO_URL="${AI_SKILLS_REPO:-https://github.com/rshingleton/skills.git}"
DEFAULT_BRANCH="${DEFAULT_BRANCH:-main}"
SKILLS_DEST="${SKILLS_DEST:-$HOME/.agents/skills}"
CLAUDE_SKILLS_DEST="${CLAUDE_SKILLS_DEST:-$HOME/.claude/skills}"
CLONE_DIR="${SKILLS_CLONE_DIR:-$HOME/.local/share/ai-skills}"
CLEANUP_LEGACY="${CLEANUP_LEGACY:-0}"

usage() {
  cat <<'EOF'
Usage: skills.sh [--cleanup-legacy] [--help]

Clones or updates the skills repo and links its promoted skills into
~/.agents/skills and ~/.claude/skills.

Every run then prunes stale links automatically: symlinks whose skill is gone
or now sits under deprecated/ are removed and reported. Real directories and
links to live skills are left alone.

  --cleanup-legacy  Also remove the legacy skill folders listed in
                    scripts/legacy-skills.txt (same as CLEANUP_LEGACY=1).
  --help            Show this help.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --cleanup-legacy) CLEANUP_LEGACY=1 ;;
    --help|-h)
      usage
      exit 0
      ;;
  esac
done

echo "==> Internal Skills Installer"
echo "    OpenCode/Cursor target:  $SKILLS_DEST"
echo "    Claude Code target:      $CLAUDE_SKILLS_DEST"
echo "    Clone cache:             $CLONE_DIR"
echo ""

mkdir -p "$(dirname "$CLONE_DIR")"

if [ -d "$CLONE_DIR/.git" ]; then
  echo "==> Updating clone at $CLONE_DIR (branch: $DEFAULT_BRANCH)..."
  git -C "$CLONE_DIR" fetch --depth 1 origin "$DEFAULT_BRANCH"
  git -C "$CLONE_DIR" reset --hard "origin/$DEFAULT_BRANCH"
  git -C "$CLONE_DIR" clean -fd
else
  echo "==> Cloning $REPO_URL (branch: $DEFAULT_BRANCH)..."
  git clone --depth 1 -b "$DEFAULT_BRANCH" "$REPO_URL" "$CLONE_DIR"
fi

if [ "$CLEANUP_LEGACY" = "1" ]; then
  echo "==> Removing legacy skill folders..."
  bash "$CLONE_DIR/scripts/cleanup-legacy-skills.sh" --yes
  echo ""
fi

link_skills() {
  local dest="$1"
  local label="$2"
  mkdir -p "$dest"
  find "$CLONE_DIR/skills" -name SKILL.md \
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

# Remove symlinks whose target is gone (wherever it pointed) or resolves under
# the clone's skills/deprecated/. Real directories, live links into other
# checkouts, and live links to promoted skills are left alone.
prune_stale_links() {
  local dest="$1"
  local label="$2"
  local clone_real link resolved
  [ -d "$dest" ] || return 0
  clone_real="$(cd "$CLONE_DIR" && pwd -P)" || return 1
  for link in "$dest"/*; do
    [ -L "$link" ] || continue
    if [ ! -e "$link" ]; then
      rm -f "$link"
      echo "  [$label] pruned $(basename "$link"): target gone"
      continue
    fi
    resolved="$(cd "$link" 2>/dev/null && pwd -P)" || continue
    case "$resolved" in
      "$clone_real"/skills/deprecated/*)
        rm -f "$link"
        echo "  [$label] pruned $(basename "$link"): deprecated"
        ;;
    esac
  done
}

echo "==> Linking skills..."
link_skills "$SKILLS_DEST" "agents"
link_skills "$CLAUDE_SKILLS_DEST" "claude"

echo "==> Pruning stale links..."
prune_stale_links "$SKILLS_DEST" "agents"
prune_stale_links "$CLAUDE_SKILLS_DEST" "claude"

echo ""
echo "==> Install complete."
echo "    OpenCode/Cursor:  $SKILLS_DEST"
echo "    Claude Code:      $CLAUDE_SKILLS_DEST"
echo "    Source clone:     $CLONE_DIR"
echo ""
echo "==> Next steps:"
if [ -f "$CLONE_DIR/scripts/load-jira-env.sh" ]; then
  # Silent: install is not the place to block on an interactive credential
  # prompt. JIRA_ENV_SILENT suppresses load-jira-env.sh's `read` fallback.
  # shellcheck source=/dev/null
  JIRA_ENV_SILENT=1 source "$CLONE_DIR/scripts/load-jira-env.sh" 2>/dev/null || true
fi
if [ -n "${JIRA_API_TOKEN:-}" ]; then
  echo "  1. Jira credentials: loaded (${_jira_env_loaded:-from environment})"
else
  echo "  1. Jira credentials: copy .env.example to ~/.config/ai-skills/.env"
  echo "       then (from any repo): source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh"
  echo "     (or export JIRA_BASE_URL, JIRA_API_TOKEN, JIRA_PROJECT_KEY)"
fi
echo "  2. Run /setup-internal-skills in each application repo."
echo "  3. Re-run this script anytime to refresh skills from $DEFAULT_BRANCH."
