# From Jira — dual-path reference

## Resolve the Jira key

From a bare key (`CDS-142`) or URL (`https://.../browse/CDS-142`):

```bash
JIRA_KEY=$(echo "$INPUT" | grep -oE '[A-Z]+-[0-9]+' | head -1)
```

## Fetch the issue and comments

**Connector path (preferred):**

When Jira MCP connector is available and authenticated:

```bash
# Fetch issue with comments included
ISSUE=$(mcp__jira__jira_get_issue \
  --issue_key "$JIRA_KEY" \
  --fields "summary,description,issuetype,status,labels,created" \
  --include "comments")

SUMMARY=$(echo "$ISSUE" | jq -r '.fields.summary')
ISSUE_TYPE=$(echo "$ISSUE" | jq -r '.fields.issuetype.name')
STATUS=$(echo "$ISSUE" | jq -r '.fields.status.name')
BODY=$(echo "$ISSUE" | jq -r '.fields.description // ""')
COMMENTS=$(echo "$ISSUE" | jq -r '.changelog.histories[]? | select(.items[].field == "comment")')
```

**Bash fallback:**

If connector unavailable, source credentials and use bash helpers:

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh

ISSUE=$(_jira_fetch_issue "$JIRA_KEY" "summary,description,issuetype,status,labels,created")

COMMENTS=$(_jira_fetch_comments "$JIRA_KEY")

SUMMARY=$(echo "$ISSUE" | jq -r '.fields.summary')
ISSUE_TYPE=$(echo "$ISSUE" | jq -r '.fields.issuetype.name')
STATUS=$(echo "$ISSUE" | jq -r '.fields.status.name')
BODY=$(echo "$ISSUE" | jq -r '.fields.description // ""')
```
