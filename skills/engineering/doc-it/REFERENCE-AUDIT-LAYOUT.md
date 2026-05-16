# docs/reference-audit/ layout

Phase 2 of `/doc-it`. Directory at **`docs/reference-audit/`** (sibling to `docs/reference/`).

Slice files by concern so reviewers can open one topic at a time. Update **`README.md` last** as the index.

## Required files

| File | Contents |
|------|----------|
| `README.md` | Generated date, scope, link to `docs/reference/README.md`, **executive summary**, table of slices with one-line status |
| `tech-debt.md` | Debt inventory per [TECH-DEBT.md](TECH-DEBT.md) |
| `testing.md` | Test gaps and recommendations per [TESTING-SLICE.md](TESTING-SLICE.md) |
| `architecture.md` | Numbered design findings, **Core value**, **Accretion** (see below) |
| `follow-ups.md` | Draft issues, docs to review, deepening/debt paydown links |

## architecture.md sections

Inside `architecture.md` (single file for design judgment):

1. **Findings** — numbered items (shallow module, leaky seam, etc.)
2. **Core value** — modules worth protecting when paying down debt
3. **Accretion** — pass-through or over-engineered layers

Use vocabulary from [improve-codebase-architecture/LANGUAGE.md](../improve-codebase-architecture/LANGUAGE.md).

## follow-ups.md sections

1. **Issues (draft)** — bullets ready for `/issues-it` ([audit-to-issues.md](../setup-internal-skills/audit-to-issues.md)); after filing, note `Tracked: docs/issues/<slug>.md`
2. **Docs to review** — ADRs, `CONTEXT.md`, stale reference pages
3. **Next steps** — map finding IDs (`1`, `2`), debt IDs (`TD-1`), and test IDs (`TR-1`) to skills

## Cross-links

- Each slice links back to `[reference-audit/README.md](README.md)`.
- `README.md` links to every slice.
- Reference finding IDs in `architecture.md`; debt IDs in `tech-debt.md`; do not duplicate full text across files.

## Legacy

If `docs/reference-audit.md` exists from an older run, replace it with this directory on the next `/doc-it` audit pass.
