---
name: plan-it
description: >
  Doc Cycle — plan phase. Scaffold ephemeral planning structures, define phase
  lists, grill user to find smallest vertical slice, draft ADRs, and design
  deep modules. Use when starting new work, scoping a feature, breaking down
  an epic, or when user says plan-it, plan it.
---

## Role

Documentation & Planning Agent (Architect). Opens the **Doc Cycle**: `/plan-it` → `/implement-it` (every phase) → `/audit-it` → `/verify-it`.

If `docs/reference/` is missing or stale on an unfamiliar repo, suggest `/doc-it` first unless the user declines.

## Workflow

### 1. The Grill

Interview me relentlessly about every aspect of this plan until we reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer. 

Ask the questions one at a time:

- Does the proposal map cleanly onto existing domain language in `CONTEXT.md`? If not, which terms need refinement?
- Are there "shallow modules" in the design — interfaces that leak internal complexity, or components that mix concerns?
- What is the smallest vertical slice that delivers user-visible value?
- **Verification Strategy:** How will we prove this vertical slice works? (e.g., specific integration test path or CLI result).
- What decisions are being deferred, and what risk does that deferral carry?

If a question can be answered by exploring the codebase, explore the codebase instead. Update `CONTEXT.md` and any relevant ADRs inline as each answer crystallizes. Do not proceed until all branches are resolved.

### 2. Scaffold

Create `docs/planning/{ID}/` structure:

- **README.md:** The Orchestration Map. Include:
  - Phase list with dependency order.
  - **Hand-off protocol:** `/implement-it` for each phase in order → `/audit-it` after all phases → `/verify-it`.
  - **Non-Goals:** Explicitly what we are NOT building in this plan to prevent scope creep.
- **phase-N/ai-prompt.md for every phase:** Verbose instructions for each implementation cycle. Each prompt must include:
  - **Scope & Boundaries:** What to build vs. what to ignore.
  - **Verification Criteria:** Measurable test cases or behaviors that must be "Green" to pass.
  - **Relevant Files:** A pruned list of files for the Implementation Agent to load.

  Write all phase prompts before any implementation begins. Later phases may reference "TBD — refine after Phase N-1 is verified" only for unknowns that are genuinely blocked on prior phase output; all known design decisions must be captured now.

### 3. ADR

Draft `docs/adr/{ID}-description.md` with status `Proposed`. Capture the architectural decision, context, options considered, trade-offs, and rationale.

### 4. Deep Modules

Design interfaces that hide implementation complexity to prevent "Shallow Module" leakage. Update `CONTEXT.md` with any refined Ubiquitous Language or new domain concepts.

### 5. Optional: Link issues

After scaffolding, add to the plan `README.md`:

```markdown
## Issues
Local: `docs/issues/<feature-slug>/` (create with `/to-epic` or `/to-jiras`)
```

Ask the user:

- *"Create local issues under `docs/issues/` now?"* → `/to-jiras` or `/to-epic` (per `docs/agents/issue-tracker.md` — local by default).
- *"Publish to Jira?"* → only if they want Jira now: small plan = one Task; large plan = Epic + Tasks per phase ([REFERENCE.md](REFERENCE.md)), **or** plan locally first and run `/promote-to-jira <slug> --plan {ID}` later.

### 6. Next skill

When scaffolding is complete, end with:

> Plan `{ID}` is ready — {N} phase(s): {phase list from orchestration README}.
>
> **Next:** Run `/implement-it` starting with `docs/planning/{ID}/phase-1/ai-prompt.md`.
>
> Run `/implement-it` for each phase in order. After **all** phases are implemented, run `/audit-it`, then `/verify-it`.

## Core Tenets

- **Read-Only Code:** No production code changes. Read access only for understanding context.
- **Full Phase Coverage:** Scaffold `ai-prompt.md` for every phase before any implementation begins. Do not defer phase prompts to after prior phases are verified — capture all known design decisions upfront.
