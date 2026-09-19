# Audit report templates

## Full audit

Write `docs/planning/{ID}/audit-report.md`:

```markdown
# Plan Audit — {ID}

**Verdict:** PASS | FAIL
**Date:** {ISO date}
**Phases audited:** 1 … N

## Mechanical
PASS | FAIL — {detail}

## Spec
PASS | FAIL — {detail per phase if needed}

## Standards
PASS | FAIL | NOTES — {detail}

## Compliance
PASS | FAIL — {detail}

## Architecture
OK | NOTES | FAIL — {detail}

**Flagged modules:**
- `{module}`: {signal} ({dependency}) — {impact}
- …

## Blocking findings
- …

## Non-blocking notes (for ADR execution notes)
- …
```

## Single-phase audit

Write `docs/planning/{ID}/audit-report-{phase-N}.md`:

```markdown
# Plan Audit — {phase-N} ({ID})

**Verdict:** PASS | FAIL
**Date:** {ISO date}
**Phase:** phase-N

## Mechanical
PASS | FAIL — {detail}

## Spec
PASS | FAIL — {detail}

## Standards
PASS | FAIL | NOTES — {detail}

## Compliance
PASS | FAIL — {detail}

## Architecture
OK | NOTES | FAIL — {detail}

**Flagged modules:**
- `{module}`: {signal} ({dependency}) — {impact}
- …

## Blocking findings
- …

## Non-blocking notes (for ADR execution notes)
- …
```
