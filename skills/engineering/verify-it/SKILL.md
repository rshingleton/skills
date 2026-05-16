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

### 4. Tracker update

`docs/agents/issue-tracker.md` should have been provided — run `/setup-internal-skills` if missing.

**Jira** — for each phase row with a key in `docs/planning/{ID}/jira.md`:

- If `JIRA_ASSIGNEE` is set, `_jira_set_assignee "$KEY"` before other writes ([issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md#assignee-jira_assignee)).
- **Prompt for resolution comment:** draft a concise Jira resolution comment from the phase summary (2-4 sentences covering what was delivered). Present it to the user as a suggestion: *"Post this resolution comment to {KEY}? (y/edit/skip)"*. If they edit, use their text. If y, post via `POST /issue/{KEY}/comment?notifyUsers=false` ([issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md#helper-functions-copy-into-shell-before-jira-work)).
- **Resolve:** ask *"Resolve {KEY}? (y/n)"* per key. If yes, transition to the `Resolved` or `Done` status (`POST /issue/{KEY}/transitions?notifyUsers=false`). Apply `_jira_apply_watcher_policy "$KEY" update` after each write ([jira-notifications.md](../setup-internal-skills/jira-notifications.md)).

If any phase row lacks a Jira key, report it — run `/plan-it --jira {ID} --sync-only` before closing Jira.

**Sources** — on each `docs/planning/{ID}/sources/*.md`, set `status: done` and append that verify-it completed the Doc Cycle. When archiving the plan, move `sources/` with `docs/planning/{ID}/` to `docs/archive/planning/{ID}/`.

### 5. Conclusion

Report verified and "Green." Durable core updated.

### 6. Next skill

End with:

> Verify complete. Durable core updated. **Next:** commit when ready.
>
> Before opening a PR, run `/internal-compliance`.
>
> For non-blocking architecture notes, consider `/improve-codebase-architecture`, `/issues-it` or [audit-to-issues](../setup-internal-skills/audit-to-issues.md) for inbox tracking, or a follow-up `/plan-it` slice.

## Core Tenets

- **Audit-first:** No durable doc updates until `audit-report.md` verdict is PASS.
- **Read-only code:** No production code changes — documentation files only.
- **Decoupled:** Do not stage or commit changes.
