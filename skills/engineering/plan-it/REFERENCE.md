# plan-it: Jira Publish Reference

## Small Plan — Single Task

```bash
curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
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
    }')"
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

for phase in phase-1 phase-2 phase-3; do
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
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
      }')"
done
```
