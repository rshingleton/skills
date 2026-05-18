#!/usr/bin/env bash
# Jira helper functions for agent skills.
#
# Source via load-jira-env.sh (recommended — gives env vars + helpers):
#   source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
#
# Or source directly (env vars must already be set):
#   source ~/.agents/skills/setup-internal-skills/scripts/jira-helpers.sh
#
# All functions require JIRA_BASE_URL and JIRA_API_TOKEN in the environment.

# shellcheck disable=SC2317  # functions are for callers, not called directly here

# Comma- or space-separated list -> words
_jira_split_usernames() { echo "${1//,/ }"; }

# Remove ignored watchers from an issue.
_jira_remove_ignored_watchers() {
  local key="$1" users="" u
  if [ -n "${JIRA_WATCHER_IGNORE:-}" ]; then
    users="$(_jira_split_usernames "$JIRA_WATCHER_IGNORE")"
  elif [ -n "${JIRA_EMAIL:-}" ]; then
    users="${JIRA_EMAIL%%@*}"
  fi
  for u in $users; do
    [ -z "$u" ] && continue
    curl -s -o /dev/null -X DELETE \
      -H "Authorization: Bearer $JIRA_API_TOKEN" \
      "$JIRA_BASE_URL/rest/api/2/issue/${key}/watchers?username=${u}&notifyUsers=false" 2>/dev/null || true
  done
}

# Add watchers to a newly created issue.
_jira_add_watchers() {
  local key="$1" u
  [ -z "${JIRA_WATCHER_USERNAME:-}" ] && return 0
  for u in $(_jira_split_usernames "$JIRA_WATCHER_USERNAME"); do
    [ -z "$u" ] && continue
    curl -s -o /dev/null -X POST \
      -H "Authorization: Bearer $JIRA_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$(jq -n --arg u "$u" '$u')" \
      "$JIRA_BASE_URL/rest/api/2/issue/${key}/watchers?notifyUsers=false" 2>/dev/null || true
  done
}

# Apply full watcher policy after a Jira write.
# Usage: _jira_apply_watcher_policy <key> [create|update]
_jira_apply_watcher_policy() {
  local key="$1" mode="${2:-create}"
  _jira_remove_ignored_watchers "$key"
  [ "$mode" = "create" ] && _jira_add_watchers "$key"
}

# Legacy alias for update-only calls (implement-it, verify-it transitions).
_remove_jira_watcher() { _jira_apply_watcher_policy "$1" "update"; }

# Set assignee on an issue. Does NOT call watcher policy — call
# _jira_apply_watcher_policy separately after this if needed.
_jira_set_assignee() {
  local key="$1"
  [ -z "${JIRA_ASSIGNEE:-}" ] || [ -z "$key" ] && return 0
  curl -s -o /dev/null -X PUT \
    -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/2/issue/${key}?notifyUsers=false" \
    -d "{\"fields\": {\"assignee\": {\"name\": \"${JIRA_ASSIGNEE}\"}}}"
}

# Resolve parent Epic key from --parent flag, plan jira.md, intake file,
# JIRA_DEFAULT_EPIC env var, or docs/agents/issue-tracker.md.
# Usage: resolve_jira_parent_epic "<--parent or empty>" "<plan-id or slug or empty>"
resolve_jira_parent_epic() {
  local flag_parent="$1" id="$2" k=""
  if [ -n "$flag_parent" ]; then echo "$flag_parent"; return; fi
  if [ -n "$id" ] && [ -f "docs/planning/${id}/jira.md" ]; then
    k=$(awk -F': *' '/^epic_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/planning/${id}/jira.md")
    [ -n "$k" ] && echo "$k" && return
  fi
  if [ -n "$id" ] && [ -f "docs/issues/${id}.md" ]; then
    k=$(awk -F': *' '/^jira_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/issues/${id}.md")
    [ -n "$k" ] && echo "$k" && return
  fi
  if [ -n "$id" ] && [ -f "docs/issues/${id}/epic.md" ]; then
    k=$(awk -F': *' '/^jira_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/issues/${id}/epic.md")
    [ -n "$k" ] && echo "$k" && return
  fi
  if [ -n "${JIRA_DEFAULT_EPIC:-}" ]; then echo "$JIRA_DEFAULT_EPIC"; return; fi
  if [ -f docs/agents/issue-tracker.md ]; then
    k=$(grep -E '^\*\*default_epic:\*\*|^default_epic:' docs/agents/issue-tracker.md \
      | sed -n 's/.*`\([^`]*\)`.*/\1/p' | head -1)
    [ -n "$k" ] && echo "$k" && return
  fi
}

# Read Jira key for a phase from docs/planning/<plan-id>/jira.md
# Usage: _jira_phase_key "<plan-id>" "phase-1"
_jira_phase_key() {
  local plan="$1" phase="$2" f="docs/planning/${plan}/jira.md"
  [ -f "$f" ] || return 1
  awk -F'|' -v p="$phase" '
    NF >= 4 {
      gsub(/^[ \t]+|[ \t]+$/, "", $2)
      if ($2 == p) {
        gsub(/^[ \t]+|[ \t]+$/, "", $3)
        if ($3 != "" && $3 !~ /^(Jira|Phase|Est\.?|)$/) { print $3; exit }
      }
    }
  ' "$f"
}

# Convert hours number to Jira duration string.
# Usage: _jira_hours_to_duration 4  -> 4h
_jira_hours_to_duration() {
  local h="${1:-}"
  [ -z "$h" ] && return 1
  case "$h" in
    *h|*m|*d|*w) echo "$h" ;;
    *.*) printf '%sm' "$(echo "$h * 60" | bc 2>/dev/null | cut -d. -f1)" ;;
    *) echo "${h}h" ;;
  esac
}

# Build timetracking JSON fragment from hours.
# Usage: _jira_timetracking_fields 4
# Output: {"timetracking":{"originalEstimate":"4h","remainingEstimate":"4h"}}
_jira_timetracking_fields() {
  local dur
  dur="$(_jira_hours_to_duration "$1")" || return 1
  jq -n --arg o "$dur" --arg r "$dur" \
    '{timetracking: {originalEstimate: $o, remainingEstimate: $r}}'
}

# Convert markdown to Jira wiki markup (basic sed conversion).
# Usage: _jira_wiki_body <file>
_jira_wiki_body() {
  sed -e 's/^## /h2. /' -e 's/^### /h3. /' \
      -e 's/^- \[[ xX]\] /* /' -e 's/^- /* /' "$1"
}
