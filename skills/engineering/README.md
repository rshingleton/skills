# Engineering

Skills I use daily for code work.

## Doc Cycle

Pipeline for plan-it–driven work (implement every phase, then audit and verify once):

- **[plan-it](./plan-it/SKILL.md)** — Grill, scaffold phases, ADRs, `--from-issues`, optional `--jira` → `jira.md`.
- **[implement-it](./implement-it/SKILL.md)** — TDD implementation with repo standards and spec-bound scope. Transitions Jira to "In Progress" on start.
- **[audit-it](./audit-it/SKILL.md)** — Independent phase auditor (spec, standards, compliance, architecture). Repo reviews write `docs/AUDIT.md`. Gates verify-it.
- **[verify-it](./verify-it/SKILL.md)** — After plan audit passes, finalize ADRs, CONTEXT.md, changelog, and planning cleanup once (not per issue during implement). Optionally close Jira issues.

## Codebase reference

Run when onboarding or before large work on an unfamiliar repo (not part of the Doc Cycle):

- **[doc-it](./doc-it/SKILL.md)** — Phase 1: `docs/reference/` (maps, entry points, test landscape). Phase 2: `docs/reference-audit/` (`tech-debt.md`, `testing.md`, `architecture.md`, `follow-ups.md`). Hand off to `/issues-it`, `/plan-it`, or `/improve-codebase-architecture`.

## Other engineering skills

- **[diagnose](./diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions.
- **[doc-it](./doc-it/SKILL.md)** — `docs/reference/` then `docs/reference-audit/` (sliced: tech-debt, testing, architecture, follow-ups). Not `/verify-it` or `/zoom-out`.
- **[grill-with-docs](./grill-with-docs/SKILL.md)** — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `CONTEXT.md` and ADRs inline.
- **[improve-codebase-architecture](./improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in a codebase.
- **[internal-compliance](./internal-compliance/SKILL.md)** — Pre-flight compliance check against internal security linting rules before finalizing any PR.
- **[prototype](./prototype/SKILL.md)** — Build a throwaway prototype to flesh out a design.
- **[setup-internal-skills](./setup-internal-skills/SKILL.md)** — Scaffold `AGENTS.md`, `docs/agents/`, and optional OpenCode/Copilot/Cursor config. **Default:** local issues in `docs/issues/`. Jira setup seeds `issue-tracker.md`, [jira-notifications.md](./setup-internal-skills/jira-notifications.md), [jira-description-style.md](./setup-internal-skills/jira-description-style.md).
- **[tdd](./tdd/SKILL.md)** — Test-driven development with red-green-refactor loop.
- **[issues-it](./issues-it/SKILL.md)** — Pre-plan intake (`docs/issues/*.md`): bugs, defers, todos, features.
- **[triage](./triage/SKILL.md)** — Triage issues through a state machine (Jira issue tracker).
- **[zoom-out](./zoom-out/SKILL.md)** — Get broader context on unfamiliar code.
