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
# Auth type: set JIRA_AUTH_TYPE=basic for Basic auth (-u ":$TOKEN"), default is Bearer.
# JIRA_PROJECT_KEY can be inferred from any Jira key (e.g. DASH-2196 -> DASH) via _jira_extract_project_key.

# shellcheck disable=SC2317  # functions are for callers, not called directly here

# Comma- or space-separated list -> words
_jira_split_usernames() { echo "${1//,/ }"; }

# Centralized curl wrapper for Jira API calls.
# Usage: _jira_curl <method> [--dry-run] [curl args...]
#   method: GET, POST, PUT, DELETE
#   --dry-run: print intended operation without executing
#
# Automatically adds auth header based on JIRA_AUTH_TYPE (bearer|basic).
# Captures HTTP status code; non-2xx prints error to stderr and returns 1.
# All Jira curl calls from helpers MUST use this function.
_jira_curl() {
  local method="$1" dry_run=0 auth_args=()
  [ -z "$method" ] && return 1
  shift

  case "${JIRA_AUTH_TYPE:-bearer}" in
    basic) auth_args=(-u ":$JIRA_API_TOKEN") ;;
    *) auth_args=(-H "Authorization: Bearer $JIRA_API_TOKEN") ;;
  esac

  # Scan for --dry-run and collect passthru args
  local passthru=() url="" prev_arg=""
  for arg in "$@"; do
    if [ "$arg" = "--dry-run" ]; then
      dry_run=1
    else
      passthru+=("$arg")
      case "$arg" in
        http*) [ -z "$url" ] && url="$arg" ;;
      esac
    fi
  done

  if [ "$dry_run" -eq 1 ]; then
    echo "[DRY RUN] $method $url"
    # Extract -d payload for display
    local payload="" prev=""
    for arg in "$@"; do
      if [ "$prev" = "-d" ]; then payload="$arg"; break; fi
      prev="$arg"
    done
    if [ -n "$payload" ]; then
      echo "PAYLOAD: $(echo "$payload" | jq -c '{summary: .fields.summary, issuetype: .fields.issuetype}' 2>/dev/null || echo "$payload" | head -c 200)"
    fi
    return 0
  fi

  local response code body
  response=$(curl -s -w "\n%{http_code}" -X "$method" "${auth_args[@]}" "${passthru[@]}" 2>/dev/null || true)
  code=$(echo "$response" | tail -1)
  body=$(echo "$response" | sed '$d')

  if [ -z "$code" ]; then
    echo "Jira API error: no response (connection failed)" >&2
    return 1
  fi
  if [ "$code" -lt 200 ] || [ "$code" -ge 300 ]; then
    echo "Jira API error ($code):" >&2
    [ -n "$body" ] && echo "$body" | jq -r '.errorMessages // .message // "Unknown error"' >&2 2>/dev/null || echo "$body" | head -c 500 >&2
    return 1
  fi

  echo "$body"
}

# Extract project key from a Jira issue key (e.g. DASH-2196 -> DASH).
# Usage: _jira_extract_project_key "DASH-2196"  ->  DASH
_jira_extract_project_key() {
  local key="$1"
  [[ "$key" =~ ^([A-Za-z][A-Za-z0-9]*)-[0-9] ]] && echo "${BASH_REMATCH[1]}" || echo ""
}

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
    _jira_curl DELETE -s -o /dev/null \
      "$JIRA_BASE_URL/rest/api/2/issue/${key}/watchers?username=${u}&notifyUsers=false" 2>/dev/null || true
  done
}

# Add watchers to a newly created issue.
_jira_add_watchers() {
  local key="$1" u
  [ -z "${JIRA_WATCHER_USERNAME:-}" ] && return 0
  for u in $(_jira_split_usernames "$JIRA_WATCHER_USERNAME"); do
    [ -z "$u" ] && continue
    _jira_curl POST -s -o /dev/null \
      -H "Content-Type: application/json" \
      "$JIRA_BASE_URL/rest/api/2/issue/${key}/watchers?notifyUsers=false" \
      -d "$(jq -n --arg u "$u" '$u')" 2>/dev/null || true
  done
}

# Apply full watcher policy after a Jira write.
# Usage: _jira_apply_watcher_policy <key> [create|update]
_jira_apply_watcher_policy() {
  local key="$1" mode="${2:-create}"
  _jira_remove_ignored_watchers "$key"
  if [ "$mode" = "create" ]; then
    _jira_add_watchers "$key"
  fi
  return 0
}

