---
name: plan-it
description: >
  Doc Cycle — plan phase. Grill, scaffold phases, draft ADRs, optional Jira
  (jira.md), start from intake (--from-issues), re-sync Jira keys
  (--jira --sync-only). Use plan-it, plan it, --jira, --from-issues.
---

## Role

Documentation & Planning Agent (Architect). Opens the **Doc Cycle**: `/plan-it` → `/implement-it` (every phase) → `/audit-it` → `/verify-it`.

If `docs/reference/` is missing or stale on an unfamiliar repo, suggest `/doc-it` first unless the user declines.

**Issue tracker:** `docs/agents/issue-tracker.md` should have been provided — run `/setup-internal-skills` if missing.

## Three layers (do not mix)

| Layer | Path | Purpose |
|-------|------|---------|
| **Inbox** | `docs/issues/*.md` | Unplanned intake only ([issues-it](../issues-it/SKILL.md)) |
| **Plan** | `docs/planning/<id>/` | Phases, `sources/` (moved intake), ADR, README |
| **Jira map** | `docs/planning/<id>/jira.md` | Phase ↔ Jira keys only ([JIRA.md](JIRA.md)) |

At **`--from-issues`**, move each inbox file → `docs/planning/<id>/sources/` so the inbox stays clean. Execution specs live in **phase prompts**; Jira keys in **`jira.md`**.

## Arguments

