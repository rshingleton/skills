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
# If a resolution comment was provided:
_jira_comment "$1" "$2"
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
