# Verify Skill — Examples

Self-contained examples for each workflow step. Replace placeholder values
(`{key}`, `{phase-N}`, etc.) with your project's actual names.

---

## Phase audit gate

`/verify-it` requires `docs/planning/{key}/audit-report.md` with **Verdict: PASS** from `/audit-it` (after all implement-it phases are complete).

Merge non-blocking architecture notes from the audit report into ADR execution notes (step below).

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

## Accordion Compression — Purge

All phases of a planning key are done. Remove the ephemeral directory:

```bash
rm -rf docs/planning/{key}
```

Before removal:
```
docs/planning/{key}/
├── README.md
├── phase-1/
├── phase-2/
└── phase-3/
```

After removal: directory gone.

---

## Accordion Compression — Archive

Move raw execution history instead of deleting:

```bash
mv docs/planning/{key} docs/archive/planning/{key}
```
