# Agent instructions

Open, tool-neutral instructions for this repository. **Commit this file.** Point every agent host here.

| Host | Config in this repo |
|------|---------------------|
| **OpenCode** | `opencode.json` → `instructions` |
| **Cursor** | Native **`AGENTS.md`** ([docs](https://cursor.com/docs/context/rules)); optional `.cursor/rules/` for scoped rules |
| **GitHub Copilot** | `.github/copilot-instructions.md` (tool-specific; should link here) |
| **Claude Code** | `CLAUDE.md` (pointer + `.claude-plugin/plugin.json`) |

Platform setup details: [docs/AGENT-PLATFORMS.md](docs/AGENT-PLATFORMS.md).

## Purpose

Internal **ai-skills** monorepo — composable `SKILL.md` workflows for real engineering (planning, implementation, audit, verify).

**Repository:** `https://github.com/rshingleton/skills.git` (default branch `main`)

Install into a machine with [scripts/skills.sh](scripts/skills.sh) or [scripts/link-skills.sh](scripts/link-skills.sh) (symlinks under `~/.agents/skills`). Then run `/setup-internal-skills` **in each application repo**.

## Skill buckets

Under `skills/`:

| Bucket | Use |
|--------|-----|
| `engineering/` | Daily code work — shipped in README + plugin |
| `productivity/` | Non-code workflow |
| `misc/` | Rarely used, still listed |
| `personal/`, `in-progress/`, `deprecated/` | **Not** in top-level README or `.claude-plugin/plugin.json` |

## Maintaining this monorepo

1. Every shipped skill in `engineering/`, `productivity/`, or `misc/` needs:
   - A linked entry in the top-level [README.md](README.md)
   - An entry in [.claude-plugin/plugin.json](.claude-plugin/plugin.json)
2. Each bucket has a [README.md](skills/engineering/README.md) listing its skills (name → `SKILL.md`).
3. Domain language for cross-skill terms: [CONTEXT.md](CONTEXT.md).
4. When adding skills, follow [write-a-skill](skills/productivity/write-a-skill/SKILL.md).

## Consumer projects (your app repos)

After installing skills, run **`/setup-internal-skills`** once per repo. It writes:

- `AGENTS.md` — `## Agent skills` block (issue tracker, triage, domain docs)
- `docs/agents/*.md` — machine-readable config skills read at runtime
- `docs/issues/` — local Epics and tasks (default)

On **existing repos**, setup audits Copilot and Cursor files (see `PLATFORM-AUDIT.md` in the setup skill): patches `.github/copilot-instructions.md` in place, lists `.cursor/rules/` without requiring new Cursor config.

**Doc Cycle:** `/plan-it` → `/implement-it` (each phase) → `/audit-it` → `/verify-it`.

**Jira later:** `/promote-to-jira` after local planning is stable.

## Scripts

| Script | Role |
|--------|------|
| [scripts/skills.sh](scripts/skills.sh) | Clone + link skills to `~/.agents/skills` |
| [scripts/link-skills.sh](scripts/link-skills.sh) | Link from this repo without clone |

## What not to do

- Do not duplicate skill bodies into `AGENTS.md` — skills stay in `skills/**/SKILL.md`.
- Do not list `personal/`, `in-progress/`, or `deprecated/` skills in README or plugin.json.
- Prefer editing **AGENTS.md** over forking rules into each tool; update tool stubs when conventions change.
