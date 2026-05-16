# Triage Labels

Five **canonical roles** used by `/triage`. Map them to your tracker in the columns below.

**Vocabulary:** use **triage** (verb) for `/triage` work — not "groom". **Capture** = `/issues-it`. **Grill** = `/plan-it` planning session only.

| Canonical role | Local inbox `status:` | Jira label | Meaning |
|----------------|----------------------|------------|---------|
| `needs-triage` | `intake` | `needs-triage` | Maintainer needs to evaluate |
| `needs-info` | `triaged` | `needs-info` | Waiting on reporter (document questions in `## Comments` locally) |
| `ready-for-agent` | `ready-for-plan` | `ready-for-agent` | Ready for `/plan-it` or AFK agent |
| `ready-for-human` | `triaged` | `ready-for-human` | Human implementation (note why in `## Comments` locally) |
| `wontfix` | `wontfix` | `wontfix` | Will not be actioned |

**Local tracker:** edit the **Local inbox `status:`** column if your repo uses different status strings.

**Jira:** edit **Jira label** if labels differ; status transitions stay in [issue-tracker-jira.md](issue-tracker-jira.md#triage-state-mapping).

When a skill says "apply the `ready-for-agent` role", set local `status: ready-for-plan` or Jira label `ready-for-agent` per this table.
