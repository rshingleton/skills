# ADR-0012: Plans Write ADRs Only When a Decision Warrants One

**Status:** Accepted
**Date:** 2026-10-19
**Author:** Russell Shingleton
**Plan:** `docs/planning/doc-cycle-parallel/`

## Context

plan-it drafts `docs/adr/{ID}-description.md` for every plan, and verify-it treats ADRs plus
the changelog as the only durable record before it deletes `docs/planning/{ID}/`. The
`domain-modeling` skill, which plan-it calls during the grill, offers an ADR only when a
decision is hard to reverse, surprising without context, and the result of a real trade-off,
and numbers ADRs `NNNN-slug.md`. The two rules disagree, so plans produce ADRs that record no
real decision, under a second naming scheme.

## Decision

plan-it writes an ADR only when `domain-modeling`'s three tests pass, named with the next
sequential number. A plan may produce none. verify-it accepts only the ADRs a plan links; for a
plan with none, it records the plan's execution notes in the plan's changelog entry. The
planning directory is still deleted at verify.

## Consequences

- `docs/adr/` holds decisions, not one entry per plan.
- The changelog carries more detail for plans without ADRs.
- Existing `{ID}-description.md` ADRs in consumer repos stay as they are.

## Execution Notes

Implemented in phase 3 of `doc-cycle-parallel`. plan-it offers an ADR only when
`domain-modeling`'s three tests pass, named `docs/adr/NNNN-slug.md`; verify-it accepts only the
ADRs a plan's README links and, with none, writes the execution notes into the changelog entry.
Dry runs: a one-phase plan wrote no ADR, and verify-it on it wrote the notes into the changelog
and removed the planning directory. The audit found three audit-it lines and the GLOSSARY Plan
and AGENTS.md planning-dir lines still assuming an ADR; all fixed. Open: `verify-it/EXAMPLES.md`
still describes finalizing as compacting planning docs into ADRs.
