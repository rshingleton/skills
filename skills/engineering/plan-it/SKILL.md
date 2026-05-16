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
| **Intake** | `docs/issues/*.md` | Pre-plan: bugs, defers, todos, feature requests ([issues-it](../issues-it/SKILL.md)) |
| **Plan** | `docs/planning/<id>/` | Phases, `ai-prompt.md`, ADR draft, orchestration README |
| **Jira map** | `docs/planning/<id>/jira.md` | Phase ↔ Jira keys only ([JIRA.md](JIRA.md)) |

Execution specs live in **phase prompts**. Jira keys live in **`jira.md`**. Intake issues are **sources**, not phase copies.

## Arguments

| Argument | Meaning |
|----------|---------|
| `--from-issues <path>…` | Start plan from intake files ([FROM-ISSUES.md](FROM-ISSUES.md)) |
| `--from-issues ready` | All `docs/issues/*.md` with `status: ready-for-plan` |
| `--jira` | After scaffold: create/sync Jira + write `jira.md` ([JIRA.md](JIRA.md)) |
| `--jira --sync-only` | Re-sync: pull Epic children into `jira.md` only — **no new POSTs** |
| `--parent EPIC-123` | Link new Tasks to this Epic (with `--jira`) |

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

If `--from-issues`, follow [FROM-ISSUES.md](FROM-ISSUES.md) first, then continue at step 2 with merged scope.

If user has intake but no flag, ask: *"Start from `docs/issues/` files?"*

### 1. The Grill

Interview relentlessly until shared understanding. One question at a time; recommend an answer each time.

- Domain language vs `CONTEXT.md`
- Shallow modules / mixed concerns
- Smallest vertical slice + verification strategy
- Deferred decisions and risk

Explore the codebase when that answers faster than asking. Update `CONTEXT.md` and ADRs inline. Do not proceed until branches are resolved.

### 2. Scaffold

Create `docs/planning/{ID}/`:

- **README.md** — phase list, dependency order, hand-off (`/implement-it` → `/audit-it` → `/verify-it`), non-goals.
  - If from intake: **`## Sources`** with paths to `docs/issues/*.md` ([FROM-ISSUES.md](FROM-ISSUES.md)).
- **phase-N/ai-prompt.md** (every phase) — scope & boundaries, verification criteria, relevant files. **No** duplicate of intake issue bodies; **no** `jira_key` in frontmatter (use `jira.md`).
- **jira.md** — stub when user may use Jira later:

```markdown
---
epic_key:
---

# Jira map

| Phase | Jira | Summary |
|-------|------|---------|
| phase-1 | | |
```

Write all phase prompts before implementation begins.

### 3. ADR

Draft `docs/adr/{ID}-description.md` with status `Proposed`.

### 4. Deep Modules

Design deep interfaces; update `CONTEXT.md` terminology.

### 5. Jira (optional)

If user wants Jira (or passed `--jira`), follow [JIRA.md](JIRA.md): publish phase Tasks, fill **`docs/planning/{ID}/jira.md`**. Sync-from-Epic first when `JIRA_DEFAULT_EPIC` may already have phase tasks.

Do **not** create `docs/issues/<slug>/tasks/` for plan phases.

### 6. Next skill

> Plan `{ID}` ready — {N} phase(s): {list}.
>
> Jira: `docs/planning/{ID}/jira.md` (if published).
>
> **Next:** `/implement-it` on `docs/planning/{ID}/phase-1/ai-prompt.md` → … → `/audit-it` → `/verify-it`.

## Core Tenets

- **Read-only code** during planning.
- **Full phase coverage** before any implement-it.
- **One Jira map per plan** — `jira.md`, not parallel tracker trees.
