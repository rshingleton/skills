# Audit report templates

`## Spec` and `## Standards` hold code-review's reports verbatim, under audit-it's verdict line. Multi-phase reports repeat both sections per phase.

## Full audit

Write `docs/planning/{ID}/audit-report.md`:

```markdown
# Plan Audit: {ID}

**Verdict:** PASS | FAIL
**Date:** {ISO date}
**Phases audited:** 1 … N
**Fixed point:** {start ref}

## Mechanical
PASS | FAIL: {detail}

## Spec
PASS | FAIL: {one line}

{code-review Spec report, verbatim}

## Standards
PASS | FAIL | NOTES: {one line}

{code-review Standards report, verbatim}

## Compliance
PASS | FAIL: {detail}

## Architecture
OK | NOTES | FAIL: {detail}

**Flagged modules:**
- `{module}`: {signal} ({dependency}): {impact}
- …

## Guardrail candidates
- {mechanical rule}: {lint rule or hook that would catch it}
- …

## Blocking findings
- …

## Non-blocking notes (for ADR execution notes)
- …
```

## Single-phase audit

Write `docs/planning/{ID}/audit-report-{phase-N}.md`:

```markdown
# Plan Audit: {phase-N} ({ID})

**Verdict:** PASS | FAIL
**Date:** {ISO date}
**Phase:** phase-N
**Fixed point:** {start ref}

## Mechanical
PASS | FAIL: {detail}

## Spec
PASS | FAIL: {one line}

{code-review Spec report, verbatim}

## Standards
PASS | FAIL | NOTES: {one line}

{code-review Standards report, verbatim}

## Compliance
PASS | FAIL: {detail}

## Architecture
OK | NOTES | FAIL: {detail}

**Flagged modules:**
- `{module}`: {signal} ({dependency}): {impact}
- …

## Guardrail candidates
- {mechanical rule}: {lint rule or hook that would catch it}
- …

## Blocking findings
- …

## Non-blocking notes (for ADR execution notes)
- …
```
