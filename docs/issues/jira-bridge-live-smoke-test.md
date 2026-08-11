---
title: Live smoke test for Jira connector bridge against a real OSS project
type: todo
status: ready-for-plan
source: verify-it
---

**Executed 2026-08-10** against real OSS-318..321 (created, exercised, then deleted). Both
connector and bash-fallback paths ran create-epic/create-task/transition/assign/comment
successfully end-to-end, each confirmed by reading the issue back afterward. Surfaced two real
bugs, filed separately: `docs/issues/jira-bridge-transition-echo-wrong-shape.md` and
`docs/issues/jira-helpers-watcher-policy-exit-code.md`. The third acceptance item below
("document how to re-run") is not yet done.

## Context

Surfaced while reconciling `docs/issues/jira-connector-bridge.md` and `docs/issues/issue-tracker-connectors-oss.md`
against the completed jira-bridge-simplify refactor (see ADR-0007, ADR-0008). Both intake items
listed a "tested against a real OSS project" acceptance criterion that the automated test suite
doesn't cover.

`scripts/jira-connector-bridge.test.sh` (36 assertions) validates detection, argument
construction, and routing logic against a stubbed `curl` and canned MCP-tool-call strings -- it
never exercises a real connector call or a real bash-path API request.

## Problem / request

No test has actually run `jira_bridge_call create-epic`, `create-task`, `transition`, `assign`,
or `comment` against a live Jira MCP connector or a live bash/curl path pointed at a real
project (e.g. OSS). The bridge's argument construction and the connector's actual API behavior
have never been verified together.

## Acceptance (for planning)

- Create-epic, create-task, transition, assign, and comment each run once against a real Jira
  project via the connector path, with the resulting issue/transition/comment manually confirmed
  in Jira
- The same five operations run once against the bash fallback path (connector unavailable),
  confirming the curl requests succeed against the real API
- Document how to re-run this smoke test (env vars needed, project to use, cleanup steps for
  created issues)

## Notes

Not blocking -- the bridge has been in use via the connector path already per ADR-0007's original
acceptance criteria. This is closing the gap between "unit-tested with mocks" and "verified
against the real API," which matters most for the bash fallback path since that's the
less-exercised of the two.
