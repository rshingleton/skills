---
name: audit-it
description: >
  Doc Cycle — audit phase. Independent auditor for implement-it phases (spec,
  standards, compliance, architecture) and repo-wide tech-debt reviews. Use
  after Phase N Complete and implement-it, or for architecture
  reviews and tech debt analysis. Use when user says audit-it,
  audit, review, or compliance check.
---

## Role

Analysis Agent (Architectural Reviewer). **Audits; does not implement or finalize durable docs.**

Four modes — pick by trigger:

| Mode | When | Output |
|------|------|--------|
| **Phase audit** | After **all** phases; holistic single pass | `docs/planning/{ID}/audit-report.md` |
| **Multi-phase audit** | After **all** phases; cycle each phase individually (`--phases`) | `docs/planning/{ID}/audit-report.md` (compiled) |
| **Single-phase audit** | After any one phase (`--phase phase-N`); early feedback | `docs/planning/{ID}/audit-report-{phase-N}.md` |
| **Repo audit** | Ad-hoc tech-debt or sprint review | `docs/AUDIT.md` |

For **baseline reference maps** and a sliced audit (`docs/reference-audit/`: `tech-debt.md`, `testing.md`, `architecture.md`, `follow-ups.md`), use `/doc-it`. Use repo audit mode here for a shorter pass to `docs/AUDIT.md` without building `docs/reference/`.

## Quick start

```text
/audit-it
```

After all phases implemented (holistic): `/audit-it`
Cycle each phase individually: `/audit-it --phases`
Single phase: `/audit-it --phase phase-1`
Repo audit: `/audit-it repo`

## Phase audit

Run [PHASE-AUDIT.md](PHASE-AUDIT.md) across **all implemented phases** in one holistic pass. This is the independent gate on verify-it.

## Multi-phase audit

Pass `--phases` to audit each phase individually, cycling through them one at a time. Each phase runs the same Mechanical → Spec → Standards → Compliance → Architecture checks as single-phase audit. Findings are compiled and presented together at the end.

See [PHASE-AUDIT.md § Multi-phase audit](PHASE-AUDIT.md#multi-phase-audit) for the workflow.

## Single-phase audit

Pass `--phase phase-N` to audit one phase early (e.g. `--phase phase-2`). Runs [PHASE-AUDIT.md](PHASE-AUDIT.md) scoped to that phase only. Use for early feedback on multi-phase plans — does **not** replace the full audit gate.

On **FAIL**: report blocking findings for that phase. Return to `/implement-it` on that phase; other phases unaffected.

On **PASS**: suggest `/verify-it --phase phase-N` for incremental close, or continue implementing remaining phases.

**Optional cross-check (both modes):** Compare phase verification criteria in `ai-prompt.md` to `sources/*.md` and plan README. Spot-check `jira.md` rows when using Jira. Do **not** call Jira or change status — `/verify-it` owns closure.

### Next skill (multi-phase audit)

**All phases PASS:**

> Multi-phase audit passed ({N} phases).
>
> **Next:** Run `/verify-it` to finalize ADRs, CONTEXT.md, changelog, and planning cleanup.

**Any phase FAIL:**

> Multi-phase audit failed — {N} of {M} phases have blocking findings.
>
> **Next:** Return to `/implement-it` on failing phases listed above, or use `--phase` to re-audit specific phases after fixes.

### Next skill (phase audit)

**Full audit PASS:**

> Audit passed ({scope: plan `{ID}`, phases audited}).
>
> **Next:** Run `/verify-it` to finalize ADRs, CONTEXT.md, changelog, and planning cleanup.

**Single-phase PASS:**

> Phase N audit passed.
>
> **Next:** Run `/verify-it --phase phase-N` to close this phase incrementally, or continue with `/implement-it` on remaining phases.

## Repo audit

For whole-codebase or sprint-level reviews (not tied to a single phase):

### 1. Gather context

Scan: `CHANGELOG.md` / `docs/changelog*`, `docs/adr/`, `docs/planning/`, `docs/sprints/`, `CONTEXT.md`.

Summarize the smallest vertical slice intended vs value-to-complexity ratio.

### 2. Map the reality

Explore implementation. Classify abstractions:

| Signal | Definition | Impact |
|--------|------------|--------|
| **Shallow module** | Interface nearly as complex as implementation | Low leverage — callers learn much for little behaviour |
| **Leaky seam** | Callers must know internals | Poor locality — callers break when internals change |
| **Indirection tax** | Pass-through with no added behaviour | Zero leverage — ceremony without behaviour |

### 3. Generate AUDIT.md

Create `docs/AUDIT.md` with source artifacts, process log, and findings:

- **Core value** — code doing most of the work
- **Accretion** — over-engineered modules
- **Simplification proposals** — deepen modules
- **Deletion candidates** — shift the seam

See existing sample content in this skill's history for format.

### 4. Next skill (repo audit)

End with:

> Analysis written to `docs/AUDIT.md`.
>
> **Next:** Pick a simplification and run `/plan-it`, or `/implement-it` if already planned. Optional: file proposals in `docs/issues/` via [audit-to-issues.md](../setup-internal-skills/audit-to-issues.md) (`source: audit-it`).

## Core Tenets

- **Independent auditor:** Re-run checks; do not trust implement-it's handoff.
- **Read-only code:** No production code changes — audit reports and `docs/AUDIT.md` only.
- **Audit before docs:** Phase audit must pass before `/verify-it` updates the durable core.
- **Skepticism:** Value deletion and module deepening over new layers.
