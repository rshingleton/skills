# Issue tracker: Local markdown

**Inbox** (`docs/issues/`) holds **unplanned** intake only. Once `/plan-it --from-issues` runs, files **move** to `docs/planning/<plan-id>/sources/`. Execution and Jira keys live on the plan (`phase-N/`, `jira.md`).

## Layout

**Active inbox** (single `.md` per item):

```
docs/issues/
├── README.md
├── auth-token-refresh.md      # status: ready-for-plan
└── wontfix/                   # optional — closed without a plan
    └── old-idea.md
```

**Plan** (intake + execution):

```
docs/planning/<plan-id>/
├── README.md
├── jira.md
├── sources/                   # intake files moved here at plan creation
│   ├── auth-token-refresh.md
│   └── defer-legacy-csv.md
├── phase-1/ai-prompt.md
└── phase-2/ai-prompt.md
```

Do **not** leave `status: in-plan` files in `docs/issues/`. Do **not** mirror phases as `docs/issues/<slug>/tasks/`.

## Inbox frontmatter

```yaml
---
title: Short summary
type: bug | defer | todo | feature
status: intake | triaged | ready-for-plan | wontfix
source: user | email | servicenow | review | grill | doc-it | improve-codebase-architecture | audit-it | jira
external_id:
requester:
received:
jira_key:              # only if intake came from existing Jira
---
```

## Under-plan frontmatter (in `sources/`)

```yaml
---
title: Short summary
type: bug | defer | todo | feature
status: in-plan              # verify-it → done
source: user | email | servicenow | review | grill | doc-it | improve-codebase-architecture | audit-it | jira
external_id:
requester:
received:
moved_from: docs/issues/<slug>.md
jira_key:
---
```

Triage: **`/triage`** updates `status` and `## Comments` per [triage-labels.md](triage-labels.md). Capture new items with **`/issues-it`** (or `/triage` create — same file shape). See [TRACKER-ROUTING.md](../../triage/TRACKER-ROUTING.md).

## Capture intake

**`/issues-it`** — creates `docs/issues/<slug>.md` only. See [INTAKE-TEMPLATE.md](../../issues-it/INTAKE-TEMPLATE.md).

## Plan from intake

**`/plan-it --from-issues`** — reads inbox, scaffolds plan, **moves** each file to `docs/planning/<id>/sources/`, updates README `## Sources`. See [FROM-ISSUES.md](../../plan-it/FROM-ISSUES.md).

## Jira during Doc Cycle

| Action | Where |
|--------|--------|
| Phase ↔ Jira keys | `docs/planning/<id>/jira.md` (`## Parent Epic` + `## Phase tasks`) |
| Publish / sync | `/plan-it --jira` or `--jira --sync-only` |
| implement / verify Jira | `jira.md` phase row |

## Resolving Jira for implement-it / verify-it

1. `docs/planning/{ID}/jira.md` → row for `phase-N` (or `_jira_phase_key`).
2. Source context: `docs/planning/{ID}/sources/*.md` if needed — **not** `docs/issues/`.

## verify-it and archive

- Append completion notes on `sources/*.md`; set `status: done`.
- When purging planning, move whole `docs/planning/{ID}/` (including `sources/`) to `docs/archive/planning/{ID}/` if preserving history.

## Legacy

- `docs/issues/<slug>/epic.md` + `tasks/` — split into inbox intake + `/plan-it`, or archive.
- `.scratch/` — migrate to `docs/issues/`.
