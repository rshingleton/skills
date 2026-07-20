# Jira operations — dual-path reference

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

Then:
1. Select **"Manage MCP servers"** → **"Jira"** → **"Authenticate"**
2. Click the authorization URL or complete OAuth in your browser
3. Grant access to your Jira instance
4. Return to Claude Code — credentials cache locally

Credentials are now cached and available to all CLI sessions. See SKILL.md § Authentication for alternatives.

## Operation dispatch: Detect and route

**BEFORE ANY OPERATION**, detect which path to use:

1. **Check for Jira MCP tools** — If `mcp__jira__jira_create_issue` and related tools are available (via prior search or tooling context), use the **Connector path** below.
2. **If connector unavailable** — Fall back to **Bash path** (source `load-jira-env.sh` and call helper functions).
3. **If uncertain** — Try connector first; if it fails with "tool not available" or auth error, fall back to bash.

This dispatch is **transparent to callers** — they invoke `/to-jira` the same way regardless of which path is used internally.

## Path selection (automatic)

This skill uses a **dual-path** approach:

1. **Jira MCP connector (preferred)** — When available and authenticated, use the MCP connector. No credentials needed. Simpler, more reliable.
2. **Bash helpers (fallback)** — When connector unavailable, use curl/bash helpers. Requires `source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh` first.

**Detection is automatic.** When writing operations, assume both paths are available and the skill will route to whichever is accessible. If using bash helpers directly (rare), each block assumes credentials are already sourced (see SKILL.md § Sourcing credentials).

## Using the Jira MCP connector

When the connector is available, operations use MCP tools instead of curl. The connector handles:
- Authentication automatically (no env vars needed)
- Consistent error handling and retries
- API rate limit awareness
- Standard Jira operations: create issue, update, transition, comment, search, etc.

**Detector pattern** (optional, for bash-based callers):
```bash
# Rough detection: if Jira MCP tools are available, use them; else fall back
if command -v mcp__jira__fetch_issue &>/dev/null; then
  # Use connector: mcp__jira__* tools
  true
else
  # Fall back: source helpers and use bash functions
  source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
fi
```

For AI-driven skills (the common case), the routing is automatic and transparent.

## `create-epic` — Create a new Epic

**Connector path (preferred):**
```bash
EPIC_KEY=$(mcp__jira__jira_create_issue \
  --project_key "$JIRA_PROJECT_KEY" \
  --summary "$1" \
  --issue_type "Epic" \
  --description "Epic for plan: $1" \
  --additional_fields '{}' | jq -r '.key')
```

**Bash fallback:**
```bash
# (credentials)
EPIC_KEY=$(_jira_create_epic "$JIRA_PROJECT_KEY" "$1" "" "$1")
```

Write `epic_key` to `jira.md` frontmatter. Report key.

## `create-task` — Create a phase Task under an Epic

Args: `<plan-id> <phase-N>` (e.g. `auth-v2 phase-1`)

Reads `docs/planning/<plan-id>/phase-<N>/ai-prompt.md` for title, scope, and `estimate_hours:`. Reads `jira.md` for Epic key.

**Connector path (preferred):**
```bash
PLAN_ID="$1" PHASE="$2"
EPIC_KEY=$(awk -F': *' '/^epic_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/planning/${PLAN_ID}/jira.md")
SUMMARY=$(head -1 "docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md" | sed 's/^# //')
DESCRIPTION=$(cat "docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md")
EST_HOURS=$(grep -E '^estimate_hours:' "docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md" | awk '{print $2}')

TASK_KEY=$(mcp__jira__jira_create_issue \
  --project_key "$JIRA_PROJECT_KEY" \
  --summary "$SUMMARY" \
  --issue_type "Task" \
  --description "$DESCRIPTION" \
  --assignee "${JIRA_ASSIGNEE:-}" \
  --additional_fields "{\"epicKey\": \"$EPIC_KEY\", \"timetracking\": {\"originalEstimate\": \"${EST_HOURS}h\", \"remainingEstimate\": \"${EST_HOURS}h\"}}" | jq -r '.key')
```

**Bash fallback:**
```bash
# (credentials)
PLAN_ID="$1" PHASE="$2"
EPIC_KEY=$(awk -F': *' '/^epic_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/planning/${PLAN_ID}/jira.md")
EST_HOURS=$(grep -E '^estimate_hours:' "docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md" | awk '{print $2}')
SUMMARY=$(head -1 "docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md" | sed 's/^# //')
BODY_FILE="docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md"
_jira_create_task "$JIRA_PROJECT_KEY" "$SUMMARY" "$BODY_FILE" "$EPIC_KEY" "$EST_HOURS" "${JIRA_ASSIGNEE:-}"
```

After POST, write Jira key to `jira.md` phase row immediately.

## `transition` — Transition an issue to a new status

Used by `/implement-it` (→ "In Progress") and `/verify-it` (→ "Done"/"Resolved").

Before executing, present to the user for confirmation:

> Transition {KEY} to "{status}"? (y/n)

If yes:

**Connector path (preferred):**
```bash
# Get available transitions first
TRANSITIONS=$(mcp__jira__jira_get_transitions --issue_key "$1")
# Find transition ID for the target status (e.g., "In Progress")
TRANSITION_ID=$(echo "$TRANSITIONS" | jq -r ".transitions[] | select(.name == \"$2\") | .id" | head -1)
if [ -z "$TRANSITION_ID" ]; then
  echo "Transition '$2' not available for $1"
  return 1
fi
mcp__jira__jira_transition_issue --issue_key "$1" --transition_id "$TRANSITION_ID"
```

