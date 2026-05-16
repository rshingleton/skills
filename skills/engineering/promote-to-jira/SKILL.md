---
name: promote-to-jira
description: >
  Push local issues from docs/issues/ and optionally link docs/planning/
  to Jira (Epic + Tasks). Backfills jira_key on each markdown file. Use
  when user says promote to jira, publish issues to jira, sync local
  issues, or after plan-it/to-jiras local tracking is complete.
---

# Promote to Jira

Move **local** planning and issue tracking into Jira. Does not replace `/to-jiras` for initial slice breakdown — use this when issues already exist under `docs/issues/` or you want to publish a completed plan.

Requires `JIRA_BASE_URL`, `JIRA_API_TOKEN`, and `JIRA_PROJECT_KEY` (shell export or `.env`; see [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md)). On every create: [jira-notifications.md](../setup-internal-skills/jira-notifications.md) (`notifyUsers=false` + remove API user from watchers).

Read `docs/agents/issue-tracker.md` first. If the repo is already Jira-only, tell the user promotion is unnecessary.

## Arguments

| Argument | Meaning |
|----------|---------|
| `<feature-slug>` | Promote `docs/issues/<feature-slug>/` (epic + tasks) |
| `--plan <plan-id>` | Also read `docs/planning/<plan-id>/` for phase list / context |
| `--parent EPIC-123` | Skip Epic creation; link new Tasks to existing Epic |
| `--dry-run` | List what would be created; do not call Jira |

## Process

### 1. Gather local artifacts

For the feature slug (or derive slug from `--plan`):

- `docs/issues/<slug>/epic.md` — Epic body (frontmatter `type: epic`)
- `docs/issues/<slug>/tasks/*.md` — Tasks in dependency order
- If `--plan`: `docs/planning/<plan-id>/README.md` and phase list

Skip any file whose frontmatter already has `jira_key` (already promoted) unless the user asks to re-sync.

### 2. Present plan

Show the user:

- Epic title (from epic frontmatter or plan README)
- Each task title, type (HITL/AFK if noted), blocked-by
- Whether a new Epic will be created or `--parent` will be used

Get confirmation before calling Jira.

### 3. Create Epic (unless `--parent`)

If `epic.md` exists and no `jira_key`:

```bash
# issue-tracker-jira.md — POST .../issue?notifyUsers=false, issuetype Epic, customfield_10881
# Then DELETE .../issue/{KEY}/watchers?username=... per jira-notifications.md
```

Write returned key into `epic.md` frontmatter: `jira_key: MT-…`

### 4. Create Tasks

For each `tasks/*.md` without `jira_key`, POST Task to Jira with `?notifyUsers=false` (link Epic via `customfield_10880` when Epic exists). Remove API user from watchers on each new key. Use task file body as Jira description. Preserve acceptance criteria and blocked-by; rewrite `blocked_by` to Jira keys where local blockers were already promoted.

Write each `jira_key` back into the task file frontmatter.

### 5. Link planning (optional)

If `--plan` was passed, append to `docs/planning/<plan-id>/README.md`:

```markdown
## Jira
- Epic: MT-… (docs/issues/<slug>/epic.md)
- Tasks: …
```

### 6. Next skill

> Promotion complete. Epic **MT-…** and N tasks created; `jira_key` recorded in `docs/issues/<slug>/`.
>
> **Next:** Continue the Doc Cycle with `/implement-it`, or triage incoming work in Jira via `/triage`.

See [EXAMPLES.md](EXAMPLES.md) for a full walkthrough.
