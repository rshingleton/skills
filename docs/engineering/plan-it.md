## What it does

`plan-it` turns a request, an intake file or a Jira issue into a Doc Cycle plan under `docs/planning/<id>/`: a README with the phase table and the decisions, and one `ai-prompt.md` per phase. It always grills before it scaffolds, even when the request looks complete, because the grill is where the decisions in the README come from.

Each phase is a vertical slice with a `Blocked by` column and a `## Seams` section, so the plan is a task graph that `/implement-it` can build in parallel and test at agreed boundaries. ADRs are written only for decisions that pass domain-modeling's three tests (hard to reverse, surprising without context, a real trade-off); the rest live in the plan README.

## When to reach for it

You invoke this by typing `/plan-it`, and the agent won't reach for it on its own.

| Your situation | Reach for |
| --- | --- |
| A feature, bugfix or change needs scoping before code | `/plan-it` |
| Items are waiting in `docs/issues/` | `/plan-it --from-issues` |
| The work starts from a Jira issue | [from-jira](https://github.com/rshingleton/skills/blob/main/skills/engineering/from-jira/SKILL.md) |
| The plan should appear in Jira | `/plan-it <id> --jira` (never asked; only with the flag) |
| You only want to capture something for later | [issue-it](https://github.com/rshingleton/skills/blob/main/skills/engineering/issue-it/SKILL.md) |

## The grill and the breakdown

The grill runs in numbered rounds, each question carrying a recommended answer so "yes" accepts it. A multi-phase plan then gets one approval of the phase breakdown before any file is written. A one-phase plan folds that approval into the grill's final confirmation, so a small change has a single stop.

## Common questions

**Why didn't it write an ADR?**

Most plan decisions are cheap to reverse and are recorded in the plan README instead. An ADR is drafted only when a decision passes all three tests, and `/verify-it` accepts only ADRs that exist.

**Why doesn't it ask about Jira any more?**

Publishing is flag-only: `--jira` publishes, `--jira --sync-only` re-syncs keys into `jira.md`. Without the flag, nothing goes to Jira.

## It's working if

- Every phase in the README has a `Blocked by` entry, and independent phases say `None`.
- Every phase prompt has a `## Seams` section that says what a test there catches and misses.
- A one-phase plan stopped you once, not twice.

## Where it fits

`plan-it` opens the Doc Cycle: `/plan-it` → `/implement-it {ID}` → `/audit-it` → `/verify-it` → `/commit-it`.

- [implement-it](https://github.com/rshingleton/skills/blob/main/docs/engineering/implement-it.md) builds what this skill scaffolds, and reads the `Blocked by` edges to run phases in parallel.
- [grilling](https://aihero.dev/skills-grilling) and [domain-modeling](https://aihero.dev/skills-domain-modeling) are called for the grill and the glossary and ADR rules.

[ask-matt](https://aihero.dev/skills-ask-matt) routes the upstream set; the README's Doc Cycle section maps the `-it` skills.
