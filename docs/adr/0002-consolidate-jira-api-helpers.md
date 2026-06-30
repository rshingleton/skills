# Consolidate Jira API helpers into callable shell functions

## Status

Accepted

## Context

Jira API calls were duplicated as raw `curl` examples across 5+ files (`OPERATIONS.md`, `issue-tracker-jira.md`, `from-jira/COMMANDS.md`, `jira-epic-sync.md`, `plan-it/JIRA.md`). Every skill (plan-it, implement-it, verify-it, to-jira, from-jira) needed these operations but reconstructed the curl each time from prose instructions.

This meant:
- Switching auth type (bearer ↔ basic) required patching every doc page
- Common operations (transition, comment, create-task) had subtly different curl in each file
- Skills could not delegate actual function calls — only hand-copied prose

## Decision

Add 9 new callable shell functions to `jira-helpers.sh` that consolidate all Jira API operations behind the existing `_jira_curl` auth dispatch. All doc examples now reference these functions instead of raw curl.

### New functions

Write operations:
- `_jira_comment` — POST comment
- `_jira_transition` — GET transitions → POST status change → watcher policy
- `_jira_create_epic` — POST Epic with optional Epic Name field
- `_jira_create_task` — POST Task with optional Epic Link, timetracking, assignee
- `_jira_update_issue` — PUT partial field update
- `_jira_set_labels` — append labels

Read operations:
- `_jira_fetch_issue` — GET issue by key
- `_jira_fetch_comments` — GET comments
- `_jira_search` — GET JQL search

Validation:
- `_jira_require_env` — check `JIRA_BASE_URL` + `JIRA_API_TOKEN` are set

### Interactive config prompt

`load-jira-env.sh` now detects missing credentials and interactively prompts for `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` when sourced in a TTY. Supports `JIRA_ENV_SILENT=1` in scripted contexts.

## Consequences

- Switching auth type (bearer ↔ basic) is a one-line change in `_jira_curl`
- Raw `curl -H "Authorization: Bearer"` eliminated from all operational docs (single dispatch in `_jira_curl` remains)
- `issue-tracker-jira.md` reduced from 429 to 301 lines
- Skills can now source once and call functions, not reconstruct curl
- Existing legacy (the Jira integration code) — the old approach was prose-and-copy; the new approach is function-and-call
