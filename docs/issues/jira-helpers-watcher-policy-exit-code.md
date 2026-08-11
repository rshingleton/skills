---
title: "_jira_apply_watcher_policy update mode always returns exit 1, masking real success/failure"
type: bug
status: ready-for-plan
source: user
---

## Context

Found during a live smoke test of the Jira bridge's bash-fallback path against the real OSS Jira
project (see `docs/issues/jira-bridge-live-smoke-test.md`). Traced with `bash -x` against a real
`_jira_transition` call on OSS-321.

`_jira_apply_watcher_policy` in `skills/engineering/setup-internal-skills/scripts/jira-helpers.sh`:

```bash
_jira_apply_watcher_policy() {
  local key="$1" mode="${2:-create}"
  _jira_remove_ignored_watchers "$key"
  [ "$mode" = "create" ] && _jira_add_watchers "$key"
}
```

## Problem / request

When `mode` is `"update"` (the case for every transition, comment, and description update --
see `_jira_transition`, `_jira_update_description`, and other write helpers, all of which pass
`update`), the condition `[ "$mode" = "create" ]` is false, so `&& _jira_add_watchers "$key"`
never runs and the **false condition itself** becomes this function's exit status: 1.

Since `_jira_apply_watcher_policy` is the last statement in `_jira_transition` (and several other
write helpers), its exit code becomes the caller's exit code. Confirmed live: transitioning
OSS-321 to "In Progress" returned HTTP 204 (success) from the real Jira API, the status changed
correctly, but `_jira_transition`'s exit code was `1` -- indistinguishable from an actual failure
to any caller checking `$?`.

This means `/implement-it`, `/verify-it`, and anything else that checks the bridge/helper's exit
code cannot trust it for `update`-mode writes -- a real failure and a real success look identical
downstream.

## Acceptance (for planning)

- `_jira_apply_watcher_policy` returns 0 on the "nothing to do" path (mode != create, no watchers
  to remove) instead of falling through to a false condition's exit code
- Re-run the same live transition test against a throwaway OSS issue and confirm `$?` is 0 after
  a successful transition
- Audit other callers of `_jira_apply_watcher_policy` in "update" mode
  (`_jira_update_description`, label-update helper, `_jira_comment` if applicable) for the same
  false-failure pattern

## Notes

- File: `skills/engineering/setup-internal-skills/scripts/jira-helpers.sh`
- Minimal fix is likely just adding an explicit `return 0` after the conditional, or restructuring
  as an `if/fi` rather than relying on `&&`'s exit code as the function's return value.
- Out of scope for the jira-bridge-simplify refactor (ADR-0007/0008) -- that plan deliberately left
  `jira-helpers.sh` untouched. This is a pre-existing bug in code that plan didn't modify, only
  newly discovered by testing against real data instead of mocks.
- Related: `docs/issues/jira-bridge-transition-echo-wrong-shape.md` (separate bug found in the
  same smoke test)
