# Changelog

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
