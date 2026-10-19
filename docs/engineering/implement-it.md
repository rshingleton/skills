## What it does

`implement-it` builds a Doc Cycle plan. Given one phase, it builds it inline: test-first with [tdd](https://aihero.dev/skills-tdd) at the seams the plan agreed, to the repo's standards, ending in one commit. Given a plan ID, it works the plan's **frontier**: every phase whose `Blocked by` phases are done.

When two or more phases are ready at once, each gets its own [subagent](https://www.aihero.dev/ai-coding-dictionary/subagent), git worktree and `plan/{ID}--phase-N` branch, and the phases merge one at a time into the integration branch before the next frontier starts. Every phase records the commit it started from (`Base ref`) in its `execution-notes.md`, so `/audit-it` can diff exactly that phase.

## When to reach for it

You invoke this by typing `/implement-it`, and the agent won't reach for it on its own.

| Invocation | What happens |
| --- | --- |
| `/implement-it {ID}` | Builds every remaining phase; ready phases in parallel worktrees |
| `/implement-it docs/planning/{ID}/phase-N` | Builds that one phase inline on the current branch |
| A host without background subagents | Builds the frontier one phase after another, still one commit each |

The integration branch is the current branch, or `plan/{ID}` when you start on `main`. An uncommitted plan directory is committed first (`{ID}: add plan`); any other uncommitted change stops the run.

## Commit per phase

Each phase ends in one commit prefixed with its Jira key from `jira.md`, else `{ID} phase-N`. Nothing is pushed: pushing, the docs commit and an optional squash belong to `/commit-it`. A failure it cannot explain in one hypothesis, or one still failing after three fix rounds, goes to [diagnosing-bugs](https://aihero.dev/skills-diagnosing-bugs) instead of a fourth guess.

## Common questions

**Where did `Start ref` go?**

It is now `Base ref`: the commit the phase branched from. A Single-phase audit reads the phase's own commits since `Base ref`, selected by their prefix (`{ID} phase-N:` or the phase's Jira key); a Full audit diffs the integration branch from its fork point with `main`.

**Two parallel phases touched the same file. What happens?**

The phase subagent merges the integration branch into its phase branch before reporting, calling [resolving-merge-conflicts](https://aihero.dev/skills-resolving-merge-conflicts) on conflict, so the final merge is trivial.

## It's working if

- Each phase shows up in `git log` as one commit with its prefix (`{ID} phase-N:` or its Jira key), plus any later fix commits under the same prefix.
- Independent phases ran at the same time, and the worktrees are gone when it finishes.
- Each closing message starts with what happened and its commit hash, carries a `Skipped / Not checked / Risk` line, and ends with the next step.

## Where it fits

Chain step two: `/plan-it` → `/implement-it {ID}` → `/audit-it` → `/verify-it` → `/commit-it`.

- [plan-it](https://github.com/rshingleton/skills/blob/main/docs/engineering/plan-it.md) supplies the phases, edges and seams.
- [audit-it](https://github.com/rshingleton/skills/blob/main/docs/engineering/audit-it.md) reviews the result once every phase is in.

[ask-matt](https://aihero.dev/skills-ask-matt) routes the upstream set; the README's Doc Cycle section maps the `-it` skills.
