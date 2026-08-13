---
title: "jira-helpers.sh write functions discard their own curl exit status because watcher policy runs last"
type: bug
status: ready-for-plan
source: implement-it
---

## Context

Found while implementing `docs/planning/jira-bridge-fixes/phase-2/ai-prompt.md` (fixing
`_jira_apply_watcher_policy`'s update-mode exit code, see
`docs/planning/jira-bridge-fixes/sources/jira-helpers-watcher-policy-exit-code.md`).

That phase fixed `_jira_apply_watcher_policy` to always `return 0` instead of leaking a false
`&&` condition's exit status on update-mode calls. This closes the specific bug that was found
live (a successful transition reporting `$?=1`). But auditing the six callers in
`skills/engineering/setup-internal-skills/scripts/jira-helpers.sh`
(`_jira_transition`, `_jira_create_epic`, `_jira_create_task`, `_jira_update_issue`,
`_jira_update_description`, `_jira_set_labels`) surfaced a broader, pre-existing issue.

## Problem / request

In every one of those six functions, `_jira_apply_watcher_policy` is the last statement, so its
return value becomes the caller's return value -- regardless of whether the actual `_jira_curl`
write (the POST/PUT that performs the real Jira mutation) succeeded or failed. `_jira_curl` does
return 1 on a non-2xx HTTP response, but that exit status is discarded because it isn't the last
command in the function.

This means a genuine API failure (e.g. a 400 or 500 from a bad transition ID, or a permissions
error on an update) is silently reported as success (`$?=0`) to any caller checking the exit
code, since watcher policy always returns 0. This is the same class of bug as the one just
fixed, but inverted -- false success instead of false failure -- and it predates this phase: the
"create" mode path already had this masking before phase 2, since `_jira_add_watchers` swallows
its own curl errors with `|| true` and returns 0 regardless.

## Acceptance (for planning)

- Each of the six write functions captures its own `_jira_curl` exit status and returns that,
  running watcher policy as a best-effort side effect that does not override it
- A forced-failure test (e.g. stubbed `curl` returning a 4xx) confirms the caller's exit code is
  non-zero even though watcher policy still runs and returns 0

## Notes

- File: `skills/engineering/setup-internal-skills/scripts/jira-helpers.sh`
- Deliberately out of scope for `docs/planning/jira-bridge-fixes/phase-2` -- that phase's mandate
  was fixing the shared function once, not restructuring every caller's control flow. Flagged per
  that phase's own instruction not to silently expand scope.
- Likely minimal fix per caller: capture `_jira_curl`'s status into a local var before calling
  `_jira_apply_watcher_policy`, then `return` that captured status at the end.
