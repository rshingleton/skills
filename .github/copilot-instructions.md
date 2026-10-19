# Copilot instructions

**Canonical instructions:** [AGENTS.md](../AGENTS.md)  
**Platforms:** [docs/AGENT-PLATFORMS.md](../docs/AGENT-PLATFORMS.md)  
**Repository:** [github.com/rshingleton/skills](https://github.com/rshingleton/skills.git)

This repo is the **ai-skills monorepo**. When editing here:

- Follow `AGENTS.md` for bucket layout and README / plugin.json maintenance rules, including its **Mirrors and ORG.md** section.
- Skills live under `skills/**/SKILL.md` — do not inline skill bodies into this file.
- Shipped skills must appear in [README.md](../README.md) and [.claude-plugin/plugin.json](../.claude-plugin/plugin.json) (plugin manifest — not skill discovery; skills are consumed via `~/.claude/skills/` or `~/.agents/skills/`).

Install skills into `~/.agents/skills` with [scripts/skills.sh](../scripts/skills.sh) or [scripts/link-skills.sh](../scripts/link-skills.sh). In application repos, run `/setup-internal-skills` once.

**Intake:** `docs/issues/` — `issue-it` (capture or paste email/ServiceNow), or `audit-to-issues`. **Plan:** `plan-it` always grills; `--from-issues` evaluates intake then → `sources/`.

**Doc Cycle:** `plan-it` → `implement-it` → `audit-it` → `verify-it` → `commit-it`. `implement-it {ID}` builds ready phases in parallel worktrees and commits each phase; `commit-it` commits verify-it's docs and pushes only on approval. **Audit modes:** Full (`audit-it`), Per-phase (`--phases`), Single-phase (`--phase phase-N`), Repo audit (`audit-it repo`). **Phase Jira:** `plan-it --jira` → `jira.md` only. `--parent EPIC` overrides `JIRA_DEFAULT_EPIC`. Re-sync: `plan-it <id> --jira --sync-only`.

**Codebase reference:** `doc-it` → `docs/reference/` + `docs/reference-audit/`.

**Jira:** [`.env.example`](../.env.example) + [load-jira-env.sh](../scripts/load-jira-env.sh). Watcher policy: [jira-notifications.md](../skills/engineering/setup-internal-skills/jira-notifications.md). Descriptions: wiki markup per [jira-description-style.md](../skills/engineering/setup-internal-skills/jira-description-style.md). Helpers: [issue-tracker-jira.md](../skills/engineering/setup-internal-skills/issue-tracker-jira.md#helper-functions-copy-into-shell-before-jira-work).
