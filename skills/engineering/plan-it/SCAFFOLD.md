# Scaffold

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

**Small plan check.** If the plan has ≤3 phases and the user wants Jira, ask
whether to use a single Task instead of Epic+Tasks ([JIRA.md](JIRA.md#small-plan-3-phases)).

Write all phase prompts before implementation begins.
