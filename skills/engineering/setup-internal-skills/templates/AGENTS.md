# Agent instructions

Tool-neutral project instructions. Supported hosts: OpenCode, Cursor, GitHub Copilot, Claude Code.

See `docs/agents/` for machine-readable skill configuration (issue tracker, triage, domain docs).

## Agent skills

<!-- Populated by /setup-internal-skills -->

### Issue tracker

Local markdown under `docs/issues/`. See `docs/agents/issue-tracker.md`. Promote to Jira with `/promote-to-jira`.

### Triage labels

Five canonical roles. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context. See `docs/agents/domain.md`.

## Doc Cycle

`/plan-it` → `/implement-it` (each phase) → `/audit-it` → `/verify-it`.

## Codebase reference

`/doc-it` — `docs/reference/` (as-is maps) and `docs/reference-audit/` (tech debt, testing, architecture, follow-ups). Use when onboarding or the repo is unfamiliar. Not a substitute for the Doc Cycle after a feature ships.
