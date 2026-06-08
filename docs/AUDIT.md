# Repo Audit — post-session verification

**Date:** 2026-06-08
**Scope:** Session changes: commit-it push policy, implement-it compliance-rules +
Jira assign, skill partitions (to-jira, from-jira, verify-it),
.compliance-rules/coding-standards*.

## Process

1. `git diff HEAD` and `git status` — verify all changes are in-repo only
2. `~/.local/share/ai-skills` and `~/.agents/skills/` checked for stale diffs
3. All new sub-files checked: references, line counts, structural consistency
4. Cross-referenced against write-a-skill review checklist
5. Cross-referenced against `internal-compliance`, `audit-it/PHASE-AUDIT.md`, `.compliance-rules/`

## Findings

### H1 — Split brain: agent install vs repo **RESOLVED**

All changes confirmed in-repo only (`git diff HEAD` shows everything). The stale
diff in `~/.local/share/ai-skills` is from early symlink edits — those same
edits were re-applied to prod/skills. Sub-files (OPERATIONS.md, COMMANDS.md,
etc.) exist only in prod/skills.

**Post-commit:** run `bash scripts/skills.sh` to re-sync the install, overwriting the stale files.

### M2 — Skill partitions: 3 skills split into sub-files

| Skill | Before | After | Sub-files |
|-------|--------|-------|-----------|
| `to-jira` | 257 lines | 131 lines | `OPERATIONS.md` (126 lines) |
| `from-jira` | 136 lines | 77 lines | `COMMANDS.md` (30) + `REFERENCE.md` (39) |
| `verify-it` | 151 lines | 120 lines | `JIRA-RESOLUTION.md` (29) + `RETRO-CLEANUP.md` (13) |

All sub-files are one-level deep references. SKILL.md files hold core orchestration only.

### M3 — implement-it Jira assign logic updated

Before: unconditional `Assign` → `Transition "In Progress"` → `Watcher policy`
After: conditional assign (`JIRA_ASSIGNEE` set + no existing assignee) → `Transition` → `Watcher policy`

Consistent with verify-it's JIRA-RESOLUTION.md pattern.

### L1 — grill-me is minimal (10 lines)

At 10 lines this is the thinnest skill. Intentional for a productivity pattern skill.

### L2 — to-jira still over 100 lines (131)

The orchestration logic (create flow, delegation tables) remains in SKILL.md and
can't be cleanly extracted. The bash-heavy content was the right extraction target.

### L3 — verify-it still over 100 lines (120)

Same pattern — core workflow for 3 distinct modes remains in SKILL.md. The two
sub-flows (Jira resolution, retro cleanup) were extracted.

## Accretion

+7 new files (3 coding-standards, 5 partition sub-files), —275 lines net from
the 3 partitioned skills. Good compression ratio.

## Simplification proposals

None. All changes are structural improvements.

## Deletion candidates

None.

## Next

> Audit PASS. Ready for verify and commit.
>
> **Post-commit:** run `bash scripts/skills.sh` to sync the install.
