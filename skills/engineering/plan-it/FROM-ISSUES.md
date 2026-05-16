# plan-it — Start from intake issues

Use when work already exists as **pre-plan** files under `docs/issues/` (bugs, defers, todos, feature requests).

## Intake issue shape

Flat files: `docs/issues/<slug>.md`

```yaml
---
title: Short summary
type: bug | defer | todo | feature
status: intake | triaged | ready-for-plan | planned | wontfix
source: user | review | grill | doc-it | jira
planned_in:
jira_key:
---
```

Capture new intake with **`/issues-it`**, not plan-it.

## Invocation

```text
/plan-it --from-issues docs/issues/auth-bug.md docs/issues/defer-csv.md
/plan-it --from-issues ready
```

`ready` = all files with `status: ready-for-plan`.

## Process

1. **Read** each issue body and frontmatter. Summarize scope for the user.
2. **Grill** (plan-it step 1) — merge overlapping issues; confirm one plan vs multiple plans.
3. **Scaffold** `docs/planning/{ID}/` — phases derived from issues (one phase per issue or grouped slices).
4. **README.md** must include:

```markdown
## Sources
- docs/issues/auth-bug.md — …
- docs/issues/defer-csv.md — …
```

5. **Mark intake** — set each source issue `status: planned` and `planned_in: docs/planning/{ID}/`.
6. **Optional Jira** — if user wants Jira, run publish per [JIRA.md](JIRA.md) and write `jira.md`.
7. Do **not** copy full issue bodies into phase prompts — phase prompts hold execution scope; issues remain the intake record.

## After planning

> Plan `{ID}` created from {N} intake issue(s). **Next:** `/implement-it` on `phase-1/ai-prompt.md`. Jira map: `docs/planning/{ID}/jira.md` (if published).
