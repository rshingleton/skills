# Plan mode: work the frontier

`/implement-it {ID}` builds every remaining phase of `docs/planning/{ID}/`. The phases are a task
graph, not a list: the plan README's `Blocked by` column gives the edges, and the **frontier** is
every phase whose blocking phases are all done (ADR-0011).

## 1. Integration branch

```bash
git branch --show-current
```

If the current branch is not `main` or `master`, it is the integration branch. Otherwise create
`plan/{ID}` from it and switch to it. Phase worktrees branch from the integration branch, so the
plan must be committed there. plan-it leaves its files uncommitted: `README.md`, `jira.md`,
`phase-*/ai-prompt.md` and `sources/` under `docs/planning/{ID}/`. Commit those by path as
`{ID}: add plan`. An uncommitted `phase-N/execution-notes.md` means phase N was interrupted:
stop and tell the user to finish it with `/implement-it docs/planning/{ID}/phase-N` or discard it.
Any other uncommitted change: stop and ask the user to commit or stash.

## 2. Compute the frontier

Read the `## Phases` table in `docs/planning/{ID}/README.md`. `Blocked by` holds `None`, phase
names, or a range (`phase-1 … phase-6` means every phase from 1 to 6).

A phase is **done** when `docs/planning/{ID}/phase-N/execution-notes.md` exists at the
integration branch tip: the single-phase flow commits it with the phase, so it lands only once
the phase is merged. Re-running plan mode resumes from there.

The frontier is every phase that is not done, not running, and whose blocking phases are all
done. One frontier phase, or a host without background subagents: go to §5. Otherwise §3.

## 3. Implementer subagents

For each frontier phase, from the repo root:

```bash
repo=$(basename "$(git rev-parse --show-toplevel)")
git worktree add "../$repo.worktrees/{ID}/phase-N" -b "plan/{ID}--phase-N" <integration branch>
```

Phase branches use `--` because git cannot hold both `plan/{ID}` and `plan/{ID}/phase-N`.

Start one background subagent per worktree. Pass pointers, not pasted content:

- the worktree path, the phase prompt `docs/planning/{ID}/phase-N/ai-prompt.md` and the plan
  README;
- the integration branch name.

Tell it to:

1. Confirm `HEAD` is the integration branch tip it was created from; if not, reset onto it.
2. Run `/implement-it docs/planning/{ID}/phase-N` (the single-phase flow in `SKILL.md`): Base
   ref, its own Jira assign and In Progress transition, `tdd`, the phase commit.
3. Merge the integration branch tip into its phase branch, with the same message prefix as the
   phase commit, calling the Skill tool with `resolving-merge-conflicts` on conflict, so the
   later merge is a fast-forward or trivial.
4. Report only the phase branch, its commit short hash, and anything blocking. Do not push.

## 4. Merge and recompute

When an implementer reports, start a **merge subagent** in the main checkout. It:

1. Merges `plan/{ID}--phase-N` into the integration branch with `git merge --no-ff`, calling
   `resolving-merge-conflicts` on conflict.
2. Runs the repo's test, lint and format commands on the result; on failure it reports the
   failure and does not commit a fix.
3. Reports the merge commit's short hash.

Merge one phase at a time. After each merge, recompute the frontier (§2) and start implementers
for newly ready phases. A phase that reports blocked, or a merge that fails checks, stops its
dependants; tell the user which phase and why, and keep working the phases that do not depend
on it.

## 5. Sequential fallback

When there is one frontier phase, or the host cannot run background subagents, build the phase
inline on the integration branch with the single-phase flow, which commits it. Recompute the
frontier and repeat. The integration branch ends with the same phase commits, without merge
commits.

## 6. Clean up

When no phase is left, or nothing more can start:

```bash
git worktree remove "../$repo.worktrees/{ID}/phase-N"   # each phase worktree
git branch -d "plan/{ID}--phase-N"                      # merged phase branches only
```

`git branch -d` refuses unmerged branches; leave those and name them to the user. Remove
`../$repo.worktrees/{ID}/` if it is empty.

Report each phase with its commit, then one `Skipped / Not checked / Risk` line gathered from the
phases' reports ([STANDARDS.md](STANDARDS.md) §4), then the next skill: every phase done means a
Full audit (`/audit-it`) on the integration branch. A single phase can still get a Single-phase
audit with `/audit-it --phase phase-N`, which reads the phase's own commits by their prefix.
