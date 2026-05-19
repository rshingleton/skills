# Repo Audit: ai-skills structural consistency

**Date:** 2026-05-19
**Scope:** Recent changes (commit `4a1beaf`), skill registration, structure compliance with `write-a-skill` conventions, cross-skill consistency.

## Process

1. Registered skills cross-checked against `README.md`, `.claude-plugin/plugin.json`, bucket READMEs
2. All 28 SKILL.md files checked for frontmatter, triggers, broken paths
3. Commit `4a1beaf` (11 files) reviewed for consistency
4. Cross-skill references verified
5. Deprecated skill isolation confirmed

## Findings

### PASS — no action needed

- **Registration:** All 17 engineering + 4 productivity skills registered in root README, plugin.json, and bucket README. No leaks from `in-progress/` or `deprecated/`.
- **Frontmatter:** All 28 SKILL.md files have valid `name:` + `description:` frontmatter.
- **Paths:** No broken relative paths in any SKILL.md or companion file.
- **Commit consistency:** All 11 files from `4a1beaf` are internally consistent — `~/.agents/...` paths match across all files, to-jira cross-references agree.
- **Deprecated isolation:** No active skill references a deprecated skill file path.

### MEDIUM — should fix before next release

**M1: Stale Jira setup description in engineering README.**

`skills/engineering/README.md:49` says:
> Jira setup seeds `issue-tracker.md`, `jira-notifications.md`, `jira-description-style.md`.

Per commit `4a1beaf`, only `issue-tracker.md` is seeded — the other files are read from `~/.agents/skills/setup-internal-skills/`. The README description is now misleading.

**M2: Broken `audit-to-issues.md` link in AGENTS.md template.**

`skills/engineering/setup-internal-skills/templates/AGENTS.md:13,29` uses relative links `[audit-to-issues](../audit-to-issues.md)` and `[audit-to-issues.md](../audit-to-issues.md)`. When this template is written to an application repo's `AGENTS.md`, these resolve from the app repo root — but `audit-to-issues.md` only exists in the installed skills path. Should reference `~/.agents/skills/setup-internal-skills/audit-to-issues.md` instead.

### LOW — advisory

| # | Finding | File |
|---|---------|------|
| L1 | `internal-compliance/SKILL.md` description omits "Use when" trigger phrase | `skills/engineering/internal-compliance/SKILL.md` |
| L2 | `handoff/SKILL.md` description omits "Use when" trigger phrase | `skills/productivity/handoff/SKILL.md` |
| L3 | `plan-it/SKILL.md` is 212 lines — consider splitting orchestration from reference docs | `skills/engineering/plan-it/SKILL.md` |
| L4 | `setup-internal-skills/SKILL.md` is 165 lines | `skills/engineering/setup-internal-skills/SKILL.md` |

## Simplification proposals

- **M1 + M2** are quick fixes — two line edits total.
- L1-L2 pattern suggests adding a `"Use when"` lint check to `write-a-skill` review checklist (already exists in checklist at line 45 but not enforced).
- L3-L4 are acceptable for complex skills; plan-it's `JIRA.md`, `FROM-ISSUES.md`, `REFERENCE.md` already split major concerns. The SKILL.md length comes from the integrated intake-evaluation grill flow — consolidation vs. extraction is an ongoing judgment call.

## Resolution

All findings closed:

| # | Status | Action |
|---|--------|--------|
| M1 | Fixed | `skills/engineering/README.md:49` updated |
| M2 | Fixed | `templates/AGENTS.md:13,29` relative links replaced |
| L1 | Fixed | Added "Use when" trigger to `internal-compliance/SKILL.md` |
| L2 | Fixed | Added "Use when" trigger to `handoff/SKILL.md` |
| L3 | Noted | 212 lines — acceptable; major concerns already split to JIRA.md, FROM-ISSUES.md, REFERENCE.md |
| L4 | Noted | 165 lines — acceptable; orchestration of multi-step interactive setup requires the length |
| L5 | Fixed | Added migration step to `/setup-internal-skills` that cleans up old `docs/agents/` files on re-run, updates AGENTS.md references |
