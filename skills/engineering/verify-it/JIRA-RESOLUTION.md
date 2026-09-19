# Verify-it — Jira resolution

Called from the main workflow when any phase row in `jira.md` has a Jira key.

## Prerequisites

- Read `docs/agents/issue-tracker.md` for local conventions (create `docs/agents/` via `/setup-internal-skills` if missing)
- Source the connector bridge directly for all API calls -- do not curl Jira directly, and do not
  depend on the `/to-jira` skill being available:

  ```bash
  source scripts/jira-connector-bridge.sh
  jira_bridge_detect
  ```

## Scope

| Mode | Resolve |
|------|---------|
| **Full verify** | Every phase row with a key in `jira.md` |
| **Incremental close** | Only this phase's row (e.g. `phase-2` key) |

## Per-key loop

For each key to resolve:

1. If `JIRA_ASSIGNEE` is set: `jira_bridge_call assign <KEY> "$JIRA_ASSIGNEE"`.
2. **Prompt for resolution comment:** draft a concise Jira resolution comment from the phase summary (2-4 sentences covering what was delivered — deliverables only, no references to planning docs or audit reports). Present it to the user as a suggestion: *"Post this resolution comment to {KEY}? (y/edit/skip)"*. If they edit, use their text. If y: `jira_bridge_call comment <KEY> "<comment>"`.
3. **Resolve:** ask *"Resolve {KEY}? (y/n)"* per key. If yes: `jira_bridge_call transition <KEY> "Done"` (then post the comment from step 2, if provided).

## Edge cases

- **Jira API unavailable:** still update local docs (sources status `done`). Report unresolved keys and suggest manual resolution or re-run after sourcing credentials.
- **Missing keys:** if any target phase row lacks a Jira key, report it — run `/plan-it --jira {ID} --sync-only` before closing.
- **Sources:** on each `docs/planning/{ID}/sources/*.md`, set `status: done` and append that verify-it completed the Doc Cycle. These are discarded with the planning directory.
