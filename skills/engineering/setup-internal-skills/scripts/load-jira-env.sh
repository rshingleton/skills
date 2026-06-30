#!/usr/bin/env bash
# Load Jira env into the current shell (JIRA_BASE_URL, JIRA_API_TOKEN, JIRA_PROJECT_KEY,
# and optional JIRA_DEFAULT_EPIC, JIRA_ASSIGNEE, JIRA_WATCHER_IGNORE, JIRA_WATCHER_USERNAME, JIRA_EMAIL — see repo .env.example).
#
# Canonical copy — bundled with setup-internal-skills / issue-tracker-jira.md.
#
# Usage (must source, not execute):
#   source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh   # consumer repos (recommended)
#   source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh   # from ai-skills clone
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
    "${HOME}/.config/env" \
    "${HOME}/.config/ai-skills/.env"; do
    if _load_jira_env_file "$candidate"; then
      break
    fi
  done
fi

# Source Jira helper functions from the same directory.
_JIRA_HELPERS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$_JIRA_HELPERS_DIR/jira-helpers.sh" ]; then
  # shellcheck source=scripts/jira-helpers.sh
  source "$_JIRA_HELPERS_DIR/jira-helpers.sh"
fi

if [ -n "${_jira_env_loaded}" ] && [ "${JIRA_ENV_VERBOSE:-0}" = "1" ]; then
  echo "Loaded Jira env from ${_jira_env_loaded}" >&2
fi

# Validate required env vars. If missing and interactive, prompt for setup.
if ! _jira_require_env 2>/dev/null; then
  if [ -n "${JIRA_ENV_SILENT:-}" ]; then
    : # caller suppressed prompts — exit silently
  elif [ -t 0 ] && [ -t 1 ]; then
    echo "" >&2
    echo "Jira credentials are needed for issue operations." >&2
    echo "Enter values or press Ctrl-C to skip (non-blocking)." >&2
    echo "" >&2
    echo -n "JIRA_BASE_URL [https://jira.example.com]: " >&2
    read -r input_url
    JIRA_BASE_URL="${input_url:-https://jira.example.com}"
    echo -n "JIRA_API_TOKEN (input hidden): " >&2
    read -rs input_token
    echo "" >&2
    JIRA_API_TOKEN="${input_token}"
    echo -n "JIRA_PROJECT_KEY (e.g. CDS, MT): " >&2
    read -r input_project
    JIRA_PROJECT_KEY="${input_project}"
    if [ -n "$JIRA_API_TOKEN" ]; then
      export JIRA_BASE_URL JIRA_API_TOKEN JIRA_PROJECT_KEY
      echo "" >&2
      echo "Tip: save these to ~/.config/ai-skills/.env (see .env.example for format):" >&2
      echo "  cat >> ~/.config/ai-skills/.env <<- 'EOF'" >&2
      echo "  JIRA_BASE_URL=${JIRA_BASE_URL}" >&2
      echo "  JIRA_API_TOKEN=<your-token>" >&2
      echo "  JIRA_PROJECT_KEY=${JIRA_PROJECT_KEY}" >&2
      echo "  EOF" >&2
    else
      echo "No token provided — Jira operations disabled for this session." >&2
    fi
  else
    echo "Jira credentials missing. Set JIRA_BASE_URL and JIRA_API_TOKEN in a .env file." >&2
    echo "See .env.example for all available variables." >&2
  fi
fi
