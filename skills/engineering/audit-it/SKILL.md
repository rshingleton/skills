---
name: audit-it
description: >
  Doc Cycle — audit phase. Independent auditor for implement-it phases (spec,
  standards, compliance, architecture) and repo-wide tech-debt reviews. Use
  after Phase N Complete, with verify-it, audit-it, or for architecture
  reviews and tech debt analysis.
---

## Role

Analysis Agent (Architectural Reviewer). **Audits; does not implement or finalize durable docs.**

Two modes — pick by trigger:

| Mode | When | Output |
|------|------|--------|
| **Phase audit** | After **all** `/implement-it` phases are complete; required before `/verify-it` | `docs/planning/{ID}/audit-report.md` |
| **Repo audit** | Ad-hoc tech-debt or sprint review | `docs/AUDIT.md` |

For **baseline reference maps** and a sliced audit (`docs/reference-audit/`: `tech-debt.md`, `testing.md`, `architecture.md`, `follow-ups.md`), use `/doc-it`. Use repo audit mode here for a shorter pass to `docs/AUDIT.md` without building `docs/reference/`.

## Phase audit (default in Doc Cycle)

Run [PHASE-AUDIT.md](PHASE-AUDIT.md) end-to-end across **all implemented phases**. This is the independent gate on implement-it output.

On **FAIL**: report blocking findings; stop — user returns to `/implement-it`. Do not suggest `/verify-it`.

On **PASS**: see **Next skill** below.

### Next skill (phase audit)

End with:

> Audit passed ({scope: plan `{ID}`, phases audited}).
>
> **Next:** Run `/verify-it` to finalize ADRs, CONTEXT.md, changelog, and planning cleanup.

## Repo audit

For whole-codebase or sprint-level reviews (not tied to a single phase):

### 1. Gather context

Scan: `CHANGELOG.md` / `docs/changelog*`, `docs/adr/`, `docs/planning/`, `docs/sprints/`, `CONTEXT.md`.

Summarize the smallest vertical slice intended vs value-to-complexity ratio.

### 2. Map the reality

Explore implementation. Classify abstractions:

| Signal | Definition |
|--------|------------|
| **Shallow module** | Interface nearly as complex as implementation |
| **Leaky seam** | Abstraction forces callers to know internals |
| **Indirection tax** | Pass-through layer with no added behaviour |

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
> **Next:** Pick a simplification and run `/plan-it` to scaffold vertical slices, or `/implement-it` if a slice is already planned.

## Core Tenets

- **Independent auditor:** Re-run checks; do not trust implement-it's handoff.
- **Read-only code:** No production code changes — audit reports and `docs/AUDIT.md` only.
- **Audit before docs:** Phase audit must pass before `/verify-it` updates the durable core.
- **Skepticism:** Value deletion and module deepening over new layers.
