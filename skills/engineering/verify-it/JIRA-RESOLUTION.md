# Verify-it — Jira resolution

Called from the main workflow when any phase row in `jira.md` has a Jira key.

## Prerequisites

- Read `docs/agents/issue-tracker.md` for local conventions (create `docs/agents/` via `/setup-internal-skills` if missing)
- Delegate all API calls to [`to-jira`](../to-jira/SKILL.md) — do not source credentials or curl Jira directly

## Scope

| Mode | Resolve |
|------|---------|
| **Full verify** | Every phase row with a key in `jira.md` |
| **Incremental close** | Only this phase's row (e.g. `phase-2` key) |

## Per-key loop

For each key to resolve:

1. If `JIRA_ASSIGNEE` is set: `/to-jira assign <KEY>` (does not apply watcher policy).
2. **Prompt for resolution comment:** draft a concise Jira resolution comment from the phase summary (2-4 sentences covering what was delivered — deliverables only, no references to planning docs or audit reports). Present it to the user as a suggestion: *"Post this resolution comment to {KEY}? (y/edit/skip)"*. If they edit, use their text. If y: `/to-jira comment <KEY> "<comment>"`.
3. **Resolve:** ask *"Resolve {KEY}? (y/n)"* per key. If yes: `/to-jira resolve <KEY> "Done"` (transitions + applies watcher policy).

## Edge cases

- **Jira API unavailable:** still update local docs (sources status `done`). Report unresolved keys and suggest manual resolution or re-run after sourcing credentials.
- **Missing keys:** if any target phase row lacks a Jira key, report it — run `/plan-it --jira {ID} --sync-only` before closing.
- **Sources:** on each `docs/planning/{ID}/sources/*.md`, set `status: done` and append that verify-it completed the Doc Cycle. These are discarded with the planning directory.
