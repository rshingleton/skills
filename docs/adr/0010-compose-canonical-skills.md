# ADR-0010: Custom Skills Call Canonical Skills for Generic Methods

**Status:** Accepted
**Date:** 2026-10-18
**Author:** Russell Shingleton
**Plan:** `docs/planning/skill-composition/`

## Context

The Doc Cycle skills (`plan-it`, `implement-it`, `audit-it`) were written when this fork had
few canonical skills to lean on, so each carries its own copy of a generic method: grilling,
glossary and ADR upkeep, the TDD loop, bug diagnosis, and review. Upstream has since improved
every one of those methods in its own skills (`grilling`, `domain-modeling`, `tdd`,
`diagnosing-bugs`, `code-review`). The copies have drifted: plan-it still grills one question at
a time, implement-it keeps refactoring inside the TDD loop that `tdd` now puts in review, and
implement-it hands bugs to the fork's older `diagnose`. Each upstream improvement has to be
ported by hand, and the ones that were not ported are silently missing.

## Decision

1. **Custom skills call canonical skills for generic methods instead of restating them.** A
   custom skill names the canonical skill with a `Call the Skill tool with "<name>"` line and
   passes it the Doc Cycle context it needs (phase prompt, `sources/`, agreed seams, fixed
   point). It keeps only what is Doc Cycle specific: phases and their gates, `sources/`, the
   Jira map, compliance rules, and the audit and verify reports.
2. **Plans agree test seams.** plan-it's grill agrees the seams for each phase and records them
   in a `## Seams` section of the phase prompt; implement-it passes them to `tdd` as already
   agreed. Phases are vertical slices with explicit blocking edges.
3. **Standards are enforced at review.** implement-it runs the repo's tooling and stays in
   scope; judgement-call standards are checked by audit-it through `code-review`, which runs
   Spec and Standards as separate sub-agents. Mechanical rules are flagged as guardrail
   candidates rather than left to either agent.
4. **Every called skill ships.** A canonical skill a custom skill calls is listed in
   `.claude-plugin/plugin.json` and the README, so plugin installs never break a delegation.

## Consequences

- Upstream improvements to the called skills reach the Doc Cycle on the next upstream merge,
  without porting.
- A rename or removal upstream breaks a delegation silently. The static check that every called
  skill exists under `skills/` and in `plugin.json` is part of each phase's verification and
  should be re-run after every upstream merge.
- plan-it's grill changes from one question at a time to numbered rounds, the canonical style.
  This is a deliberate exception to `.compliance-rules/ai-skills-style-guide.md` section 3
  ("one at a time"), which still applies to discovery prompts that do not call `grilling`.
- Design smells (shallow module, speculative seam, test crossing internal seams) are judgement
  calls at audit and no longer block a phase; only accretion beyond ADR intent blocks at
  Architecture. With the implementer's self-check gone, "missed by the self-check" no longer
  had a meaning.
- The implementer no longer applies `.compliance-rules/` on every red and green step. The rules
  are checked once, at audit, against the diff.
- `diagnose` is deprecated in favour of `diagnosing-bugs`.
- Parallel implementation across phases (`implement-spec` style) becomes possible once phases
  carry blocking edges, but is deferred: it needs per-phase commits, which conflicts with
  `commit-it` owning commits.

## Execution Notes

Implemented in three phases; full audit failed once on two phase-3 findings, both fixed, then
passed.

- **plan-it** (phase 1): `GRILL.md` calls `grilling` and `domain-modeling` and keeps only the
  plan agenda (overlapping intake, one plan or several, vertical slices, seams, deferred risk).
  `SCAFFOLD.md` gained slicing rules (vertical tracer-bullet slices, one context window,
  prefactoring first, expand/migrate/contract), approval of the phase breakdown before any file
  is written, a `Blocked by` column in the plan README, and a fixed `ai-prompt.md` section order
  that includes `## Seams` (each seam with what it catches and misses). `AGENT-BRIEF.md`
  deleted; step 5 matches `JIRA.md`.
- **implement-it** (phases 2 and 3): calls `tdd` with the phase's seams marked as agreed, and
  proposes and confirms seams once when a prompt has none. Refactoring left the loop. Failures
  explainable in one hypothesis are fixed inline; the rest, and anything flaky, go to
  `diagnosing-bugs`. `EXAMPLES.md` deleted. `STANDARDS.md` keeps discovery, scope and secrets;
  the judgement-call rules moved to `audit-it/REVIEW-STANDARDS.md`. implement-it writes
  `Start ref: <HEAD>` to the phase's `execution-notes.md` before its first edit. `SKILL.md` went
  from 116 to 99 lines. Description trimmed to Doc Cycle triggers.
- **audit-it** (phase 3): Spec and Standards come from one `code-review` call per phase, given
  the start ref as fixed point, `git diff <ref>` plus untracked files (implement-it never
  commits, so `...HEAD` would be empty), the phase prompt and `sources/` as the spec with an
  explicit no-tracker instruction, and `.compliance-rules/coding-standards*.md` plus
  `REVIEW-STANDARDS.md` as standards sources. The report keeps code-review's two reports
  unranked and adds a "Guardrail candidates" list for mechanical rules. `PHASE-AUDIT.md` §5.1
  also reads
  `SECURITY_POLICY.md` and `docs/agents/compliance/`, which the first audit found lost in the
  move.
- **diagnose** moved to `skills/deprecated/`, added to `scripts/legacy-skills.txt` and the
  cleanup fallback list. Old installs keep it until `skills.sh --cleanup-legacy` runs, because
  the link scripts do not remove links for skills that left the repo.
- **Shipped:** `code-review`, `codebase-design`, `diagnosing-bugs`, `domain-modeling` and
  `grilling` added to `plugin.json` and the READMEs.
- **Dry runs** (toy `greet --version` plan, headless `claude -p` against the branch's linked
  skills): plan-it called both skills, grilled in numbered rounds, and got the breakdown
  approved before scaffolding; implement-it called `tdd` without re-confirming seams and handed
  a seeded flaky failure to `diagnosing-bugs`; `audit-it --phase phase-1` ran code-review's two
  sub-agents from the recorded start ref without asking about a tracker, and a seeded magic
  number landed under Standards and in Guardrail candidates.
- **Open, not acted on:**
  - `internal-compliance/SKILL.md` and `.compliance-rules/coding-standards-{markdown,shell}.md`
    still name only `implement-it/STANDARDS.md` as the baseline; `coding-standards.md` names
    both files.
  - `audit-it/SKILL.md` (131 lines) and `plan-it/SKILL.md` (121) remain over the style guide's
    100-line ceiling, both over before this work.
  - audit-it's description still triggers on "review", which overlaps `code-review`.
  - `diagnosing-bugs` asks for a regression test even when the bug sits outside the agreed
    seams; implement-it has no rule for that case.
  - `PHASE-AUDIT.md` §4 can block on a non-HIGH `.compliance-rules` rule that code-review calls
    hard, while §5.1 blocks only HIGH-severity rules.
  - Shared start refs across uncommitted phases were not exercised beyond a one-phase toy plan.
  - Static check 2's grep misses lowercase "call the Skill tool" and "Call the Skill tool
    twice, for ..." forms.

## References

- `docs/planning/skill-composition/`: plan, phase prompts, audit report (compacted at verify-it)
