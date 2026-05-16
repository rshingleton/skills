# Tech debt signals (Phase 2)

Use when writing **`docs/reference-audit/tech-debt.md`**. Ground every item in `docs/reference/` and code; cite paths.

## Categories

| Category | Look for |
|----------|----------|
| **Comments & markers** | `TODO`, `FIXME`, `HACK`, `XXX`, stale ticket IDs in comments |
| **Duplication** | Copy-pasted logic, parallel implementations of the same rule |
| **Dead weight** | Unused exports, unreachable branches, feature flags stuck on |
| **Dependency drift** | Outdated or pinned-vulnerable packages (note file, not full audit) |
| **Test gaps** | Critical seams with no tests; flaky or skipped suites (detail in `testing.md` as **TR-***) |
| **Pattern inconsistency** | Mixed error handling, logging, or layering in the same area |
| **ADR / doc drift** | Code contradicts accepted ADRs or `docs/reference/` claims |
| **Operational debt** | Missing observability, manual runbooks, hard-coded env assumptions |
| **Security smell** | Flag for `/internal-compliance`; not a full scan here |

## Severity

- **P0** — blocks safe change or ship
- **P1** — high cost to touch; plan soon
- **P2** — fix when already in the file
- **P3** — track only

## tech-debt.md shape

```markdown
# Technical debt

[← Reference audit index](README.md)

## Summary

{Themes in prose: e.g. "Auth path: 8 TODOs, no contract tests."}

## Inventory

| ID | Category | Sev | Location | Remediation |
|----|----------|-----|----------|-------------|
| TD-1 | duplication | P1 | `src/...` | {one line} |

## Notes

{Optional: dependency file refs, links to architecture finding #N}
```

Empty repos: state "No material debt identified" and note scope limits.

Do not duplicate `/internal-compliance` or CVE tooling; point to them when relevant.
