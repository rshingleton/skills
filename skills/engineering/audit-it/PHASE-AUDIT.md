# Plan Audit (Doc Cycle)

Independent audit of `/implement-it` phases for a plan. Gates `/verify-it`.

**Read-only** for production code — writes `docs/planning/{ID}/audit-report.md` (or `audit-report-{phase-N}.md` for single-phase).

## Mode

| Mode | When | Scope | Output |
|------|------|-------|--------|
| **Full audit** (default) | After **all** phases implemented | Every phase in the plan | `audit-report.md` |
| **Single-phase audit** | `--phase phase-N` after any one phase | That phase only | `audit-report-{phase-N}.md` |

Single-phase audit provides **early feedback** — it does not gate the full verify. Use it to catch issues early on multi-phase plans. Full audit is still required before final `/verify-it`.

## Multi-phase audit

Cycles through every implemented phase one at a time, running full Mechanical → Spec → Standards → Compliance → Architecture checks per phase (same as single-phase). Findings are compiled into one combined report.

### Process

1. **Discover phases** — read `docs/planning/{ID}/README.md` or enumerate `phase-*` directories.
2. **For each phase**, run sections [1-6](#1-context) individually:
   - Context scoped to that phase's `ai-prompt.md` and diff
   - Mechanical: full project test suite
   - Spec: acceptance criteria from that phase's prompt
   - Standards: phase's pre-handoff checklist
   - Compliance, Architecture: phase-scoped
3. **Compile** — collect all verdicts and findings into a combined result table:

   | Phase | Mechanical | Spec | Standards | Compliance | Architecture |
   |-------|-----------|------|-----------|------------|-------------|
   | phase-1 | PASS | PASS | NOTES | PASS | OK |
   | phase-2 | PASS | FAIL | PASS | PASS | NOTES |
   | Overall | PASS | FAIL | NOTES | PASS | NOTES |

4. **Verdict:** PASS only when every phase passes every check. Any single FAIL → overall FAIL.
5. **Report** — write `docs/planning/{ID}/audit-report.md` with the table above, per-phase blocking findings, and per-phase non-blocking notes.

## 1. Context

### Full audit

- `docs/planning/{ID}/README.md` — orchestration map and phase list
- **Every** `docs/planning/{ID}/phase-*/ai-prompt.md`
- Optional `phase-*/execution-notes.md`
- Linked ADRs and `CONTEXT.md`
- Combined diff for the plan

Confirm all implementation phases are complete. If any phase is missing, stop.

### Single-phase audit (`--phase phase-N`)

- `docs/planning/{ID}/README.md` — phase order, dependency info
- `docs/planning/{ID}/phase-N/ai-prompt.md` — the phase's spec contract
- Optional `docs/planning/{ID}/phase-N/execution-notes.md`
- Linked ADRs and `CONTEXT.md`
- Diff scoped to this phase's changes (compare implementation-start ref or working tree state before phase N vs now)

Do not trust implement-it self-checks — verify independently.

## 2. Mechanical

Re-run the full project test suite and lint/type-check commands.

| Result | Action |
|--------|--------|
| FAIL | **Blocking** — return to `/implement-it` |
| PASS | Continue |

## 3. Spec

Check the audited phase(s) against their `ai-prompt.md`:

- [ ] Every acceptance criterion met in the diff
- [ ] No behaviour beyond prompt + linked ADR scope (scope creep)
- [ ] No criterion partially or incorrectly implemented

| Result | Action |
|--------|--------|
| **Full audit** — any miss in any phase | **Blocking** — return to `/implement-it` (name the phase) |
| **Single-phase** — any miss | **Blocking** — return to `/implement-it` for this phase; other phases unaffected |
| PASS | Continue |

## 4. Standards

Audit implement-it's pre-handoff checklist ([implement-it/STANDARDS.md](../implement-it/STANDARDS.md) §3) for each phase — do not assume it was run.

Spot-check the combined diff against standards docs from [STANDARDS.md](../implement-it/STANDARDS.md) §1. Skip rules tooling already enforces.

| Result | Action |
|--------|--------|
| Hard violation | **Blocking** — return to `/implement-it` (name the phase) |
| Judgement call | **Non-blocking** — note for ADR execution notes |
| PASS | Continue |

## 5. Compliance

Blocking subset (full PR gate: `/internal-compliance`):

### 5.1 Repo compliance rules

If `.compliance-rules/` exists at repo root, read all `*.md` and `*.yaml` files. Apply their rules to the diff — treat any HIGH-severity violation as blocking.

### 5.2 Universal checks

- [ ] No secrets, tokens, or passwords in diff
- [ ] No `.env` / `.env.*` staged or added
- [ ] No credential placeholders in comments
- [ ] New dependencies comply with policy (no `*`, unbounded `>=`, shadow registries)

### 5.3 Verdict

| Result | Action |
|--------|--------|
| Any fail | **Blocking** — return to `/implement-it` (name the phase) |
| PASS | Continue |

## 6. Architecture

Scope: **all files touched across every implemented phase.**

### 6.1 Deletion test

For each new or changed module, walk through:

1. **Name the module**
2. **What behaviour vanishes if deleted?**
3. **Where does that behaviour reappear?** (N callers? other modules?)
4. **If step 3 is "nowhere"** — module is a pass-through (shallow / indirection tax)

### 6.2 Classification

Classify each flagged module with **signal**, **dependency category**, and **impact**. Dependency category weights severity (see [DEEPENING.md](../improve-codebase-architecture/DEEPENING.md)):

| Signal | Definition | Impact | Heavier when… |
|--------|------------|--------|---------------|
| **Shallow module** | Interface nearly as complex as implementation | Low leverage — callers learn much for little behaviour | dependency is in-process (merge candidate) |
| **Leaky seam** | Callers must know internals | Poor locality — callers break when internals change | dependency is in-process (merge flattens leak) |
| **Indirection tax** | Pass-through with no added behaviour | Zero leverage — ceremony without behaviour | no test adapter exists (seam is speculative) |

### 6.3 Verify implement-it self-checks

implement-it's [STANDARDS.md](../implement-it/STANDARDS.md) §3 requires deletion test, seam discipline, and test-surface checks before handoff. Verify:

- [ ] implement-it self-check was thorough — e.g. missed single-adapter seams?
- [ ] Tests cross internal seams (mocking internals, fragile setup) — sign the interface is insufficient?
- [ ] implement-it flagged borderline cases or surfaced trade-offs in execution notes?

### 6.4 Verdict

| Result | Action |
|--------|--------|
| Self-check missed issues OR egregious accretion vs ADR intent | **Blocking** — return to `/implement-it` (name the phase) |
| Minor debt caught by self-check, none missed | **Non-blocking** — note for verify-it → ADR execution notes |
| OK | Continue |

**On re-audit:** Re-run all checks — not just previously failing ones. A fix for one issue may introduce regressions elsewhere. The full gate resets on every pass.

Do not propose new interfaces here — hand off to `/improve-codebase-architecture` when follow-up is warranted.

## 7. Report

Write `docs/planning/{ID}/audit-report.md` (or `audit-report-{phase-N}.md` for single-phase). See [TEMPLATES.md](TEMPLATES.md) for formats.

Present the same summary in chat.

## 8. Next skill

### Full audit

| Verdict | Tell the user |
|---------|----------------|
| **FAIL** | Audit failed — return to `/implement-it` with blocking findings. Do **not** run `/verify-it`. |
| **PASS** | Audit passed. **Next:** Run `/verify-it` to finalize ADRs, CONTEXT.md, changelog, and planning cleanup. |

### Single-phase audit (`--phase phase-N`)

| Verdict | Tell the user |
|---------|----------------|
| **FAIL** | Phase N audit failed — return to `/implement-it` on `phase-N` only. Remaining phases are unaffected. |
| **PASS** | Phase N passed. **Next:** Run `/verify-it --phase phase-N` to close this phase incrementally, or continue with `/implement-it` on remaining phases. |
