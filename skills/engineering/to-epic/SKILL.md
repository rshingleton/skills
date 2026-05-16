---
name: to-epic
description: >
  Turn conversation context into an Epic (docs/issues/<slug>/epic.md locally or
  Jira Epic), per docs/agents/issue-tracker.md. Use for epic, to-epic, feature
  spec. Run promote-to-jira to push a local Epic to Jira later.
---

Synthesize a full Epic from conversation context. Do NOT interview the user.

**Read `docs/agents/issue-tracker.md` first** — local (default) vs Jira. Run `/setup-internal-skills` if missing.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Use the project's domain glossary vocabulary throughout the Epic, and respect any ADRs in the area you're touching.

2. Sketch out the major modules you will need to build or modify to complete the implementation. Actively look for opportunities to extract deep modules that can be tested in isolation.

A deep module (as opposed to a shallow module) is one which encapsulates a lot of functionality in a simple, testable interface which rarely changes.

Check with the user that these modules match their expectations. Check with the user which modules they want tests written for.

3. Write the Epic using the template below, then publish per tracker.

### Local (default)

Create `docs/issues/<feature-slug>/epic.md`:

```yaml
---
title: <feature name>
type: epic
status: needs-triage
jira_key:
planning_id:
---
```

Body = epic template sections below.

Tell the user:

> Epic saved to `docs/issues/<feature-slug>/epic.md`.
>
> **Next:** `/to-jiras` to break into local tasks, `/plan-it` for a phased plan, or `/promote-to-jira <feature-slug>` when ready for Jira.

### Jira

POST Epic (`issuetype: "Epic"`, `customfield_10881` for Epic Name) — see [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md).

Tell the user the Epic key and suggest: *"Run /to-jiras --parent $EPIC_KEY to break this into Tasks."*

<epic-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Do NOT include specific file paths or code snippets. They may end up being outdated very quickly.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts — not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

## Out of Scope

A description of the things that are out of scope for this Epic.

## Further Notes

Any further notes about the feature.

</epic-template>
