# Plan Audit (Doc Cycle)

Independent audit of `/implement-it` phases for a plan. Gates `/verify-it`.

**Read-only** for production code: writes `docs/planning/{ID}/audit-report.md` (or `audit-report-{phase-N}.md` for a Single-phase audit).

## Modes

| Mode | Invocation | Scope | Output |
|------|------------|-------|--------|
| **Full audit** (default) | `/audit-it` after **every** phase | The plan's combined diff, one pass | `audit-report.md` |
| **Per-phase audit** | `/audit-it --phases` after **every** phase | Each phase on its own, compiled | `audit-report.md` |
| **Single-phase audit** | `/audit-it --phase phase-N` after any one phase | That phase only | `audit-report-{phase-N}.md` |

A Single-phase audit is **early feedback**: it does not gate the final `/verify-it`. A Full or Per-phase audit is still required before it.

### Per-phase audit

Runs a Single-phase audit (sections 1 to 6) on every implemented phase, one at a time, then compiles one report.

- **Discover phases:** read `docs/planning/{ID}/README.md` or enumerate `phase-*` directories.
- **For each phase:** context and diff scoped to that phase's `ai-prompt.md` and Base ref; Mechanical runs the full project test suite; one `code-review` call against that phase's prompt and committed range; Compliance and Architecture scoped to the phase.
- **Compile:** a result table with one row per phase and an Overall row (see [TEMPLATES.md](TEMPLATES.md)), then every phase's findings numbered in one sequence.
- **Verdict:** PASS only when every phase passes every check. Any single FAIL fails the audit.

## 1. Context

### Full audit

