# Jira operations -- usage examples

Three ways to call a Jira operation from a skill, in order of preference. See
[to-jira/OPERATIONS.md](../skills/engineering/to-jira/OPERATIONS.md) for the full operation
reference and [jira-connector-bridge.sh](../scripts/jira-connector-bridge.sh) for the echo
pattern this relies on.

## Via the bridge (recommended)

```bash
source scripts/jira-connector-bridge.sh
jira_bridge_detect

jira_bridge_call create-epic "OSS" "My Epic" "Description"
jira_bridge_call transition "KEY-123" "In Progress"
```

When the connector is available, `jira_bridge_call` prints a `CONNECTOR: ...` line for the agent
to execute. When it isn't, it invokes the bash helper directly and returns real data. Callers
don't need to know which happened.

## Via direct MCP tools (advanced)

Skip the bridge when you already know the connector is available and want the tool call
without the echo indirection:

```bash
mcp__jira__jira_create_issue \
  --project_key "OSS" \
  --summary "My Task" \
  --issue_type "Task" \
  --description "Task description"
```

## Via bash helpers (OSS/offline)

Skip the bridge when the connector is confirmed unavailable (e.g. no MCP access at all):

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
_jira_create_epic "$JIRA_PROJECT_KEY" "My Epic" "" "Description"
```

## Live smoke test (re-running)

`scripts/jira-connector-bridge.test.sh` validates argument construction and routing against a
stubbed `curl` -- it can't catch real API response-shape mismatches (the connector-path
transition bug ADR-0009 fixed was invisible to it). Re-run a live smoke test after any change to
the connector-path echo strings or the bash-fallback helpers.

**Env needed:**

- Connector path: the Jira MCP connector tools (`mcp__jira__*`) available in
  the current session.
- Bash path: `JIRA_BASE_URL` and `JIRA_API_TOKEN` (or `JIRA_AUTH_TYPE=basic` credentials), sourced
  via `~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh`.

**Project:** use a real but low-stakes project (this repo's smoke tests used `OSS`). Never use a
project other teams actively depend on for reporting.

**Steps (targeted -- one operation at a time, not the full matrix unless something regressed
broadly):**

1. Create one throwaway issue (`jira_create_issue` / `jira_bridge_call create-task`).
2. Exercise the operation under test via the bridge or MCP tool directly.
3. Read the issue back (`jira_get_issue`) to confirm the real state changed, not just that the
   call returned without error.
4. For bash-path checks, also confirm `$?` is `0` after a real success -- exit code and API
   result can diverge if a helper's last statement isn't the actual write (see the
   `_jira_apply_watcher_policy` bug ADR-0009 fixed).
5. **Delete the throwaway issue(s)** (`jira_delete_issue`) when done. No created issue should
   outlive the smoke test.

**Full matrix** (create-epic, create-task, transition, assign, comment x connector + bash paths)
is documented as already run once; see ADR-0007's acceptance criteria. Re-run the full matrix
only after a change that could plausibly affect every operation (e.g. a shared helper like
`_jira_curl` or `jira_bridge_detect`), not for a single-operation fix.
