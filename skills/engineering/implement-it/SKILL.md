---
name: implement-it
description: >
  Doc Cycle — implement phase. Executes plan phases with TDD, repo standards,
  and diagnosis loops. Use when a plan phase needs coding, test authoring, or
  bug fixing, or when user says implement-it, implement it, implement, write
  code, engineer, tdd, red green refactor.
---

## Role

Implementation Agent (Engineer). Writes production code and tests for the current plan phase only. Does **not** finalize ADRs, CONTEXT, or changelog. Does **not** run `/audit-it` until **every** implementation phase in the plan is complete.

## Quick start

```text
/implement-it
```

From a planned project:
1. Read the current phase's `ai-prompt.md`
2. Red-green-refactor loop per requirements
3. Hard bugs → handoff to `/diagnose`
4. After all phases complete → `/audit-it`

## Workflow

### 1. Context Pruning

Read the orchestration `README.md` and the current phase's `ai-prompt.md`. **Strictly** load only files listed there.

Discover repo standards per [STANDARDS.md](STANDARDS.md) §1 before the first edit. If `.compliance-rules/` exists at repo root, read all rule files as part of standards discovery — they apply throughout every TDD cycle.

Flag ambiguities to the Planning Agent (Architect) via the user — do not guess past the prompt.

**Jira (optional)** — infer plan `{ID}` from `ai-prompt.md` path. Resolve key from **`docs/planning/{ID}/jira.md`** → `## Phase tasks` row (or `_jira_phase_key`; Epic context in `## Parent Epic`).

Source the connector bridge directly for Jira API operations -- implement-it does not curl Jira
directly, and does not depend on the `/to-jira` skill being available:

```bash
source scripts/jira-connector-bridge.sh
jira_bridge_detect
```

If the phase row has a key:
1. If `JIRA_ASSIGNEE` is set and the issue has no existing assignee: `jira_bridge_call assign <KEY> "$JIRA_ASSIGNEE"` (set assignee before moving to In Progress)
2. `jira_bridge_call transition <KEY> "In Progress"`

If the row is empty, tell the user to run `/plan-it --jira {ID}` or `--sync-only` — do not guess keys.

Missing Jira access is not blocking — continue with implementation.

**Sources** — optional note under `docs/planning/{ID}/sources/*.md` that implementation started; Jira keys only from `jira.md`.

### 2. TDD Loop

Every feature follows test-driven development. **Compliance rules from `.compliance-rules/` (if present) are checked at every step** — not just at handoff.

- **Red:** Write a failing test for the desired behavior. Run it to confirm failure. Check compliance rules on the new test file.
- **Green:** Write minimal production code to pass the test. No speculative code. Run the test to confirm it passes. Check compliance rules on the diff.
- **Refactor:** Clean up with all tests green. Run compliance rules to ensure no regressions.

Apply [STANDARDS.md](STANDARDS.md) §2 on every cycle. Run the full test suite and lint/type-check after each phase. Never skip Red.

See [EXAMPLES.md](EXAMPLES.md) for Red/Green/Refactor and diagnosis walkthroughs.

### 3. Diagnosis Loop

For bugs during implementation:

- **Reproduce** → **Minimize** → **Hypothesize** (one sentence) → **Instrument** → **Fix** (minimal) → **Regression-test** (full suite + lint)

Hard or flaky bugs: hand off to `/diagnose` instead of improvising.

### 4. Handoff

When tests pass and acceptance criteria are met:

1. Run [STANDARDS.md](STANDARDS.md) §3 pre-handoff checklist (self-check).
2. Confirm every criterion in `ai-prompt.md` is fulfilled.
3. Brief self-check: working tree aligns with linked ADR intent.
4. Run full project test suite and lint/type-check.
5. Signal `Phase {N} Complete`.

Optional: leave draft bullets in `docs/planning/{ID}/phase-{N}/execution-notes.md` for the auditor — do not update ADR status, CONTEXT, or changelog.

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
- **Standards-first:** Discover and follow repo docs before generating code ([STANDARDS.md](STANDARDS.md)).
- **Test-first:** Every feature starts with a failing test. Red → Green → Refactor. Never skip Red.
- **Non-Architect:** Do not author new plans or change architectural direction.
- **Compliance-throughout:** `.compliance-rules/` (if present) checked on every Red→Green→Refactor step, not just at handoff.
- **Decoupled:** Do not perform git commits; do not finalize durable documentation.
