---
name: implement-it
description: >
  Doc Cycle implement phase. Builds one plan phase test-first at the seams the
  plan agreed, to repo standards, and commits it; given a plan ID, builds the
  whole plan, running ready phases in parallel worktrees. Use when a Doc Cycle
  plan phase needs building, or when user says implement-it, implement phase N,
  implement the plan, or continue the plan.
---

## Role

Writes production code and tests for the current plan phase only. Does **not** finalize ADRs, GLOSSARY, or changelog. Does **not** run `/audit-it` until **every** implementation phase in the plan is complete.

## Quick start

`/implement-it docs/planning/{ID}/phase-N` builds one phase inline: read its `ai-prompt.md`, build it with `tdd` at its `## Seams`, hand hard bugs to `diagnosing-bugs`, commit.

`/implement-it {ID}` builds the whole plan by its frontier, in parallel worktrees where the host allows: follow [FRONTIER.md](FRONTIER.md), which runs the single-phase workflow below for each phase.

## Workflow

### 1. Context Pruning

Read the orchestration `README.md` and the current phase's `ai-prompt.md`. Its `## Starting points` are hints to read first, not a whitelist: read whatever else the phase's scope needs, and keep to the behaviour the prompt asks for.

Before the first edit, discover repo standards and tooling per [STANDARDS.md](STANDARDS.md) §1, and write `Base ref: <output of git rev-parse HEAD>` to `docs/planning/{ID}/phase-{N}/execution-notes.md`: the commit the phase starts from. `/audit-it --phase` reads the phase's prefixed commits since it (§4).

Flag ambiguities to the user; do not guess past the prompt.

**Jira (optional)** — infer plan `{ID}` from `ai-prompt.md` path. Resolve key from **`docs/planning/{ID}/jira.md`** → `## Phase tasks` row (or `_jira_phase_key`; Epic context in `## Parent Epic`).

Source the connector bridge directly for Jira API operations -- implement-it does not curl Jira directly, and does not depend on the `/to-jira` skill being available:

```bash
source ~/.agents/skills/setup-internal-skills/scripts/jira-connector-bridge.sh 2>/dev/null ||
  source scripts/jira-connector-bridge.sh
jira_bridge_detect
```

If the phase row has a key:
1. If the issue has no assignee: resolve one (the name the user gave, else `JIRA_ASSIGNEE`; if neither is set, ask, recommending the authenticated Jira user) and run `jira_bridge_call assign <KEY> "$ASSIGNEE"` before moving to In Progress. An existing assignee is left alone. See `setup-internal-skills/issue-tracker-jira.md` "Assignee".
2. `jira_bridge_call transition <KEY> "In Progress"`

If the row is empty, tell the user to run `/plan-it --jira {ID}` or `--sync-only`; do not guess keys. Missing Jira access is not blocking: continue with implementation.

**Sources** — optional note under `docs/planning/{ID}/sources/*.md` that implementation started; Jira keys only from `jira.md`.

### 2. Build with tdd

Call the Skill tool with "tdd" and follow its red, green loop. Pass it the phase prompt's `## Seams` section and say that these seams were agreed during planning, so `tdd` writes tests only at them and does not ask the user to confirm them again.

If the phase prompt has no `## Seams` section (a plan written before seams were scaffolded), propose seams yourself, each with a one-line note on what it catches and what it misses, and confirm them with the user once, before the first test. End the turn and wait for the answer.

Refactoring and judgement-call standards are not part of the loop; they belong to review. Follow [STANDARDS.md](STANDARDS.md) §2 while coding, and run the repo's automated checks (test, lint, format, type-check) after each phase. `.compliance-rules/` is checked by `/audit-it`.

### 3. Hard bugs

A failure you can explain in one hypothesis and fix directly stays in the loop. A failure you cannot, one that is flaky, or one still failing after three fix rounds goes to diagnosis. At the third failed round stop iterating, name the assumption that may be wrong, then call the Skill tool with "diagnosing-bugs", passing it that assumption, and follow it until the fix and its regression test are in. Then resume the loop.

### 4. Handoff

When tests pass and acceptance criteria are met:

- Run the [STANDARDS.md](STANDARDS.md) §3 pre-handoff checklist.
- Confirm every criterion in `ai-prompt.md` is fulfilled and the changes match linked ADR intent.
- Optional: add draft bullets for the auditor to `execution-notes.md` below the Base ref; do not update ADR status, GLOSSARY, or changelog.
- Commit the phase on the current branch: stage the files this phase changed (its `execution-notes.md` included) by path, never `git add -A`, and commit with a message prefixed by the phase's Jira key from `jira.md`, else by the plan ID and phase (`PROJ-12: <summary>` or `{ID} phase-N: <summary>`). Later fixes to the phase, such as audit fixes, use the same prefix: `/audit-it --phase` selects the phase's commits by it. Do not push.
- Signal `Phase {N} Complete` per [STANDARDS.md](STANDARDS.md) §4: the first line says what happened, with the commit's short hash; a `Skipped / Not checked / Risk` line; the last line says what to do next.

### 5. Next skill

Plan mode reports per [FRONTIER.md](FRONTIER.md) §6. A phase built inside plan mode reports to it and stops here. Otherwise read the orchestration `README.md` phase list and compare against the phase you just finished.

**More implementation phases remain** (e.g. `phase-{N+1}/ai-prompt.md` exists, or README lists phases not yet complete):

> Phase {N} implementation complete ({hash}): {what it delivers}.
>
> Skipped: {…}. Not checked: {…}. Risk: {…}.
>
> **Next:** Run `/implement-it {ID}` for the remaining phases, or `/implement-it` on `docs/planning/{ID}/phase-{N+1}/ai-prompt.md` for one; a Single-phase audit (`/audit-it --phase phase-{N}`) first gives early feedback.

Still implementing: do **not** suggest a Full audit (`/audit-it`) or `/verify-it`.

**This was the last implementation phase** (all phases in the plan are implemented):

> All {N} implementation phases complete ({hash}).
>
> Skipped: {…}. Not checked: {…}. Risk: {…}.
>
> **Next:** Run a Full audit (`/audit-it`), then `/verify-it` to finalize docs.

## Core Tenets

- **Spec-bound:** `ai-prompt.md` and linked ADRs are the scope contract — not the whole backlog.
- **Standards-first:** Discover repo docs and tooling before generating code ([STANDARDS.md](STANDARDS.md)); review enforces the judgement calls.
- **Test-first:** Every feature starts with a failing test at an agreed seam; the `tdd` skill owns the loop.
- **Non-Architect:** Do not author new plans or change architectural direction.
- **Commit per phase:** Each phase ends in one commit on the current branch; pushing and the docs commit belong to `/commit-it`.
- **Decoupled:** Do not finalize durable documentation.
