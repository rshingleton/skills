# Audit: Jira pipeline fixes & handoff template fix

Generated: repo audit — ad-hoc changes in a single session.

## Scope

4 files changed, 41 insertions, 8 deletions across two concerns:

| Concern | Files | Δ |
|---------|-------|---|
| Jira auth infrastructure | `jira-helpers.sh`, `load-jira-env.sh`, `.env.example` | +40 −8 |
| Handoff temp-file template | `skills/productivity/handoff/SKILL.md` | +1 −1 |

---

## Process log

1. Identified that `jira-helpers.sh` hardcoded `-H "Authorization: Bearer $JIRA_API_TOKEN"` in every curl call (3 occurrences), and had no support for Basic auth.
2. Added `_jira_curl` wrapper — centralized auth injection, respects `JIRA_AUTH_TYPE=basic|bearer`.
3. Added `_jira_extract_project_key` and `_jira_ensure_project_key` — infer project key from any Jira key (DASH-2196 → DASH).
4. Updated the 3 internal curl calls to use `_jira_curl`.
5. Added `~/.config/env` to the env-search chain in `load-jira-env.sh`.
6. Fixed `handoff/SKILL.md` mktemp template from `-t handoff-XXXXXX.md` (produces literal XXXXXX on BSD mktemp) to `mktemp /tmp/handoff-XXXXXX` (portable, replaces trailing X's).
7. Synced the handoff fix to the installed copy at `~/.agents/skills/handoff/SKILL.md`.

## Findings

### Core value

- `_jira_curl` centralises auth header construction in one place instead of 3 curl calls. If auth changes again, it's one function, not a grep across files.
- `_jira_extract_project_key` + `_jira_ensure_project_key` remove the need to manually export `JIRA_PROJECT_KEY` when a known Jira key exists in context.
- `handoff` mktemp fix eliminates the bug where files were created with literal `XXXXXX` in the name.

### Accretion — none

All additions are minimal and directly address identified gaps. No dead code, no over-engineered abstractions.

### Concerns

1. **Installed `jira-helpers.sh` not synced** — `~/.agents/skills/setup-internal-skills/scripts/jira-helpers.sh` and `load-jira-env.sh` still have the old code without `_jira_curl`, `_jira_extract_project_key`, or `~/.config/env` support. Consumers sourcing from the installed path (most consumer repos) won't benefit until synced.

2. ~~**Reference docs still have hardcoded auth** — `OPERATIONS.md`, `issue-tracker-jira.md`, `from-jira/COMMANDS.md`, and `plan-it/JIRA.md` all contain curl examples with inline `-H "Authorization: Bearer $JIRA_API_TOKEN"`.~~ **Resolved in `0002-consolidate-jira-api-helpers`.** All doc examples now call `_jira_*` helpers. Zero raw Bearer curls remain outside `_jira_curl` itself.

### Simplification proposals

- ~~**Auto-infer in `resolve_jira_parent_epic`** — add `_jira_ensure_project_key "$k"` after each successful key resolution in `resolve_jira_parent_epic`.~~ **Resolved in `0002-consolidate-jira-api-helpers`** — each key branch now calls `_jira_ensure_project_key`.

- ~~**Ship `_jira_curl` reference** — add a one-liner in `issue-tracker-jira.md` or `OPERATIONS.md` saying "All Jira curl calls: use `_jira_curl` from helpers instead of raw curl + auth header".~~ **Resolved** — all doc examples now use `_jira_*` helpers. The helper function table in `issue-tracker-jira.md` lists all available functions.

### Deletion candidates — none

## Test verification

| Check | Result |
|-------|--------|
| `bash -n jira-helpers.sh` | SYNTAX OK |
| `bash -n load-jira-env.sh` | SYNTAX OK |
| Source jira-helpers.sh | SOURCED OK |
| `_jira_extract_project_key DASH-2196` | `DASH` |
| `_jira_extract_project_key MT-123` | `MT` |
| `_jira_extract_project_key ""` | `` |
| `_jira_extract_project_key NOHASH` | `` |
| `_jira_ensure_project_key DASH-3373` | sets `JIRA_PROJECT_KEY=DASH` |
| `_jira_ensure_project_key` when already set | idempotent — no override |
| `_jira_curl` with `JIRA_AUTH_TYPE=basic` | uses `-u ":$JIRA_API_TOKEN"` |
| `_jira_curl` with default bearer | uses `-H "Authorization: Bearer $JIRA_API_TOKEN"` |

## Verdict

**PASS** — no blocking findings. Contains one notable gap (installed helpers not synced) and minor suggestions.

**Next:** Sync installed copy at `~/.agents/skills/` via `/setup-internal-skills` or `scripts/link-skills.sh`, then `/commit-it` to stage and commit.
