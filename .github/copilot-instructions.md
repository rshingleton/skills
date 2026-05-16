# Copilot instructions

**Canonical instructions:** [AGENTS.md](../AGENTS.md)  
**Platforms:** [docs/AGENT-PLATFORMS.md](../docs/AGENT-PLATFORMS.md)  
**Repository:** [github.com/rshingleton/skills/scm/mt/ai-skills.git](https://github.com/rshingleton/skills.git)

This repo is the **internal ai-skills monorepo**. When editing here:

- Follow `AGENTS.md` for bucket layout and README / plugin.json maintenance rules.
- Skills live under `skills/**/SKILL.md` — do not inline skill bodies into this file.
- Shipped skills must appear in [README.md](../README.md) and [.claude-plugin/plugin.json](../.claude-plugin/plugin.json).

Install skills into `~/.agents/skills` with [scripts/link-skills.sh](../scripts/link-skills.sh). In application repos, run `/setup-internal-skills` once, then use Doc Cycle skills (`plan-it`, `implement-it`, `audit-it`, `verify-it`).
