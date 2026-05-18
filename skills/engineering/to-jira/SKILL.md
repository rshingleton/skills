---
name: to-jira
description: >
  Push a local intake issue or plan to Jira as a single issue. Reads
  docs/issues/<slug>.md or docs/planning/<id>/ and creates a Jira Task/Bug
  from it. Use when user says to-jira, push to jira, create jira from issue,
  or promote to jira.
---

# To Jira

Creates a **single Jira issue** from an existing local artifact. For plan phase Tasks, use `/plan-it --jira` instead.

## Quick start

```text
/to-jira docs/issues/rate-limit-auth.md
/to-jira docs/issues/bug.md --parent CDS-200
/to-jira docs/planning/auth-v2/
```

Optional `--parent EPIC-KEY` links the new issue to an Epic. If omitted, resolves from `JIRA_DEFAULT_EPIC` or prompts you.

## Workflow

### 1. Identify the source

| Source | What happens |
|--------|-------------|
| `docs/issues/<slug>.md` | Create one Jira issue from the intake body. Issue type: `Task` (feature/todo/defer) or `Bug` (bug). |
| `docs/planning/<id>/` | Create one Jira issue from the plan README scope. Issue type: `Task`. For per-phase Tasks, use `/plan-it --jira`. |

### 2. Source Jira credentials

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
```

### 3. Resolve parent Epic

Check `--parent` flag, then `JIRA_DEFAULT_EPIC`, else ask:

> Link this issue to an Epic? (key or blank)

When resolved, set `customfield_10880` on the POST payload.

### 4. Build the Jira description

Read the source body, convert markdown → Jira wiki markup:

```bash
_jira_wiki_body docs/issues/rate-limit-auth.md
```

Follow [jira-description-style.md](../setup-internal-skills/jira-description-style.md):
- `h2.` sections, `*` bullets
- No `##`, no `- [ ]`
- Concrete behavior, no planning doc references

### 5. POST to Jira

Build the payload with `jq`, including Epic link when resolved:

```bash
PAYLOAD=$(jq -n \
  --arg project "$JIRA_PROJECT_KEY" \
  --arg summary "<issue title>" \
  --arg body "$BODY" \
  --arg type "<Task|Bug>" \
  --arg epic "$EPIC_KEY" \
  '{
    fields: ({
      project: {key: $project},
      summary: $summary,
      description: $body,
      issuetype: {name: $type},
      labels: ["ai-generated"]
    } + (if $epic != "" then {customfield_10880: $epic} else {} end))
  }')
```

Include `timetracking` when estimate hours are available (from `estimate_hours:` in plan README or `JIRA_DEFAULT_ESTIMATE_HOURS`):

```bash
EST_HOURS="${JIRA_DEFAULT_ESTIMATE_HOURS:-}"
TIMETRACKING=$(_jira_timetracking_fields "$EST_HOURS")
PAYLOAD=$(echo "$PAYLOAD" | jq --argjson tt "$TIMETRACKING" '.fields + $tt')
```

POST:

```bash
KEY=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
  -d "$PAYLOAD" | jq -r '.key')
```

After POST:
```bash
_jira_apply_watcher_policy "$KEY" create
```

### 6. Write back

Record the Jira key in the source file:

**For an intake issue** (`docs/issues/<slug>.md`): set `jira_key: KEY-123` in frontmatter.

**For a plan** (`docs/planning/<id>/`): write key to `jira.md`:

```markdown
---
jira_key: KEY-123
---

# Jira map

| Source | Jira | Summary |
|--------|------|---------|
| <plan-id> | KEY-123 | <plan title> |
```

### 7. Report

> Created KEY-123 from `docs/issues/<slug>.md`. Linked in frontmatter.
> Browse: $JIRA_BASE_URL/browse/KEY-123

## When to use

| Use `/to-jira` | Use `/plan-it --jira` |
|----------------|----------------------|
| Single intake item needs Jira tracking | Plan has multiple phases needing per-phase Tasks |
| Bug needs Jira visibility without full Doc Cycle | Need Epic + Task hierarchy |
| Quick push from intake to shared tracker | Need time tracking per phase |

## Not supported

- No Epic creation — links to existing Epics only (use `/plan-it --jira` to create new Epics + phase Tasks)
- No transition or status changes on existing Jira issues
- No sync direction from Jira back to local (use `/from-jira`)
