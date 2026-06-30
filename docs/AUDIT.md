# Audit: all skills — issue→plan→implement flow

Generated: repo audit — full survey of 28 skills across 4 buckets.

## Core value

The **Doc Cycle** (`issue-it → plan-it → implement-it → audit-it → verify-it → commit-it`) is complete, self-consistent, and well-documented. Every skill chains correctly to the next; no dead ends or broken references. The incremental `--phase` sub-flow also has no gaps.

The **seam discipline** (interface vs implementation) is strong:

| Seam | Interface | Consumer | Depth |
|------|-----------|----------|-------|
| `docs/issues/*.md` | YAML frontmatter + markdown body | `plan-it --from-issues` | Deep — single file protocol carries type, status, source, acceptance criteria |
| `docs/planning/<id>/phase-N/ai-prompt.md` | Heading + scope + verification criteria + estimate | `implement-it` | Deep — agent derives all context from one file |
| `docs/planning/<id>/jira.md` | Table rows (phase ↔ key) | `implement-it`, `verify-it`, `commit-it` | Shallow but justified — Jira keys are inherently tabular |
| `_jira_*` shell functions | Callable bash functions | All skills sourcing jira-helpers.sh | Deep — ~500 lines of curl collapsed into 17 functions |
| SKILL.md frontmatter | `name:` + `description:` with triggers | Agent dispatcher | Deep — description is the sole routing signal |

## Accretion — none

All 28 skills serve distinct purposes. No duplicate skills, no dead code. 3 deprecated skills (`to-epic`, `to-jiras`, `promote-to-jira`) are correctly excluded from the shipped skill index.

## Findings

### 1. `plan-it/SKILL.md` exceeds write-a-skill 100-line guideline (214 lines)

The write-a-skill template says "Split into separate files when SKILL.md exceeds 100 lines." At 214 lines, `plan-it` is more than double the limit. It already offloads `JIRA.md`, `FROM-ISSUES.md`, `OUT-OF-SCOPE.md`, `AGENT-BRIEF.md`, and `REFERENCE.md` — but the main file remains long.

**Suggestion:** Extract the intake evaluation workflow (lines 86-124) into `INTAKE-EVALUATION.md`, the grill section (lines 127-137) into `GRILL.md`, and the scaffold section (lines 139-170) into `SCAFFOLD.md`. The main SKILL.md would then be a routing table with "Quick start" and "Core tenets."

### 2. `issue-it/SKILL.md` at 135 lines — borderline

Also over the 100-line guideline. Already has `INTAKE-TEMPLATE.md` and `EXAMPLES.md`.

**Suggestion:** Extract the template reference and example walkthroughs into the existing supporting files. Main file should fit under 100 lines.

### 3. `setup-internal-skills` is the deepest module — also the most complex

186-line SKILL.md with 18 supporting files including shell scripts, templates, and reference docs. This is justified: it bootstraps the entire skills ecosystem across all consumer repos. But its surface area means changes here have the widest blast radius of any skill.

### 4. `deprecated/` bucket has no README.md

3 skills live here (`to-epic`, `to-jiras`, `promote-to-jira`). Per AGENTS.md policy they are correctly excluded from the shipped index. A local README would help developers browsing the repo understand the graveyard convention.

### 5. `personal/` bucket directory does not exist on disk

Referenced in AGENTS.md as a valid bucket but no `skills/personal/` directory exists. Harmless — it's a convention for users to create locally.

### 6. Skill description quality is high

All 28 SKILL.md files have valid frontmatter. 25/28 include "Use when" trigger keywords. The 3 deprecated skills omit triggers (acceptable — they should not be triggered).

## Simplification proposals

1. **Trim `plan-it/SKILL.md`** — extract intake eval, grill, and scaffold into separate files per the write-a-skill template guidance. Main file becomes an orchestrator with routing to sub-files.

2. **Trim `issue-it/SKILL.md`** — extract template reference and examples into existing supporting files.

3. **Add `deprecated/README.md`** — document the graveyard convention: skills moved here are not indexed, not triggered, and kept only for reference.

## Deletion candidates — none

## Verdict

**PASS** — no blocking findings. The issue→plan→implement flow is complete, consistent, and well-documented. The architectural depth (seam discipline, file protocol interfaces, delegation patterns) is strong.

**Next:** Pick a simplification proposal and run `/plan-it`, or `/implement-it` if already planned.
