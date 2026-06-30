# Changelog

## 2026-06-30 — Consolidate Jira API helpers

9 new shell functions in `jira-helpers.sh` consolidated ~500 lines of duplicated
curl examples across 6 files. All skills now call `_jira_*` functions instead of
reconstructing raw curl from prose. Interactive config prompt added to
`load-jira-env.sh` for first-time setup. `_jira_curl` is the single auth
dispatch point for bearer/basic switching.
