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

## Workflow

### 1. Context Pruning

Read the orchestration `README.md` and the current phase's `ai-prompt.md`. **Strictly** load only files listed there.

Discover repo standards per [STANDARDS.md](STANDARDS.md) §1 before the first edit.

Flag ambiguities to the Planning Agent (Architect) via the user — do not guess past the prompt.

**Issue tracker** — `docs/agents/issue-tracker.md` should have been provided — run `/setup-internal-skills` if missing. Then:

- **Local:** If this phase maps to `docs/issues/...`, set frontmatter `status: in-progress` and append a dated note under `## Comments`.
- **Jira:** If `JIRA_ASSIGNEE` is set, `_jira_set_assignee "$KEY"` ([issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md#assignee-jira_assignee)). Transition to "In Progress" with `?notifyUsers=false`, then `_jira_apply_watcher_policy "$KEY" update` ([jira-notifications.md](../setup-internal-skills/jira-notifications.md)). Ask for the key if unknown.

### 2. TDD Loop

Every feature follows test-driven development:

- **Red:** Failing test for the desired behavior. Confirm it fails.
- **Green:** Minimal production code to pass. No speculative code.
- **Refactor:** Clean up with all tests green.

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

Do **not** suggest `/audit-it` or `/verify-it` yet.

**This was the last implementation phase** (all phases in the plan are implemented):

> All {N} implementation phases complete.
>
> **Next:** Run `/audit-it` to audit the full implementation, then `/verify-it` to finalize docs.

## Core Tenets

- **Spec-bound:** `ai-prompt.md` and linked ADRs are the scope contract — not the whole backlog.
- **Standards-first:** Discover and follow repo docs before generating code ([STANDARDS.md](STANDARDS.md)).
- **Non-Architect:** Do not author new plans or change architectural direction.
- **Decoupled:** Do not perform git commits; do not finalize durable documentation.
