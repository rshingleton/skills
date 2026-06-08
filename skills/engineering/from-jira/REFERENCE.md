# From Jira — scaffold templates

## jira.md format (step 6)

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

## ADR file (step 7)

Create `docs/adr/<id>-from-jira.md` noting the source Jira key and the decision to plan.
