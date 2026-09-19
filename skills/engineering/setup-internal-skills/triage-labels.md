# Triage Labels

Issue state machine used by `/issue-it` and `/plan-it --from-issues`.

**Vocabulary:** **Capture** = `/issue-it`. **Intake evaluation** = `/plan-it` evaluates item readiness. **Grill** = `/plan-it` planning session.

## State machine (local inbox)

```
intake → ready-for-plan → (plan-it moves to planning/<id>/sources/, status: in-plan)
                     ↘ wontfix
```

After move: `in-plan` → `done` (set by `/verify-it`).

## Canonical states

| State | Local `status:` | Jira label | Meaning |
|-------|----------------|------------|---------|
| `intake` | `intake` | `intake` | Captured but not yet evaluated |
| `ready-for-plan` | `ready-for-plan` | `ready-for-plan` | Evaluated, ready for `/plan-it` grill + scaffold |
| `wontfix` | `wontfix` | `wontfix` | Will not be actioned |

**Intake evaluation** happens during `/plan-it --from-issues`: read context, probe if unclear, recommend `ready-for-plan` or `wontfix`. When more info is needed, set `status: intake` and document questions in `## Comments`.

## Jira state mapping

When using Jira as the tracker, intake evaluation maps states to Jira status + labels via [issue-tracker-jira.md](issue-tracker-jira.md#triage-state-mapping).
