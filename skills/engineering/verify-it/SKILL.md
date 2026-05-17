---
name: verify-it
description: >
  Doc Cycle — verify phase. Finalizes ADRs, CONTEXT.md, changelog, and
  planning cleanup after audit-it passes. Does NOT stage or commit. Use after
  Phase N Complete, with audit-it, or when user says verify-it, verify it,
  verify, close phase, finalize.
---

## Role

Documentation & Planning Agent (Architect). **Transitions docs after audit passes** — does not audit implement-it output itself.

Two modes:

| Mode | When | What it does |
|------|------|-------------|
| **Full verify** (default) | After **all** phases + full `/audit-it` PASS | Finalize ADRs, CONTEXT, changelog; accordion compression |
| **Incremental close** | `--phase phase-N` after single-phase audit PASS | Per-phase ADR notes, CONTEXT, Jira resolution; no changelog or compression |

## Quick start

```text
/verify-it
```

After audit PASS:
→ Finalizes ADRs, CONTEXT.md, changelog
→ Archives `docs/planning/{ID}/` to `docs/archive/planning/{ID}/`

Incremental: `/verify-it --phase phase-1` (after `audit-it --phase phase-1` PASS)

## Workflow

### Mode detection

| Invocation | Expected audit report |
|---|---|
| `/verify-it` (no flag) | `docs/planning/{ID}/audit-report.md` (full) |
| `/verify-it --phase phase-2` | `docs/planning/{ID}/audit-report-phase-2.md` (single-phase) |

### 1. Require phase audit

#### Full verify

Before any durable doc edits, `/audit-it` must have completed [PHASE-AUDIT.md](../audit-it/PHASE-AUDIT.md) across **all** implemented phases.

- Read `docs/planning/{ID}/audit-report.md`
- **Verdict FAIL** → Stop. Report blocking findings. User returns to `/implement-it`. Do not proceed.
- **Verdict PASS** → Continue. Carry **non-blocking notes** into ADR execution notes (step 2).

If no `audit-report.md` exists, confirm all implement-it phases are done, then run `/audit-it` in the same session before continuing.

#### Incremental close (`--phase phase-N`)

- Read `docs/planning/{ID}/audit-report-{phase-N}.md`
- **Missing or FAIL** → Stop. Run `/audit-it --phase phase-N` first. Do not proceed.
- **PASS** → Continue. Carry non-blocking notes into ADR execution notes.

### 2. Durable update

| Step | Full verify | Incremental close (`--phase`) |
|------|-------------|-------------------------------|
| **ADR** | `Proposed` → `Accepted`. Add execution notes from audit. | Add execution notes from audit. **Do not** change status (stays `Proposed` until full verify). |
| **CONTEXT.md** | Merge new terminology. | Merge new terminology (same). |
| **Changelog** | Append one technical summary for the completed plan. | **Skip** — final changelog written at full verify. |

See [EXAMPLES.md](EXAMPLES.md) for concrete before/after diffs.

### 3. Accordion compression

**Full verify only.** Not run during incremental close.

- **Summarize:** What was built, decisions crystallized, dead ends avoided.
- **Extract winner's history:** Rationale for key trade-offs (Chesterton's Fence).
- **Cleanup:** Check orchestration `README.md` for the next phase. Prepare `phase-{N+1}/ai-prompt.md` if it exists.
- **Archive:** Move `docs/planning/{ID}/` (phase dirs, `audit-report.md`, `sources/`) to `docs/archive/planning/{ID}/` to preserve execution history. Always archive — never delete without a copy.

See [EXAMPLES.md](EXAMPLES.md) for archive examples.

### 4. Tracker update

**Load the issue tracker** — read `docs/agents/issue-tracker.md` for local conventions (create `docs/agents/` via `/setup-internal-skills` if missing).

**Jira resolution** — if any row in `jira.md` has a Jira key (produced by `/plan-it --jira`), attempt Jira API access **regardless of tracker config**. The tracker config may say "local" while `jira.md` has keys — source env vars and proceed.

Source credentials before API calls: follow [issue-tracker-jira.md § Loading credentials](../setup-internal-skills/issue-tracker-jira.md#loading-credentials). See [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md) for helper functions and conventions.

If credentials are missing after sourcing (`JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY`):
- Report which keys need resolution
- Suggest: `source ~/.local/share/ai-skills/scripts/load-jira-env.sh`
- **Continue** with local doc updates — missing Jira access is not a blocking failure

**Jira resolution scope:**

| Mode | Resolve |
|------|---------|
| **Full verify** | Every phase row with a key in `jira.md` |
| **Incremental close** | Only this phase's row (e.g. `phase-2` key) |

For each key to resolve (when Jira API is available):

- If `JIRA_ASSIGNEE` is set, `_jira_set_assignee "$KEY"` before other writes.
- **Prompt for resolution comment:** draft a concise Jira resolution comment from the phase summary (2-4 sentences covering what was delivered). Present it to the user as a suggestion: *"Post this resolution comment to {KEY}? (y/edit/skip)"*. If they edit, use their text. If y, post via `POST /issue/{KEY}/comment?notifyUsers=false`.
- **Resolve:** ask *"Resolve {KEY}? (y/n)"* per key. If yes, transition to the `Resolved` or `Done` status (`POST /issue/{KEY}/transitions?notifyUsers=false`). Apply `_jira_apply_watcher_policy "$KEY" update` after each write.

**Jira API unavailable:** still update local docs (sources status `done`, archive). Report unresolved keys and suggest manual resolution or re-run after sourcing credentials.

If any target phase row lacks a Jira key, report it — run `/plan-it --jira {ID} --sync-only` before closing.

**Sources** — on each `docs/planning/{ID}/sources/*.md`, set `status: done` and append that verify-it completed the Doc Cycle. When archiving the plan, move `sources/` with `docs/planning/{ID}/` to `docs/archive/planning/{ID}/`.

### 5. Conclusion

- **Full verify:** Report verified and "Green." Durable core updated.
- **Incremental close:** Report "Phase N verified. {N-1} phases remaining until full close."

### 6. Next skill

#### Full verify

> Verify complete. Durable core updated.
>
> **Next:** Run `/commit-it` to stage, commit, and push. Before opening a PR, run `/internal-compliance`.
>
> For non-blocking architecture notes, consider `/improve-codebase-architecture`, `/issue-it` or [audit-to-issues](../setup-internal-skills/audit-to-issues.md) for inbox tracking, or a follow-up `/plan-it` slice.

#### Incremental close

> Phase N verified incrementally.
>
> **Next:** Continue with `/implement-it` on remaining phases, or run `/audit-it --phase phase-{N+1}` for the next phase.
>
> When all phases are complete, run `/audit-it` (full) then `/verify-it` (full) to finalize.

## Core Tenets

- **Audit-first:** No durable doc updates until `audit-report.md` verdict is PASS.
- **Read-only code:** No production code changes — documentation files only.
- **Decoupled:** Do not stage or commit changes.
