#!/usr/bin/env bash
# Shim — canonical jira-helpers.sh lives with setup-internal-skills.
# Keeps stable path for skills.sh, README curl docs, and app repos.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Source this script instead of executing it:" >&2
  echo "  source scripts/jira-helpers.sh" >&2
  exit 1
fi

_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=skills/engineering/setup-internal-skills/scripts/jira-helpers.sh
source "$_REPO_ROOT/skills/engineering/setup-internal-skills/scripts/jira-helpers.sh"
