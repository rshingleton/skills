# ADR-0007: Jira Connector Bridge — Unified Connector & Bash Helper Routing

Status: Accepted
Date: 2026-07-29
Author: Russell Shingleton
Execution Notes:
- Superseded in part by ADR-0008 (jira-bridge-simplify): to-jira.sh removed entirely rather than
  kept as a wrapper; COMMANDS.md deleted and merged into to-jira/OPERATIONS.md rather than kept
  as a separate bridge-usage doc
- Test coverage added: scripts/jira-connector-bridge.test.sh (36 assertions across detection,
  connector path, bash path, credential fallback, and error handling)
- "Future Work" below is resolved: implement-it and verify-it now source the bridge directly
  instead of delegating through the /to-jira skill (see ADR-0008 for the full delegation
  rework); test coverage for detection/routing exists; connector adoption is documented in
  to-jira/SKILL.md rather than left as an open monitoring item

## Problem Statement

To-jira and from-jira skills did not detect or invoke the Jira MCP connector despite documentation claiming it would be used automatically. Skills lacked the detection logic and conditional routing needed to prefer the connector when available and fall back to curl/bash helpers when unavailable.

Additionally, skills run in execution contexts that may not have direct access to invoke MCP tools. A bridge mechanism was needed to route Jira operations transparently.

## Solution

Implement jira-connector-bridge.sh as a unified routing layer that detects connector availability and dispatches all Jira operations to either the connector or bash helpers, providing a single interface for all skills to use.

The bridge detects connector availability by checking if Jira MCP tools are available in the execution context. If available, it outputs the tool invocation for the agent to execute. If unavailable, it invokes bash helpers directly.

## Rationale

A centralized routing layer eliminates code duplication across skills and provides consistent behavior. By detecting availability at runtime, skills automatically benefit from the connector when set up without requiring manual configuration changes.

The bridge echoes tool invocations rather than executing them directly because skills run in sandboxed contexts. The agent context has direct MCP tool access and can read the echoed invocation and execute it.

## Changes Implemented

scripts/jira-connector-bridge.sh: New file providing jira_bridge_detect() and jira_bridge_call() functions

skills/engineering/to-jira/SKILL.md: Phase 3 updated to source bridge and use jira_bridge_call instead of directly invoking bash helpers

skills/engineering/to-jira/OPERATIONS.md: Added section recommending bridge usage for agent instructions

skills/engineering/from-jira/SKILL.md: Updated to reference bridge detection and routing

skills/engineering/from-jira/COMMANDS.md: Updated with bridge usage examples for both connector and bash paths

skills/engineering/plan-it/JIRA.md: Publish flow updated to use bridge for create-epic and create-task operations

## Usage for Agents

### In a skill SKILL.md or referenced docs:

```bash
# Source bridge once
source scripts/jira-connector-bridge.sh

# Detect connector (sets USE_CONNECTOR global)
jira_bridge_detect

# Use unified interface for any operation
jira_bridge_call create-epic "$JIRA_PROJECT_KEY" "Epic Title" "Description"
jira_bridge_call fetch-issue "$JIRA_KEY" "summary,description"
jira_bridge_call transition "$JIRA_KEY" "In Progress"
jira_bridge_call comment "$JIRA_KEY" "Fixed in commit abc123"
```

### Connector path result:

If MCP connector is available, `jira_bridge_call` **echoes**:
```
CONNECTOR: mcp__jira__jira_create_epic --project_key "DASH" --summary "..." ...
```

The agent reads this echo and executes the tool in its own context.

### Bash path result:

If MCP connector is unavailable, `jira_bridge_call` **invokes directly**:
```
EPIC_KEY=$(_jira_create_epic "$JIRA_PROJECT_KEY" "Epic Title" "" "Description")
```

Returns the result (e.g., issue key) for the skill to capture.

## Benefits

Single unified interface for all Jira operations. Skills automatically use the connector when available without configuration changes. Bash helpers remain as fallback. Bridge logic centralized in one file, avoiding duplication across skills. 

## Consequences

Connector path echoes tool invocations for the agent to execute rather than executing directly, as skill execution contexts may be sandboxed. Error visibility occurs at agent execution time when echoed calls fail. Bridge adds a routing layer to all Jira operations.

## Alternatives Considered

Hardcode connector calls in each skill: Would require duplicating detection and routing logic across all skills using Jira, increasing maintenance burden.

Use a wrapper agent to invoke MCP tools: Would add complexity and communication overhead between contexts.

Upgrade skill execution contexts to allow direct MCP tool access: Out of scope; would require changes to Claude Code execution model.

## Implementation

Bridge detection checks if JIRA_MCP_CONNECTOR_AVAILABLE environment variable is set, or if running in a Claude Code context (indicated by presence of claude binary and ~/.claude directory). When connector is available, jira_bridge_call echoes the MCP tool invocation. When unavailable, it sources Jira credentials and invokes bash helpers directly.

Credential sourcing attempts both global installation path (~/.agents/skills/) and local repository path (skills/engineering/) to support both installed and development contexts.

## Future Work

Integrate bridge usage into implement-it and verify-it skills when they delegate Jira operations. Add test coverage for detection and routing logic. Monitor connector adoption to verify that skills prefer it when available.
