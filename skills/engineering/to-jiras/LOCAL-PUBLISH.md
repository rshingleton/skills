# To Jiras — Local publish (`docs/issues/`)

Use when `docs/agents/issue-tracker.md` describes **local markdown** tracking (default after `/setup-internal-skills`).

## Feature slug

Derive `<feature-slug>` from the plan name, user argument, or conversation. Use kebab-case.

## Epic (optional)

If breaking down from an Epic and no `docs/issues/<slug>/epic.md` exists yet, create it from the epic template in [to-epic](../to-epic/SKILL.md) local section, or skip if tasks are standalone.

## Publish each Task

For each approved vertical slice, create:

`docs/issues/<feature-slug>/tasks/<NN>-<slug>.md`

`<NN>` is two digits starting at `01`. Frontmatter:

```yaml
---
title: <Task title>
type: task
status: ready-for-agent
jira_key:
planning_id:
blocked_by: []
labels: [vertical-slice, ai-generated]
---
```

Body uses the same sections as the Jira issue template in [SKILL.md](SKILL.md) (`## What to build`, `## Acceptance criteria`, `## Blocked by`). Use local paths in `blocked_by` until promotion (e.g. `tasks/01-parse-core.md`).

## Parent epic (local)

If slicing under an existing local epic, set in each task body:

```markdown
## Parent Epic

docs/issues/<slug>/epic.md
```

## After publish

Tell the user:

> Created {N} tasks under `docs/issues/<feature-slug>/tasks/`.
>
> **Next:** `/implement-it` when ready, or `/promote-to-jira <feature-slug>` to push to Jira.

Do not call the Jira API in local mode.
