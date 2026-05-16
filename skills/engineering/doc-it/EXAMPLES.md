# doc-it examples

## Full run

User: `/doc-it` on a legacy service.

1. Phase 1: `docs/reference/module-map.md`, `test-landscape.md`, …
2. User fixes one boundary in `domains.md`.
3. Phase 2:
   - `docs/reference-audit/tech-debt.md` — TD-1…TD-6 table
   - `docs/reference-audit/testing.md` — TR-1 integration test for payment seam
   - `docs/reference-audit/architecture.md` — findings 1–4, core value, accretion
   - `docs/reference-audit/follow-ups.md` — three draft issues
   - `docs/reference-audit/README.md` — summary + links
4. Agent offers intake issues; user picks two → `docs/issues/deepen-payment-seam.md`, `docs/issues/tr-1-payment-integration.md` (`source: doc-it`); `follow-ups.md` updated with `Tracked:` links.
5. Handoff: `/plan-it --from-issues` when ready.

## Audit only

User: `/doc-it audit only` after a release.

- Refreshes stale `docs/reference/` pages if needed.
- Re-runs debt scan; updates `tech-debt.md` and `follow-ups.md`.

## Pick a slice

| Reviewer focus | Open |
|----------------|------|
| Debt backlog | `reference-audit/tech-debt.md` |
| Test gaps & recommendations | `reference-audit/testing.md` |
| Design / deepening | `reference-audit/architecture.md` |
| What to do next | `reference-audit/follow-ups.md` |

## Skill routing

| Need | Skill |
|------|--------|
| Maps + sliced audit | `/doc-it` |
| Chat orientation | `/zoom-out` |
| Grill one architecture finding | `/improve-codebase-architecture` |
| Short debt doc only | `/audit-it` repo mode |
| After shipping a plan | `/verify-it` |
