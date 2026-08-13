# Changelog

## 2026-08-11 -- Jira Bridge Fixes: transition echo shape and watcher-policy exit code

- **Bug fix:** `jira_bridge_transition()`'s connector-path echo assumed
  `jira_get_transitions` returned `{"transitions": [...]}` and filtered on the wrong field. Live
  testing showed the real MCP tool returns a bare array of flat `{"id", "name"}` objects with no
  nested `.to` -- fixed the echo to match, filtering on `.name` (already the destination status
  name in this shape).
- **Bug fix:** `_jira_apply_watcher_policy` in `jira-helpers.sh` returned the exit status of a
  false `&&` condition on every update-mode call (transition, comment, description update),
  masking real HTTP successes as shell failures. Restructured as an explicit `if`/`fi` with a
  trailing `return 0`.
- **Tests:** `scripts/jira-connector-bridge.test.sh` grew 2 assertions (38 total) covering the
  corrected filter and the removed `.transitions[]` assumption; added a reusable
  `_assert_not_contains` helper.
- **Live re-verification:** both fixes confirmed against real throwaway issues in the OSS
  project (created, exercised, deleted) rather than just the mocked test suite.
- **Docs:** Added a "Live smoke test (re-running)" section to `docs/JIRA-OPERATIONS-EXAMPLES.md`.
- **Follow-up filed, not fixed here:** all six `jira-helpers.sh` write functions still mask real
  API failures as success because watcher policy is their unconditional last statement -- see
  `docs/issues/jira-helpers-write-exit-code-masked-by-watcher-policy.md`.
- See ADR-0009 for full rationale.

## 2026-08-10 -- Jira Bridge Simplify: connector-first cleanup

- **Docs:** Consolidated `to-jira/OPERATIONS.md` and `from-jira/COMMANDS.md` into one 171-line
  bridge-first reference; `COMMANDS.md` deleted.
- **Tests:** Added `scripts/jira-connector-bridge.test.sh` (36 assertions) covering connector
  detection, both the connector-echo and bash-fallback paths, credential-sourcing failure, and
  error handling for the bridge script.
- **Routing:** Removed `skills/engineering/to-jira/to-jira.sh` -- a thin, uncalled wrapper around
  the bridge. Documented the bridge's echo-pattern design decision in its own header and in
  `to-jira/SKILL.md`. Added `docs/JIRA-OPERATIONS-EXAMPLES.md`.
- **Skill coupling:** `implement-it` and `verify-it` now source `jira-connector-bridge.sh`
  directly instead of delegating Jira operations through the `/to-jira` skill. `plan-it` and
  `from-jira` were already doing so. `to-jira` itself is kept as the ad-hoc entry point and
  bridge reference, not removed.
- **Watcher policy:** Removed from the connector-first interface (bridge dispatch, `to-jira`, and
  every skill that used to delegate to it) rather than kept as a documented bash-only limitation.
  Note the bash-helper implementation (`jira-helpers.sh`) still applies it automatically as a
  pre-existing side effect of writes -- that file was out of this refactor's scope.
- See ADR-0007 and ADR-0008 for full rationale.
