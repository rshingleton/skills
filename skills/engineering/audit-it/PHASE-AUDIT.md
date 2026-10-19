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
   - Spec and Standards: one `code-review` call against that phase's prompt and start ref
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
- `phase-*/execution-notes.md` (holds each phase's `Start ref:`)
- Linked ADRs and `GLOSSARY.md`
- Combined diff for the plan, from phase-1's start ref

Confirm all implementation phases are complete. If any phase is missing, stop.

### Single-phase audit (`--phase phase-N`)

- `docs/planning/{ID}/README.md` — phase order, dependency info
- `docs/planning/{ID}/phase-N/ai-prompt.md` — the phase's spec contract
- `docs/planning/{ID}/phase-N/execution-notes.md` (holds the phase's `Start ref:`)
- Linked ADRs and `GLOSSARY.md`
- Diff scoped to this phase's changes, from its start ref to the working tree

Do not trust implement-it self-checks — verify independently.

## 2. Mechanical

Re-run the full project test suite and lint/type-check commands.

| Result | Action |
|--------|--------|
| FAIL | **Blocking** — return to `/implement-it` |
| PASS | Continue |

## 3. Spec and Standards: call code-review

Call the Skill tool with "code-review". Single-phase and multi-phase audits call it once per phase, against that phase's spec; the full audit calls it once, with every phase prompt as the spec. Pass it:

- **Fixed point:** the `Start ref:` in the phase's `execution-notes.md` (full audit: phase-1's). If none is recorded, ask the user for the ref the phase started from, one question, and wait.
- **Diff command:** `git diff <start-ref>` (working tree against the ref, since implement-it does not commit), plus the untracked files from `git ls-files --others --exclude-standard`, read in full. Say this replaces the three-dot `...HEAD` diff.
- **Spec:** the phase's `ai-prompt.md` and the plan's `sources/*.md`, by path. Say there is no issue tracker: the spec is given, so it must not look one up or suggest `/setup-matt-pocock-skills`. If other phases share the start ref, list their `ai-prompt.md` paths too, so their changes count as other phases' work, not scope creep.
- **Standards sources:** whatever code-review finds in the repo, plus `.compliance-rules/coding-standards*.md` (if present) and [REVIEW-STANDARDS.md](REVIEW-STANDARDS.md).

Copy code-review's Standards and Spec reports verbatim into the audit report under `## Spec` and `## Standards`. Do not merge, rerank, or rewrite findings; put audit-it's verdict line above each report.

## 4. Spec and Standards: verdict

| Axis | Result | Action |
|------|--------|--------|
| Spec | Any missing, partial, or wrong requirement, or scope creep | **Blocking**: return to `/implement-it` (name the phase; other phases unaffected) |
| Standards | Hard violation of a documented standard | **Blocking**: return to `/implement-it` (name the phase) |
| Standards | Judgement call (including every baseline smell) | **Non-blocking**: note for ADR execution notes |
| Either | No findings | PASS, continue |

**Guardrail candidates.** For each violated rule that is mechanical (a fixed pattern, a banned API, an import shape, a file-location rule), add it to the report's "Guardrail candidates" list as a candidate lint rule or hook, per `retro`'s mechanical vs judgement classification. List only; do not build them.

## 5. Compliance

Blocking subset (full PR gate: `/internal-compliance`):

### 5.1 Repo compliance rules

If `.compliance-rules/` exists at repo root, read all `*.md` and `*.yaml` files. Apply their rules to the diff — treat any HIGH-severity violation as blocking.

Also read, when present, `SECURITY_POLICY.md` (repo root or `docs/`) and `docs/agents/compliance/`. A diff that breaks either is blocking.

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

### 6.3 Seams and test surface

Check the diff against the Design rules in [REVIEW-STANDARDS.md](REVIEW-STANDARDS.md); implement-it no longer self-checks them:

- [ ] Any single-adapter seam (speculative indirection)?
- [ ] Do tests cross internal seams (mocking internals, fragile setup), a sign the interface is insufficient?
- [ ] Did implement-it record borderline cases or trade-offs in execution notes? (Context for the notes, not a gate.)

### 6.4 Verdict

Shallow modules, speculative seams, and tests crossing internal seams are judgement calls, as in §4.

| Result | Action |
|--------|--------|
| Egregious accretion vs ADR intent (layers, modules, or seams the ADR does not call for) | **Blocking**: return to `/implement-it` (name the phase) |
| Shallow module, speculative seam, or test crossing internal seams | **Non-blocking**: note for verify-it → ADR execution notes |
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
| **PASS** | Audit passed. **Next:** Run `/verify-it` to finalize ADRs, GLOSSARY.md, changelog, and planning cleanup. |

### Single-phase audit (`--phase phase-N`)

| Verdict | Tell the user |
|---------|----------------|
| **FAIL** | Phase N audit failed — return to `/implement-it` on `phase-N` only. Remaining phases are unaffected. |
| **PASS** | Phase N passed. **Next:** Run `/verify-it --phase phase-N` to close this phase incrementally, or continue with `/implement-it` on remaining phases. |
