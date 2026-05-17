# Verify Skill — Examples

Self-contained examples for each workflow step. Replace placeholder values
(`{key}`, `{phase-N}`, etc.) with your project's actual names.

---

## Mode selection

| Invocation | Audit required | What it finalizes |
|---|---|---|
| `/verify-it` | `docs/planning/{key}/audit-report.md` (full) | ADR, CONTEXT, changelog, accordion compression, all Jira keys |
| `/verify-it --phase phase-2` | `docs/planning/{key}/audit-report-phase-2.md` | ADR notes + CONTEXT for phase 2, resolves phase 2 Jira key only |

---

## Incremental close (`--phase`)

After a single-phase audit passes, close that phase without waiting for the rest:

```bash
# Phase 2 implemented → audited → incrementally closed
/audit-it --phase phase-2       # writes audit-report-phase-2.md
/verify-it --phase phase-2      # ADR notes, CONTEXT, Jira for phase-2 only
```

Result: phase 2 verified. Remaining phases (1, 3) can proceed independently.

---

## Full close (all phases done)

`/verify-it` without `--phase` runs the full existing pipeline after the full audit passes.

---

## Durable Update — ADR

Before — ADR with `Proposed` status:
```markdown
# ADR-{N}: {title}

**Status:** Proposed
**Date:** 2026-05-13
```

After — move to `Accepted`, add execution notes:
```markdown
# ADR-{N}: {title}

**Status:** Accepted
**Date:** 2026-05-14
**Execution Notes:**
- Implemented {feature} in {module}
- {key}: {specific change description}
- Discovered: {unexpected finding during implementation}
```

---

## Durable Update — CONTEXT.md

Before — no entry for a new concept:
```markdown
### Core Domain Concepts

| Term | Meaning |
|------|---------|
| **Widget** | Existing concept |
```

After — add new terminology introduced by the phase:
```diff
+ | **Gizmo** | New orchestration layer wrapping Widget and Sprocket |
+ | **AcmeDB** | Primary data store for Gizmo config |
```

---

## Durable Update — Changelog

Append a dated section to the project changelog:

```markdown
## 2026-05-14 — Phase {N}: {short-title}

- {Feature}: {one-line description}
- {Module}: {specific change} ({file/commit ref})
- {Key} {fix or improvement}
```

---

## Accordion Compression — Archive

All phases of a planning key are done. Move the entire directory to preserve execution history:

```bash
mv docs/planning/{key} docs/archive/planning/{key}
```

Before:
```
docs/planning/{key}/
├── README.md
├── phase-1/
├── phase-2/
└── phase-3/
```

After:
```
docs/archive/planning/{key}/
├── README.md
├── phase-1/
├── phase-2/
└── phase-3/
```

Always archive — never delete without a copy. The archive preserves `ai-prompt.md`, `execution-notes.md`, `audit-report.md`, and `sources/` for future reference.
