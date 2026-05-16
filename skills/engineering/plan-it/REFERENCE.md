# plan-it: Jira Publish Reference

**Parent Epic:** Before creating Tasks, resolve `EPIC_KEY` with `resolve_jira_parent_epic` ([issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md#resolving-the-parent-epic-agents)) — pass `--parent` if the user gave one, else `<feature-slug>` when known. If `EPIC_KEY` is set, link Tasks with `customfield_10880` and skip creating a new Epic in the large-plan flow unless the user asked for a new Epic.

**Descriptions:** dense structured style on all `summary` / `description` fields — [jira-description-style.md](../setup-internal-skills/jira-description-style.md).

After **every** create below: apply watcher policy per [jira-notifications.md](../setup-internal-skills/jira-notifications.md) (`JIRA_WATCHER_IGNORE`, `JIRA_WATCHER_USERNAME`, `JIRA_EMAIL`). Copy `_jira_apply_watcher_policy` and related helpers from that file. On create, include `assignee: {name: $JIRA_ASSIGNEE}` in `fields` when `JIRA_ASSIGNEE` is set ([issue-tracker-jira.md](../setup-internal-skills/issue-tracker-jira.md#assignee-jira_assignee)).

## Small Plan — Single Task

If `EPIC_KEY` is resolved, add `customfield_10880: $EPIC_KEY` to fields (same as large-plan Tasks).

```bash
KEY=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
  -d "$(jq -n \
    --arg project "$JIRA_PROJECT_KEY" \
    --arg summary "<plan title>" \
    --arg body "<dense structured phase bullets>" \
    '{
      fields: {
        project: {key: $project},
        summary: $summary,
        description: $body,
        issuetype: {name: "Task"},
        labels: ["plan", "ai-generated"]
      }
    }')" | jq -r '.key')
_jira_apply_watcher_policy "$KEY" create
```

## Large Plan — Epic + Tasks per Phase

If `EPIC_KEY` is already resolved (default or `--parent`), skip the Epic POST below and use it in the phase loop. Otherwise create a new Epic:

```bash
EPIC_KEY=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
  -d "$(jq -n \
    --arg project "$JIRA_PROJECT_KEY" \
    --arg summary "<plan title>" \
    --arg body "<full plan description>" \
    '{
      fields: {
        project: {key: $project},
        summary: $summary,
        description: $body,
        issuetype: {name: "Epic"},
        customfield_10881: "<plan title>",
        labels: ["plan", "epic", "ai-generated"]
      }
    }')" | jq -r '.key')
_jira_apply_watcher_policy "$EPIC_KEY" create

for phase in phase-1 phase-2 phase-3; do
  TASK_KEY=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
    -d "$(jq -n \
      --arg project "$JIRA_PROJECT_KEY" \
      --arg summary "<phase title>" \
      --arg body "<phase description>" \
      --arg epic "$EPIC_KEY" \
      '{
        fields: {
          project: {key: $project},
          summary: $summary,
          description: $body,
          issuetype: {name: "Task"},
          customfield_10880: $epic,
          labels: ["vertical-slice", "ai-generated"]
        }
      }')" | jq -r '.key')
  _jira_apply_watcher_policy "$TASK_KEY" create
done
```
