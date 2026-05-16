---
name: issues-it
description: >
  Capture pre-plan intake under docs/issues/ (bugs, defers, todos, features).
  Does not create plans or Jira phase tasks — use plan-it for that. Use
  issues-it, report issue, defer, intake, to-epic and to-jiras are deprecated.
---

# Issues It

**Intake only** — record work **before** a Doc Cycle plan exists. Audit skills (`/doc-it`, `/improve-codebase-architecture`, `/audit-it` repo) may create files here via [audit-to-issues.md](../setup-internal-skills/audit-to-issues.md).

| Use | Skill |
|-----|--------|
| Bug, defer, todo, feature request, review follow-up | **`/issues-it`** |
| Groom inbox status / triage notes | **`/triage`** (local) — same files, updates `status` + `## Comments` |
| Grill → plan → optional Jira | **`/plan-it`** ([FROM-ISSUES.md](../plan-it/FROM-ISSUES.md), [JIRA.md](../plan-it/JIRA.md)) |
| Implement a plan phase | **`/implement-it`** |

**Read `docs/agents/issue-tracker.md` first** — run `/setup-internal-skills` if missing.

## Layout

Flat files under `docs/issues/`:

```
docs/issues/
├── README.md
├── auth-token-refresh.md
└── defer-legacy-csv.md
```

**Inbox only** — once `/plan-it --from-issues` runs, files move to `docs/planning/<id>/sources/`. Not used for phases or `jira.md`.

## Capture process

1. Derive `<slug>.md` (kebab-case, unique).
2. Write `docs/issues/<slug>.md`:

```yaml
---
title: Short summary
type: bug | defer | todo | feature
status: intake
source: user | email | servicenow | review | grill | doc-it | improve-codebase-architecture | audit-it | jira
external_id:
requester:
received:
jira_key:
---
```

Body: [INTAKE-TEMPLATE.md](INTAKE-TEMPLATE.md).

3. Set `status: triaged` or `ready-for-plan` when groomed.
4. Tell user:

> Saved `docs/issues/<slug>.md`. **Next:** `/plan-it --from-issues docs/issues/<slug>.md` when ready to plan.

## Status flow (inbox only)

```
intake → triaged → ready-for-plan → (plan-it moves to planning/<id>/sources/, status in-plan)
                  ↘ wontfix
```

After move, lifecycle continues under `docs/planning/<id>/sources/` (`in-plan` → `done` at verify-it).

## Optional: link existing Jira

If reporting from an existing ticket, set `jira_key` on the intake file only. Plan-it will map phases in `jira.md` when publishing.

## Deprecated (use plan-it)

| Old | Replacement |
|-----|-------------|
| `/to-epic`, `/to-jiras` | Large **feature** intake → `/issues-it` then `/plan-it --from-issues` |
| `/promote-to-jira`, `/issues-it --jira` | `/plan-it --jira` |
| `/issues-it --from-plan` | Built into `/plan-it` scaffold + optional `--jira` |
| `docs/issues/<slug>/tasks/` for phases | `docs/planning/<id>/phase-N/` + `jira.md` |

See [EXAMPLES.md](EXAMPLES.md).
