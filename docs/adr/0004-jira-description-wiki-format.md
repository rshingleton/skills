# ADR 0003: Jira descriptions must use wiki markup

## Status

Accepted

## Execution notes

- `_jira_create_epic` (line 256) and `_jira_create_task` (line 287) now pipe through `_jira_wiki_body`
- `_jira_update_description <key> <file>` helper added (line 336) for post-creation description fixes
- OPERATIONS.md updated with `update-description` reference block and inline DASH-4222 example

## Context

`_jira_create_task` and `_jira_create_epic` in `jira-helpers.sh` send raw markdown to Jira's `description` field. Jira expects wiki markup (e.g. `h2.`, `*`). The conversion function `_jira_wiki_body` exists but is never called.

## Decision

Pipe all description bodies through `_jira_wiki_body` before POST/PUT to Jira. Add a dedicated `_jira_update_description` helper for post-creation fixes.

## Consequences

- Descriptions render correctly in Jira UI
- Existing issues with garbage descriptions can be fixed via `_jira_update_description`
- The conversion is lossy (limited sed patterns) — complex markdown may need manual cleanup
