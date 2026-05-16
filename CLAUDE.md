# Claude Code

**Canonical instructions:** [AGENTS.md](./AGENTS.md)

Claude Code loads this file by convention. Keep it as a pointer so Cursor, Copilot, and OpenCode can share one source of truth.

Skills for Claude Code are registered in [.claude-plugin/plugin.json](.claude-plugin/plugin.json). Install via [scripts/skills.sh](scripts/skills.sh) (curl one-liner in [README.md](README.md)) or [scripts/link-skills.sh](scripts/link-skills.sh).

Shipped engineering skills include the Doc Cycle (`plan-it`, `implement-it`, `audit-it`, `verify-it`) and codebase reference (`doc-it`). See [AGENTS.md](AGENTS.md).
