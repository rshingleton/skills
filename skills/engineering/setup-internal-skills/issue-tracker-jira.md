# Issue tracker: Jira

Issues and Epics for this repo live as Jira issues. Use the Jira REST API v2 via `curl` for all operations.

## Environment variables

The skills read these from the environment:

| Variable | Purpose |
|---|---|
| `JIRA_BASE_URL` | Jira instance base URL (e.g. `https://jira.example.com`). |
| `JIRA_API_TOKEN` | Personal access token (Bearer auth in `Authorization` header). |
| `JIRA_PROJECT_KEY` | Jira project key where issues live (e.g. `your-project-key`). |
| `JIRA_EMAIL` | Optional. **Not sent on API calls** — if `JIRA_WATCHER_IGNORE` is unset, remove `${JIRA_EMAIL%%@*}` from watchers after writes (PAT self-unwatch; doc-manager pattern). |
| `JIRA_WATCHER_IGNORE` | Optional. Comma-separated Jira usernames to **remove** from watchers after each write (`DELETE .../watchers?username=...`). When set, replaces the `JIRA_EMAIL` default. |
| `JIRA_WATCHER_USERNAME` | Optional. Comma-separated Jira usernames to **add** as watchers after each **create** (`POST .../watchers`). |
| `JIRA_DEFAULT_EPIC` | Optional. Default parent Epic key for new Tasks when skills omit `--parent` (see [Default Epic](#default-epic-optional)). |

### Loading credentials

**`.env` file (recommended).** Copy [`.env.example`](../../../.env.example) from the ai-skills repo to one of:

| Path | Scope | Precedence |
|------|--------|------------|
| `.env` at the application repo root | Per project | **Highest** (when cwd is that repo) |
| `~/.agents/.env` | Beside installed skills | |
| `~/.config/ai-skills/.env` | User-wide default | Lowest |

Set `JIRA_PROJECT_KEY` to your Jira project key and `JIRA_API_TOKEN` in that file. Do not commit tokens.

Before Jira `curl` in a shell, run from the application repo (so its `.env` wins):

```bash
source ~/.local/share/ai-skills/scripts/load-jira-env.sh
```

The loader checks: `JIRA_ENV_FILE` (if set), then `./.env`, then `~/.agents/.env`, then `~/.config/ai-skills/.env`. From an ai-skills clone: `source scripts/load-jira-env.sh`.

**Shell exports.** Alternatively `export JIRA_BASE_URL=...` etc. in your profile.

**Agents.** Before calling the Jira API, ensure all three variables are set. If the shell may not have them, `source` the loader script or read the `.env` file and export values for the session. Do not print tokens in chat output.

Optional project alias mapping (matching the doc-manager `PROJECT_<ALIAS>_KEY` convention):

| Variable | Purpose |
|---|---|
| `PROJECT_<ALIAS>_KEY` | Map a short alias to a real project key. E.g. `PROJECT_ISOFT_KEY=ISFONE`. |

## API Base

```
$JIRA_BASE_URL/rest/api/2
```

All calls use `Authorization: Bearer $JIRA_API_TOKEN` and `Content-Type: application/json`.

## Notification suppression (required on writes)

Follow [jira-notifications.md](jira-notifications.md) on **every** create, update, transition, and comment (same as doc-manager):

1. Append **`?notifyUsers=false`** to the URL.
2. Apply watcher policy: **remove** `JIRA_WATCHER_IGNORE` (or PAT from `JIRA_EMAIL`); **add** `JIRA_WATCHER_USERNAME` on creates ([jira-notifications.md](jira-notifications.md)).

Skips cause watcher email noise to service accounts and shared inboxes.

## Description style (required on create)

All **`summary`** and **`description`** fields on `POST /issue` must follow [jira-description-style.md](jira-description-style.md): **structured and detailed**, no AI essay prose. Edit local `docs/issues/` for Jira — preserve implementable detail, cut filler only.

## Epic custom fields

These standard Jira custom fields are used when creating or linking Epics:

| Field | Customfield ID | Used by |
|---|---|---|
| **Epic Name** | `customfield_10881` | `/to-epic` and `/plan-it` when creating an Epic. Set to the Epic's summary/title. |
| **Epic Link** | `customfield_10880` | `/to-jiras --parent EPIC-123` and `/plan-it` when creating Tasks under an Epic. Links the Task to the parent Epic. |

If your Jira instance uses different customfield IDs, update them in the skill files or at `docs/agents/issue-tracker.md`.

## Default Epic (optional)

Use a default parent Epic so `/to-jiras` and `/plan-it` can link new Tasks without passing `--parent` every time.

| Priority | Source | Example |
|----------|--------|---------|
| 1 | `--parent` on the skill invocation | `/to-jiras --parent MT-100` |
| 2 | Feature epic file | `jira_key: MT-100` in `docs/issues/<slug>/epic.md` (set by `/to-epic`, `/promote-to-jira`, or manually) |
| 3 | Project `.env` | `JIRA_DEFAULT_EPIC=MT-100` |
| 4 | This file | **default_epic:** `MT-100` below |

**default_epic:** ``

When all are empty, Tasks are created without Epic Link unless the user passes `--parent`.

### Resolving the parent Epic (agents)

Before POSTing Tasks, resolve the Epic key (equivalent logic in any language):

```bash
# Usage: resolve_jira_parent_epic "<--parent value or empty>" "<feature-slug or empty>"
resolve_jira_parent_epic() {
  local flag_parent="$1" slug="$2" k=""
  if [ -n "$flag_parent" ]; then echo "$flag_parent"; return; fi
  if [ -n "$slug" ] && [ -f "docs/issues/${slug}/epic.md" ]; then
    k=$(awk -F': *' '/^jira_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/issues/${slug}/epic.md")
    [ -n "$k" ] && echo "$k" && return
  fi
  if [ -n "${JIRA_DEFAULT_EPIC:-}" ]; then echo "$JIRA_DEFAULT_EPIC"; return; fi
  if [ -f docs/agents/issue-tracker.md ]; then
    k=$(grep -E '^\*\*default_epic:\*\*|^default_epic:' docs/agents/issue-tracker.md \
      | sed -n 's/.*`\([^`]*\)`.*/\1/p' | head -1)
    [ -n "$k" ] && echo "$k" && return
  fi
}
```

When a resolved Epic exists, set `customfield_10880` on Task creates. Tell the user which Epic was used when it was not passed explicitly.

After `/to-epic` or `/promote-to-jira` creates an Epic, suggest adding `JIRA_DEFAULT_EPIC=<key>` to the project `.env` if the team wants that Epic as the ongoing default.

## Conventions

- **Create an issue** (normal — use a heredoc for the body):
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
    -d '{
      "fields": {
        "project": {"key": "'"$JIRA_PROJECT_KEY"'"},
        "summary": "Issue title",
        "description": "Issue body in text or ADF",
        "issuetype": {"name": "Task"}
      }
    }'
  ```

  Then apply watcher policy (best-effort; [jira-notifications.md](jira-notifications.md)):

  ```bash
  _jira_apply_watcher_policy "<NEW_KEY>" create
  ```

  See [jira-notifications.md](jira-notifications.md) for the helper and rationale.

- **Create an issue with multi-line body** (use `jq` to build JSON safely):
  ```bash
  BODY=$(cat <<'ISSUEBODY'
  Multi-line
  description
  here
  ISSUEBODY
  )
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
    -d "$(jq -n \
      --arg project "$JIRA_PROJECT_KEY" \
      --arg summary "Issue title" \
      --arg body "$BODY" \
      '{
        fields: {
          project: {key: $project},
          summary: $summary,
          description: $body,
          issuetype: {name: "Task"},
          labels: ["ai-generated"]
        }
      }')"
  ```

  Issue `issuetype` values: `Task`, `Story`, `Bug`, `Epic`, `Sub-task`, `Improvement`.

- **Create an Epic**:
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
    -d '{
      "fields": {
        "project": {"key": "'"$JIRA_PROJECT_KEY"'"},
        "summary": "Epic title",
        "description": "Epic body",
        "issuetype": {"name": "Epic"},
        "customfield_10881": "Epic name"
      }
    }'
  ```

- **Create a Task linked to an Epic**:
  Add `"customfield_10880": "EPIC-123"` to the fields.

- **Read an issue**:
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    "$JIRA_BASE_URL/rest/api/2/issue/<KEY>"
  ```

- **Read issue comments**:
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    "$JIRA_BASE_URL/rest/api/2/issue/<KEY>/comment"
  ```

- **List issues by JQL**:
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    "$JIRA_BASE_URL/rest/api/2/search?jql=project+%3D+$JIRA_PROJECT_KEY+AND+status+%3D+%22Open%22&maxResults=20"
  ```

- **Comment on an issue**:
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue/<KEY>/comment?notifyUsers=false" \
    -d '{"body": "Comment text here"}'
  ```

- **Transition issue status**:
  ```bash
  TRANSITIONS=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    "$JIRA_BASE_URL/rest/api/2/issue/<KEY>/transitions")
  TID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name == "<Target Status>") | .id')
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue/<KEY>/transitions?notifyUsers=false" \
    -d "{\"transition\": {\"id\": \"$TID\"}}"
  ```

## Triage state mapping

| Triage role | Jira status | Jira label |
|---|---|---|
| `needs-triage` | `Open` | `needs-triage` |
| `needs-info` | `On Hold` | `needs-info` |
| `ready-for-agent` | `Open` | `ready-for-agent` |
| `ready-for-human` | `Open` | `ready-for-human` |
| `wontfix` | `Closed` | `wontfix` |

## When a skill says "publish to the issue tracker"

Create a Jira issue via `curl` POST to `/rest/api/2/issue?notifyUsers=false`, then remove the API user from watchers per [jira-notifications.md](jira-notifications.md).

## When a skill says "fetch the relevant ticket"

Run `curl` to GET the issue by key and parse with `jq`. Fetch comments separately.
