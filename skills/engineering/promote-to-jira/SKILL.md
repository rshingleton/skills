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

**Read `docs/agents/issue-tracker.md` first** — Jira API patterns and env vars. Run `/setup-internal-skills` if that file is missing.

## Bundled references (in skills repo)

| Doc | Path from this skill |
|-----|----------------------|
| Jira API + env | [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md) |
| Watcher policy | [jira-notifications.md](../setup-internal-skills/jira-notifications.md) |
| Description style | [jira-description-style.md](../setup-internal-skills/jira-description-style.md) |
| Walkthrough | [EXAMPLES.md](EXAMPLES.md) |

## Prerequisites (application repo)

| Requirement | Required? | If missing |
|-------------|-----------|------------|
| `docs/agents/issue-tracker.md` | Yes (seed via setup) | Run `/setup-internal-skills` |
| `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` in env | Yes | `source` [load-jira-env.sh](../../../scripts/load-jira-env.sh) from app repo root; see [.env.example](../../../.env.example). **`JIRA_PROJECT_KEY` = Jira project key** (e.g. `CDS` from `CDS-109`), **not** Bitbucket project slug (`MT`). |
| `docs/issues/<feature-slug>/tasks/*.md` | Yes (≥1 task) | Stop — run `/to-jiras <slug>` first |
| `docs/issues/<feature-slug>/epic.md` | No | OK if `--parent`, `jira_key` on epic, or `JIRA_DEFAULT_EPIC` / `default_epic` supplies Epic |
| `docs/planning/<plan-id>/README.md` | Only if `--plan` passed | If absent: warn, promote tasks anyway, skip plan README update |

### Preflight (before any POST)

```bash
source ~/.local/share/ai-skills/scripts/load-jira-env.sh   # or repo scripts/load-jira-env.sh
# Fail fast if project key wrong (avoids misleading 400 "project is required"):
curl -sf -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/2/project/$JIRA_PROJECT_KEY" >/dev/null \
  || echo "JIRA_PROJECT_KEY=$JIRA_PROJECT_KEY not found — use Jira key from issue prefix (CDS-109 → CDS), not Bitbucket slug"
```

Copy `_jira_apply_watcher_policy` and helpers from [jira-notifications.md](../setup-internal-skills/jira-notifications.md) before creates.

## Arguments

| Argument | Meaning |
|----------|---------|
| `<feature-slug>` | Promote `docs/issues/<feature-slug>/` (tasks; optional epic) |
| `--plan <plan-id>` | Optionally read `docs/planning/<plan-id>/` — **do not fail** if missing |
| `--parent EPIC-123` | Skip Epic creation; link Tasks to this Epic |
| `--dry-run` | List what would be created; do not call Jira |

## Process

### 1. Gather local artifacts

Resolve `<feature-slug>` from the argument (not from `--plan` alone).

**Must exist:**

- `docs/issues/<slug>/tasks/*.md` — at least one file

**Optional:**

- `docs/issues/<slug>/epic.md` — Epic body (`type: epic` in frontmatter)
- `docs/planning/<plan-id>/README.md` — only when `--plan` set; if missing, note it and continue

Skip any file whose frontmatter already has `jira_key` unless the user asks to re-sync.

If the repo is Jira-only (no local `docs/issues/`), tell the user promotion is unnecessary.

### 2. Present plan

Show the user:

- Epic title (from `epic.md` frontmatter, plan README, or slug)
- Each task title, type (HITL/AFK if noted), blocked-by
- Whether a new Epic will be created, `--parent` / `JIRA_DEFAULT_EPIC` / existing `jira_key` applies

Get confirmation before calling Jira (skip confirmation on `--dry-run`).

### 3. Create Epic (unless `--parent` or existing key)

If `--parent` is set, use that Epic key for Task linking and skip Epic creation.

Else if `epic.md` exists and has `jira_key`, use it and skip Epic creation.

Else if `epic.md` exists and no `jira_key`:

```bash
# issue-tracker-jira.md — POST .../issue?notifyUsers=false, issuetype Epic, customfield_10881
# Summary + description from epic.md — jira-description-style.md
# Then _jira_apply_watcher_policy "$KEY" create
```

Write returned key into `epic.md` frontmatter: `jira_key: CDS-…` (use actual project prefix).

If no `epic.md`, skip Epic creation; resolve parent for Tasks in step 4.

### 4. Create Tasks

Epic key for linking, first match:

1. `--parent` value  
2. New or existing `epic.md` `jira_key`  
3. `resolve_jira_parent_epic "" "<slug>"` ([issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md#resolving-the-parent-epic-agents))

If no Epic key after resolution, stop and ask — Tasks need `customfield_10880` or user confirmation for standalone Tasks.

For each `tasks/*.md` without `jira_key`, POST Task with `?notifyUsers=false` (link Epic via `customfield_10880` when Epic key set). Edit per [jira-description-style.md](../setup-internal-skills/jira-description-style.md). `_jira_apply_watcher_policy "$KEY" create` after each create.

Write each `jira_key` back into task frontmatter.

### 5. Link planning (optional)

Only if `--plan` was passed **and** `docs/planning/<plan-id>/README.md` exists — append:

```markdown
## Jira
- Epic: CDS-… (docs/issues/<slug>/epic.md)
- Tasks: …
```

If plan path missing, tell user promotion succeeded for issues; plan file not updated.

### 6. Next skill

> Promotion complete. Epic **CDS-…** (or parent used) and N tasks created; `jira_key` recorded under `docs/issues/<slug>/`.
>
> **Next:** `/implement-it`, or `/triage` for incoming Jira work.

See [EXAMPLES.md](EXAMPLES.md).
