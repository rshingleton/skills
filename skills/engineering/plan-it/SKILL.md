---
name: plan-it
description: >
  Doc Cycle plan phase. Grill, scaffold phases, record ADRs only for decisions
  that warrant one, start from intake (--from-issues), publish to Jira with
  --jira (jira.md), re-sync Jira keys (--jira --sync-only). Use when a feature,
  bugfix, or change needs structured scoping, or when user says plan-it, plan,
  or --from-issues.
---

Opens the **Doc Cycle**: `/plan-it` → `/implement-it` → `/audit-it` → `/verify-it` → `/commit-it`.

If `docs/reference/` is missing or stale on an unfamiliar repo, suggest `/doc-it` first unless the user declines. `docs/agents/issue-tracker.md` should exist; run `/setup-internal-skills` if missing.

## Quick start

- `/plan-it`: grill on scope, then scaffold `docs/planning/<id>/` with phases.
- `/plan-it --from-issues docs/issues/rate-limit-auth.md`: evaluate intake, grill, scaffold.
- `/plan-it <id> --jira`: publish the plan to Jira.
- Single issue, not a plan: `/to-jira docs/issues/<slug>.md` ([to-jira](../to-jira/SKILL.md)).

## Three layers (do not mix)

| Layer | Path | Purpose |
|-------|------|---------|
| **Inbox** | `docs/issues/*.md` | Unplanned intake only ([issue-it](../issue-it/SKILL.md)) |
| **Plan** | `docs/planning/<id>/` | Phases, `sources/` (moved intake), README |
| **Jira map** | `docs/planning/<id>/jira.md` | Phase ↔ Jira keys only ([JIRA.md](JIRA.md)) |

At **`--from-issues`**, move each inbox file to `docs/planning/<id>/sources/` so the inbox stays clean.

## Arguments

| Argument | Meaning |
|----------|---------|
| `--from-issues <path>…` | Start plan from intake files ([FROM-ISSUES.md](FROM-ISSUES.md)) |
| `--from-issues ready` | All `docs/issues/*.md` with `status: ready-for-plan` |
| `--jira` | After scaffold: create or sync Jira and write `jira.md` ([JIRA.md](JIRA.md)) |
| `--jira --sync-only` | Re-sync: pull Epic children into `jira.md` only, **no new POSTs** |
| `--parent EPIC-123` | **Override** parent Epic, beats `JIRA_DEFAULT_EPIC` ([JIRA.md](JIRA.md#parent-epic-override)) |

`/plan-it {ID} --jira --sync-only` on an existing plan runs [jira-epic-sync.md](../setup-internal-skills/jira-epic-sync.md) to fill phase rows; no re-grill or rescaffold.

## Workflow

### 0. Intake (optional)

Ad-hoc: skip to [GRILL.md](GRILL.md). No inbox file required.

`--from-issues`: follow [FROM-ISSUES.md](FROM-ISSUES.md) to read inbox items, then proceed to grill.
If any item is `status: intake`, run [INTAKE-EVALUATION.md](INTAKE-EVALUATION.md) first.

### 1. The Grill

Always runs, however small the work looks. Call the Skill tool twice, for "grilling" and
"domain-modeling", then add the plan agenda in [GRILL.md](GRILL.md). For seams and interfaces,
call the Skill tool with "codebase-design" and use its vocabulary. End your turn after each
round and wait for answers.

### 2. Scaffold

See [SCAFFOLD.md](SCAFFOLD.md): get the phase breakdown approved (folded into the grill's final
confirmation for a one-phase plan), then create `docs/planning/{ID}/` with README, phase
prompts, and jira.md stub.

### 3. ADR (only when warranted)

Offer an ADR only for a decision that passes all three of domain-modeling's tests: hard to
reverse, surprising without context, and the result of a real trade-off. If any test fails,
write no ADR; the decision lives in the plan README. A plan may produce none.

Name an ADR `docs/adr/NNNN-slug.md` with the next free number, in domain-modeling's
[ADR-FORMAT.md](../domain-modeling/ADR-FORMAT.md), status `Proposed`, and link it from the plan README.

### 4. Jira (only with `--jira`)

Without `--jira`, do not publish and do not ask. With it, follow [JIRA.md](JIRA.md): publish
operations source the connector bridge directly, and only the small-plan single-Task shortcut
goes through [`to-jira`](../to-jira/SKILL.md). Helpers:
[issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md#helper-functions-copy-into-shell-before-jira-work).

### 5. Next skill

> Plan `{ID}` ready: {N} phase(s): {list}.
>
> **Next:** `/implement-it {ID}` → `/audit-it` → `/verify-it` → `/commit-it`.
>
> To track it in Jira, run `/plan-it {ID} --jira`. *(Omit this line after a `--jira` run.)*

## Core Tenets

- **Read-only code** during planning.
- **Full phase coverage** before any implement-it.
- **One Jira map per plan:** `jira.md`, not parallel tracker trees.
- Rejected features go to `.out-of-scope/`, as `triage` describes in its [OUT-OF-SCOPE.md](../triage/OUT-OF-SCOPE.md).

## See also

- **Work spanning more than one plan or session:** scope it with `/wayfinder` first, then run `/plan-it` per decision it resolves.
