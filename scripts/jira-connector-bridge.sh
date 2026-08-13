#!/usr/bin/env bash
# Jira connector bridge -- detect and route to Jira MCP connector or bash helpers.
#
# Usage:
#   source jira-connector-bridge.sh
#   jira_bridge_detect  # Sets USE_CONNECTOR=true/false
#   jira_bridge_call <operation> <args...>
#
# Operations: create-epic, create-task, fetch-issue, fetch-comments, transition, comment,
# assign, get-transitions
#
# Tests: bash scripts/jira-connector-bridge.test.sh (no credentials or network required)
#
# This script enables skills (which run in a potentially sandboxed context) to:
# 1. Detect if Jira MCP connector tools are available
# 2. Route to connector-first path (preferred)
# 3. Fall back to bash helpers if connector unavailable
# 4. Provide unified interface for all Jira operations
#
# DESIGN DECISION: the echo pattern
#
# When the connector is available, jira_bridge_call does not invoke the MCP tool itself --
# it ECHOES the tool invocation as a string, e.g.:
#   CONNECTOR: mcp__jira__jira_create_issue --project_key 'DASH' ...
#
# Why: this script runs as bash. Bash cannot call an MCP tool -- only the agent's own
# execution context can. Skills source this bridge to get routing decisions and argument
# construction for free, then the agent reads the "CONNECTOR: ..." line from the function's
# output and executes that tool call itself. This is intentional, not a stopgap -- do not
# "fix" it to call the tool directly; that call has to happen one layer up, in the agent.
#
# In the bash path (USE_CONNECTOR=false), there is no such indirection: jira_bridge_call
# invokes the real `_jira_*` helper function directly, which curls the Jira API and returns
# actual data. Both paths are called identically by the caller; only what comes back differs
# (a tool invocation to execute vs. the already-fetched result).

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  echo "Source this script instead of executing it:" >&2
  echo "  source scripts/jira-connector-bridge.sh" >&2
  exit 1
fi

# Global state: whether connector is available
USE_CONNECTOR=false
CONNECTOR_CHECKED=false

# Detect Jira MCP connector availability.
# Sets USE_CONNECTOR=true if tools are available, false otherwise.
jira_bridge_detect() {
  if [ "$CONNECTOR_CHECKED" = "true" ]; then
    return 0  # Already checked; return cached result
  fi

  # Try to detect if MCP tools are available.
  # In a Claude Code context, we check if the tool names are in scope.
  # Fallback: try a harmless tool call and catch failures.

  # For now, assume connector is available if JIRA_MCP_CONNECTOR_AVAILABLE env var is set,
  # or if we're in a Claude context (heuristic: check for claude binary or .claude dir).
  if [ -n "${JIRA_MCP_CONNECTOR_AVAILABLE:-}" ]; then
    USE_CONNECTOR=true
  elif command -v claude &>/dev/null && [ -d ~/.claude ]; then
    # In Claude Code context; assume connector is available
    # (actual availability check happens when we try to call tools)
    USE_CONNECTOR=true
  else
    USE_CONNECTOR=false
  fi

  CONNECTOR_CHECKED=true
  export USE_CONNECTOR CONNECTOR_CHECKED
}

# Route a Jira operation to connector or bash helpers.
# Usage: jira_bridge_call <operation> <args...>
#
# Supported operations:
#   - create-epic <project_key> <summary> [description]
#   - create-task <project_key> <summary> <body_file> <epic_key> <est_hours> [assignee]
#   - fetch-issue <issue_key> [fields]
#   - fetch-comments <issue_key>
#   - transition <issue_key> <status>
#   - comment <issue_key> <body>
#   - assign <issue_key> [assignee]
#   - get-transitions <issue_key>
#
jira_bridge_call() {
  local op="$1"
  shift

  jira_bridge_detect

  case "$op" in
    create-epic)
      jira_bridge_create_epic "$@"
      ;;
    create-task)
      jira_bridge_create_task "$@"
      ;;
    fetch-issue)
      jira_bridge_fetch_issue "$@"
      ;;
    fetch-comments)
      jira_bridge_fetch_comments "$@"
      ;;
    transition)
      jira_bridge_transition "$@"
      ;;
    comment)
      jira_bridge_comment "$@"
      ;;
    assign)
      jira_bridge_assign "$@"
      ;;
    get-transitions)
      jira_bridge_get_transitions "$@"
      ;;
    *)
      echo "Unknown operation: $op" >&2
      return 1
      ;;
  esac
}

# Create Epic via connector or bash helper.
jira_bridge_create_epic() {
  local project_key="$1" summary="$2" description="${3:-}"

  if [ "$USE_CONNECTOR" = "true" ]; then
    # Connector path: call MCP tool
    # This will be invoked by the agent context; skill itself just provides instructions
    local call="CONNECTOR: mcp__jira__jira_create_issue"
    call+=" --project_key '$project_key' --summary '$summary' --issue_type 'Epic'"
    call+=" --description '${description}' --additional_fields '{}'"
    echo "$call"
  else
    # Bash helper path
    if ! source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh 2>/dev/null; then
      source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh || {
        echo "Failed to source Jira credentials." \
          "Set JIRA_BASE_URL, JIRA_API_TOKEN, JIRA_PROJECT_KEY." >&2
        return 1
      }
    fi
    _jira_create_epic "$project_key" "$summary" "" "$description"
  fi
}

