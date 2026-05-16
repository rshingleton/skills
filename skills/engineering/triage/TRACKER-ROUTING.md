# Triage — tracker routing

Read **`docs/agents/issue-tracker.md`** (from `/setup-internal-skills`) before acting.

| Tracker doc | Use |
|-------------|-----|
| [issue-tracker-local.md](../setup-internal-skills/issue-tracker-local.md) | Inbox `docs/issues/*.md` — default |
| [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md) | Jira REST — when project uses Jira as primary tracker |

## Canonical roles → tracker fields

From [triage-labels.md](../setup-internal-skills/triage-labels.md):

| Role | Local `status:` | Jira |
|------|-----------------|------|
| `needs-triage` | `intake` | `Open` + label `needs-triage` |
| `needs-info` | `triaged` (+ questions in `## Comments`) | `On Hold` + `needs-info` |
| `ready-for-agent` | `ready-for-plan` | `Open` + `ready-for-agent` |
| `ready-for-human` | `triaged` (+ note in `## Comments`) | `Open` + `ready-for-human` |
| `wontfix` | `wontfix` (optional `wontfix/` subfolder) | `Closed` + `wontfix` |

Category (`bug` vs `enhancement`) on local: `type:` frontmatter (`bug` | `feature` | `todo` | `defer`).

## Email / ServiceNow

Paste request text in the **project repo** → `/triage` → `docs/issues/<slug>.md` (`source: email` | `servicenow`). Full flow: [SCENARIO-EMAIL-SERVICENOW.md](../setup-internal-skills/SCENARIO-EMAIL-SERVICENOW.md).

## Create issue (never plan or phase Jira here)

| Tracker | Skill path |
|---------|------------|
| **Local** | Same as **`/issues-it`**: one `docs/issues/<slug>.md`, [INTAKE-TEMPLATE.md](../issues-it/INTAKE-TEMPLATE.md), `status: intake`. |
| **Jira** | `POST /rest/api/2/issue?notifyUsers=false` — [issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md) (wiki description, `timetracking`, watcher policy). |

**Not here:** `docs/planning/`, phase Tasks, `jira.md` → **`/plan-it`** and **`/plan-it --jira`**.

## Deprecated

| Old | Use |
|-----|-----|
| `/to-epic`, `/to-jiras` | `/issues-it` → `/plan-it --from-issues` |
| `/promote-to-jira`, `/issues-it --jira` | `/plan-it --jira` |
