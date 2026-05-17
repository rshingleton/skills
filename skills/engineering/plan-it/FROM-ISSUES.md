# plan-it — Start from intake issues

Use when work already exists as **pre-plan** files in the **`docs/issues/` inbox** (bugs, defers, todos, feature requests).

## Inbox vs plan

| Location | Contents |
|----------|----------|
| `docs/issues/<slug>.md` | **Active inbox only** — not yet attached to a plan |
| `docs/planning/<plan-id>/sources/<slug>.md` | Intake **moved here at plan creation** — stays with the plan through implement/verify/archive |

**Do not leave planned or in-flight items in `docs/issues/`** — that causes duplicate plans when browsing the inbox.

## Intake shape (inbox)

Flat single file: `docs/issues/<slug>.md`

```yaml
---
title: Short summary
type: bug | defer | todo | feature
status: intake | ready-for-plan | wontfix
source: user | email | servicenow | review | grill | doc-it | improve-codebase-architecture | audit-it | jira
jira_key:              # only if filed from existing Jira
---
```

Capture with **`/issue-it`**. `wontfix` may stay in the inbox or move to `docs/issues/wontfix/` (team choice).

## After move (under plan)

```yaml
---
title: Short summary
type: bug | defer | todo | feature
status: in-plan              # verify-it sets done
source: user | email | servicenow | review | grill | doc-it | improve-codebase-architecture | audit-it | jira
moved_from: docs/issues/<slug>.md
jira_key:
---
```

## Invocation

```text
/plan-it --from-issues docs/issues/auth-bug.md docs/issues/defer-csv.md
/plan-it --from-issues ready
```

`ready` = top-level `docs/issues/*.md` with `status: ready-for-plan` (not `sources/`, not subfolders except optional `wontfix/`).

## Process (before plan-it scaffold)

1. **Read** each inbox file. Summarize scope for the user.
2. **Readiness** — if `status: intake`, run [intake evaluation](../SKILL.md#1-intake-evaluation-for-intake-items) (codebase exploration, reproduction, clarifying questions). If `status: ready-for-plan`, proceed. Do **not** skip The Grill.
3. **Hand off to The Grill** — plan-it **always** grills next: questionable items, overlaps, one plan vs multiple plans, vertical slice, ADRs. Intake evaluation refines the inbox; the grill decides the plan.
4. After The Grill resolves branches, **scaffold** `docs/planning/{ID}/` (phases, `jira.md` stub, ADR as usual).
5. **Move intake** — for each source file:

```bash
mkdir -p "docs/planning/${ID}/sources"
mv "docs/issues/auth-bug.md" "docs/planning/${ID}/sources/auth-bug.md"
```

Update frontmatter on each moved file: `status: in-plan`, `moved_from: docs/issues/<slug>.md`.

6. **README.md** — `## Sources` lists paths **under the plan** (not inbox):

```markdown
## Sources
- sources/auth-bug.md — token refresh failure
- sources/defer-csv.md — CSV edge cases deferred
```

7. **Optional Jira** — [JIRA.md](JIRA.md) → `jira.md`.
8. Do **not** copy full issue bodies into phase prompts.

## After planning

> Plan `{ID}` created — {N} issue(s) moved to `docs/planning/{ID}/sources/`. Inbox cleared for those items. **Next:** `/implement-it` on `phase-1/ai-prompt.md`.
