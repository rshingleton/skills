## What it does

`audit-it` is the independent check between building and closing a Doc Cycle plan. It runs mechanical checks and the repo's `.compliance-rules/`, gets Spec and Standards findings from [code-review](https://aihero.dev/skills-code-review), and checks the change against the plan's ADRs. It never fixes what it finds.

The report ends with one `Verdict:` line, and only Must findings block. Should and Nice findings are notes that `/verify-it` carries into the record. A decision the plan or an ADR already recorded, or a `shortcut:` comment that names its limit, is not a finding.

## When to reach for it

You invoke this by typing `/audit-it`, and the agent won't reach for it on its own.

| Mode | Invocation | Use |
| --- | --- | --- |
| Full audit | `/audit-it` | After every phase; the gate on `/verify-it` |
| Per-phase audit | `/audit-it --phases` | After every phase, each audited on its own, one report |
| Single-phase audit | `/audit-it --phase phase-N` | Early feedback on one phase, diffed from its `Base ref` |
| Repo audit | `/audit-it repo` | Tech-debt pass not tied to a plan; writes `docs/AUDIT.md` |

For a review of any branch outside the Doc Cycle, use [code-review](https://aihero.dev/skills-code-review) directly.

## Findings

Each finding states where it is, the problem, the fix and the cost of skipping it, graded Must, Should or Nice. Mechanical rules that a linter or hook could enforce are listed as guardrail candidates instead of being left to judgement next time.

## It's working if

- The report's last lines are `Verdict:` and `Not checked:`.
- A Single-phase audit's diff covers that phase's files and nothing from its neighbours.
- A deliberate, recorded trade-off does not come back as a finding.

## Where it fits

Chain step three: `/plan-it` → `/implement-it {ID}` → `/audit-it` → `/verify-it` → `/commit-it`.

- [implement-it](https://github.com/rshingleton/skills/blob/main/docs/engineering/implement-it.md) records the `Base ref` this skill diffs from.
- [verify-it](https://github.com/rshingleton/skills/blob/main/docs/engineering/verify-it.md) runs only on a PASS.

[ask-matt](https://aihero.dev/skills-ask-matt) routes the upstream set; the README's Doc Cycle section maps the `-it` skills.
