# Changelog

## 2026-06-30 — Consolidate Jira API helpers

9 new shell functions in `jira-helpers.sh` consolidated ~500 lines of duplicated
curl examples across 6 files. All skills now call `_jira_*` functions instead of
reconstructing raw curl from prose. Interactive config prompt added to
`load-jira-env.sh` for first-time setup. `_jira_curl` is the single auth
dispatch point for bearer/basic switching.

## 2026-06-30 — `_jira_curl` method-first, dry-run, error handling

`_jira_curl` redesigned: method as first positional arg (`_jira_curl POST ...`),
`--dry-run` flag for safe preview, and HTTP error capture (non-2xx → stderr +
exit 1). All 14 internal callers migrated. Dry-run example in
`issue-tracker-jira.md`.
