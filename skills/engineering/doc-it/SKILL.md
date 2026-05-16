---
name: doc-it
description: >
  Inspects a codebase and writes baseline reference docs under docs/reference/,
  then docs/reference-audit/ (tech-debt, testing, architecture, follow-ups slices).
  Use when onboarding, documenting an unfamiliar repo, baseline reference,
  tech debt survey, or before plan-it. Not verify-it or zoom-out.
---

# Doc-it

**Read-only.** Writes documentation only; no production code changes.

## Quick start

```
/doc-it                    → Phase 1 + Phase 2 (default)
/doc-it reference only     → docs/reference/ only
/doc-it audit only         → docs/reference-audit/ (needs docs/reference/)
```

## Phases

| Phase | Output | Purpose |
|-------|--------|---------|
| **1 — Reference** | `docs/reference/` | As-is maps: modules, entry points, tests, domains |
| **2 — Reference audit** | `docs/reference-audit/` | Sliced review: tech debt, testing, architecture, follow-ups |

**Not:** `/verify-it` (post-plan finalize). `/zoom-out` (chat only). `/audit-it` repo mode (`docs/AUDIT.md`, shorter debt-focused pass).

## Before you start

1. `/setup-internal-skills` if `docs/agents/` is missing.
2. Read `CONTEXT.md`, `docs/adr/`, prior `docs/reference/` and `docs/reference-audit/`.
3. Confirm scope on huge repos (subtree, single service, one context).

## Phase 1 — Reference

- Agent tool: `subagent_type=Explore`, thoroughness **very thorough**.
- Create `docs/reference/` per [REFERENCE-LAYOUT.md](REFERENCE-LAYOUT.md).
- Use `CONTEXT.md` vocabulary; list **Glossary gaps** in `domains.md`.
- Current state only; cite paths; index last in `reference/README.md`.
- Pause for user review before Phase 2 unless they want both without stopping.

## Phase 2 — Reference audit

Create **`docs/reference-audit/`** per [REFERENCE-AUDIT-LAYOUT.md](REFERENCE-AUDIT-LAYOUT.md):

| File | Content |
|------|---------|
| `tech-debt.md` | [TECH-DEBT.md](TECH-DEBT.md) inventory (required) |
| `testing.md` | Gaps and **TR-*** recommendations ([TESTING-SLICE.md](TESTING-SLICE.md)) |
| `architecture.md` | Numbered findings, core value, accretion |
| `follow-ups.md` | Draft issues, docs to review, next skills |
| `README.md` | Executive summary + index (write last) |

Re-explore code where the reference pass is thin. Do not create `docs/issues/` unless asked.

## Handoff

**Reference only:**

> `docs/reference/` complete. **Next:** `/doc-it audit` or `/plan-it`.

**Both phases:**

> `docs/reference/` + `docs/reference-audit/`. **Next:** `/issues-it`, `/plan-it`, `/improve-codebase-architecture`, `/grill-with-docs`.

Examples: [EXAMPLES.md](EXAMPLES.md).
