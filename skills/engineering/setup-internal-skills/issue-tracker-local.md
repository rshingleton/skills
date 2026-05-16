# Issue tracker: Local markdown (`docs/issues/`)

**Pre-plan intake** — bugs, defers, todos, and feature requests captured before `/plan-it`. Doc Cycle execution and Jira phase mapping live under **`docs/planning/<plan-id>/`** (`jira.md` for keys).

## Layout

```
docs/issues/
├── README.md
├── auth-token-refresh.md
├── defer-legacy-csv.md
└── feature-export-api.md
```

```
docs/planning/<plan-id>/
├── README.md          # orchestration + ## Sources → intake paths
├── jira.md            # phase ↔ Jira (canonical)
├── phase-1/ai-prompt.md
└── phase-2/ai-prompt.md
```

Do **not** mirror plan phases as `docs/issues/<slug>/tasks/` — that duplicates the plan and breaks the model.

## Intake frontmatter

```yaml
---
title: Short summary
type: bug | defer | todo | feature
status: intake | triaged | ready-for-plan | planned | wontfix
source: user | review | grill | doc-it | jira
planned_in:              # docs/planning/<id>/ after plan-it
jira_key:                # only if intake came from existing Jira
---
```

Triage strings: `docs/agents/triage-labels.md`. Append history under `## Comments`.

## Capture intake

**`/issues-it`** — creates `docs/issues/<slug>.md`. See [INTAKE-TEMPLATE.md](../../issues-it/INTAKE-TEMPLATE.md).

## Plan from intake

**`/plan-it --from-issues`** — reads intake files, scaffolds plan, sets `planned_in` and `status: planned` on sources. Optional **`--jira`** writes `docs/planning/<id>/jira.md`. See [FROM-ISSUES.md](../../plan-it/FROM-ISSUES.md) and [JIRA.md](../../plan-it/JIRA.md).

## Jira during Doc Cycle

| Action | Where |
|--------|--------|
| Phase ↔ Jira keys | `docs/planning/<id>/jira.md` only |
| Publish / sync | `/plan-it --jira` or `--jira --sync-only` |
| implement / verify Jira updates | Read current phase row from `jira.md` |

Epic pull-back: [jira-epic-sync.md](./jira-epic-sync.md).

## Resolving Jira for implement-it / verify-it

Given plan `{ID}` and current `phase-N`:

1. Open `docs/planning/{ID}/jira.md` → table row for `phase-N` → **Jira** column (or shell: `_jira_phase_key "{ID}" "phase-N"` — [issue-tracker-jira.md](./issue-tracker-jira.md#helper-functions-copy-into-shell-before-jira-work)).
2. If empty and user expects Jira, stop — run `/plan-it {ID} --jira --sync-only` (re-sync keys) or `/plan-it {ID} --jira` (sync + create missing).
3. Intake files in README `## Sources` — optional comment that plan completed; do **not** use intake files for phase Jira keys.

**Update functions on Jira writes:** `_jira_set_assignee`, then transition/comment, then `_jira_apply_watcher_policy` — see [issue-tracker-jira.md](./issue-tracker-jira.md).

## Legacy

- `docs/issues/<slug>/epic.md` + `tasks/` trees — migrate to intake file + `/plan-it`, or archive.
- `.scratch/` — migrate to `docs/issues/`.
