# Repo Audit: to-jira centralization — verification pass

**Date:** 2026-05-22
**Scope:** Verify fixes from prior audit (commit range covering to-jira centralization + immediate follow-up fixes)

## Process

1. All prior findings re-checked against current working tree
2. Credential sourcing duplication counted across shipped skills
3. CONTEXT.md, README.md, bucket READMEs checked for stale references
4. Cross-skill delegation patterns re-verified

## Findings from previous audit

| # | Status | Resolution |
|---|--------|-----------|
| M1 | **Deferred** | `from-jira` still has independent credential sourcing — justified (read-only, inverse direction). Not worth the abstraction layer. |
| M2 | **FIXED** | `CONTEXT.md:35` — added `to-jira` as central Jira handler to the Relationships list |
| M3 | **FIXED** | `to-jira/SKILL.md` — credential sourcing block moved to top (one canonical copy), 7 operation blocks changed from `source ...` to `# (credentials)` reference |
| L1 | Noted | Deprecated skills still present — non-blocking, harmless |
| L2 | **FIXED** | `from-jira/SKILL.md` — added read-direction note with cross-reference to `to-jira` |
| L3 | **FIXED** | `plan-it/JIRA.md` — clarified step 1 credentials are for plan-it's own local ops |
| L4 | **FIXED** | `jira-helpers.sh` — removed unused `_remove_jira_watcher` alias |

## New findings

None. All prior findings resolved (M1 deferred as intentional). The delegation boundary is clean — only `to-jira` and `from-jira` touch Jira API.

## Core value

The centralization is structurally sound. The `# (credentials)` shorthand keeps bash blocks copy-pasteable while eliminating the duplication maintenance hazard. CONTEXT.md now documents the boundary for new readers.

## Accretion

None introduced. The overall diff is +296/−213 lines — net negative after the fix pass, which is the right direction.

## Next

No remaining findings. Ready for `/commit-it` if desired.
