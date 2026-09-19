# Verify-it — Retroactive cleanup (`--retro`)

Sweep historic artifacts left behind by the old archive policy. No audit required.

## Process

1. **Scan** for `docs/archive/planning/` and any orphaned `docs/planning/` dirs not tied to a current cycle.
2. **For each dir**, check:
   - Does the plan reference an ADR that already captures the decisions? If not, scan phase docs for architectural context, trade-off rationale, or design constraints not yet recorded. Present to user for confirmation before backfilling.
   - Does the changelog already cover what shipped? If not, surface unrecorded deliverables for user to add.
   - Mark `sources/*.md` status `done` if present.
3. **Discard** the directory (archive or planning). Confirm with user before each deletion.
4. **Report** summary: `{N} directories cleaned, {M} ADRs backfilled, {K} changelog entries added.`
