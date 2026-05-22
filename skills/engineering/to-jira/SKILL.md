---
name: to-jira
description: >
  Central Jira operation handler. All skills delegate Jira API calls here
  instead of duplicating curl commands — create, transition, resolve,
  comment, assign, and watcher-policy. Reads docs/issues/<slug>.md or
  docs/planning/<id>/ and creates Jira issues from local artifacts.
  Use when user says to-jira, push to jira, create jira, make jira,
  create jira from issue, or promote to jira.
---

# To Jira

Central Jira operation handler. **All other skills delegate Jira API operations here** — no skill sources credentials or curls Jira directly.

The helper functions in `setup-internal-skills/scripts/jira-helpers.sh` remain the canonical implementation; this skill is the **orchestration layer** that calls them.

## Quick start

Bare path defaults to `create`:

```text
/to-jira docs/issues/rate-limit-auth.md
/to-jira docs/issues/bug.md --parent CDS-200
/to-jira docs/planning/auth-v2/
```

Other operations:

```text
/to-jira create-epic "Plan Title" <plan-id>
/to-jira create-task <plan-id> phase-1
/to-jira transition KEY-123 "In Progress"
/to-jira resolve KEY-123 "Done"
/to-jira comment KEY-123 "Comment text"
/to-jira assign KEY-123
/to-jira watcher-policy KEY-123 create|update
```

## Sourcing credentials (read first)

Every operation needs Jira credentials. Source once:

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
```

This sets `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` and provides all helper functions (`_jira_apply_watcher_policy`, `resolve_jira_parent_epic`, `_jira_timetracking_fields`, `_jira_wiki_body`, `_jira_set_assignee`, etc.).

For this ai-skills repo itself:

```bash
source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh
```

If credentials are missing after sourcing:
- Report the target key(s)
- Suggest checking `.env` at the repo root or `~/.config/ai-skills/.env`
- **Stop** — Jira operations cannot proceed without credentials

Each operation below says "(credentials)" instead of repeating this block.

## Default operation: `create`

When invoked with a **bare path** (no subcommand), `/to-jira <path>` runs the `create` flow. Aliases: any invocation that starts with a path or `--parent` flag triggers create.

Parts of this flow ask you questions before acting — Epic linking, phase splitting, and posting all require confirmation.

## Operations

### `create` — Create Jira issue(s) from a local artifact

| Source | Issue type | Behaviour |
|--------|-----------|-----------|
| `docs/issues/<slug>.md` | `Task` (feature/todo/defer) or `Bug` (bug) | Creates one Jira issue from intake body |
| `docs/planning/<id>/` | `Task` or per-phase Tasks | Detects phases and offers single vs per-phase |

#### Phase 1: Epic grill

If `--parent EPIC-KEY` was not passed:

1. Check `JIRA_DEFAULT_EPIC` env var.
2. If found, confirm with the user: *"Link to default Epic {JIRA_DEFAULT_EPIC}? (Y/n)"*. If no, ask for an alternate key or blank for standalone.
3. If not found, ask: *"Link this issue to an Epic? (key or blank)"*.

Resolved Epic key → set `customfield_10880` on the POST payload.

#### Phase 2: Phase detection (plan sources only)

When the source is `docs/planning/<id>/`:

1. Detect phases by listing `phase-*/ai-prompt.md` files.
2. If multiple phases found and an Epic is resolved (or `JIRA_DEFAULT_EPIC` is set), ask:

   > This plan has {N} phase(s). Create a single Task for the whole plan, or one Task per phase? (single/per-phase)

   - **single** → Create one `Task` from the plan README. Write one row in `jira.md` with that key for all phases.
   - **per-phase** → Run `create-task` for each phase under the resolved Epic. Write per-phase rows in `jira.md`.

   If no Epic is resolved, create one `Task` for the whole plan.

#### Phase 3: Create

1. Read source body, convert markdown → Jira wiki markup (`_jira_wiki_body`)
2. Build payload with `jq`, POST with `notifyUsers=false`
3. Apply watcher policy: `_jira_apply_watcher_policy "$KEY" create`
4. Write Jira key back to source (frontmatter for issues, per-phase rows for plans)

### `create-epic` — Create a new Epic

Used by the create flow when the user chooses per-phase but no parent Epic exists.

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

### `create-task` — Create a phase Task under an Epic

Used by the create flow for per-phase splits.

Args: `<plan-id> <phase-N>` (e.g. `auth-v2 phase-1`)

Reads `docs/planning/<plan-id>/phase-<N>/ai-prompt.md` for title, scope, and `estimate_hours:`. Reads `jira.md` for Epic key.

```bash
# (credentials)
# Resolve plan-id and phase
PLAN_ID="$1" PHASE="$2"
EPIC_KEY=$(awk -F': *' '/^epic_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/planning/${PLAN_ID}/jira.md")
EST_HOURS=$(grep -E '^estimate_hours:' "docs/planning/${PLAN_ID}/${PHASE}/ai-prompt.md" | awk '{print $2}')
# ... POST Task with customfield_10880 = Epic key, timetracking from EST_HOURS
# ... _jira_apply_watcher_policy "$KEY" create
# ... Write key to jira.md phase row
```

If `JIRA_ASSIGNEE` is set, include it in the POST payload. After POST, write Jira key to `jira.md` phase row immediately.

### `transition` — Transition an issue to a new status

Used by `/implement-it` (→ "In Progress") and `/verify-it` (→ "Done"/"Resolved").

Before executing, present the transition to the user for confirmation:

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

### `resolve` — Transition to Done and optional comment

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

### `comment` — Add a comment to an issue

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

### `assign` — Set assignee on an issue

```bash
# (credentials)
_jira_set_assignee "$1"
```

Does **not** apply watcher policy — caller should run `watcher-policy` separately.

### `watcher-policy` — Apply watcher policy

```bash
# (credentials)
_jira_apply_watcher_policy "$1" "$2"
```

`$2` is `create` (add watchers + remove ignored) or `update` (remove ignored only).

## Delegation rules

| Skill | Delegates to `to-jira` | What |
|-------|------------------------|------|
| `plan-it` | `create-epic`, `create-task`, `watcher-policy` | Publish phase Tasks to Jira |
| `implement-it` | `transition`, `assign`, `watcher-policy` | Move phase to "In Progress" |
| `verify-it` | `resolve`, `comment`, `transition`, `watcher-policy` | Resolve phase in Jira |
| `from-jira` | — (reads FROM Jira, inverse direction) | Uses own fetch logic |

## When to use

| Use `/to-jira` (this skill) | Other |
|-----------------------------|-------|
| Any Jira create/update/transition/comment | `/from-jira` for reading Jira → local plan |
| Single intake item needs Jira tracking | `/plan-it --jira` for Epic + per-phase Task hierarchy |
| Phase needs transition during implement-it | Direct Jira UI for manual edits |

## Not supported

- No sync direction from Jira back to local (use `/from-jira`)
- No JQL queries or bulk operations
