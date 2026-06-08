# Jira operations — bash reference

Each block assumes credentials are already sourced (see SKILL.md § Sourcing credentials).

## `create-epic` — Create a new Epic

```bash
# (credentials)
EPIC_KEY=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
  -d "$(jq -n \
    --arg project "$JIRA_PROJECT_KEY" \
    --arg summary "$1" \
    '{
      fields: {
        project: {key: $project},
        summary: $summary,
        issuetype: {name: "Epic"},
        labels: ["ai-generated"]
      }
    }')" | jq -r '.key')
_jira_apply_watcher_policy "$EPIC_KEY" create
```

Write `epic_key` to `jira.md` frontmatter. Report key.

## `create-task` — Create a phase Task under an Epic

Args: `<plan-id> <phase-N>` (e.g. `auth-v2 phase-1`)

Reads `docs/planning/<plan-id>/phase-<N>/ai-prompt.md` for title, scope, and `estimate_hours:`. Reads `jira.md` for Epic key.

```bash
# (credentials)
PLAN_ID="$1" PHASE="$2"
EPIC_KEY=$(awk -F': *' '/^epic_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/planning/${PLAN_ID}/jira.md")
EST_HOURS=$(grep -E '^estimate_hours:' "docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md" | awk '{print $2}')
# POST Task with customfield_10880 = Epic key, timetracking from EST_HOURS
# _jira_apply_watcher_policy "$KEY" create
# Write key to jira.md phase row
```

If `JIRA_ASSIGNEE` is set, include it in the POST payload. After POST, write Jira key to `jira.md` phase row immediately.

## `transition` — Transition an issue to a new status

Used by `/implement-it` (→ "In Progress") and `/verify-it` (→ "Done"/"Resolved").

Before executing, present to the user for confirmation:

> Transition {KEY} to "{status}"? (y/n)

If yes:

```bash
# (credentials)
TRANSITIONS=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/2/issue/$1/transitions")
TARGET_ID=$(echo "$TRANSITIONS" | jq -r ".transitions[] | select(.to.name == \"$2\") | .id" | head -1)
curl -s -o /dev/null -X POST \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/2/issue/$1/transitions?notifyUsers=false" \
  -d "$(jq -n --arg id "$TARGET_ID" '{transition: {id: $id}}')"
_jira_apply_watcher_policy "$1" update
```

If credentials are missing, report which key needs transition and suggest checking `.env`. **Continue** — missing Jira access is non-blocking.

## `resolve` — Transition to Done and optional comment

Used by `/verify-it`. Shorthand for `transition KEY "Done"` + optional `comment`.

Ask:

> Resolve {KEY} to "{status}"? (y/n)

If yes, prompt for a resolution comment:

> Add a resolution comment? (y/n)

If yes, ask for text (or present a draft): *"Post this comment to {KEY}? (y/edit/skip)"*. Post if confirmed.

```bash
# (credentials)
# Run transition "$1" "Done" (or "Resolved")
# If comment text provided, post via curl POST /issue/$1/comment?notifyUsers=false
_jira_apply_watcher_policy "$1" update
```

## `comment` — Add a comment to an issue

Always prompt before posting:

> Post this comment to {KEY}? (y/edit/skip)

If y, post. If edit, take user's edited text. If skip, abort.

```bash
# (credentials)
curl -s -o /dev/null -X POST \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  "$JIRA_BASE_URL/rest/api/2/issue/$1/comment?notifyUsers=false" \
  -d "$(jq -n --arg body "$2" '{body: $body}')"
```

## `assign` — Set assignee on an issue

```bash
# (credentials)
_jira_set_assignee "$1"
```

Does **not** apply watcher policy — caller should run `watcher-policy` separately.

## `watcher-policy` — Apply watcher policy

```bash
# (credentials)
_jira_apply_watcher_policy "$1" "$2"
```

`$2` is `create` (add watchers + remove ignored) or `update` (remove ignored only).
