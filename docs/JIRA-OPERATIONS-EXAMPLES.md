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
