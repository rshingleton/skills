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

Three modes:

| Mode | When | What it does |
|------|------|-------------|
| **Full verify** (default) | After **all** phases + full `/audit-it` PASS | Finalize ADRs, CONTEXT, changelog; extract essence from planning docs into ADRs, discard artifacts |
| **Incremental close** | `--phase phase-N` after single-phase audit PASS | Per-phase ADR notes, CONTEXT, Jira resolution; no changelog or compression |
| **Retroactive cleanup** | `--retro` anytime | Sweep historic `docs/archive/planning/` and orphaned `docs/planning/` dirs, backfill ADRs, delete artifacts |

## Quick start

```text
/verify-it
```

After audit PASS:
→ Finalizes ADRs, CONTEXT.md, changelog
→ Extracts any missing decisions from planning docs into ADRs, discards `docs/planning/{ID}/`

Incremental: `/verify-it --phase phase-1` (after `audit-it --phase phase-1` PASS)
Retroactive: `/verify-it --retro` (sweep historic archives, no audit needed)

## Workflow

### Mode detection

| Invocation | Expected audit report |
|---|---|---|
| `/verify-it` (no flag) | `docs/planning/{ID}/audit-report.md` (full) |
| `/verify-it --phase phase-2` | `docs/planning/{ID}/audit-report-phase-2.md` (single-phase) |
| `/verify-it --retro` | None -- scans orphaned dirs independently |

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

### 3. Compact -- extract essence, discard artifacts

**Full verify only.** Not run during incremental close.

Planning docs are intermediate work product. The durable records are ADRs (decision rationale) and changelog (what shipped). Compact by extracting anything missing from those, then discarding.

- **Review ADRs:** For each ADR linked from the plan, confirm it captures the decision, context, and consequences. If the planning directory reveals additional architectural context or trade-off rationale not yet in the ADR, backfill it.
- **Review changelog:** Confirm the changelog entry covers what was shipped. If planning docs surfaced unrecorded deliverables, add them.
- **Discard:** Remove `docs/planning/{ID}/` entirely. No archive -- the durable core (ADRs, changelog) holds everything worth keeping.

See [EXAMPLES.md](EXAMPLES.md) for examples.

### 4. Tracker update

If any row in `jira.md` has a Jira key, follow [JIRA-RESOLUTION.md](JIRA-RESOLUTION.md) for the per-key resolution loop. The tracker config may say "local" while `jira.md` has keys — still proceed.

### 5. Retroactive cleanup (`--retro`)

Follow [RETRO-CLEANUP.md](RETRO-CLEANUP.md) to sweep historic artifacts. No audit required.

### 6. Conclusion

- **Full verify:** Report verified and "Green." Durable core updated.
- **Incremental close:** Report "Phase N verified. {N-1} phases remaining until full close."

### 7. Next skill

#### Full verify

> Verify complete. Durable core updated.
>
> **Next:** Run `/commit-it` to stage and commit locally (push only after your approval). Before opening a PR, run `/internal-compliance`.
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
