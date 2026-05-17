# Copilot instructions

Follow [AGENTS.md](../AGENTS.md) and `docs/agents/` for issue tracker, triage labels, and domain conventions.

Intake: `docs/issues/` (`/issue-it`, audit-to-issues). Plan: `/plan-it` (always grills; `--from-issues` evaluates + moves to `sources/`). Doc Cycle: `/plan-it` → `/implement-it` → `/audit-it` → `/verify-it` → `/commit-it`. Phase Jira: `/plan-it --jira` → `jira.md` (`--parent` overrides env Epic). Baseline: `/doc-it`.

Load skill workflows from installed internal skills (`~/.agents/skills/`).
