---
name: implement-it
description: >
  Doc Cycle implement phase. Builds one plan phase test-first at the seams the
  plan agreed, to repo standards. Use when a Doc Cycle plan phase needs building,
  or when user says implement-it, implement phase N, implement the plan, or
  continue the plan.
---

## Role

Implementation Agent (Engineer). Writes production code and tests for the current plan phase only. Does **not** finalize ADRs, GLOSSARY, or changelog. Does **not** run `/audit-it` until **every** implementation phase in the plan is complete.

## Quick start

From a planned project, `/implement-it`:
- Read the current phase's `ai-prompt.md`
- Build it with the `tdd` skill at the phase's `## Seams`
- Hard bugs: hand off to `diagnosing-bugs`
- After all phases complete: `/audit-it`

## Workflow

### 1. Context Pruning

Read the orchestration `README.md` and the current phase's `ai-prompt.md`. **Strictly** load only files listed there.

Before the first edit, discover repo standards and tooling per [STANDARDS.md](STANDARDS.md) §1, and write `Start ref: <output of git rev-parse HEAD>` to `docs/planning/{ID}/phase-{N}/execution-notes.md`. `/audit-it` diffs the phase from it.

Flag ambiguities to the Planning Agent (Architect) via the user — do not guess past the prompt.

**Jira (optional)** — infer plan `{ID}` from `ai-prompt.md` path. Resolve key from **`docs/planning/{ID}/jira.md`** → `## Phase tasks` row (or `_jira_phase_key`; Epic context in `## Parent Epic`).

Source the connector bridge directly for Jira API operations -- implement-it does not curl Jira
directly, and does not depend on the `/to-jira` skill being available:

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

A failure you can explain in one hypothesis and fix directly stays in the loop. A failure you cannot, or one that is flaky, goes to diagnosis: call the Skill tool with "diagnosing-bugs" and follow it until the fix and its regression test are in, then resume the loop.

### 4. Handoff

When tests pass and acceptance criteria are met:

- Run the [STANDARDS.md](STANDARDS.md) §3 pre-handoff checklist.
- Confirm every criterion in `ai-prompt.md` is fulfilled and the working tree matches linked ADR intent.
- Signal `Phase {N} Complete`.

Optional: add draft bullets for the auditor to `execution-notes.md` below the start ref; do not update ADR status, GLOSSARY, or changelog.

### 5. Next skill

Read the orchestration `README.md` phase list. Compare against the phase you just finished.

**More implementation phases remain** (e.g. `phase-{N+1}/ai-prompt.md` exists, or README lists phases not yet complete):

> Phase {N} implementation complete.
>
> **Next:** Run `/implement-it` on `docs/planning/{ID}/phase-{N+1}/ai-prompt.md`.
>
> For early feedback on this phase, run `/audit-it --phase phase-{N}` before continuing.

Still implementing — do **not** suggest full `/audit-it` or `/verify-it`.

**This was the last implementation phase** (all phases in the plan are implemented):

> All {N} implementation phases complete.
>
> **Next:** Run `/audit-it` to audit the full implementation, then `/verify-it` to finalize docs.

## Core Tenets

- **Spec-bound:** `ai-prompt.md` and linked ADRs are the scope contract — not the whole backlog.
- **Standards-first:** Discover repo docs and tooling before generating code ([STANDARDS.md](STANDARDS.md)); review enforces the judgement calls.
- **Test-first:** Every feature starts with a failing test at an agreed seam; the `tdd` skill owns the loop.
- **Non-Architect:** Do not author new plans or change architectural direction.
- **Decoupled:** Do not perform git commits; do not finalize durable documentation.
