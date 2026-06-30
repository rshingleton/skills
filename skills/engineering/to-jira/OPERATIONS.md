# Jira operations — bash reference

Each block assumes credentials are already sourced (see SKILL.md § Sourcing credentials).

## `create-epic` — Create a new Epic

```bash
# (credentials)
EPIC_KEY=$(_jira_create_epic "$JIRA_PROJECT_KEY" "$1" "" "$1")
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

```bash
# (credentials)
_jira_transition "$1" "$2"
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
_jira_transition "$1" "Done"   # or "Resolved" — watcher policy applied inside
```

## `comment` — Add a comment to an issue

Always prompt before posting:

> Post this comment to {KEY}? (y/edit/skip)

If y, post. If edit, take user's edited text. If skip, abort.

```bash
# (credentials)
_jira_comment "$1" "$2"
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
