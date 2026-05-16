#!/usr/bin/env bash
# Load Jira env into the current shell (JIRA_BASE_URL, JIRA_API_TOKEN, JIRA_PROJECT_KEY,
# and optional JIRA_DEFAULT_EPIC, JIRA_ASSIGNEE, JIRA_WATCHER_IGNORE, JIRA_WATCHER_USERNAME, JIRA_EMAIL — see repo .env.example).
#
# Canonical copy — bundled with setup-internal-skills / issue-tracker-jira.md.
#
# Usage (must source, not execute):
#   source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh   # from ai-skills clone
#   source ~/.local/share/ai-skills/skills/engineering/setup-internal-skills/scripts/load-jira-env.sh
#   source scripts/load-jira-env.sh   # repo-root shim (same behavior)
#
# Search order (first file found wins):
#   1. $JIRA_ENV_FILE (explicit override)
#   2. ./.env in the current working directory (application repo)
#   3. ~/.agents/.env
#   4. ~/.config/ai-skills/.env
#
# Set JIRA_ENV_VERBOSE=1 to print which file was loaded.

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Source this script instead of executing it:" >&2
  echo "  source scripts/load-jira-env.sh" >&2
  exit 1
fi

_jira_env_loaded=""

_load_jira_env_file() {
  local f="$1"
  [ -f "$f" ] || return 1
  set -a
  # shellcheck disable=SC1090
  source "$f"
  set +a
  _jira_env_loaded="$f"
  return 0
}

if [ -n "${JIRA_ENV_FILE:-}" ]; then
  _load_jira_env_file "$JIRA_ENV_FILE" || true
else
  for candidate in \
    "${PWD}/.env" \
    "${HOME}/.agents/.env" \
    "${HOME}/.config/ai-skills/.env"; do
    if _load_jira_env_file "$candidate"; then
      break
    fi
  done
fi

if [ -n "${_jira_env_loaded}" ] && [ "${JIRA_ENV_VERBOSE:-0}" = "1" ]; then
  echo "Loaded Jira env from ${_jira_env_loaded}" >&2
fi
