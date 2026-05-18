# Agent instructions

Tool-neutral project instructions. Supported hosts: Cursor, GitHub Copilot, Claude Code. OpenCode is also supported.

See `docs/agents/` for machine-readable skill configuration (issue tracker, triage labels, domain docs).

## Agent skills

<!-- Populated by /setup-internal-skills -->

### Issue tracker

Intake: `docs/issues/` (`/issue-it`, [audit-to-issues](../audit-to-issues.md)). Plans: `docs/planning/<id>/` (`/plan-it` always grills; `--from-issues` → `sources/`). Jira map: `jira.md` via `/plan-it --jira`.

### Triage labels

Five canonical roles — `/plan-it --from-issues` evaluates intake items. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context. See `docs/agents/domain.md`.

## Doc Cycle

`/plan-it` → `/implement-it` (each phase) → `/audit-it` → `/verify-it`.

## Codebase reference

`/doc-it` — `docs/reference/` (as-is maps) and `docs/reference-audit/` (tech debt, testing, architecture, follow-ups). Optional: file selected findings in `docs/issues/` ([audit-to-issues.md](../audit-to-issues.md)). Not a substitute for the Doc Cycle after a feature ships.
