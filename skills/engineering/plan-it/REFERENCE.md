# plan-it: Jira Publish Reference

After **every** create below: remove the API user from watchers per [jira-notifications.md](../setup-internal-skills/jira-notifications.md) (`JIRA_WATCHER_USERNAME` or `${JIRA_EMAIL%%@*}`).

```bash
_remove_jira_watcher() {
  local key="$1"
  local user="${JIRA_WATCHER_USERNAME:-${JIRA_EMAIL%%@*}}"
  [ -z "$key" ] || [ -z "$user" ] && return 0
  curl -s -o /dev/null -X DELETE \
    -H "Authorization: Bearer $JIRA_API_TOKEN" \
    "$JIRA_BASE_URL/rest/api/2/issue/${key}/watchers?username=${user}" 2>/dev/null || true
}
```

## Small Plan — Single Task

```bash
KEY=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
  -d "$(jq -n \
    --arg project "$JIRA_PROJECT_KEY" \
    --arg summary "<plan title>" \
    --arg body "<phase list as bullets>" \
    '{
      fields: {
        project: {key: $project},
        summary: $summary,
        description: $body,
        issuetype: {name: "Task"},
        labels: ["plan", "ai-generated"]
      }
    }')" | jq -r '.key')
_remove_jira_watcher "$KEY"
```

## Large Plan — Epic + Tasks per Phase

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
_remove_jira_watcher "$EPIC_KEY"

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
  _remove_jira_watcher "$TASK_KEY"
done
```
