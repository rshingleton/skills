## What it does

`verify-it` finalizes a plan's durable docs after `/audit-it` passes: it accepts the ADRs the plan linked, merges new terms into `GLOSSARY.md`, writes the changelog entry and removes the planning directory. It does not audit, stage or commit; if the audit report is missing or its verdict is FAIL, it stops.

A plan with no ADR keeps its decisions in the changelog entry's execution notes, so nothing the grill decided is lost when `docs/planning/<id>/` goes away.

## When to reach for it

You invoke this by typing `/verify-it`, and the agent won't reach for it on its own.

| Invocation | Use |
| --- | --- |
| `/verify-it` | After a Full or Per-phase audit PASS; closes the whole plan |
| `/verify-it --phase phase-N` | After a Single-phase audit PASS; per-phase notes and Jira only, no changelog or cleanup |

## Prerequisites

A passing `audit-report.md` (or `audit-report-phase-N.md`) under the plan directory.

## Common questions

**Where do the audit's Should and Nice findings go?**

Into the execution notes: the ADR's, or the changelog entry's when there is no ADR. An undecided finding is recorded as Open.

**What happens to `shortcut:` comments?**

A marker with no upgrade trigger is offered to the inbox under `docs/issues/`.

## It's working if

- The changelog entry reads as the plan's permanent record: what shipped, what was decided, what was left out.
- `docs/planning/<id>/` is gone and nothing is staged.

## Where it fits

Chain step four: `/plan-it` → `/implement-it {ID}` → `/audit-it` → `/verify-it` → `/commit-it`.

- [audit-it](https://github.com/rshingleton/skills/blob/main/docs/engineering/audit-it.md) is its gate.
- [commit-it](https://github.com/rshingleton/skills/blob/main/docs/engineering/commit-it.md) commits what this skill changed.

[ask-matt](https://aihero.dev/skills-ask-matt) routes the upstream set; the README's Doc Cycle section maps the `-it` skills.