# Set assignee on an issue. Does NOT call watcher policy — call
# _jira_apply_watcher_policy separately after this if needed.
_jira_set_assignee() {
  local key="$1"
  [ -z "${JIRA_ASSIGNEE:-}" ] || [ -z "$key" ] && return 0
  _jira_curl PUT -s -o /dev/null \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/2/issue/${key}?notifyUsers=false" \
    -d "{\"fields\": {\"assignee\": {\"name\": \"${JIRA_ASSIGNEE}\"}}}"
}

# Ensure JIRA_PROJECT_KEY is set, inferring from a known Jira key if needed.
# Idempotent — does not override an already-set JIRA_PROJECT_KEY.
# Usage: _jira_ensure_project_key "DASH-3373"
_jira_ensure_project_key() {
  local hint="$1"
  [ -n "${JIRA_PROJECT_KEY:-}" ] && return 0
  local inferred
  inferred="$(_jira_extract_project_key "$hint")"
  [ -n "$inferred" ] && export JIRA_PROJECT_KEY="$inferred"
}

# Resolve parent Epic key from --parent flag, plan jira.md, intake file,
# JIRA_DEFAULT_EPIC env var, or docs/agents/issue-tracker.md.
# Usage: resolve_jira_parent_epic "<--parent or empty>" "<plan-id or slug or empty>"
resolve_jira_parent_epic() {
  local flag_parent="$1" id="$2" k=""
  if [ -n "$flag_parent" ]; then _jira_ensure_project_key "$flag_parent"; echo "$flag_parent"; return; fi
  if [ -n "$id" ] && [ -f "docs/planning/${id}/jira.md" ]; then
    k=$(awk -F': *' '/^epic_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/planning/${id}/jira.md")
    [ -n "$k" ] && { _jira_ensure_project_key "$k"; echo "$k"; return; }
  fi
  if [ -n "$id" ] && [ -f "docs/issues/${id}.md" ]; then
    k=$(awk -F': *' '/^jira_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/issues/${id}.md")
    [ -n "$k" ] && { _jira_ensure_project_key "$k"; echo "$k"; return; }
  fi
  if [ -n "$id" ] && [ -f "docs/issues/${id}/epic.md" ]; then
    k=$(awk -F': *' '/^jira_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/issues/${id}/epic.md")
    [ -n "$k" ] && { _jira_ensure_project_key "$k"; echo "$k"; return; }
  fi
  if [ -n "${JIRA_DEFAULT_EPIC:-}" ]; then _jira_ensure_project_key "$JIRA_DEFAULT_EPIC"; echo "$JIRA_DEFAULT_EPIC"; return; fi
  if [ -f docs/agents/issue-tracker.md ]; then
    k=$(grep -E '^\*\*default_epic:\*\*|^default_epic:' docs/agents/issue-tracker.md \
      | sed -n 's/.*`\([^`]*\)`.*/\1/p' | head -1)
    [ -n "$k" ] && { _jira_ensure_project_key "$k"; echo "$k"; return; }
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

# Convert markdown to Jira wiki markup.
# Handles headings (h1-h3), inline code, bold, code blocks, tables, and lists.
# 
# This function ensures all markdown input is converted to Jira wiki format before
# being sent to the Jira API. It is called automatically by _jira_create_epic,
# _jira_create_task, and _jira_update_description — callers do not need to
# pre-convert. This guarantees consistency across all Jira body writes.
#
# Conversion rules:
#   - Lines starting with # / ## / ### → h1. / h2. / h3. (headings)
#   - `inline code` → {{inline code}} (monospace)
#   - **bold text** → *bold text* (Jira wiki emphasis)
#   - ```lang code ``` → {code:language=lang}...{code} (code blocks with language hint)
#   - [link text](url) → link text (URL dropped, text preserved)
#   - - [ ] / - [x] → * (task lists become plain bullets)
#   - - bullet → * bullet (list markers normalized)
#
# Usage: _jira_wiki_body <file>
# Returns: converted text to stdout, non-zero on file not found
_jira_wiki_body() {
  local file="$1"
  [ -f "$file" ] || return 1

  # First pass: handle multi-line patterns (code blocks) with awk
  # Then second pass: handle line-level and inline patterns with sed
  awk '
    BEGIN { in_code = 0 }
    /^```/ {
      if (in_code) {
        print "{code}"
        in_code = 0
      } else {
        lang = $0
        sub(/^```/, "", lang)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", lang)
        if (lang) {
          print "{code:language=" lang "}"
        } else {
          print "{code}"
        }
        in_code = 1
      }
      next
    }
    in_code { print; next }
    { print }
  ' "$file" | sed \
    -e 's/^# /h1. /' \
    -e 's/^## /h2. /' \
    -e 's/^### /h3. /' \
    -e 's/^- \[[ xX]\] /* /' \
    -e 's/^- /* /' \
    -e 's/\*\*\([^*]*\)\*\*/\*\1\*/g' \
    -e 's/`\([^`]*\)`/{{\1}}/g' \
    -e 's/\[[^]]*\](\([^)]*\))/\1/g'
}

# ---------------------------------------------------------------------------
# Write operations
# ---------------------------------------------------------------------------

# Post a comment on an issue. notifyUsers=false.
# Usage: _jira_comment <key> <body>
# Returns: comment ID on stdout
_jira_comment() {
  local key="$1" body="$2"
  [ -z "$key" ] || [ -z "$body" ] && return 1
  _jira_curl POST -s \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/2/issue/${key}/comment?notifyUsers=false" \
    -d "$(jq -n --arg b "$body" '{body: $b}')" | jq -r '.id'
}

# Transition an issue to a target status.
# Usage: _jira_transition <key> <status_name>
# Silent if status not found. Applies watcher policy on success.
_jira_transition() {
  local key="$1" target="$2" tid
  [ -z "$key" ] || [ -z "$target" ] && return 1
  tid=$(_jira_curl GET -s "$JIRA_BASE_URL/rest/api/2/issue/${key}/transitions" \
    | jq -r --arg t "$target" '.transitions[] | select(.to.name == $t) | .id' | head -1)
  [ -z "$tid" ] && return 1
  _jira_curl POST -s -o /dev/null \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/2/issue/${key}/transitions?notifyUsers=false" \
    -d "$(jq -n --arg id "$tid" '{transition: {id: $id}}')"
  _jira_apply_watcher_policy "$key" update
}

# Create a new Epic.
# Usage: _jira_create_epic <project_key> <summary> [desc_file] [epic_name]
# If epic_name omitted, defaults to summary. Echoes the new issue key on stdout.
_jira_create_epic() {
  local project="$1" summary="$2" desc_file="${3:-}" epic_name="${4:-$summary}" body=""
  [ -z "$project" ] || [ -z "$summary" ] && return 1
  [ -n "$desc_file" ] && body=$(_jira_wiki_body "$desc_file" 2>/dev/null)
  local key
  key=$(_jira_curl POST -s \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
    -d "$(jq -n \
      --arg p "$project" \
      --arg s "$summary" \
      --arg b "$body" \
      --arg en "$epic_name" \
      '{
        fields: {
          project: {key: $p},
          summary: $s,
          description: $b,
          issuetype: {name: "Epic"},
          customfield_10881: $en,
          labels: ["ai-generated"]
        }
      }')" | jq -r '.key')
  [ -z "$key" ] || [ "$key" = "null" ] && return 1
  _jira_apply_watcher_policy "$key" create
  echo "$key"
}

# Create a new Task (optionally under an Epic, with estimate and assignee).
# 
# The body_file is automatically converted from markdown to Jira wiki format
# via _jira_wiki_body — callers can pass raw markdown. The conversion ensures
# inline code, bold, headings, and code blocks render correctly in Jira.
#
# Usage: _jira_create_task <project_key> <summary> <body_file> [epic_key] [hours] [assignee]
# Args:
#   project_key  - Jira project key (e.g. CDS, DASH)
#   summary      - Task title (one line)
#   body_file    - Path to markdown file (converted to wiki format before POST)
#   epic_key     - Optional parent Epic key; if empty, Task is standalone
#   hours        - Optional time estimate (e.g. 4, 0.5, "2h", "1d")
#   assignee     - Optional assignee username; if empty, unassigned
#
# Returns: Jira issue key on stdout (e.g. CDS-1234), non-zero on error
# Applies watcher policy on success.
_jira_create_task() {
  local project="$1" summary="$2" body_file="$3" epic_key="${4:-}" hours="${5:-}" assignee="${6:-}" body="" payload=""
  [ -z "$project" ] || [ -z "$summary" ] && return 1
  [ -n "$body_file" ] && body=$(_jira_wiki_body "$body_file" 2>/dev/null)
  payload=$(jq -n \
    --arg p "$project" \
    --arg s "$summary" \
    --arg b "$body" \
    --arg e "$epic_key" \
    --arg a "$assignee" \
    '{
      fields: ({
        project: {key: $p},
        summary: $s,
        description: $b,
        issuetype: {name: "Task"},
        labels: ["ai-generated"]
      } + (if $e != "" then {customfield_10880: $e} else {} end)
       + (if $a != "" then {assignee: {name: $a}} else {} end))
    }')
  if [ -n "$hours" ]; then
    local tt
    tt=$(_jira_timetracking_fields "$hours") || true
    [ -n "$tt" ] && payload=$(echo "$payload" | jq --argjson tt "$tt" '.fields += $tt')
  fi
  local key
  key=$(_jira_curl POST -s \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
    -d "$payload" | jq -r '.key')
  [ -z "$key" ] || [ "$key" = "null" ] && return 1
  _jira_apply_watcher_policy "$key" create
  echo "$key"
}

# Partial update of issue fields.
# Usage: _jira_update_issue <key> <json_updates>
# json_updates is a jq-compatible object to merge into fields.
# Example: _jira_update_issue KEY-123 '{assignee: {name: "user"}}'
_jira_update_issue() {
  local key="$1" updates="$2"
  [ -z "$key" ] || [ -z "$updates" ] && return 1
  _jira_curl PUT -s -o /dev/null \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/2/issue/${key}?notifyUsers=false" \
    -d "$(jq -n --argjson u "$updates" '{fields: $u}')"
  _jira_apply_watcher_policy "$key" update
}

# Update the description of an issue (converts body through wiki markup).
# Usage: _jira_update_description <key> <file>
# Echoes nothing on success, non-zero on failure.
_jira_update_description() {
  local key="$1" file="$2" body
  [ -z "$key" ] || [ ! -f "$file" ] && return 1
  body=$(_jira_wiki_body "$file" 2>/dev/null)
  _jira_curl PUT -s -o /dev/null \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/2/issue/${key}?notifyUsers=false" \
    -d "$(jq -n --arg b "$body" '{fields: {description: $b}}')"
  _jira_apply_watcher_policy "$key" update
}

# Add labels to an issue (appends, does not replace).
# Usage: _jira_set_labels <key> <label> [label...]
_jira_set_labels() {
  local key="$1" label new_labels; shift
  [ -z "$key" ] || [ $# -eq 0 ] && return 1
  new_labels=$(_jira_curl GET -s "$JIRA_BASE_URL/rest/api/2/issue/${key}?fields=labels" \
    | jq -r --argjson add "$(jq -n --args '$ARGS.positional' -- "$@")" \
      '.fields.labels + $add | unique')
  _jira_curl PUT -s -o /dev/null \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/2/issue/${key}?notifyUsers=false" \
    -d "$(jq -n --argjson l "$new_labels" '{fields: {labels: $l}}')"
  _jira_apply_watcher_policy "$key" update
}

# ---------------------------------------------------------------------------
# Read operations
# ---------------------------------------------------------------------------

# Fetch an issue by key.
# Usage: _jira_fetch_issue <key> [fields]
# Default fields: summary,description,issuetype,status,labels,created
_jira_fetch_issue() {
  local key="$1" fields="${2:-summary,description,issuetype,status,labels,created}"
  [ -z "$key" ] && return 1
  _jira_curl GET -s "$JIRA_BASE_URL/rest/api/2/issue/${key}?fields=${fields}"
}

# Fetch comments for an issue.
# Usage: _jira_fetch_comments <key>
_jira_fetch_comments() {
  local key="$1"
  [ -z "$key" ] && return 1
  _jira_curl GET -s "$JIRA_BASE_URL/rest/api/2/issue/${key}/comment"
}

# Search issues by JQL.
# Usage: _jira_search <jql> [max_results] [fields]
# Default max_results: 50. Default fields: summary,key,created.
_jira_search() {
  local jql="$1" max="${2:-50}" fields="${3:-summary,key,created}"
  [ -z "$jql" ] && return 1
  _jira_curl GET -s -G \
    --data-urlencode "jql=${jql}" \
    --data-urlencode "maxResults=${max}" \
    --data-urlencode "fields=${fields}" \
    "$JIRA_BASE_URL/rest/api/2/search"
}

# ---------------------------------------------------------------------------
# Environment validation
# ---------------------------------------------------------------------------

# Check that required Jira env vars are set. Prints diagnostics if missing.
# Usage: _jira_require_env
# Returns 0 if all required vars are present, 1 if any are missing.
_jira_require_env() {
  local missing=0
  if [ -z "${JIRA_BASE_URL:-}" ]; then
    echo "JIRA_BASE_URL is not set" >&2
    missing=1
  fi
  if [ -z "${JIRA_API_TOKEN:-}" ]; then
    echo "JIRA_API_TOKEN is not set" >&2
    missing=1
  fi
  if [ "$missing" -eq 1 ]; then
    echo "Set these in a .env file (repo root, ~/.agents/.env, or ~/.config/ai-skills/.env) and source load-jira-env.sh" >&2
    echo "Or export them directly in your shell." >&2
    return 1
  fi
  return 0
}
