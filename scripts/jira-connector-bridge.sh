#!/usr/bin/env bash
# Shim — canonical bridge lives with setup-internal-skills (Jira setup skill).
# Keeps a stable path for repo-dev scripts, README/docs, and the test suite.
#
# Consumers in app repos should prefer:
#   source ~/.agents/skills/setup-internal-skills/scripts/jira-connector-bridge.sh
# This shim is for ai-skills repo developers and backward compatibility.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Source this script instead of executing it:" >&2
  echo "  source scripts/jira-connector-bridge.sh" >&2
  exit 1
fi

_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=skills/engineering/setup-internal-skills/scripts/jira-connector-bridge.sh
source "$_REPO_ROOT/skills/engineering/setup-internal-skills/scripts/jira-connector-bridge.sh"