| Argument | Meaning |
|----------|---------|
| `--from-issues <path>…` | Start plan from intake files ([FROM-ISSUES.md](FROM-ISSUES.md)) |
| `--from-issues ready` | All `docs/issues/*.md` with `status: ready-for-plan` |
| `--jira` | After scaffold: create/sync Jira + write `jira.md` ([JIRA.md](JIRA.md)) |
| `--jira --sync-only` | Re-sync: pull Epic children into `jira.md` only — **no new POSTs** |
| `--parent EPIC-123` | **Override** parent Epic for this publish — **beats** `JIRA_DEFAULT_EPIC` in `.env` and existing defaults ([JIRA.md](JIRA.md#parent-epic-override)) |

### Re-sync an existing plan (no re-grill)

When `docs/planning/{ID}/` already exists and Jira issues were created earlier:

```text
/plan-it {ID} --jira --sync-only
```

1. Read existing `phase-N/ai-prompt.md` files and `jira.md` (create stub if missing).
2. Run [jira-epic-sync.md](../setup-internal-skills/jira-epic-sync.md) — JQL Tasks under Epic → fill phase rows in `jira.md`.
3. Report matched / unmatched phases; **do not** re-run the grill or rescaffold.

Full publish (sync, then create missing Tasks): `/plan-it {ID} --jira`.

Does **not** rewrite Jira descriptions on existing issues — only keys in `jira.md`. To fix bad descriptions, edit in Jira or re-POST (manual).

## Workflow

### 0. Intake (optional)

**Ad-hoc** (`/plan-it` with no flags) — skip to [The Grill](#1-the-grill). No inbox file required.

**From issue(s)** (`--from-issues <path>…` or `ready`) — follow [FROM-ISSUES.md](FROM-ISSUES.md): read inbox files, optional readiness gate, then **always** continue to The Grill with merged scope.

If the user passes an inbox path without `--from-issues`, ask: *"Start planning from `docs/issues/<slug>.md`?"*

**Triage is optional pre-work.** `/triage` moves items through inbox states (`intake` → `ready-for-plan`). It does **not** replace plan-it's grill. Do **not** invoke `/triage` automatically when `--from-issues` is set.

| Inbox `status:` | Before The Grill |
|-----------------|------------------|
| `ready-for-plan` | Proceed — grill still runs |
| `triaged` | Proceed — grill resolves planning questions triage left open |
| `intake` | Offer `/triage` or a few inline clarifiers; if user says plan now, proceed to The Grill |

### 1. The Grill

**Always runs** — ad-hoc or from issues, with or without prior `/triage`. Interview relentlessly until shared understanding. One question at a time; recommend an answer each time.

Use intake and `sources/` as context, not a substitute for grilling: challenge vague scope, merge or split issues, and decide one plan vs several.

- Domain language vs `CONTEXT.md`
- Shallow modules / mixed concerns
- Smallest vertical slice + verification strategy
- Deferred decisions and risk

Explore the codebase when that answers faster than asking. Update `CONTEXT.md` and ADRs inline. Do not proceed until branches are resolved.

### 2. Scaffold

Create `docs/planning/{ID}/`:

- **README.md** — phase list, dependency order, hand-off (`/implement-it` → `/audit-it` → `/verify-it`), non-goals.
  - **`sources/`** — moved intake `.md` files ([FROM-ISSUES.md](FROM-ISSUES.md)); **`## Sources`** lists `sources/<slug>.md` only.
- **phase-N/ai-prompt.md** (every phase) — scope & boundaries, verification criteria, relevant files. Optional `estimate_hours:` (number) for Jira time tracking when using `--jira`. **No** duplicate of intake issue bodies; **no** `jira_key` in frontmatter (use `jira.md`).
- **jira.md** — stub when user may use Jira later ([JIRA.md](JIRA.md) — include **Parent Epic** when `epic_key` is known):

```markdown
---
epic_key:
epic_summary:
parent_source:
---

# Jira map

## Parent Epic

(Set when epic_key is known — key, summary, browse link, parent_source.)

## Phase tasks

| Phase | Jira | Summary | Est. |
|-------|------|---------|------|
| phase-1 | | | |
```

Write all phase prompts before implementation begins.

### 3. ADR

Draft `docs/adr/{ID}-description.md` with status `Proposed`.

### 4. Deep Modules

Design deep interfaces; update `CONTEXT.md` terminology.

### 5. Jira (optional)

If user wants Jira (or passed `--jira`):

1. **Read `docs/agents/issue-tracker.md`** — it tells you the tracker type (Local vs Jira), `JIRA_*` env vars, and provides helper functions. **Source Jira env before any API calls:** first check if `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` are already exported; if not, try `source scripts/load-jira-env.sh`, then `source ~/.local/share/ai-skills/scripts/load-jira-env.sh`. If still unset, read `.env` directly and export vars. Do not ask the user for credentials — the env file is the configured source.
2. **Follow [JIRA.md](JIRA.md):** publish phase Tasks (with **time estimates** per phase), fill **`docs/planning/{ID}/jira.md`**. Sync-from-Epic first when `JIRA_DEFAULT_EPIC` may already have phase tasks. If `estimate_hours` is missing on a phase, ask for hours before POST or use `JIRA_DEFAULT_ESTIMATE_HOURS`.

When `JIRA_DEFAULT_EPIC` is set but this plan belongs elsewhere, require or confirm **`--parent EPIC-KEY`** — do not silently use the env default if the user named a different Epic.

Do **not** create `docs/issues/<slug>/tasks/` for plan phases.

**If Jira was not requested:** ask the user *"Create Jira issues for this plan now?"* If yes, run the Jira publish flow (step 5a); if no, note that they can later run `/plan-it {ID} --jira` or `/plan-it {ID} --jira --sync-only` to publish or re-sync.

### 6. Next skill

> Plan `{ID}` ready — {N} phase(s): {list}.
>
> **Jira:** `docs/planning/{ID}/jira.md` (if published). To publish later: `/plan-it {ID} --jira`.
>
> **Next:** `/implement-it` on `docs/planning/{ID}/phase-1/ai-prompt.md` → … → `/audit-it` → `/verify-it`.

## Core Tenets

- **Read-only code** during planning.
- **Full phase coverage** before any implement-it.
- **One Jira map per plan** — `jira.md`, not parallel tracker trees.
