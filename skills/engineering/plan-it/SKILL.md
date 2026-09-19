---
name: plan-it
description: >
  Doc Cycle — plan phase. Grill, scaffold phases, draft ADRs, optional Jira
  (jira.md), start from intake (--from-issues), re-sync Jira keys
  (--jira --sync-only). Publish operations source the connector bridge
  directly — no direct curl. Use when a feature,
  bugfix, or change needs structured scoping, or when user says plan-it,
  plan, --from-issues, design, or architecture.
---

## Role

Documentation & Planning Agent (Architect). Opens the **Doc Cycle**: `/plan-it` → `/implement-it` (every phase) → `/audit-it` → `/verify-it`.

If `docs/reference/` is missing or stale on an unfamiliar repo, suggest `/doc-it` first unless the user declines.

**Issue tracker:** `docs/agents/issue-tracker.md` should have been provided — run `/setup-internal-skills` if missing.

## Quick start

Ad-hoc plan (no pre-existing intake):

```text
/plan-it
```

→ Agent grills you on scope, then scaffolds `docs/planning/<id>/` with phases, ADRs.

From existing inbox items:

```text
/plan-it --from-issues docs/issues/rate-limit-auth.md
```

→ Evaluates intake (triage), grills, scaffolds. With Jira: `/plan-it <id> --jira`.

Single issue (not a plan): `/to-jira docs/issues/<slug>.md` ([to-jira](../to-jira/SKILL.md)).

## Three layers (do not mix)

| Layer | Path | Purpose |
|-------|------|---------|
| **Inbox** | `docs/issues/*.md` | Unplanned intake only ([issue-it](../issue-it/SKILL.md)) |
| **Plan** | `docs/planning/<id>/` | Phases, `sources/` (moved intake), ADR, README |
| **Jira map** | `docs/planning/<id>/jira.md` | Phase ↔ Jira keys only ([JIRA.md](JIRA.md)) |

At **`--from-issues`**, move each inbox file → `docs/planning/<id>/sources/` so the inbox stays clean.

## Arguments

| Argument | Meaning |
|----------|---------|
| `--from-issues <path>…` | Start plan from intake files ([FROM-ISSUES.md](FROM-ISSUES.md)) |
| `--from-issues ready` | All `docs/issues/*.md` with `status: ready-for-plan` |
| `--jira` | After scaffold: create/sync Jira + write `jira.md` ([JIRA.md](JIRA.md)) |
| `--jira --sync-only` | Re-sync: pull Epic children into `jira.md` only — **no new POSTs** |
| `--parent EPIC-123` | **Override** parent Epic — beats `JIRA_DEFAULT_EPIC` ([JIRA.md](JIRA.md#parent-epic-override)) |

### Re-sync an existing plan (no re-grill)

```text
/plan-it {ID} --jira --sync-only
```

Read existing `phase-N/ai-prompt.md` and `jira.md`, then run
[jira-epic-sync.md](../setup-internal-skills/jira-epic-sync.md) to fill phase
rows. No re-grill or rescaffold.

## Workflow

### 0. Intake (optional)

Ad-hoc: skip to [GRILL.md](GRILL.md). No inbox file required.

`--from-issues`: follow [FROM-ISSUES.md](FROM-ISSUES.md) to read inbox items,
then proceed to grill. If any item is `status: intake`, run
[INTAKE-EVALUATION.md](INTAKE-EVALUATION.md) first.

### 1. The Grill

See [GRILL.md](GRILL.md) — always runs. One question at a time until shared
understanding. Update `CONTEXT.md` and ADRs inline.

### 2. Scaffold

See [SCAFFOLD.md](SCAFFOLD.md) — create `docs/planning/{ID}/` with README,
phase prompts, and jira.md stub.

### 3. ADR

Draft `docs/adr/{ID}-description.md` with status `Proposed`.

### 4. Deep Modules

Design deep interfaces; update `CONTEXT.md` terminology.

### 5. Jira (optional)

Delegate all API operations to [`to-jira`](../to-jira/SKILL.md). Follow
[JIRA.md](JIRA.md) for Epic and Task creation. If Jira not requested, ask
the user. For a single intake item, suggest `/to-jira create` as lighter
alternative.

### 6. Next skill

> Plan `{ID}` ready — {N} phase(s): {list}.
>
> **Next:** `/implement-it` on `docs/planning/{ID}/phase-1/ai-prompt.md` → … → `/audit-it` → `/verify-it`.

## Core Tenets

- **Read-only code** during planning.
- **Full phase coverage** before any implement-it.
- **One Jira map per plan** — `jira.md`, not parallel tracker trees.

## See also

- **Work spanning more than one plan or session:** scope it with `/wayfinder` first, then run `/plan-it` per decision it resolves — `/plan-it` assumes a single plan already has clear boundaries.
