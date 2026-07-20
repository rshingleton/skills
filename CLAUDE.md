# Claude Code

**Canonical instructions:** [AGENTS.md](./AGENTS.md)

Claude Code loads this file by convention. Keep it as a pointer so Cursor, Copilot, and OpenCode can share one source of truth.

Skills for Claude Code are symlinked into `~/.claude/skills/` by [scripts/skills.sh](scripts/skills.sh) or [scripts/link-skills.sh](scripts/link-skills.sh) — the installer populates both `~/.agents/skills/` (OpenCode/Cursor) and `~/.claude/skills/` (Claude Code) automatically. Per-project skills can also go in `.claude/skills/`.

The [.claude-plugin/plugin.json](.claude-plugin/plugin.json) is for Claude Code plugins (agents, hooks, MCP), not skills.

Shipped engineering skills include the Doc Cycle (`plan-it`, `implement-it`, `audit-it`, `verify-it`, `commit-it`) and codebase reference (`doc-it`). See [AGENTS.md](AGENTS.md).
