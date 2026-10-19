## What it does

`commit-it` closes a Doc Cycle plan. The code is already committed, one commit per phase, by `/implement-it`; commit-it runs the compliance gate, commits the docs `/verify-it` changed in one key-prefixed commit, offers to squash the unpushed branch, and pushes or opens a PR only when you approve.

It never pushes to `main` directly and never pushes without a yes. It is not a code review.

## When to reach for it

You invoke this by typing `/commit-it`, and the agent won't reach for it on its own. Reach for it after `/verify-it`. For a branch review, use [code-review](https://aihero.dev/skills-code-review); for the compliance scan on its own, use `/internal-compliance`.

## The stops

| Stop | What you decide |
| --- | --- |
| Compliance findings | Fix first, or proceed with low-severity ones |
| Docs commit | Approve or edit the message |
| Squash | One commit for the branch, or keep the phase history |
| Push or PR | Only on approval; skipped when there is no remote |

## It's working if

- The docs commit holds only verify-it's files: ADRs, `GLOSSARY.md`, the changelog and the planning removal.
- Nothing left the machine until you said so.

## Where it fits

Chain step five, the last: `/plan-it` → `/implement-it {ID}` → `/audit-it` → `/verify-it` → `/commit-it`.

- [verify-it](https://github.com/rshingleton/skills/blob/main/docs/engineering/verify-it.md) produces the docs it commits.
- [pr](https://aihero.dev/skills-pr) shapes the PR body when you choose a PR.

[ask-matt](https://aihero.dev/skills-ask-matt) routes the upstream set; the README's Doc Cycle section maps the `-it` skills.
