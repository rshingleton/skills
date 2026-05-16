# Plan Audit (Doc Cycle)

Independent audit of **all** `/implement-it` phases for a plan. Gates `/verify-it`.

Run only after every implementation phase in the orchestration `README.md` is complete.

**Read-only** for production code — writes `docs/planning/{ID}/audit-report.md` at the plan root.

## 1. Context

Load:

- `docs/planning/{ID}/README.md` — orchestration map and phase list
- **Every** `docs/planning/{ID}/phase-*/ai-prompt.md` — spec contracts for all implemented phases
- Optional `phase-*/execution-notes.md` from implement-it
- Linked ADRs and `CONTEXT.md` for touched areas
- Combined diff for the plan (all changes since implementation began; use `git diff` if a base ref exists)

Confirm all phases listed for implementation in the README have been completed. If any phase is missing, stop — user must finish `/implement-it` first.

Do not trust implement-it self-checks — verify independently.

## 2. Mechanical

Re-run the full project test suite and lint/type-check commands.

| Result | Action |
|--------|--------|
| FAIL | **Blocking** — return to `/implement-it` |
| PASS | Continue |

## 3. Spec

For **each** phase `ai-prompt.md`:

- [ ] Every acceptance criterion met in the diff
- [ ] No behaviour beyond that phase's prompt + linked ADR scope (scope creep)
- [ ] No criterion partially or incorrectly implemented

| Result | Action |
|--------|--------|
| Any miss in any phase | **Blocking** — return to `/implement-it` (name the phase) |
| PASS | Continue |

## 4. Standards

Audit implement-it's pre-handoff checklist ([implement-it/STANDARDS.md](../implement-it/STANDARDS.md) §3) for each phase — do not assume it was run.

Spot-check the combined diff against standards docs from [STANDARDS.md](../implement-it/STANDARDS.md) §1. Skip rules tooling already enforces.

| Result | Action |
|--------|--------|
| Hard violation | **Blocking** |
| Judgement call | **Non-blocking** — note for ADR execution notes |
| PASS | Continue |

## 5. Compliance

Blocking subset (full PR gate: `/internal-compliance`):

- [ ] No secrets, tokens, or passwords in diff
- [ ] No `.env` / `.env.*` staged or added
- [ ] No credential placeholders in comments
- [ ] New dependencies comply with policy (no `*`, unbounded `>=`, shadow registries)

| Result | Action |
|--------|--------|
| Any fail | **Blocking** |
| PASS | Continue |

## 6. Architecture

Scope: **all files touched across every implemented phase.**

Apply the **deletion test** (see [LANGUAGE.md](../improve-codebase-architecture/LANGUAGE.md)) and classify new or changed modules:

| Signal | Definition |
|--------|------------|
| **Shallow module** | Interface nearly as complex as implementation |
| **Leaky seam** | Callers must know internals |
| **Indirection tax** | Pass-through with no added behaviour |

| Result | Action |
|--------|--------|
| Egregious accretion vs ADR intent | **Blocking** — return to `/implement-it` |
| Minor debt | **Non-blocking** — note for verify-it → ADR execution notes |
| OK | Continue |

Do not propose new interfaces here — hand off to `/improve-codebase-architecture` when follow-up is warranted.

## 7. Report

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

## Blocking findings
- …

## Non-blocking notes (for ADR execution notes)
- …
```

Present the same summary in chat.

## 8. Next skill

| Verdict | Tell the user |
|---------|----------------|
| **FAIL** | Audit failed — return to `/implement-it` with blocking findings. Do **not** run `/verify-it`. |
| **PASS** | Audit passed. **Next:** Run `/verify-it` to finalize ADRs, CONTEXT.md, changelog, and planning cleanup. |
