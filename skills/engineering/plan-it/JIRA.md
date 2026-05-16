# plan-it — Jira (optional)

Jira keys for a Doc Cycle plan live in **`docs/planning/<plan-id>/jira.md`** only — not in `docs/issues/` task trees or scattered phase frontmatter.

Before any Jira API calls, **read `docs/agents/issue-tracker.md`** — it contains the tracker type, `JIRA_*` env vars, helper functions, and conventions. Run `/setup-internal-skills` if missing.

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

**Time estimates:** on each phase Task **create**, set Jira `timetracking.originalEstimate` and `remainingEstimate` (same value, e.g. `"4h"`) per [issue-tracker-jira.md § Time estimates](../setup-internal-skills/issue-tracker-jira.md#time-estimates-timetracking). Store hours in `phase-N/ai-prompt.md` as `estimate_hours:` and mirror in the `jira.md` table **Est.** column.

## `jira.md` format

Create or update `docs/planning/<plan-id>/jira.md`. **Always document the parent Epic in the body** when `epic_key` is set (not only in frontmatter).

When `epic_key` is resolved, **GET** the Epic once and fill `epic_summary` + the **Parent Epic** section:

```bash
curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/2/issue/CDS-109?fields=summary" \
  | jq -r '.fields.summary'
```

Template:

```markdown
---
epic_key: CDS-109
epic_summary: <Epic title from Jira GET or plan README>
parent_source: --parent | JIRA_DEFAULT_EPIC | env | created
---

# Jira map

## Parent Epic

| Field | Value |
|-------|--------|
| Key | CDS-109 |
| Summary | <epic title> |
| Link | $JIRA_BASE_URL/browse/CDS-109 |
| Source | JIRA_DEFAULT_EPIC / --parent / created by plan-it |

Phase Tasks below use Epic Link (`customfield_10880` = CDS-109).

## Phase tasks

| Phase | Jira | Summary | Est. |
|-------|------|---------|------|
| phase-1 | CDS-142 | <phase title> | 4h |
| phase-2 | CDS-143 | <phase title> | 8h |

## Unmatched

(optional — orphan Jira rows or phases without keys)
```

**No parent Epic** (standalone Tasks only): leave `epic_key` empty, omit **Parent Epic** section, add under `# Jira map`:

```markdown
No parent Epic — phase Tasks are standalone in $JIRA_PROJECT_KEY.
```

`/implement-it` and `/verify-it` read the **current phase row** from **Phase tasks** for Jira transitions; use **Parent Epic** for context and JQL sync.

## Parent Epic override

**`--parent EPIC-KEY` on the invocation always wins** over `JIRA_DEFAULT_EPIC` in `.env`, `default_epic` in `issue-tracker.md`, and prior team habit.

Examples:

```text
/plan-it auth-fix --jira --parent CDS-200
```

Even when `.env` has `JIRA_DEFAULT_EPIC=CDS-100`, phase Tasks link to **CDS-200**. Set `parent_source: --parent` in `jira.md`.

At publish time, if only the env default exists, ask: *"Link phase Tasks to default Epic CDS-100, or pass `--parent` for a different Epic?"*

## Publish flow

1. **Resolve parent Epic** — `resolve_jira_parent_epic "<--parent or empty>" "<plan-id>"` ([issue-tracker-jira.md § Default Epic](../setup-internal-skills/issue-tracker-jira.md#default-epic-optional)). Pass the CLI `--parent` value as the first argument when set.
2. **`--sync-only`** — [jira-epic-sync.md](../setup-internal-skills/jira-epic-sync.md): JQL Tasks under Epic → match phases → fill `jira.md` table. Stop if sync-only.
3. **Create Epic** (if no parent) — POST Epic; set `epic_key` in `jira.md` frontmatter.
4. **Create Tasks** — For each `phase-N` without a Jira row: POST Task (`customfield_10880` = Epic; `JIRA_ASSIGNEE` when set; **`timetracking`** from `estimate_hours` in `ai-prompt.md` or ask maintainer — see [time estimates](../setup-internal-skills/issue-tracker-jira.md#time-estimates-timetracking)). Summary/description from phase `ai-prompt.md` (dense structured).
5. **Write `jira.md`** — **Parent Epic** section (when `epic_key` set) + phase table; no duplicate keys elsewhere.

Do **not** create phase Tasks under `docs/issues/`.

## Small plan (≤3 phases)

Optional single Jira Task for the whole plan instead of Epic+Tasks — one row in `jira.md`:

```markdown
| phase-1 | CDS-200 | <plan title> |
```

(or one Task spanning all phases if user prefers a single ticket)

## curl reference

See [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md) for POST Epic, POST Task with Epic Link, and transitions.
