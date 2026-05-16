# Issue tracker: Local markdown (`docs/issues/`)

Issues and Epics for this repo live as markdown under **`docs/issues/`**. Jira is optional — use `/promote-to-jira` when you want to push local tracking to Jira.

## Layout

```
docs/issues/
└── <feature-slug>/
    ├── epic.md              # Epic body (`type: epic`)
    └── tasks/
        ├── 01-<slug>.md
        └── 02-<slug>.md
```

Optional cross-links:

- `docs/planning/<plan-id>/` — Doc Cycle plans; reference from epic frontmatter via `planning_id`
- After Jira promotion, each file records `jira_key` in frontmatter

## Frontmatter (required on every issue file)

```yaml
---
title: Short summary
type: epic | task
status: needs-triage | needs-info | ready-for-agent | ready-for-human | wontfix | in-progress | done
jira_key:              # empty until /promote-to-jira; then e.g. MT-123
planning_id:           # optional — docs/planning/<id>/
blocked_by: []         # local task paths or Jira keys after promote
---
```

Triage roles use the strings in `docs/agents/triage-labels.md`. Record changes by updating `status` in frontmatter and appending under `## Comments`.

## When a skill says "publish to the issue tracker"

Create or update files under `docs/issues/<feature-slug>/` (create directories as needed). Do **not** call Jira unless the user explicitly runs `/promote-to-jira` or the repo is configured for Jira in `docs/agents/issue-tracker.md`.

## When a skill says "fetch the issue"

Read the markdown file at the path the user gave, or resolve from `docs/issues/<feature-slug>/tasks/<NN>-<slug>.md`.

## Promote to Jira

When planning and local issues are stable, run **`/promote-to-jira`** to create matching Epic/Tasks in Jira and backfill `jira_key` on each file.

## Legacy `.scratch/`

Older repos may still use `.scratch/<feature>/` (including legacy `PRD.md` files). Migrate to `docs/issues/<slug>/epic.md`. Prefer `docs/issues/` for new work.