**Bash fallback:**
```bash
# (credentials)
_jira_transition "$1" "$2"
```

If credentials are missing or connector unavailable, report which key needs transition and suggest checking `.env`. **Continue** — missing Jira access is non-blocking.

## `resolve` — Transition to Done and optional comment

Used by `/verify-it`. Shorthand for `transition KEY "Done"` + optional `comment`.

Ask:

> Resolve {KEY} to "{status}"? (y/n)

If yes, prompt for a resolution comment:

> Add a resolution comment? (y/n)

If yes, ask for text (or present a draft): *"Post this comment to {KEY}? (y/edit/skip)"*. Post if confirmed.

```bash
# (credentials)
_jira_transition "$1" "Done"   # or "Resolved" — watcher policy applied inside
# If a resolution comment was provided:
_jira_comment "$1" "$2"
```

## `comment` — Add a comment to an issue

Always prompt before posting:

> Post this comment to {KEY}? (y/edit/skip)

If y, post. If edit, take user's edited text. If skip, abort.

**Connector path (preferred):**
```bash
mcp__jira__jira_add_comment --issue_key "$1" --body "$2"
```

**Bash fallback:**
```bash
# (credentials)
_jira_comment "$1" "$2"
```

## `assign` — Set assignee on an issue

**Connector path (preferred):**
```bash
mcp__jira__jira_assign_issue --issue_key "$1" --assignee "${JIRA_ASSIGNEE:-}"
```

**Bash fallback:**
```bash
# (credentials)
_jira_set_assignee "$1"
```

Does **not** apply watcher policy — caller should run `watcher-policy` separately.

## `update-description` — Replace issue description (wiki-converted)

```bash
# (credentials)
_jira_update_description "$1" "$2"
```

`$1` is the issue key (e.g. `KEY-123`), `$2` is the path to a markdown file. Content is converted through `_jira_wiki_body` before being sent.

Example — fix DASH-4222 description (was posted as raw markdown, fix with wiki markup):

Source file (`some-plan/phase-1/ai-prompt.md`):
```markdown
## Goal

Clean up AmpSystemMonitorStatusHistory tables.

## Phase 1

Reduce retention from 60 to 30 days.
```

After conversion via `_jira_wiki_body`, Jira receives:

```text
h2. Goal

Clean up AmpSystemMonitorStatusHistory tables.

h2. Phase 1

Reduce retention from 60 to 30 days.
```

```bash
_jira_update_description DASH-4222 docs/planning/some-plan/phase-1/ai-prompt.md
```

## `watcher-policy` — Apply watcher policy

```bash
# (credentials)
_jira_apply_watcher_policy "$1" "$2"
```

`$2` is `create` (add watchers + remove ignored) or `update` (remove ignored only).

---

## Connector tool reference — Quick lookup

When the Jira MCP connector is available and authenticated, use these tools instead of bash helpers:

| `to-jira` operation | Connector tool | MCP tool name | Key parameters |
|---|---|---|---|
| `create-epic` | Create Epic | `mcp__jira__jira_create_issue` | `project_key`, `summary`, `issue_type: "Epic"`, `description` |
| `create-task` | Create Task | `mcp__jira__jira_create_issue` | `project_key`, `summary`, `issue_type: "Task"`, `description`, `additional_fields: {epicKey: "..."}` |
| `transition` | Change status | `mcp__jira__jira_transition_issue` | `issue_key`, `transition_id` (from `jira_get_transitions`), optional `comment` |
| `comment` | Add comment | `mcp__jira__jira_add_comment` | `issue_key`, `body` (markdown) |
| `assign` | Set assignee | `mcp__jira__jira_assign_issue` | `issue_key`, `assignee` |
| `update-description` | Update description | `mcp__jira__jira_update_issue` | `issue_key`, `fields: {description: "..."}` |
| `watcher-policy create` | Add watchers | `mcp__jira__jira_add_watcher` | `issue_key`, `user_identifier` |
| `watcher-policy update` | Remove ignored | `mcp__jira__jira_remove_watcher` | `issue_key`, `username` or `account_id` |
| Read: get issue | Fetch issue | `mcp__jira__jira_get_issue` | `issue_key`, optional `fields`, `expand`, `include` |
| Read: transitions | List transitions | `mcp__jira__jira_get_transitions` | `issue_key` |
| Read: search | Query issues | `mcp__jira__jira_search` | `jql` (JQL query string) |

### Connector example: Create a Task

```bash
# Via connector (preferred when available):
mcp__jira__jira_create_issue \
  --project_key "DASH" \
  --summary "Fix rate-limit auth" \
  --issue_type "Task" \
  --description "## Problem\n\nRate limiting broken.\n\n## Solution\n\nReauth." \
  --assignee "user@example.com" \
  --additional_fields '{"epicKey": "DASH-100", "priority": {"name": "High"}}'

# Via curl/bash (fallback):
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
_jira_create_task "$JIRA_PROJECT_KEY" "Fix rate-limit auth" "docs/issues/rate-limit-auth.md" "DASH-100" "8"
```

### Key differences: Connector vs bash helpers

**Connector advantages:**
- No credential management (OAuth handled automatically)
- Better error reporting and retries
- Markdown → Wiki conversion built-in (for description fields)
- Supports more fields natively (custom fields, components, etc.)

**Bash helpers still needed for:**
- Complex watcher policies (ignored-user filtering)
- Custom field transformations not in the connector
- Backwards compatibility during gradual migration
