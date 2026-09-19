# Engineering

Skills I use daily for code work.

## Intake & triage

Pre-plan work lives in **`docs/issues/`** (inbox only). At plan creation, files move to **`docs/planning/<id>/sources/`**.

| Skill | Role |
|-------|------|
| [issue-it](./issue-it/SKILL.md) | Capture one inbox file (also paste email/ServiceNow — [SCENARIO-EMAIL-SERVICENOW](./setup-internal-skills/SCENARIO-EMAIL-SERVICENOW.md)) |

**Plan:** [plan-it](./plan-it/SKILL.md) — **always grills** (ad-hoc or `--from-issues`); intake evaluation built-in for unclear items.

## Doc Cycle

Pipeline for plan-it–driven work:

- **[plan-it](./plan-it/SKILL.md)** — Always grills; scaffold phases, ADRs, `--from-issues`, optional `--jira` → `jira.md`.
- **[implement-it](./implement-it/SKILL.md)** — TDD implementation with repo standards and spec-bound scope. Transitions Jira to "In Progress" on start.
- **[audit-it](./audit-it/SKILL.md)** — Independent phase auditor (spec, standards, compliance, architecture). Single-phase mode (`--phase phase-N`) for early feedback. Repo reviews write `docs/AUDIT.md`. Gates verify-it.
- **[verify-it](./verify-it/SKILL.md)** — After audit passes, finalize ADRs, CONTEXT.md, changelog, and planning cleanup. Incremental close (`--phase phase-N`) for per-phase Jira resolution and CONTEXT updates.
- **[commit-it](./commit-it/SKILL.md)** — After verify, stage changes, auto-draft commit message from changelog, and commit locally. Push only after user approval.

## Codebase reference

Run when onboarding or before large work on an unfamiliar repo (not part of the Doc Cycle):

- **[doc-it](./doc-it/SKILL.md)** — Phase 1: `docs/reference/` (maps, entry points, test landscape). Phase 2: `docs/reference-audit/` (`tech-debt.md`, `testing.md`, `architecture.md`, `follow-ups.md`). Optional intake from audit via [audit-to-issues](./setup-internal-skills/audit-to-issues.md); then `/plan-it` or `/improve-codebase-architecture`.

## Jira bridge

One-way bridges between local artifacts and Jira:

| Skill | Direction | Role |
|-------|-----------|------|
| [to-jira](./to-jira/SKILL.md) | Local → Jira | Ad-hoc Jira handler and bridge reference: create, transition, resolve, comment, assign. Other skills source the connector bridge directly rather than delegating here. |
| [from-jira](./from-jira/SKILL.md) | Jira → Local | Create a Doc Cycle plan from a Jira issue — no inbox step |

For per-phase Jira Task creation, use `/plan-it --jira` instead.

## Other engineering skills

- **[diagnose](./diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions.
- **[grill-with-docs](./grill-with-docs/SKILL.md)** — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `CONTEXT.md` and ADRs inline.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)** — Find deepening opportunities; optional intake via [audit-to-issues](./setup-internal-skills/audit-to-issues.md).
- **[internal-compliance](./internal-compliance/SKILL.md)** — Pre-flight compliance check against internal security linting rules before finalizing any PR.
- **[prototype](./prototype/SKILL.md)** — Build a throwaway prototype to flesh out a design.
- **[setup-internal-skills](./setup-internal-skills/SKILL.md)** — Scaffold `AGENTS.md`, `docs/agents/`, and optional OpenCode/Copilot/Cursor config. **Default:** local issues in `docs/issues/`. Jira setup seeds `docs/agents/issue-tracker.md` only; canonical docs (jira-notifications.md, jira-description-style.md, jira-helpers.sh, triage-labels.md, domain.md) are read from `~/.agents/skills/setup-internal-skills/`.
- **[tdd](./tdd/SKILL.md)** — Test-driven development with red-green-refactor loop.
- **[zoom-out](./zoom-out/SKILL.md)** — Get broader context on unfamiliar code.
