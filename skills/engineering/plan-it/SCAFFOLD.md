# Scaffold

## Slicing rules

- Each phase is a vertical slice: a narrow but complete path through every layer it touches,
  verifiable on its own.
- Each phase fits one fresh context window.
- Prefactoring comes first, in its own phase if it is more than trivial.
- A wide mechanical refactor (one change whose blast radius fans across the codebase) is the
  exception to vertical slicing. Sequence it expand, migrate in batches, contract: add the new
  form beside the old, move call sites over in batches each blocked by the expand, then delete
  the old form in a phase blocked by every batch.

Give each phase its blocking edges: the phases that must complete before it can start.

## Approve the breakdown

Before writing any file, present the breakdown as a numbered list. For each phase show:

- **Title**
- **Blocked by:** the phases that gate it, or none
- **Delivers:** the behaviour it makes work

Ask whether the granularity and the blocking edges are right, and whether any phase should be
merged or split. End your turn and wait. Iterate until the user approves.

A one-phase plan has a single approval stop: present its one phase inside the grill's final
confirmation, and treat the user's confirmation of shared understanding as approval of the
breakdown. Do not stop again before writing files.

## Files

Create `docs/planning/{ID}/`:

- **README.md**: phase table, hand-off (`/implement-it {ID}` → `/audit-it` → `/verify-it` →
  `/commit-it`), decisions from the grill, links to any ADRs the plan wrote, non-goals.
  The phase table has a `Blocked by` column:

  ```markdown
  | Phase | Delivers | Blocked by |
  |-------|----------|------------|
  | [phase-1](phase-1/ai-prompt.md) | ... | None |
  | [phase-2](phase-2/ai-prompt.md) | ... | phase-1 |
  ```

  - **`sources/`**: moved intake `.md` files ([FROM-ISSUES.md](FROM-ISSUES.md)); **`## Sources`** lists `sources/<slug>.md` only.
- **phase-N/ai-prompt.md** (every phase) uses these sections, in this order: `## Goal`,
  `## Scope`, `## Boundaries`, `## Seams`, `## Verification criteria`, `## Starting points`.
  The header line under the title names the plan and `Blocked by`. Optional `estimate_hours:` (number) for Jira time tracking when
  using `--jira`. **No** duplicate of intake issue bodies; **no** `jira_key` in frontmatter
  (use `jira.md`).
  - Describe behaviour and interfaces, not procedures. Name the types, functions, commands, or
    config shapes the phase changes and what they should do.
  - **Starting points** list files worth reading first. They are not the contract: files move,
    and the behaviour above is what the phase must deliver.
  - **`## Seams`** has one line per seam agreed in the grill: the public interface, what a test
    there catches, and what it misses. A phase with no code seam states that and names its
    observable check instead:

    ```markdown
    ## Seams

    - `parseArgs(argv)`: catches flag parsing and defaults; misses how output is printed.
    - `cli --version` (process exit and stdout): catches the end-to-end wiring; misses edge
      cases in the parser.
    ```

- **jira.md**: stub, so `--jira` can fill it later ([JIRA.md](JIRA.md), include **Parent Epic** when `epic_key` is known):

```markdown
---
epic_key:
epic_summary:
parent_source:
---

# Jira map

## Parent Epic

(Set when epic_key is known: key, summary, browse link, parent_source.)

## Phase tasks

| Phase | Jira | Summary | Est. |
|-------|------|---------|------|
| phase-1 | | | |
```

**Small plan check.** Only with `--jira`: if the plan has ≤3 phases, ask whether to use a
single Task instead of Epic+Tasks ([JIRA.md](JIRA.md#small-plan-3-phases)).

Write all phase prompts before implementation begins.
