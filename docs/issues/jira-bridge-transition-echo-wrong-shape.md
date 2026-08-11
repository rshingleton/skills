---
title: Connector-path transition echo assumes the wrong JSON shape
type: bug
status: ready-for-plan
source: user
---

## Context

Found during a live smoke test of `scripts/jira-connector-bridge.sh` against the real OSS Jira
project via the Jira MCP connector (see `docs/issues/jira-bridge-live-smoke-test.md`).

`jira_bridge_transition()` in `scripts/jira-connector-bridge.sh` echoes this pipeline for the
connector path:

```
mcp__jira__jira_get_transitions --issue_key '<KEY>' \
  | jq -r '.transitions[] | select(.name == "<STATUS>") | .id' \
  | head -1 \
  | xargs -I {} mcp__jira__jira_transition_issue --issue_key '<KEY>' --transition_id '{}'
```

## Problem / request

The `jq` filter `.transitions[]` assumes `jira_get_transitions` returns `{"transitions": [...]}`.
Live testing against OSS-319 showed the MCP tool actually returns a **bare array**:
`[{"id": 11, "name": "Open"}, {"id": 21, "name": "In Progress"}, ...]` -- no top-level
`"transitions"` key. Run literally, `.transitions[]` matches nothing, `tid` comes back empty, and
the transition silently never happens.

(Separately, the same filter also selects on `.name` rather than `.to.name` -- the real REST API
distinguishes transition name from destination-status name; they were identical in this test but
won't always be.)

This was worked around live by having the agent read `jira_get_transitions`'s actual output and
call `jira_transition_issue` directly with the correct id, bypassing the broken echoed pipeline.
The bug is in what gets echoed, not in the underlying MCP tools.

## Acceptance (for planning)

- `jira_bridge_transition`'s connector-path echo matches the real `jira_get_transitions` MCP
  response shape (bare array, confirmed via live call)
- Filters on `.name` (the transition's own name) unless `.to.name` (destination status) is
  confirmed to be the more correct match for how `/implement-it` and `/verify-it` call this
  (they pass status names like `"In Progress"`, `"Done"`)
- Re-verified live against a real Jira issue, not just the mocked test suite (which stubs its own
  `curl`/response shape and would not have caught this)

## Notes

- File: `scripts/jira-connector-bridge.sh`, `jira_bridge_transition()`
- The bash-fallback path (`_jira_transition` in `jira-helpers.sh`) uses the real REST API shape
  (`{"transitions": [...]}`) and filters on `.to.name` correctly -- confirmed working live. Only
  the connector-path echo string in the bridge script is wrong.
- Related: `docs/issues/jira-helpers-watcher-policy-exit-code.md` (separate bug found in the same
  smoke test)
