#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Remove legacy skill folders from ~/.agents/skills
# ============================================================================
# Matt Pocock renames, removed misc skills, and pre -it Doc Cycle names
# (implement, verify, audit-engineering).
#
# Dry-run (default):
#   bash scripts/cleanup-legacy-skills.sh
#
# Delete:
#   bash scripts/cleanup-legacy-skills.sh --yes
#
# One-liner (VPN or on-site):
#   bash <(curl -fsSL 'https://raw.githubusercontent.com/rshingleton/skills/main/scripts/cleanup-legacy-skills.sh') --yes
#
# With install:
#   CLEANUP_LEGACY=1 bash <(curl -fsSL '.../skills.sh?at=refs%2Fheads%2Fmain')
# ============================================================================

SKILLS_DEST="${SKILLS_DEST:-$HOME/.agents/skills}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIST_FILE="${LEGACY_SKILLS_LIST:-$SCRIPT_DIR/legacy-skills.txt}"

YES=0
for arg in "$@"; do
  case "$arg" in
    --yes|-y) YES=1 ;;
    --help|-h)
      sed -n '1,20p' "$0"
      exit 0
      ;;
  esac
done

read_legacy_names() {
  if [ -f "$LIST_FILE" ]; then
    grep -v '^[[:space:]]*#' "$LIST_FILE" | grep -v '^[[:space:]]*$' || true
    return
  fi
  # Fallback when script is piped via curl without legacy-skills.txt alongside
  cat <<'EOF'
setup-matt-pocock-skills
to-prd
to-issues
implement
verify
audit-engineering
git-guardrails-claude-code
migrate-to-shoehorn
scaffold-exercises
setup-pre-commit
qa
ubiquitous-language
design-an-interface
request-refactor-plan
EOF
}

echo "==> Legacy skills cleanup"
echo "    Target: $SKILLS_DEST"
echo "    Mode:   $([ "$YES" -eq 1 ] && echo 'DELETE' || echo 'dry-run (pass --yes to delete)')"
echo ""

if [ ! -d "$SKILLS_DEST" ]; then
  echo "Nothing to do — $SKILLS_DEST does not exist."
  exit 0
fi

removed=0
missing=0

while IFS= read -r name; do
  target="$SKILLS_DEST/$name"
  if [ ! -e "$target" ]; then
    missing=$((missing + 1))
    continue
  fi

  if [ -L "$target" ]; then
    kind="symlink -> $(readlink "$target")"
  elif [ -d "$target" ]; then
    kind="directory"
  else
    kind="file"
  fi

  if [ "$YES" -eq 1 ]; then
    rm -rf "$target"
    echo "  removed $name ($kind)"
  else
    echo "  would remove $name ($kind)"
  fi
  removed=$((removed + 1))
done < <(read_legacy_names)

echo ""
if [ "$removed" -eq 0 ]; then
  echo "No legacy skill folders found under $SKILLS_DEST."
elif [ "$YES" -eq 0 ]; then
  echo "Found $removed legacy folder(s). Re-run with --yes to delete."
  echo ""
  echo "  bash scripts/cleanup-legacy-skills.sh --yes"
else
  echo "Removed $removed legacy folder(s). ($missing were not present.)"
  echo ""
  echo "Install or refresh internal skills:"
  echo "  bash <(curl -fsSL 'https://raw.githubusercontent.com/rshingleton/skills/main/scripts/skills.sh')"
fi
