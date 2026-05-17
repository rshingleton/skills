# Audit findings → intake issues

Use when **`/doc-it`**, **`/improve-codebase-architecture`**, or **`/audit-it`** (repo mode) produced actionable items and the user wants them in the **inbox** for planning — not lost in audit markdown only.

Capture with **`/issue-it`** (one `docs/issues/<slug>.md` per item). Do **not** create plans or Jira here.

## When to offer

Ask once after findings are written:

> *"Create intake issues in `docs/issues/` for tracking? (I'll file selected items from the audit — you can plan later with `/plan-it --from-issues`.)"*

Skip if the user declines. Do not file everything automatically — **quiz** which rows to capture.

## Source artifacts

| Skill | Read from |
|-------|-----------|
| `/doc-it` | `docs/reference-audit/follow-ups.md`, `tech-debt.md` (TD-*), `testing.md` (TR-*), `architecture.md` (numbered findings) |
| `/improve-codebase-architecture` | Numbered candidates from the presentation step (or grilled outcome) |
| `/audit-it` (repo) | `docs/AUDIT.md` simplification / deletion proposals |

## Issue type mapping

| Audit item | `type:` | `status:` |
|------------|---------|-----------|
| Tech debt / refactor / deepening | `defer` or `todo` | `ready-for-plan` |
| Missing tests / TR-* | `todo` | `ready-for-plan` |
| Architecture finding worth a slice | `feature` | `ready-for-plan` |
| Bug / incorrect behaviour | `bug` | `intake` or `ready-for-plan` |
| Revisit later / low priority | `defer` | `intake` |

## `source:` frontmatter

Set to the audit skill:

```yaml
source: doc-it
source: improve-codebase-architecture
source: audit-it
```

## File content

Use [INTAKE-TEMPLATE.md](../../issue-it/INTAKE-TEMPLATE.md). In **Notes**, always link the audit anchor:

```markdown
## Notes
- Audit: docs/reference-audit/architecture.md#3
- Debt: TD-2 in docs/reference-audit/tech-debt.md
- Candidate #2 from improve-codebase-architecture session
```

**Title:** short verb + object (same as issue summary line in follow-ups).

**Slug:** kebab-case from title; avoid colliding with existing `docs/issues/*.md`.

## Process

1. Present a numbered list of **proposed** intake files (title, type, audit link) — user selects.
2. For each approved item, write `docs/issues/<slug>.md` with frontmatter + body.
3. Update the audit doc — append under the finding in **Notes** or in `follow-ups.md`:

```markdown
- Tracked: docs/issues/deepen-order-intake.md
```

4. Handoff:

> Created {N} intake issue(s) under `docs/issues/`. **Next:** `/plan-it --from-issues` when ready to plan, or capture more items with `/issue-it`.

## Do not

- Create `docs/planning/` or `jira.md`
- Leave the same finding tracked twice (check inbox before creating)
- Move issues to `sources/` until `/plan-it --from-issues`
