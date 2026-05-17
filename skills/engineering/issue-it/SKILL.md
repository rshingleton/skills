---
name: issue-it
description: >
  Capture pre-plan intake under docs/issues/ (bugs, defers, todos, features).
  Does not create plans or Jira phase tasks — use plan-it for that.
  Use when user reports a bug, defer, todo, or feature request, pastes
  email or ServiceNow text, or says issue-it.
---

# Issue It

**Intake only** — record work **before** a Doc Cycle plan exists. Audit skills (`/doc-it`, `/improve-codebase-architecture`, `/audit-it` repo) may create files here via [audit-to-issues.md](../setup-internal-skills/audit-to-issues.md).

## Quick start

```text
/issue-it
> "Add rate limiting to the auth endpoint"
```

→ Creates `docs/issues/rate-limit-auth.md`, `type: feature`, `status: intake`.

For pasted email/ServiceNow: paste the body after `/issue-it`. See [Capture process](#from-pasted-text-email--servicenow).

| Use | Skill |
|-----|--------|
| Bug, defer, todo, feature request, review follow-up | **`/issue-it`** |
| Evaluate + refine intake → plan | **`/plan-it --from-issues`** (triage evaluation + grill in one session) |
| Implement a plan phase | **`/implement-it`** |

**Read `docs/agents/issue-tracker.md` first** — run `/setup-internal-skills` if missing.

## Layout

Flat files under `docs/issues/`:

```
docs/issues/
├── README.md
├── auth-token-refresh.md
└── defer-legacy-csv.md
```

**Inbox only** — once `/plan-it --from-issues` runs, files move to `docs/planning/<id>/sources/`. Not used for phases or `jira.md`.

## Capture process

### From user description

When the user gives a loose or vague request, build a structured issue through three phases:

**Phase 1 — Gather codebase context**

Before writing the file, understand the relevant area:

- Check `docs/reference/` for module maps, domain vocabulary, and architecture docs that relate to the request.
- If `docs/reference/` is missing or the domain is unfamiliar, suggest running `/zoom-out` on the likely affected area (e.g. `/zoom-out src/auth/`) to get a quick map.
- If the request references a specific file or error, explore it directly.
- Note relevant module names, key abstractions, and domain terms — they go into the issue body.

**Phase 2 — Probe**

Use the codebase context to ask targeted questions that flesh out the request. Adapt to the `type:`:

| Type | Probe for |
|------|-----------|
| **bug** | Steps to reproduce, expected vs actual behaviour, error output, affected module |
| **feature** | User need, proposed behaviour, edge cases, integration points |
| **todo** | Context trigger, why now, what "done" looks like |
| **defer** | Why deferred, what would unblock it |

Limit to 1-3 questions — don't over-interview.

Examples:

> "You mentioned rate limiting on auth. Is this brute-force protection (X attempts/min per IP) or quota enforcement (Y req/hour per token)? The auth module currently uses token-based throttling in `AuthFilter.java`."

> "The error you pasted comes from `PaymentService.process()`. Does this happen with all payment methods or a specific one? Are there recent changes to that flow?"

If the request is already detailed enough (`status: ready-for-plan`), skip probing.

**Phase 3 — Create**

Write `docs/issues/<slug>.md` with filled-in frontmatter and body:

```yaml
---
title: Short summary
type: bug | defer | todo | feature
status: intake | ready-for-plan
source: user
---
```

Body: [INTAKE-TEMPLATE.md](INTAKE-TEMPLATE.md) — fill **Problem / request** and **Acceptance** from what was gathered. Add code-area references under **Context** or **Notes**. Leave sections blank only when genuinely unknown.

Tell user:

> Saved `docs/issues/<slug>.md`. **Next:** `/plan-it --from-issues docs/issues/<slug>.md` to evaluate and plan.

### From pasted text (email / ServiceNow)

When the user pastes an email thread or ServiceNow ticket:

1. Derive `title`, `type`, and `slug` from the paste. Ask if category is unclear.
2. Create `docs/issues/<slug>.md` with `source: email` or `source: servicenow`; optional `external_id:` (ticket number), `requester:`, `received:`.
3. Put the **verbatim paste** under `## Context`; distill **Problem / request** and minimal **Acceptance**.
4. Leave `status: intake` unless already fully specified (then `ready-for-plan`).
5. Tell user:

> Created `docs/issues/<slug>.md` from pasted request. **Next:** review the file, then `/plan-it --from-issues docs/issues/<slug>.md` to evaluate and plan.

See [SCENARIO-EMAIL-SERVICENOW.md](../setup-internal-skills/SCENARIO-EMAIL-SERVICENOW.md) for the full org flow.

## Status flow (inbox only)

```
intake → ready-for-plan → (plan-it moves to planning/<id>/sources/, status in-plan)
       ↘ wontfix
```

After move, lifecycle continues under `docs/planning/<id>/sources/` (`in-plan` → `done` at verify-it).

## Optional: link existing Jira

If reporting from an existing ticket, set `jira_key` on the intake file only. Plan-it will map phases in `jira.md` when publishing.

See [EXAMPLES.md](EXAMPLES.md).
