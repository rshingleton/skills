# ADR-0011: implement-it Works the Frontier in Parallel and Commits Each Phase

**Status:** Accepted
**Date:** 2026-10-19
**Author:** Russell Shingleton
**Plan:** `docs/planning/doc-cycle-parallel/`
**Supersedes:** ADR-0010, the consequence that parallel implementation is deferred because
`commit-it` owns commits.

## Context

Since ADR-0010, plan phases carry blocking edges, so a plan is a task graph like upstream's
tickets. implement-it still builds one phase at a time and never commits. Every phase in a plan
shares one uncommitted working tree, so a phase's diff from its start ref also contains the
earlier phases' work, and `/audit-it --phase` cannot isolate a phase. Upstream's
`implement-spec` already builds a ticket graph in parallel: one subagent and worktree per ready
ticket, merged into an integration branch. That needs per-ticket commits.

## Decision

1. `/implement-it {ID}` works the plan's **frontier**. When more than one phase is ready, each
   runs in a subagent with its own worktree (`../<repo>.worktrees/{ID}/phase-N`) and **phase
   branch** (`plan/{ID}--phase-N`), and a merge subagent merges each finished phase into the
   **integration branch** (the current branch unless it is `main`, else `plan/{ID}`). A linear
   plan runs sequentially. A host without background subagents builds the frontier
   sequentially on the integration branch.
2. implement-it **commits each phase**. `execution-notes.md` records the phase's **Base ref**,
   the commit it branched from. Phase commits carry the phase's Jira key, else `{ID} phase-N`,
   as subject prefix, and later fixes to the phase reuse it. Single-phase audit reads the
   non-merge commits since the Base ref with that prefix, so sibling phases merged into a phase
   branch stay out; full audit diffs the integration branch from its merge-base with `main`.
3. commit-it keeps the compliance gate, commits the docs verify-it changed, offers to squash the
   unpushed integration branch into one commit, and pushes or opens a PR only on approval.

## Alternatives considered

- **Keep phases uncommitted, record an end ref per phase:** no ref exists for uncommitted work,
  and it still rules out worktrees.
- **Call `implement-spec` directly:** it reads specs and tickets from a tracker, closes tickets
  itself and has no Base ref, Jira map or audit gate. Mirroring its model inside implement-it
  keeps the Doc Cycle's gates.

## Consequences

- Phases can run concurrently, and per-phase audits see only that phase.
- Phase commits land before audit. A failed audit is fixed with further commits on the phase or
  integration branch, not by discarding a working tree.
- commit-it no longer groups code changes by Jira key; phase commits carry the key at creation.
- A plan adds one commit per phase plus a docs commit to its branch. Phase commits are working
  checkpoints; teams that want one commit per plan take commit-it's squash offer or squash-merge
  the PR.
- `Start ref` is retired in favour of `Base ref`.

## Execution Notes

Implemented in seven phases on `plan/doc-cycle-parallel`. Phases 1 and 2 were built one at a
time; `/implement-it doc-cycle-parallel` then built phases 3, 4 and 6 in parallel worktrees,
phase 5 once phase 3 merged, and phase 7 last. The full audit failed twice and passed on the
third pass.

- **Commit per phase** (phase 1): implement-it writes `Base ref:` before its first edit and
  commits the phase at handoff. commit-it keeps the compliance gate, one docs commit, an
  approval-gated squash of the unpushed branch (added after review: per-phase commits read as
  noise on `main`), and push or PR on approval.
- **Frontier** (phase 2): `implement-it/FRONTIER.md`. Dry runs on a three-phase toy plan
  covered parallel worktrees, a seeded merge conflict handed to `resolving-merge-conflicts`,
  and the sequential fallback. A single ready phase builds inline, not in a worktree. Phase 7's
  end-to-end run forced two fixes: plan mode commits plan-it's uncommitted files, and the
  phase-branch merge reuses the phase prefix.
- **Single-phase range, amended at audit:** a phase branch also holds the integration tip merged
  into it, so `Base ref..phase branch` included sibling phases. The audit selects the phase's
  non-merge commits since its Base ref by subject prefix, `^<Jira key>:` or `^{ID} phase-N:`,
  colon required so `PROJ-1` does not match `PROJ-12`. Later fix commits reuse the prefix.
  Phases 1 to 7 of this plan predate the convention and use `doc-cycle-parallel:`.
- **Plan mode resume:** a phase is done when its `execution-notes.md` is on the integration
  branch. Plan mode commits only plan-it's files and stops on an uncommitted
  `execution-notes.md`, which marks an interrupted phase.
- **Compliance:** ai-skills-style-guide.md §4 (HIGH) says to leave git commands to the developer.
  The audit treated the git steps here as this ADR's recorded decision: none is destructive, and
  squash and push are approval-gated. §4 is not yet amended to match.
- **Open (non-blocking audit notes):**
  - Amend ai-skills-style-guide.md §4 to allow approved, non-destructive git steps an ADR records.
  - `implement-it/SKILL.md` is exactly 100 lines (§2 says under 100).
  - Numbered workflow lists (style guide §3) conflict with coding-standards-markdown.md, which
    allows ordered sequential steps; soft verbs remain in `plan-it/SKILL.md:13`,
    `commit-it/SKILL.md:33`, `FRONTIER.md`.
  - The prefixed-commit rule is restated in nine places; `prune_stale_links` is duplicated in
    `scripts/link-skills.sh` and `scripts/skills.sh`.
  - `PHASE-AUDIT.md` drops body-line grep matches by hand; a subject-only command would make it
    mechanical.
  - A skill under `~/.claude/skills` shadows a project skill of the same name, so dry runs of an
    edited skill must load it under another name.
