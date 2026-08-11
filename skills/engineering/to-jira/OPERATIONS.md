# Jira operations reference

Single reference for every Jira operation used by `to-jira`, `from-jira`, `plan-it`, `implement-it`,
and `verify-it`. Primary path: the connector bridge (routes to the Jira MCP connector or bash
helpers transparently). Secondary: bash-only operations with no connector equivalent.

## Setup (one-time)

### 1. Register the connector globally

```bash
claude mcp add --transport http jira https://your-jira-mcp-server.example.com/mcp
claude mcp add --transport http confluence https://your-confluence-mcp-server.example.com/mcp
```

This creates `~/.claude/.mcp.json` with the server URLs.

### 2. Authenticate via Claude Code CLI

```bash
claude /mcp
```

Select **"Manage MCP servers"** -> **"Jira"** -> **"Authenticate"**, complete OAuth in the
browser, and grant access. Credentials cache locally and are available to all CLI sessions.

## Using the bridge (recommended)

```bash
source scripts/jira-connector-bridge.sh
jira_bridge_detect                       # sets USE_CONNECTOR=true/false
jira_bridge_call <operation> <args...>   # routes to connector or bash helpers
```

`jira_bridge_detect` is cached per session; call it once before the first `jira_bridge_call`.
Supported operations: `create-epic`, `create-task`, `fetch-issue`, `fetch-comments`, `transition`,
`comment`, `assign`, `get-transitions`. Routing is transparent to callers -- every operation is
invoked the same way regardless of which path served it.

## Operations (via bridge)

### Resolve the Jira key

From a bare key (`CDS-142`) or URL (`https://.../browse/CDS-142`):

```bash
JIRA_KEY=$(echo "$INPUT" | grep -oE '[A-Z]+-[0-9]+' | head -1)
```

### `create-epic` -- create a new Epic

```bash
EPIC_KEY=$(jira_bridge_call create-epic "$JIRA_PROJECT_KEY" "$1" "Epic for plan: $1")
```

Write `epic_key` to `jira.md` frontmatter. Report key.

### `create-task` -- create a phase Task under an Epic

Reads `docs/planning/<plan-id>/phase-<N>/ai-prompt.md` for title, scope, and `estimate_hours:`.
Reads `jira.md` for the Epic key.

```bash
EPIC_KEY=$(awk -F': *' '/^epic_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/planning/${PLAN_ID}/jira.md")
SUMMARY=$(head -1 "docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md" | sed 's/^# //')
EST_HOURS=$(grep -E '^estimate_hours:' "docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md" | awk '{print $2}')
BODY_FILE="docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md"

TASK_KEY=$(jira_bridge_call create-task "$JIRA_PROJECT_KEY" "$SUMMARY" "$BODY_FILE" "$EPIC_KEY" "$EST_HOURS" "${JIRA_ASSIGNEE:-}")
```

After creation, write the Jira key to the `jira.md` phase row immediately.

### `fetch-issue` / `fetch-comments` -- read an issue

```bash
ISSUE=$(jira_bridge_call fetch-issue "$JIRA_KEY" "summary,description,issuetype,status,labels,created")
COMMENTS=$(jira_bridge_call fetch-comments "$JIRA_KEY")

SUMMARY=$(echo "$ISSUE" | jq -r '.fields.summary')
ISSUE_TYPE=$(echo "$ISSUE" | jq -r '.fields.issuetype.name')
STATUS=$(echo "$ISSUE" | jq -r '.fields.status.name')
BODY=$(echo "$ISSUE" | jq -r '.fields.description // ""')
```

Result parsing is identical regardless of which path served the fetch.

### `transition` -- move an issue to a new status

Used by `/implement-it` (-> "In Progress") and `/verify-it` (-> "Done"/"Resolved"). Confirm first:

> Transition {KEY} to "{status}"? (y/n)

```bash
jira_bridge_call transition "$1" "$2"
```

If credentials are missing or the connector is unavailable, report which key needs transition and
suggest checking `.env`. Missing Jira access is non-blocking -- continue implementation.

### `resolve` -- transition to Done plus an optional comment

Used by `/verify-it`. Shorthand for `transition KEY "Done"` + optional `comment`. Confirm first:

> Resolve {KEY} to "{status}"? (y/n)

If yes, ask whether to add a resolution comment before posting:

```bash
jira_bridge_call transition "$1" "Done"        # or "Resolved"
jira_bridge_call comment "$1" "$2"             # only if a comment was provided
```

### `comment` -- add a comment to an issue

Always confirm first: *"Post this comment to {KEY}? (y/edit/skip)"*.

```bash
jira_bridge_call comment "$1" "$2"
```

### `assign` -- set the assignee on an issue

```bash
jira_bridge_call assign "$1" "${JIRA_ASSIGNEE:-}"
```

### `get-transitions` -- list available transitions for an issue

```bash
jira_bridge_call get-transitions "$1"
```

## Operations without a bridge dispatch case

The bridge script has no `jira_bridge_call` case for these yet -- call the connector tool or bash
helper directly.

### `update-description` -- replace an issue description

**Connector path:** `jira_update_issue` converts markdown to Jira wiki markup automatically -- pass
the markdown description as-is, no manual conversion needed.

```bash
mcp__jira__jira_update_issue --issue_key "$1" --fields '{"description": "'"$(cat "$2")"'"}'
```

**Bash fallback:** curl has no automatic conversion, so the helper runs content through
`_jira_wiki_body` before sending (`## Goal` becomes `h2. Goal`):

```bash
_jira_update_description "$1" "$2"   # $1 = issue key, $2 = path to a markdown file
```

## Connector tool reference

Direct MCP tool names, for advanced use or when bypassing the bridge:

| Operation | MCP tool | Key parameters |
|---|---|---|
| `create-epic` | `mcp__jira__jira_create_issue` | `project_key`, `summary`, `issue_type: "Epic"`, `description` |
| `create-task` | `mcp__jira__jira_create_issue` | as above, `issue_type: "Task"`, `additional_fields: {epicKey}` |
| `transition` | `mcp__jira__jira_transition_issue` | `issue_key`, `transition_id` (from `jira_get_transitions`) |
| `comment` | `mcp__jira__jira_add_comment` | `issue_key`, `body` (markdown) |
| `assign` | `mcp__jira__jira_assign_issue` | `issue_key`, `assignee` |
| `get-transitions` | `mcp__jira__jira_get_transitions` | `issue_key` |
| `fetch-issue` | `mcp__jira__jira_get_issue` | `issue_key`, optional `fields`, `include` |
| `update-description` (no bridge) | `mcp__jira__jira_update_issue` | `issue_key`, `fields: {description}` |

**Bash helpers still needed for:** `update-description`'s wiki conversion (bash path only) and
OSS/offline environments without connector access.
