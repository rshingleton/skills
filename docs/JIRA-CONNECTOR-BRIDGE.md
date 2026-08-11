Jira Connector Bridge Implementation Guide

This document describes the connector bridge mechanism that routes Jira operations to the Jira MCP connector when available, or to bash helpers when unavailable.

Supported Operations

The bridge supports these operations via jira_bridge_call:

create-epic: jira_bridge_call create-epic <project_key> <summary> [description]
create-task: jira_bridge_call create-task <project_key> <summary> <body_file> <epic_key> <est_hours> [assignee]
fetch-issue: jira_bridge_call fetch-issue <issue_key> [fields]
fetch-comments: jira_bridge_call fetch-comments <issue_key>
transition: jira_bridge_call transition <issue_key> <status>
comment: jira_bridge_call comment <issue_key> <body>
assign: jira_bridge_call assign <issue_key> [assignee]
get-transitions: jira_bridge_call get-transitions <issue_key>

Basic Usage

To use the bridge in any skill:

source scripts/jira-connector-bridge.sh
jira_bridge_detect

jira_bridge_call create-epic "DASH" "Epic Title" "Description"

The bridge detects connector availability automatically. If the connector is available, it outputs the MCP tool invocation. If unavailable, it invokes bash helpers.

Error Handling

If a connector path operation fails, check that the Jira MCP connector is authenticated. Run: claude /mcp

If a bash path operation fails, ensure credentials are set: JIRA_BASE_URL, JIRA_API_TOKEN, JIRA_PROJECT_KEY

The bridge searches for credentials in both global installation paths and local repository paths.

Integration with Skills

Skills using the bridge no longer need separate connector and bash code paths. The bridge provides a single interface that automatically adapts to the available Jira access method.

Skills updated to use the bridge:
- plan-it/JIRA.md: publish flow
- to-jira/SKILL.md: phase 3 operations
- from-jira/COMMANDS.md: issue fetching
- to-jira/OPERATIONS.md: operation dispatch

Architecture

The bridge works by detecting the execution context and routing operations appropriately. When the connector is available, the bridge outputs the MCP tool invocation as a line prefixed with CONNECTOR:. The agent reads this line and executes the tool. When the connector is unavailable, the bridge directly invokes bash helpers.

For details on the design and rationale, see docs/adr/0007-jira-connector-bridge.md
