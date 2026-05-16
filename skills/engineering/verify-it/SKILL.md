---
name: verify-it
description: >
  Doc Cycle — verify phase. Finalizes ADRs, CONTEXT.md, changelog, and
  planning cleanup after audit-it passes. Does NOT stage or commit. Use after
  Phase N Complete, with audit-it, or when user says verify-it, verify it,
  verify, close phase, finalize.
---

## Role

Documentation & Planning Agent (Architect). **Transitions docs after audit passes** — does not audit implement-it output itself. Run **once per plan** after all `/implement-it` phases and `/audit-it` PASS (not per issue as each task finishes).

## Workflow

### 1. Require phase audit

Before any durable doc edits, `/audit-it` must have completed [PHASE-AUDIT.md](../audit-it/PHASE-AUDIT.md) after all implementation phases.

- Read `docs/planning/{ID}/audit-report.md`
- **Verdict FAIL** → Stop. Report blocking findings. User returns to `/implement-it`. Do not proceed.
- **Verdict PASS** → Continue. Carry **non-blocking notes** into ADR execution notes (step 2).

If no `audit-report.md` exists, confirm all implement-it phases are done, then run `/audit-it` in the same session before continuing.

### 2. Durable update

- **ADR:** Move status from `Proposed` to `Accepted`. Add execution notes, technical debt, and discoveries — include non-blocking items from `audit-report.md`.
- **CONTEXT.md:** Merge new domain terminology or architectural shifts from the phase.
- **Changelog:** Append one technical summary for the completed plan (or final phase batch) — `/implement-it` does not update `CHANGELOG.md` incrementally.

See [EXAMPLES.md](EXAMPLES.md) for concrete before/after diffs.

### 3. Accordion compression

- **Summarize:** What was built, decisions crystallized, dead ends avoided.
- **Extract winner's history:** Rationale for key trade-offs (Chesterton's Fence).
- **Cleanup:** Check orchestration `README.md` for the next phase. Prepare `phase-{N+1}/ai-prompt.md` if it exists.
- **Purge:** Delete completed phase directories under `docs/planning/{ID}/` (including `audit-report.md` at plan root if present). If the plan is finished, delete the root `{ID}` directory.
- **Archive:** Move raw execution history to `docs/archive/planning/{ID}/` when preservation is required.

See [EXAMPLES.md](EXAMPLES.md) for purge/archive examples.

### 4. Issue tracker update

`docs/agents/issue-tracker.md` should have been provided — run `/setup-internal-skills` if missing.

**Local:** On linked `docs/issues/...` files, set `status: done` (or appropriate triage role) and append under `## Comments` that verify-it completed the Doc Cycle.

**Jira:** Post summary comment and any transition with `?notifyUsers=false`; apply watcher policy after each write (`_jira_apply_watcher_policy` — update mode) ([issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md), [jira-notifications.md](../setup-internal-skills/jira-notifications.md)). Ask *"Close this Jira? (y/n)"* before transitioning to Resolved.

### 5. Conclusion

Report verified and "Green." Durable core updated.

### 6. Next skill

End with:

> Verify complete. Durable core updated. **Next:** commit when ready.
>
> Before opening a PR, run `/internal-compliance`.
>
> For non-blocking architecture notes from the audit, consider `/improve-codebase-architecture` or a follow-up `/plan-it` slice.

## Core Tenets

- **Audit-first:** No durable doc updates until `audit-report.md` verdict is PASS.
- **Read-only code:** No production code changes — documentation files only.
- **Decoupled:** Do not stage or commit changes.
