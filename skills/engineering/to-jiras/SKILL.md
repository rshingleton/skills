---
name: to-jiras
description: >
  Break a plan, spec, or Epic into independently-grabbable issues using
  tracer-bullet vertical slices. Publishes to docs/issues/ when using
  local tracking (default), or Jira when configured. Use to-jiras,
  --parent EPIC-123 for Jira, or after local planning to create tasks.
  Run promote-to-jira to move local issues to Jira later.
---

# To Jiras

Break a plan into independently-grabbable issues using vertical slices (tracer bullets).

**Read `docs/agents/issue-tracker.md` first** — it decides local vs Jira publish path.

| Tracker | Publish path |
|---------|----------------|
| **Local** (default) | [LOCAL-PUBLISH.md](LOCAL-PUBLISH.md) → `docs/issues/<slug>/tasks/` |
| **Jira** | Step 5 below (curl) |

Run `/setup-internal-skills` if `docs/agents/issue-tracker.md` is missing.

Accepts optional `--parent EPIC-123` (Jira) or a path to a local epic (`docs/issues/<slug>/epic.md`) when publishing locally.

## Process

### 1. Gather context

Work from conversation context. If the user passes a parent:

- **Jira:** `EPIC-123` — fetch via API (see [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md))
- **Local:** path to `epic.md` or feature slug under `docs/issues/`

### 2. Explore the codebase (optional)

Use domain glossary and ADRs if not already explored.

### 3. Draft vertical slices

Tracer-bullet Tasks — thin vertical slices through all layers. Prefer **AFK** over **HITL** where possible.

### 4. Quiz the user

Present breakdown: title, type (HITL/AFK), blocked-by, user stories covered. Iterate until approved.

### 5. Publish

**Local:** Follow [LOCAL-PUBLISH.md](LOCAL-PUBLISH.md).

**Jira:** For each approved slice, POST Task with `?notifyUsers=false` (link Epic via `customfield_10880` when `--parent` set). Remove API user from watchers on each new key — [jira-notifications.md](../setup-internal-skills/jira-notifications.md). See curl templates below.

Publish in dependency order so blockers can reference real keys (Jira keys or local task paths).

<issue-template>
## Parent Epic

Parent Epic key (Jira) or path to `docs/issues/<slug>/epic.md` (local). Omit if standalone.

## What to build

End-to-end behavior for this slice.

## Acceptance criteria

- [ ] …

## Blocked by

Jira keys, local task paths, or "None - can start immediately".
</issue-template>

**Standalone Jira Task:**

```bash
KEY=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
  -d "$(jq -n \
    --arg project "$JIRA_PROJECT_KEY" \
    --arg summary "<Task title>" \
    --arg body "$BODY" \
    '{
      fields: {
        project: {key: $project},
        summary: $summary,
        description: $body,
        issuetype: {name: "Task"},
        labels: ["vertical-slice", "ai-generated"]
      }
    }')" | jq -r '.key')
# _remove_jira_watcher "$KEY" — see jira-notifications.md
```

**Jira with parent Epic:** add `customfield_10880: $epic` — see prior skill revision / [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md).

### 6. Next skill

**Local:**

> Tasks live in `docs/issues/<slug>/`. **Next:** `/implement-it` or `/promote-to-jira <slug>` when ready for Jira.

**Jira:**

> **Next:** `/implement-it` on the first task, or `/promote-to-jira` only if you also have unpublished local issues.
