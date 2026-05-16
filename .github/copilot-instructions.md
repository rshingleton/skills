# Copilot instructions

**Canonical instructions:** [AGENTS.md](../AGENTS.md)  
**Platforms:** [docs/AGENT-PLATFORMS.md](../docs/AGENT-PLATFORMS.md)  
**Repository:** [github.com/rshingleton/skills/scm/mt/ai-skills.git](https://github.com/rshingleton/skills.git)

This repo is the **internal ai-skills monorepo**. When editing here:

- Follow `AGENTS.md` for bucket layout and README / plugin.json maintenance rules.
- Skills live under `skills/**/SKILL.md` — do not inline skill bodies into this file.
- Shipped skills must appear in [README.md](../README.md) and [.claude-plugin/plugin.json](../.claude-plugin/plugin.json).

Install skills into `~/.agents/skills` with [scripts/skills.sh](../scripts/skills.sh) or [scripts/link-skills.sh](../scripts/link-skills.sh). In application repos, run `/setup-internal-skills` once.

**Doc Cycle:** `plan-it` → `implement-it` → `audit-it` → `verify-it`.

**Codebase reference:** `doc-it` writes `docs/reference/` and `docs/reference-audit/` (tech debt, testing, architecture, follow-ups).

**Jira:** copy [`.env.example`](../.env.example) to `~/.config/ai-skills/.env` or the app repo `.env`; `source` [load-jira-env.sh](../scripts/load-jira-env.sh) before API calls. Optional `JIRA_EMAIL` / `JIRA_WATCHER_USERNAME` for watcher cleanup; all writes use [jira-notifications.md](../skills/engineering/setup-internal-skills/jira-notifications.md).
