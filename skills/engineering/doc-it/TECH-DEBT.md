# Tech debt signals (Phase 2)

Use when writing **`docs/reference-audit/tech-debt.md`**. Ground every item in `docs/reference/` and code; cite paths.

## Categories

| Category | Look for |
|----------|----------|
| **Comments & markers** | `TODO`, `FIXME`, `HACK`, `XXX`, stale ticket IDs in comments (`shortcut:` markers go in the ledger below) |
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

## Shortcut ledger

`/implement-it` marks a deliberate shortcut with a comment `shortcut: <the limit>, <when to upgrade>`
([STANDARDS.md](../implement-it/STANDARDS.md) §2). Collect every one, skipping `.git` and ignored
files:

```bash
git grep -nE '(#|//|/[*]|--|<!--) ?shortcut:'
```

Add comment prefixes the stack uses. The prefix keeps prose that only mentions the convention out
of the ledger; also skip hits that are not a deferral (a keyboard shortcut). One row per marker:
the limit and the upgrade trigger come straight from the comment. A marker that names no upgrade
trigger is tagged `no-trigger`: those are the ones that rot. Close the ledger with
`{N} markers, {M} no-trigger.`, or `No shortcut markers.` when there are none. A `no-trigger`
marker is an inventory candidate too, offered under Track findings in [SKILL.md](SKILL.md).

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

## Shortcut ledger

| Location | Limit | Upgrade when | Tag |
|----------|-------|--------------|-----|
| `src/upload.ts:42` | reads the whole file into memory | inputs pass 50 MB | |
| `src/cache.py:17` | cache never expires | (none) | `no-trigger` |

2 markers, 1 no-trigger.

## Notes

{Optional: dependency file refs, links to architecture finding #N}
```

Empty repos: state "No material debt identified" and note scope limits.

Do not duplicate `/internal-compliance` or CVE tooling; point to them when relevant.
