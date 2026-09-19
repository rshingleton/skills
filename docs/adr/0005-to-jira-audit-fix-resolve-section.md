# ADR 0004: Align resolve docs with comment flow

## Status

Accepted

## Execution notes

- `resolve` bash block in OPERATIONS.md now includes `_jira_comment "$1" "$2"` after `_jira_transition`
- Prose and code block agree on the two-step sequence

## Context

The `resolve` section in OPERATIONS.md describes a two-step flow (transition + optional comment) in prose but only shows the transition in the code block.

## Decision

Add the comment-posting call to the code block so the bash reference matches the described flow.

## Consequences

- Agents reading the docs see a complete, runnable example
- Single doc change, no behavioural impact
