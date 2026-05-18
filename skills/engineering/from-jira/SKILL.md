---
name: from-jira
description: >
  Create a Doc Cycle plan from an existing Jira issue. Fetches the Jira
  issue + comments, presents the scope, then runs the standard plan-it grill
  and scaffold. Skips the local inbox. Use when user says from-jira, plan
  from jira, create plan from jira KEY-123, or provides a Jira URL.
---

# From Jira

Creates a `docs/planning/<id>/` plan from an existing Jira issue — no local inbox file needed.

## Quick start

```text
/from-jira CDS-142
/from-jira https://jira.example.com/browse/CDS-142
```

## Workflow

### 1. Resolve the Jira key

From a bare key (`CDS-142`) or URL (`https://.../browse/CDS-142`):

```bash
JIRA_KEY=$(echo "$INPUT" | grep -oE '[A-Z]+-[0-9]+' | head -1)
```

### 2. Source Jira credentials

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
```

### 3. Fetch the issue and comments

```bash
ISSUE=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/2/issue/$JIRA_KEY?fields=summary,description,issuetype,status,labels,created")

COMMENTS=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/2/issue/$JIRA_KEY/comment")

SUMMARY=$(echo "$ISSUE" | jq -r '.fields.summary')
ISSUE_TYPE=$(echo "$ISSUE" | jq -r '.fields.issuetype.name')
STATUS=$(echo "$ISSUE" | jq -r '.fields.status.name')
BODY=$(echo "$ISSUE" | jq -r '.fields.description // ""')
```

### 4. Present to user

Summarise what was fetched — title, type, status, description preview, comment count. Ask:

> Fetched CDS-142: "<title>" (type, status). {N} comment(s).
> Description: <first 3 lines or "empty">
>
> Shall I grill you on this scope and scaffold a plan?

If yes, continue. If no, stop.

### 5. Grill

Run the standard plan-it grill ([plan-it SKILL.md](../plan-it/SKILL.md#2-the-grill)) using the Jira description and comments as scope context. One question at a time. Always keep the Jira key for later mapping.

By default the grill treats the Jira issue as the scope anchor. The user can narrow, split, or merge scope during grilling.

### 6. Scaffold

Create `docs/planning/<id>/` with:

- **README.md** — phase list, dependency order, non-goals
- **phase-N/ai-prompt.md** — one per phase, with scope and verification criteria
- **jira.md** — pre-filled with the Jira key:

```markdown
---
epic_key: CDS-142
epic_summary: <title from Jira>
parent_source: from-jira
---

# Jira map

## Parent Epic

| Field | Value |
|-------|-------|
| Key | CDS-142 |
| Summary | <title> |
| Link | $JIRA_BASE_URL/browse/CDS-142 |
| Source | from-jira |

## Phase tasks

| Phase | Jira | Summary | Est. |
|-------|------|---------|------|
| phase-1 | | | |
```

The Jira key becomes the `epic_key` in `jira.md`. When the plan publishes to Jira later (`/plan-it <id> --jira`), new phase Tasks will link to this Epic.

If the original Jira issue is a Task (not an Epic), set a note in `jira.md`:

> Source issue CDS-142 is a Task — no Epic was created. Phase Tasks will be standalone.
> To create an Epic, run `/plan-it <id> --jira` and use `--parent <epic-key>`.

### 7. Draft ADR

Create `docs/adr/<id>-from-jira.md` noting the source Jira key and the decision to plan.

### 8. Next skill

> Plan `{ID}` created from CDS-142 — {N} phase(s).
>
> **Next:** `/implement-it` on `docs/planning/{ID}/phase-1/ai-prompt.md`
>
> To publish phase Tasks to Jira: `/plan-it {ID} --jira --parent CDS-142`

## When to use

| Use `/from-jira` | Use `/issue-it` + `/plan-it --from-issues` |
|------------------|------------------------------------------|
| Jira issue already exists, needs Doc Cycle implementation | Starting from scratch or email/ServiceNow |
| Bug/feature filed in Jira but needs structured planning | Capturing unplanned work |
| Epic already has requirements in Jira description | Need intake evaluation before planning |

## Not supported

- No local inbox file created (goes straight to plan)
- No triage evaluation (assumes the Jira issue is already evaluated)
- No changes to the Jira issue itself (no transitions, comments, or status changes)
- No multi-issue plan creation from JQL — one Jira key at a time
