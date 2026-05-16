# plan-it — Jira (optional)

Jira keys for a Doc Cycle plan live in **`docs/planning/<plan-id>/jira.md`** only — not in `docs/issues/` task trees or scattered phase frontmatter.

## Re-sync existing Jira (keys only)

On an **existing** plan (no re-grill):

```text
/plan-it <plan-id> --jira --sync-only
```

Updates **`docs/planning/<plan-id>/jira.md`** from Epic children via [jira-epic-sync.md](../setup-internal-skills/jira-epic-sync.md). Does not update Jira description text on remote issues.

## When to publish

Ask during `/plan-it` after phases are scaffolded:

- *"Create Jira issues for this plan?"* → continue with **`--jira`** (or user says yes mid-skill).
- *"Sync from existing Epic?"* → **`--jira --sync-only`** when `JIRA_DEFAULT_EPIC` already has phase Tasks.

Requires `JIRA_*` env — preflight in [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md). Watcher policy: [jira-notifications.md](../setup-internal-skills/jira-notifications.md).

**Descriptions:** convert phase content to **Jira wiki markup** before POST — `h2. What`, `h2. Done when`, `*` bullets only; no markdown `##` or `- [ ]` ([jira-description-style.md](../setup-internal-skills/jira-description-style.md)).

## `jira.md` format

Create or update `docs/planning/<plan-id>/jira.md`:

```markdown
---
epic_key: CDS-109
parent_source: env | --parent | created
---

# Jira map

| Phase | Jira | Summary |
|-------|------|---------|
| phase-1 | CDS-142 | <phase title> |
| phase-2 | CDS-143 | <phase title> |

## Unmatched

(optional — Jira rows or phases with no pair after sync)
```

`/implement-it` and `/verify-it` read the **current phase row** from this file for Jira transitions.

## Publish flow

1. **Resolve parent Epic** — `resolve_jira_parent_epic "" "<plan-id>"` ([issue-tracker-jira.md § Default Epic](../setup-internal-skills/issue-tracker-jira.md#default-epic-optional)): `--parent`, `jira.md` `epic_key`, `JIRA_DEFAULT_EPIC`.
2. **`--sync-only`** — [jira-epic-sync.md](../setup-internal-skills/jira-epic-sync.md): JQL Tasks under Epic → match phases → fill `jira.md` table. Stop if sync-only.
3. **Create Epic** (if no parent) — POST Epic; set `epic_key` in `jira.md` frontmatter.
4. **Create Tasks** — For each `phase-N` without a Jira row: POST Task (`customfield_10880` = Epic; `JIRA_ASSIGNEE` when set). Summary/description from phase `ai-prompt.md` (dense structured).
5. **Write `jira.md`** — one row per phase; no duplicate keys elsewhere.

Do **not** create phase Tasks under `docs/issues/`.

## Small plan (≤3 phases)

Optional single Jira Task for the whole plan instead of Epic+Tasks — one row in `jira.md`:

```markdown
| phase-1 | CDS-200 | <plan title> |
```

(or one Task spanning all phases if user prefers a single ticket)

## curl reference

See [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md) for POST Epic, POST Task with Epic Link, and transitions.
