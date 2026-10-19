# Audit report templates

Fill the template for the mode exactly. `## Spec` and `## Standards` hold code-review's reports verbatim, under audit-it's verdict line. A Per-phase audit report repeats both sections per phase. The finding contract below covers every other section and the summary.

## Finding contract

- **Concrete case or no finding.** Every finding names a file and line, an input, or a scenario that shows the problem. Re-read the lines before reporting: the caller exists, the value can be empty, the file was added. No case, no finding; no "consider", no vague worries.
- **Recorded decisions are not findings.** A choice the phase prompt or a linked ADR records is not flagged unless the diff contradicts it; then the finding cites the decision.
- **Groups.** **Must** blocks the verdict (a failed Mechanical check, a Compliance **Must** per the severity rule, egregious accretion, a blocking Spec or Standards verdict). **Should** and **Nice** do not block; verify-it carries them into the execution notes (the plan's ADR, else its changelog entry) as the non-blocking notes. Skip empty groups.
- **Numbering.** One sequence across all groups (Must first), so the user can say "fix 2 and 5". A Per-phase report keeps one sequence across phases and tags each finding with its phase.
- **Four parts per finding**, each one or two short sentences: what it is, the problem, the fix (the smallest that works), and the cost of skipping it.
- **Ending.** The report ends with `Verdict:` and `Not checked:`. `Not checked:` names what mattered and could not be checked, or `nothing`.

Finding shape:

```markdown
1. **`.env` committed with a live token** (`config/.env:L3`)
   - **What this is:** The phase adds `config/.env`, read at startup for the API token.
   - **Problem:** Line 3 holds a real token, now in git history for anyone with clone access.
   - **Fix:** Remove the file, add `config/.env` to `.gitignore`, commit `.env.example`, rotate the token.
   - **If we skip it:** The token leaks with every clone and fork until rotated.
```

## Full audit

Write `docs/planning/{ID}/audit-report.md`:

```markdown
# Plan Audit: {ID}

**Mode:** Full audit
**Date:** {ISO date}
**Phases audited:** 1 … N
**Fixed point:** {merge-base of the integration branch with main}

## Mechanical
PASS | FAIL: {commands run, one line}

## Spec
PASS | FAIL: {one line}

{code-review Spec report, verbatim}

## Standards
PASS | FAIL | NOTES: {one line}

{code-review Standards report, verbatim}

## Compliance
PASS | FAIL: {rules and checks applied, one line}

## Architecture
OK | NOTES | FAIL: {one line}

## Guardrail candidates
- {mechanical rule}: {lint rule or hook that would catch it}

## Findings

### Must
1. **{title}** (`{file}:L{line}` or {input or scenario})
   - **What this is:** …
   - **Problem:** …
   - **Fix:** …
   - **If we skip it:** …

### Should
2. …

### Nice
3. …

Verdict: PASS | FAIL, fix {numbers} first.
Not checked: {what mattered and could not be checked, or nothing}
```

## Per-phase audit

Write `docs/planning/{ID}/audit-report.md`: the Full audit template with `**Mode:** Per-phase audit`, and the result table after the header:

```markdown
| Phase | Mechanical | Spec | Standards | Compliance | Architecture |
|-------|-----------|------|-----------|------------|-------------|
| phase-1 | PASS | PASS | NOTES | PASS | OK |
| phase-2 | PASS | FAIL | PASS | PASS | NOTES |
| Overall | PASS | FAIL | NOTES | PASS | NOTES |
```

Then `## phase-N` per phase, each with its Mechanical to Architecture sections, followed by one `## Guardrail candidates`, one `## Findings` numbered across all phases (each title prefixed `phase-N:`), `Verdict:` and `Not checked:`.

## Single-phase audit

Write `docs/planning/{ID}/audit-report-{phase-N}.md`: the Full audit template with these header lines instead:

```markdown
# Plan Audit: {phase-N} ({ID})

**Mode:** Single-phase audit
**Date:** {ISO date}
**Phase:** phase-N
**Fixed point:** {Base ref from execution-notes.md}
```
