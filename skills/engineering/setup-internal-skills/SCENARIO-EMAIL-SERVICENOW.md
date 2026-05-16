# Scenario — Email & ServiceNow → triage → plan → Jira

Org pattern: work arrives outside the repo (email, ServiceNow). The **application project** is the system of record for intake and planning; Jira is published at plan time.

## Flow

```text
Email / ServiceNow request
        ↓
/triage  (paste body in chat — project repo)
        ↓
docs/issues/<slug>.md   (review in repo)
        ↓
/triage  (refine → ready-for-plan)  OR  direct if already clear
        ↓
/plan-it --from-issues …  (always grills)
        ↓
/plan-it <id> --jira [--parent EPIC-123]
        ↓
Doc Cycle (implement-it → audit-it → verify-it)
```

## Step 1 — Triage from pasted text

In the **project repo** (after `/setup-internal-skills`):

```text
/triage

<paste email thread or ServiceNow ticket text>
```

Agent:

1. Parses summary, requester, ticket id (if present), and asks bug vs enhancement if unclear.
2. Creates **`docs/issues/<slug>.md`** (local inbox — default for this scenario).
3. Sets frontmatter:

```yaml
---
title: Short summary from request
type: bug | feature | todo | defer
status: intake
source: email | servicenow
external_id: INC0012345    # ServiceNow number when known
received: 2026-05-16        # optional
requester: name@org.com     # optional
---
```

4. Puts **verbatim pasted text** under `## Context` (blockquote or fenced block). Fills **Problem / request** and minimal **Acceptance** from the paste.
5. Hands off: *"Review `docs/issues/<slug>.md`. When ready: `/triage` to refine or `/plan-it --from-issues`."*

**Do not** POST Jira or create `docs/planning/` in this step.

## Step 2 — Review and triage

Maintainer reads the file in git/IDE.

```text
/triage docs/issues/<slug>.md
```

- Reproduce (bugs), grill if vague, set `status: ready-for-plan` when spec is clear enough to plan.
- Append triage notes under `## Comments` (with AI disclaimer).

## Step 3 — Plan

```text
/plan-it --from-issues docs/issues/<slug>.md
```

- **Always grills** (scope, phases, vertical slice) — even after triage.
- Moves file → `docs/planning/<id>/sources/<slug>.md`.

## Step 4 — Jira (optional)

```text
/plan-it <id> --jira
/plan-it <id> --jira --parent CDS-999
```

- Phase Tasks + `jira.md` with **Parent Epic** table and time estimates.
- **`--parent` overrides `JIRA_DEFAULT_EPIC` in `.env`** — use when this request belongs on a different Epic than the team default.

If `.env` has `JIRA_DEFAULT_EPIC` but this plan is a one-off, pass `--parent` explicitly; do not rely on the default.

## Epic resolution reminder

| Priority | Source |
|----------|--------|
| 1 | **`--parent` on invocation** (wins over `.env`) |
| 2 | `jira.md` `epic_key:` |
| 3 | Intake `jira_key:` in `sources/` |
| 4 | `JIRA_DEFAULT_EPIC` in `.env` |

See [issue-tracker-jira.md § Default Epic](issue-tracker-jira.md#default-epic-optional).

## Tracker choice

This scenario assumes **local inbox** for intake. If the org uses **Jira as the only intake**, `/triage` POSTs a Jira issue instead — same paste step; review in Jira until `ready-for-agent`, then capture locally or plan from the Jira brief. Prefer **local inbox + plan-it --jira** when the repo is the planning source of truth.
