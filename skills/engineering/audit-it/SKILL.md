---
name: audit-it
description: >
  Doc Cycle audit phase. Independent auditor for implement-it phases (spec,
  standards, compliance, architecture) and repo-wide tech-debt audits. Use
  after Phase N Complete and implement-it, or for an architecture or tech-debt
  audit. Use when user says audit-it, audit, or compliance check.
---

## Role

**Audits; does not implement or finalize durable docs.**

Four modes, one name each:

| Mode | Invocation | When | Output |
|------|------------|------|--------|
| **Full audit** | `/audit-it` | After **every** phase; one pass over the plan's combined diff. The gate on `/verify-it` | `docs/planning/{ID}/audit-report.md` |
| **Per-phase audit** | `/audit-it --phases` | After **every** phase; each phase audited on its own, compiled into one report | `docs/planning/{ID}/audit-report.md` |
| **Single-phase audit** | `/audit-it --phase phase-N` | After any one phase; early feedback, not the gate | `docs/planning/{ID}/audit-report-{phase-N}.md` |
| **Repo audit** | `/audit-it repo` | Ad-hoc tech-debt or sprint audit, not tied to a plan | `docs/AUDIT.md` |

For baseline reference maps and a sliced audit under `docs/reference-audit/`, use `/doc-it`. Repo audit is the shorter pass to `docs/AUDIT.md`.

## Plan audits (Full, Per-phase, Single-phase)

Run [PHASE-AUDIT.md](PHASE-AUDIT.md) in the chosen mode. It defines each mode's diff, the checks (Mechanical, Spec, Standards, Compliance, Architecture), the severity rules and the next-skill message.

Spec and Standards come from the `code-review` skill, given the phase prompt, its committed range (from the Base ref), and [REVIEW-STANDARDS.md](REVIEW-STANDARDS.md). audit-it owns the Mechanical, Compliance and Architecture checks, the verdict, and the report.

Write the report from [TEMPLATES.md](TEMPLATES.md). Its finding contract, in short:

- Every finding names a concrete case: a file and line, an input, or a scenario. No case, no finding.
- Findings are grouped **Must** (blocking), **Should**, **Nice**, numbered across the groups so the user can say "fix 2 and 5".
- Each finding says what it is, the problem, the fix, and the cost of skipping it.
- The report ends with `Verdict:` and `Not checked:`.
- code-review's Spec and Standards reports stay verbatim under audit-it's verdict line; the contract covers audit-it's own sections and the summary.

**Recorded decisions are not findings.** A choice the phase prompt or a linked ADR records is not flagged, unless the diff contradicts that decision. Flag the contradiction, citing the decision.

**Optional cross-check:** compare each phase's verification criteria to `sources/*.md` and the plan README, and spot-check `jira.md` rows. Do **not** call Jira or change status; `/verify-it` owns closure.

## Repo audit

For whole-codebase or sprint-level audits, not tied to a plan.

### 1. Gather context

Scan `CHANGELOG.md` or `docs/changelog*`, `docs/adr/`, `docs/reference/`, `GLOSSARY.md`. For residual `docs/archive/planning/` or orphaned `docs/planning/` dirs, suggest `/verify-it --retro`.

Summarize the smallest vertical slice intended against its value-to-complexity ratio.

### 2. Map the reality

Explore the implementation and classify abstractions:

| Signal | Definition | Impact |
|--------|------------|--------|
| **Shallow module** | Interface nearly as complex as implementation | Low leverage: callers learn much for little behaviour |
| **Leaky seam** | Callers must know internals | Poor locality: callers break when internals change |
| **Indirection tax** | Pass-through with no added behaviour | Zero leverage: ceremony without behaviour |

### 3. Generate AUDIT.md

Create `docs/AUDIT.md` with source artifacts, a process log, and findings that each name a concrete module or file:

- **Core value**: code doing most of the work
- **Accretion**: over-engineered modules
- **Simplification proposals**: deepen modules
- **Deletion candidates**: shift the seam

### 4. Next skill

End with:

> Analysis written to `docs/AUDIT.md`.
>
> **Next:** Pick a simplification and run `/plan-it`, or `/implement-it` if already planned. Optional: file proposals in `docs/issues/` via [audit-to-issues.md](../setup-internal-skills/audit-to-issues.md) (`source: audit-it`).

## Core Tenets

- **Independent auditor:** Re-run checks; do not trust implement-it's handoff.
- **Read-only code:** No production code changes; audit reports and `docs/AUDIT.md` only.
- **Audit before docs:** A Full or Per-phase audit must pass before `/verify-it` updates the durable core.
- **Concrete or nothing:** No case, no finding; no re-flagging what the plan decided.
- **Skepticism:** Value deletion and module deepening over new layers.
