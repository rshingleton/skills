#!/usr/bin/env bash
# Shim — canonical loader lives with setup-internal-skills (Jira setup skill).
# Keeps stable path for skills.sh, README curl docs, and app repos that already source scripts/.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Source this script instead of executing it:" >&2
  echo "  source scripts/load-jira-env.sh" >&2
  exit 1
fi

_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=skills/engineering/setup-internal-skills/scripts/load-jira-env.sh
source "$_REPO_ROOT/skills/engineering/setup-internal-skills/scripts/load-jira-env.sh"
