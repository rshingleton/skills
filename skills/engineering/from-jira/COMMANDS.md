# From Jira — bash reference

## Resolve the Jira key

From a bare key (`CDS-142`) or URL (`https://.../browse/CDS-142`):

```bash
JIRA_KEY=$(echo "$INPUT" | grep -oE '[A-Z]+-[0-9]+' | head -1)
```

## Source Jira credentials

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
```

## Fetch the issue and comments

```bash
ISSUE=$(_jira_fetch_issue "$JIRA_KEY" "summary,description,issuetype,status,labels,created")

COMMENTS=$(_jira_fetch_comments "$JIRA_KEY")

SUMMARY=$(echo "$ISSUE" | jq -r '.fields.summary')
ISSUE_TYPE=$(echo "$ISSUE" | jq -r '.fields.issuetype.name')
STATUS=$(echo "$ISSUE" | jq -r '.fields.status.name')
BODY=$(echo "$ISSUE" | jq -r '.fields.description // ""')
```
