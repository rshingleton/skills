# Issue tracker: Jira

Issues and Epics for this repo live as Jira issues. Use the Jira REST API v2 via `curl` for all operations.

## Environment variables

The skills read these from the environment:

| Variable | Purpose |
|---|---|
| `JIRA_BASE_URL` | Jira instance base URL (e.g. `https://jira.example.com`). |
| `JIRA_API_TOKEN` | Personal access token (Bearer auth in `Authorization` header). |
| `JIRA_PROJECT_KEY` | Jira project key where issues live (e.g. `MT`). |

Optional project alias mapping (matching the doc-manager `PROJECT_<ALIAS>_KEY` convention):

| Variable | Purpose |
|---|---|
| `PROJECT_<ALIAS>_KEY` | Map a short alias to a real project key. E.g. `PROJECT_ISOFT_KEY=ISFONE`. |

## API Base

```
$JIRA_BASE_URL/rest/api/2
```

All calls use `Authorization: Bearer $JIRA_API_TOKEN` and `Content-Type: application/json`.

## Epic custom fields

These standard Jira custom fields are used when creating or linking Epics:

| Field | Customfield ID | Used by |
|---|---|---|
| **Epic Name** | `customfield_10881` | `/to-epic` and `/plan-it` when creating an Epic. Set to the Epic's summary/title. |
| **Epic Link** | `customfield_10880` | `/to-jiras --parent EPIC-123` and `/plan-it` when creating Tasks under an Epic. Links the Task to the parent Epic. |

If your Jira instance uses different customfield IDs, update them in the skill files or at `docs/agents/issue-tracker.md`.

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

Create a Jira issue via `curl` POST to `/rest/api/2/issue`.

## When a skill says "fetch the relevant ticket"

Run `curl` to GET the issue by key and parse with `jq`. Fetch comments separately.