# Create Task via connector or bash helper.
jira_bridge_create_task() {
  local project_key="$1" summary="$2" body_file="$3" epic_key="$4" est_hours="$5" assignee="${6:-}"

  if [ "$USE_CONNECTOR" = "true" ]; then
    # Connector path: instructions for agent to call MCP tool
    local description=$(cat "$body_file" 2>/dev/null || echo "")
    local fields="{\"epicKey\": \"$epic_key\", \"timetracking\":"
    fields+=" {\"originalEstimate\": \"${est_hours}h\", \"remainingEstimate\": \"${est_hours}h\"}}"
    local call="CONNECTOR: mcp__jira__jira_create_issue"
    call+=" --project_key '$project_key' --summary '$summary' --issue_type 'Task'"
    call+=" --description '$description' --assignee '${assignee}' --additional_fields '$fields'"
    echo "$call"
  else
    # Bash helper path
    if ! source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh 2>/dev/null; then
      source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh || {
        echo "Failed to source Jira credentials." >&2
        return 1
      }
    fi
    _jira_create_task "$project_key" "$summary" "$body_file" "$epic_key" "$est_hours" "${assignee}"
  fi
}

# Fetch issue via connector or bash helper.
jira_bridge_fetch_issue() {
  local issue_key="$1" fields="${2:-summary,description,issuetype,status,labels,created}"

  if [ "$USE_CONNECTOR" = "true" ]; then
    echo "CONNECTOR: mcp__jira__jira_get_issue --issue_key '$issue_key'" \
      "--fields '$fields'"
  else
    if ! source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh 2>/dev/null; then
      source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh || {
        echo "Failed to source Jira credentials." >&2
        return 1
      }
    fi
    _jira_fetch_issue "$issue_key" "$fields"
  fi
}

# Fetch comments via connector or bash helper.
jira_bridge_fetch_comments() {
  local issue_key="$1"

  if [ "$USE_CONNECTOR" = "true" ]; then
    echo "CONNECTOR: mcp__jira__jira_get_issue --issue_key '$issue_key'" \
      "--include 'comments'"
  else
    if ! source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh 2>/dev/null; then
      source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh || {
        echo "Failed to source Jira credentials." >&2
        return 1
      }
    fi
    _jira_fetch_comments "$issue_key"
  fi
}

# Transition issue via connector or bash helper.
jira_bridge_transition() {
  local issue_key="$1" status="$2"

  if [ "$USE_CONNECTOR" = "true" ]; then
    local call="CONNECTOR: mcp__jira__jira_get_transitions --issue_key '$issue_key'"
    call+=" | jq -r \".[] | select(.name == \\\"$status\\\") | .id\" | head -1"
    call+=" | xargs -I {} mcp__jira__jira_transition_issue --issue_key '$issue_key'"
    call+=" --transition_id '{}'"
    echo "$call"
  else
    if ! source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh 2>/dev/null; then
      source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh || {
        echo "Failed to source Jira credentials." >&2
        return 1
      }
    fi
    _jira_transition "$issue_key" "$status"
  fi
}

# Add comment via connector or bash helper.
jira_bridge_comment() {
  local issue_key="$1" body="$2"

  if [ "$USE_CONNECTOR" = "true" ]; then
    echo "CONNECTOR: mcp__jira__jira_add_comment --issue_key '$issue_key'" \
      "--body '$body'"
  else
    if ! source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh 2>/dev/null; then
      source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh || {
        echo "Failed to source Jira credentials." >&2
        return 1
      }
    fi
    _jira_comment "$issue_key" "$body"
  fi
}

# Assign issue via connector or bash helper.
jira_bridge_assign() {
  local issue_key="$1" assignee="${2:-${JIRA_ASSIGNEE:-}}"

  if [ "$USE_CONNECTOR" = "true" ]; then
    echo "CONNECTOR: mcp__jira__jira_assign_issue --issue_key '$issue_key'" \
      "--assignee '${assignee}'"
  else
    if ! source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh 2>/dev/null; then
      source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh || {
        echo "Failed to source Jira credentials." >&2
        return 1
      }
    fi
    _jira_set_assignee "$issue_key"
  fi
}

# Get available transitions via connector or bash helper.
jira_bridge_get_transitions() {
  local issue_key="$1"

  if [ "$USE_CONNECTOR" = "true" ]; then
    echo "CONNECTOR: mcp__jira__jira_get_transitions --issue_key '$issue_key'"
  else
    if ! source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh 2>/dev/null; then
      source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh || {
        echo "Failed to source Jira credentials." >&2
        return 1
      }
    fi
    _jira_get_transitions "$issue_key"
  fi
}
