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

See [OPERATIONS.md](OPERATIONS.md) for bash reference blocks for each sub-command.

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
