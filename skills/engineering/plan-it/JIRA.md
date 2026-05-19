# plan-it — Jira (optional)

Jira keys for a Doc Cycle plan live in **`docs/planning/<plan-id>/jira.md`** only — not in `docs/issues/` task trees or scattered phase frontmatter.

Before any Jira API calls, source env vars + helpers:

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
```

This sets `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` and provides all helper functions (`_jira_apply_watcher_policy`, `resolve_jira_parent_epic`, `_jira_timetracking_fields`, `_jira_wiki_body`, etc.).

For this ai-skills repo itself:

```bash
source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh
```

## Invocations

| Command | Use |
|---------|-----|
| `/plan-it <id> --jira` | Publish phase Tasks to Jira (creates Epic + Tasks) |
| `/plan-it <id> --jira --sync-only` | Re-sync keys from existing Epic, no re-grill |
| `/plan-it <id> --jira --parent EPIC-KEY` | Override default parent Epic |

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

Requires `JIRA_*` env — source via `load-jira-env.sh` as shown above. Watcher policy: [jira-notifications.md](../setup-internal-skills/jira-notifications.md).

**Descriptions:** build from phase scope — work content only (`h2. What`, `h2. Done when`, `*` bullets). Convert to **Jira wiki markup** before POST; no markdown `##` or `- [ ]` ([jira-description-style.md](../setup-internal-skills/jira-description-style.md)). No references to planning docs (`ai-prompt.md`, `execution-notes.md`, audit reports) in the description body.

**Time estimates:** on each phase Task **create**, set Jira `timetracking.originalEstimate` and `remainingEstimate` (same value, e.g. `"4h"`) per [issue-tracker-jira.md § Time estimates](../setup-internal-skills/issue-tracker-jira.md#time-estimates-timetracking). Use `_jira_timetracking_fields $HOURS` to build the JSON. Store hours in `phase-N/ai-prompt.md` as `estimate_hours:` and mirror in the `jira.md` table **Est.** column.

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

1. **Source env + helpers** — `source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh`. This gives all `JIRA_*` vars and helper functions.
2. **Resolve parent Epic** — `resolve_jira_parent_epic "<--parent or empty>" "<plan-id>"`. Pass the CLI `--parent` value as the first argument when set.
3. **Sync-only early exit** — If `--sync-only`: run [jira-epic-sync.md](../setup-internal-skills/jira-epic-sync.md) (JQL Tasks under Epic → match phases → fill `jira.md` table), then stop.
4. **Create Epic** (if no parent) — POST Epic; set `epic_key` in `jira.md` frontmatter; apply `_jira_apply_watcher_policy "$KEY" create`.
5. **Ask about title prefix** — before creating tasks, ask:
   > Prefix phase titles with plan name in Jira? E.g. **"Auth v2: Implement login form"** instead of **"Implement login form"** (y/N)
   
   If yes, each phase summary becomes `"<Plan title>: <phase title>"`. If no (default), use phase title as-is. The Epic link already provides parent context.

6. **Create Tasks** — For each `phase-N` without a Jira row:
   - Resolve `estimate_hours:` from `phase-N/ai-prompt.md`, else `JIRA_DEFAULT_ESTIMATE_HOURS`, else ask once.
   - POST Task with `customfield_10880` = Epic key; `JIRA_ASSIGNEE` when set.
   - Use `_jira_timetracking_fields $HOURS` for the `timetracking` object.
   - Summary: phase title from `ai-prompt.md` (with optional plan-name prefix if user chose y).
   - Description from phase scope — work content only, no doc references, wiki markup.
   - After POST, `_jira_apply_watcher_policy "$KEY" create`.
   - Write Jira key + **Est.** to `jira.md` phase row immediately.
7. **Write `jira.md`** — **Parent Epic** section (when `epic_key` set) + phase table.

Do **not** create phase Tasks under `docs/issues/`.

## Small plan (≤3 phases)

When a plan has ≤3 phases, offer the option to use a single Jira Task for the
whole plan instead of creating an Epic + per-phase Tasks:

> This plan has {N} phase(s). Map to a single Jira Task instead of
> Epic+Tasks? (Y/n)

If yes, create one Task and write one row in `jira.md`:

```markdown
| phase-1 | CDS-200 | <plan title> |
```

The single key covers all phases. Phase-level reporting is lost, but setup
overhead is lower. All phases still get individual `ai-prompt.md` files — the
grouping is Jira-only.

When to choose:

| Small plan (single Task) | Epic + Tasks |
|--------------------------|-------------|
| ≤3 phases, all tightly coupled | 4+ phases, or phases with independent timelines |
| Team prefers light Jira footprint | Team wants per-phase time tracking and Jira reporting |
| Quick spike, straightforward scope | Complex work needing phase-level audit trail |

## curl reference

See [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md) for POST Epic, POST Task with Epic Link, and transitions.
