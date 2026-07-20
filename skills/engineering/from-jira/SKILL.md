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

This is the **read direction** (Jira → local). For the write direction (local → Jira), use [`to-jira`](../to-jira/SKILL.md).

**Uses Jira MCP connector when available** — automatically prefers `jira_get_issue` over bash helpers. Requires connector setup (see [`to-jira` § Connector availability](../to-jira/SKILL.md#connector-availability)).

## Quick start

```text
/from-jira CDS-142
/from-jira https://jira.example.com/browse/CDS-142
```

## Workflow

### 1. Resolve the Jira key

See [COMMANDS.md](COMMANDS.md) for bash: key extraction, credential sourcing, and issue fetch.

From a bare key (`CDS-142`) or URL (`https://.../browse/CDS-142`), extract the key, then source credentials and fetch the issue.

### 2. Present to user

Summarise what was fetched — title, type, status, description preview, comment count. Ask:

> Fetched CDS-142: "<title>" (type, status). {N} comment(s).
> Description: <first 3 lines or "empty">
>
> Shall I grill you on this scope and scaffold a plan?

If yes, continue. If no, stop.

### 3. Grill

Run the standard plan-it grill ([plan-it SKILL.md](../plan-it/SKILL.md#2-the-grill)) using the Jira description and comments as scope context. One question at a time. Always keep the Jira key for later mapping.

By default the grill treats the Jira issue as the scope anchor. The user can narrow, split, or merge scope during grilling.

### 4. Scaffold

Create `docs/planning/<id>/` following the template in [REFERENCE.md](REFERENCE.md) — README.md, phase prompts, and `jira.md` pre-filled with the Jira key.

### 5. Draft ADR

See [REFERENCE.md](REFERENCE.md) for the ADR format.

### 6. Next skill

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
