# Testing slice (Phase 2)

Write **`docs/reference-audit/testing.md`**. Build on factual coverage in `docs/reference/test-landscape.md`; add judgment and recommendations here.

## What to cover

| Section | Contents |
|---------|----------|
| **Summary** | Overall test health in 2–4 sentences |
| **Coverage gaps** | Critical behaviours or seams with no meaningful tests; cite paths |
| **Risk areas** | Flaky suites, skipped tests, slow e2e bottlenecks, env-dependent tests |
| **Recommendations** | Prioritized actions: what to test next, at which level (unit, integration, contract, e2e) |
| **Tooling notes** | Run commands, CI gaps, missing fixtures/factories (if observed) |

## Recommendation shape

Each recommendation:

- **ID:** `TR-1`, `TR-2`, …
- **Target:** module or behaviour (use `CONTEXT.md` terms)
- **Level:** unit | integration | contract | e2e
- **Rationale:** one line why this reduces risk
- **Effort:** S | M | L (rough)

## Relationship to other slices

- **`tech-debt.md`:** List bare "test gap" as **TD-*** when it is debt to track; link to **TR-*** for the remediation plan.
- **`architecture.md`:** Interface/seam design issues stay there; testing.md focuses on verification strategy.
- **`follow-ups.md`:** Turn **TR-*** items into draft issues when actionable.

## testing.md shape

```markdown
# Testing

[← Reference audit index](README.md)

## Summary

{prose}

## Coverage gaps

| Area | What's untested | Risk |
|------|-----------------|------|
| … | … | … |

## Risk areas

- …

## Recommendations

| ID | Target | Level | Rationale | Effort |
|----|--------|-------|-----------|--------|
| TR-1 | … | integration | … | M |

## Tooling notes

{optional}
```

If the repo has no tests, say so explicitly and recommend a minimal tracer-bullet test strategy.