- `docs/planning/{ID}/README.md`: orchestration map and phase list
- **Every** `docs/planning/{ID}/phase-*/ai-prompt.md`
- `phase-*/execution-notes.md` (holds each phase's `Base ref:`)
- Linked ADRs and `GLOSSARY.md`
- Combined diff for the plan: `git diff $(git merge-base main HEAD)..HEAD` on the integration branch

Confirm all implementation phases are complete. If any phase is missing, stop.

### Single-phase audit (`--phase phase-N`)

- `docs/planning/{ID}/README.md`: phase order, dependency info
- `docs/planning/{ID}/phase-N/ai-prompt.md`: the phase's spec contract
- `docs/planning/{ID}/phase-N/execution-notes.md` (holds the phase's `Base ref:`)
- Linked ADRs and `GLOSSARY.md`
- Diff scoped to this phase's commits: those since its Base ref with the phase's message prefix (§3)

Do not trust implement-it self-checks: verify independently.

### Recorded decisions

Before judging anything, list the decisions the phase prompts and linked ADRs record (the plan README's decisions, each ADR's Decision section, a phase's Scope and Boundaries). A recorded decision is not a finding in Mechanical, Compliance, Architecture or the summary, even where a baseline standard would flag it. Flag it only when the diff contradicts the decision, and cite the decision in the finding. A `shortcut:` marker that names its limit is a recorded decision too, per [REVIEW-STANDARDS.md](REVIEW-STANDARDS.md) "Recorded shortcuts".

## 2. Mechanical

Re-run the full project test suite and lint/type-check commands.

| Result | Action |
|--------|--------|
| FAIL | **Must**: return to `/implement-it`. Name the failing command and test as the case |
| PASS | Continue |

## 3. Spec and Standards: call code-review

Call the Skill tool with "code-review". Single-phase and Per-phase audits call it once per phase, against that phase's spec; the Full audit calls it once, with every phase prompt as the spec. Pass it:

- **Fixed point:** single phase, the `Base ref:` in the phase's `execution-notes.md`; Full audit, `git merge-base main HEAD` on the integration branch. If a phase has no Base ref recorded, ask the user for the commit the phase started from, one question, and wait.
- **Diff command:** single phase, the phase's own commits since its Base ref, by their subject prefix, the phase's Jira key from `jira.md` else `{ID} phase-N`, always followed by its colon so `PROJ-1` does not match `PROJ-12`: `git log -p --reverse --no-merges --grep='^<prefix>:' <Base ref>..HEAD` on the integration branch. The grep also matches body lines; drop any listed commit whose subject lacks the prefix. Merges and sibling phases' commits stay out, and later fix commits with the same prefix are in. Full audit, `git diff <merge-base>..HEAD`.
- **Spec:** the phase's `ai-prompt.md` and the plan's `sources/*.md`, by path. Say there is no issue tracker: the spec is given, so it must not look one up or suggest `/setup-matt-pocock-skills`. The Full audit passes every phase's `ai-prompt.md`.
- **Standards sources:** whatever code-review finds in the repo, plus `.compliance-rules/coding-standards*.md` (if present) and [REVIEW-STANDARDS.md](REVIEW-STANDARDS.md).

Copy code-review's Standards and Spec reports verbatim into the audit report under `## Spec` and `## Standards`. Do not merge, rerank, or rewrite findings; put audit-it's verdict line above each report.

## 4. Spec and Standards: verdict

| Axis | Result | Action |
|------|--------|--------|
| Spec | Any missing, partial, or wrong requirement, or scope creep | **Blocking**: return to `/implement-it` (name the phase; other phases unaffected) |
| Standards | Violation of a `.compliance-rules/` rule | Blocking or not by the [severity rule](#severity-rule), the same as §5.1 |
| Standards | Hard violation of any other documented standard | **Blocking**: return to `/implement-it` (name the phase) |
| Standards | Judgement call (including every baseline smell) | **Non-blocking**: note for the execution notes (the plan's ADR, else its changelog entry) |
| Either | No findings | PASS, continue |

A Spec or Standards finding that only restates a recorded decision does not block. Say so on the verdict line rather than editing code-review's report.

**Guardrail candidates.** For each violated rule that is mechanical (a fixed pattern, a banned API, an import shape, a file-location rule), add it to the report's "Guardrail candidates" list as a candidate lint rule or hook, per `retro`'s mechanical vs judgement classification. List only; do not build them.

## 5. Compliance

Blocking subset (full PR gate: `/internal-compliance`):

### 5.1 Repo compliance rules

If `.compliance-rules/` exists at repo root, read all `*.md` and `*.yaml` files and apply their rules to the diff.

#### Severity rule

One rule for every `.compliance-rules/` violation, whether §4 (via code-review) or this section finds it:

| Rule's stated severity | Group | Blocks |
|------------------------|-------|--------|
| HIGH, or none stated | **Must** | Yes |
| MEDIUM | **Should** | No |
| LOW | **Nice** | No |

Also read, when present, `SECURITY_POLICY.md` (repo root or `docs/`) and `docs/agents/compliance/`. A diff that breaks either is a **Must**.

### 5.2 Universal checks

Each failed check is a **Must**; name the file and line.

- [ ] No secrets, tokens, or passwords in diff
- [ ] No `.env` / `.env.*` staged or added
- [ ] No credential placeholders in comments
- [ ] New dependencies comply with policy (no `*`, unbounded `>=`, shadow registries)

### 5.3 Verdict

| Result | Action |
|--------|--------|
| Any **Must** | **Blocking**: return to `/implement-it` (name the phase) |
| Only Should or Nice, or none | PASS, continue |

## 6. Architecture

Scope: **all files touched** by the audited diff.

### 6.1 Deletion test

For each new or changed module, walk through:

- **Name the module.**
- **What behaviour vanishes if deleted?**
- **Where does that behaviour reappear?** (N callers? other modules?)
- **If the answer is "nowhere":** the module is a pass-through (shallow, indirection tax).

### 6.2 Classification

Classify each flagged module with **signal**, **dependency category**, and **impact**. Dependency category weights severity (see [DEEPENING.md](../improve-codebase-architecture/DEEPENING.md)):

| Signal | Definition | Impact | Heavier when… |
|--------|------------|--------|---------------|
| **Shallow module** | Interface nearly as complex as implementation | Low leverage: callers learn much for little behaviour | dependency is in-process (merge candidate) |
| **Leaky seam** | Callers must know internals | Poor locality: callers break when internals change | dependency is in-process (merge flattens leak) |
| **Indirection tax** | Pass-through with no added behaviour | Zero leverage: ceremony without behaviour | no test adapter exists (seam is speculative) |

### 6.3 Seams and test surface

Check the diff against the Design rules in [REVIEW-STANDARDS.md](REVIEW-STANDARDS.md); implement-it no longer self-checks them:

- [ ] Any single-adapter seam (speculative indirection)?
- [ ] Do tests cross internal seams (mocking internals, fragile setup), a sign the interface is insufficient?
- [ ] Did implement-it record borderline cases or trade-offs in execution notes? (Context for the notes, not a gate.)

### 6.4 Verdict

Shallow modules, speculative seams, and tests crossing internal seams are judgement calls, as in §4. A layer or seam that a linked ADR records is not accretion.

| Result | Action |
|--------|--------|
| Egregious accretion vs ADR intent (layers, modules, or seams the ADR does not call for) | **Must**: return to `/implement-it` (name the phase) |
| Shallow module, speculative seam, or test crossing internal seams | **Should**: note for verify-it's execution notes (the plan's ADR, else its changelog entry) |
| OK | Continue |

**On re-audit:** Re-run all checks, not just previously failing ones. A fix for one issue may introduce regressions elsewhere. The full gate resets on every pass.

Do not propose new interfaces here; hand off to `/improve-codebase-architecture` when follow-up is warranted.

## 7. Report

Write `docs/planning/{ID}/audit-report.md` (or `audit-report-{phase-N}.md` for a Single-phase audit) from [TEMPLATES.md](TEMPLATES.md), following its finding contract.

Present the same Findings, `Verdict:` and `Not checked:` lines in chat.

## 8. Next skill

### Full audit and Per-phase audit

| Verdict | Tell the user |
|---------|----------------|
| **FAIL** | Audit failed: {N} Must findings in {phases}. **Next:** Return to `/implement-it` on those phases, or re-audit one with `/audit-it --phase phase-N` after the fix. Do **not** run `/verify-it`. |
| **PASS** | Audit passed ({phases audited}). **Next:** Run `/verify-it` to finalize ADRs, GLOSSARY.md, changelog, and planning cleanup. |

### Single-phase audit (`--phase phase-N`)

| Verdict | Tell the user |
|---------|----------------|
| **FAIL** | Phase N audit failed. **Next:** Return to `/implement-it` on `phase-N` only. Remaining phases are unaffected. |
| **PASS** | Phase N passed. **Next:** Run `/verify-it --phase phase-N` to close this phase incrementally, or continue with `/implement-it` on remaining phases. |
