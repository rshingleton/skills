# Verify Skill — Examples

Self-contained examples for each workflow step. Replace placeholder values
(`{key}`, `{phase-N}`, etc.) with your project's actual names.

---

## Mode selection

| Invocation | Audit required | What it finalizes |
|---|---|---|
| `/verify-it` | `docs/planning/{key}/audit-report.md` (full) | ADR, CONTEXT, changelog, compact planning docs into ADRs, all Jira keys |
| `/verify-it --phase phase-2` | `docs/planning/{key}/audit-report-phase-2.md` | ADR notes + CONTEXT for phase 2, resolves phase 2 Jira key only |
| `/verify-it --retro` | None | Sweep `docs/archive/planning/` + orphaned `docs/planning/`, backfill ADRs, delete artifacts |

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

## Compact -- extract essence, discard artifacts

All phases done. Review ADRs and changelog for gaps, then discard the planning directory.

```bash
rm -rf docs/planning/{key}
```

Before:
```
docs/planning/{key}/
├── README.md
├── phase-1/
├── phase-2/
├── phase-3/
└── sources/
```

After — durable records hold the condensed value:
```
docs/adr/{N}-{title}.md    # decision rationale, now Accepted
CHANGELOG.md                 # what shipped
CONTEXT.md                   # domain terms introduced
```

Checklist:
- [ ] Each trade-off or architectural finding from the planning docs is captured in an ADR
- [ ] Changelog covers what was delivered across all phases
- [ ] `CONTEXT.md` has any new domain terms
- [ ] `rm -rf docs/planning/{key}` — no archive needed

---

## Retroactive cleanup (`--retro`)

Clean up historic planning archives left from the old archive policy:

```bash
/verify-it --retro
```

Before:
```
docs/
├── archive/
│   └── planning/
│       ├── plan-001/        # old archive, decisions might lack ADR coverage
│       └── plan-002/
├── planning/
│   └── plan-003/            # orphaned -- never verified
```

Scan flow per directory:

1. Has `docs/adr/` cover plan-001's scope? If not, read `phase-*/*.md` and `sources/*.md`, suggest ADR backfills.
2. Does changelog mention plan-001 deliverables? If not, surface for user to append.
3. Confirm with user, then `rm -rf` the directory.

After:
```
docs/
└── adr/                     # backfilled with any missing decisions
CHANGELOG.md                  # appended with unrecorded deliverables
CONTEXT.md                    # any missing terms added
```

Plan-001's `audit-report.md` can contain findings not worth ADR-ing. Discard those or capture as a `docs/issues/` item if still actionable.
