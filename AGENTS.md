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

Internal **ai-skills** monorepo — composable `SKILL.md` workflows for planning, implementation, audit, verify, and baseline codebase reference (`/doc-it`).

**Repository:** `https://github.com/rshingleton/skills.git` (default branch `main`)

Install into a machine (VPN or on-site):

```bash
bash <(curl -fsSL 'https://raw.githubusercontent.com/rshingleton/skills/main/scripts/skills.sh')
```

Or use [scripts/skills.sh](scripts/skills.sh) / [scripts/link-skills.sh](scripts/link-skills.sh) from a clone. Then run `/setup-internal-skills` **in each application repo**.

## Skill buckets

Under `skills/`:

| Bucket | Use |
|--------|-----|
| `engineering/` | Daily code work — shipped in README + plugin |
| `productivity/` | Non-code workflow |
| `in-progress/` | Draft skills (e.g. `review`) — not in README or plugin |
| `personal/`, `deprecated/` | **Not** in top-level README or `.claude-plugin/plugin.json` |

## Maintaining this monorepo

1. Every shipped skill in `engineering/` or `productivity/` needs:
   - A linked entry in the top-level [README.md](README.md)
   - An entry in [.claude-plugin/plugin.json](.claude-plugin/plugin.json)
2. Each bucket has a [README.md](skills/engineering/README.md) listing its skills (name → `SKILL.md`).
3. Domain language for cross-skill terms: [CONTEXT.md](CONTEXT.md).
4. When adding skills, follow [write-a-skill](skills/productivity/write-a-skill/SKILL.md).

## Consumer projects (your app repos)

After installing skills, run **`/setup-internal-skills`** once per repo. It writes:

- `AGENTS.md` — `## Agent skills` block (issue tracker, triage, domain docs)
- `docs/agents/*.md` — machine-readable config skills read at runtime
- `docs/issues/` — **inbox only** (unplanned intake; moved to `docs/planning/<id>/sources/` at `--from-issues`)
- `docs/planning/<id>/` — phases, ADRs, `sources/`
- `docs/planning/<id>/jira.md` — phase ↔ Jira keys when published

On **existing repos**, setup audits Copilot and Cursor files (see `PLATFORM-AUDIT.md` in the setup skill): patches `.github/copilot-instructions.md` in place, lists `.cursor/rules/` without requiring new Cursor config.

**Intake:** `/issues-it` (capture) · `/triage` (groom/create, local or Jira) · audit skills → [audit-to-issues.md](skills/engineering/setup-internal-skills/audit-to-issues.md).

**Plan:** `/plan-it` (ad-hoc or `--from-issues`) — **always grills** before scaffold; optional triage pre-work does not replace the grill.

**Doc Cycle:** `/plan-it` → `/implement-it` (each phase) → `/audit-it` (once) → `/verify-it` (once: ADR, CONTEXT, changelog, sources).

**Codebase reference:** `/doc-it` → `docs/reference/` + `docs/reference-audit/`. Optional inbox from follow-ups via audit-to-issues.

**Jira (optional):** `/plan-it --jira` → `jira.md` (phase Tasks, timetracking, Epic link). Re-sync: `/plan-it <id> --jira --sync-only`.

**Jira credentials:** `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` via shell export or `.env` ([.env.example](.env.example), [load-jira-env.sh](scripts/load-jira-env.sh)). Optional `JIRA_DEFAULT_EPIC`, `JIRA_ASSIGNEE`, `JIRA_DEFAULT_ESTIMATE_HOURS`, `JIRA_WATCHER_IGNORE` (remove watchers), `JIRA_WATCHER_USERNAME` (add watchers on create), or `JIRA_EMAIL` (PAT self-unwatch fallback). Default Epic resolution: [issue-tracker-jira.md](skills/engineering/setup-internal-skills/issue-tracker-jira.md#default-epic-optional). Writes use `notifyUsers=false` per [jira-notifications.md](skills/engineering/setup-internal-skills/jira-notifications.md). Jira creates use [jira-description-style.md](skills/engineering/setup-internal-skills/jira-description-style.md) (**wiki markup** `h2.` / `*` bullets — not markdown `##` / `- [ ]`). Re-sync keys: `/plan-it <id> --jira --sync-only` → [jira-epic-sync.md](skills/engineering/setup-internal-skills/jira-epic-sync.md). Project repo `.env` wins over user-wide files when sourced from that repo.

## Scripts

| Script | Role |
|--------|------|
| [scripts/skills.sh](scripts/skills.sh) | Clone to `~/.local/share/ai-skills`, link to `~/.agents/skills` (curl one-liner in README) |
| [setup-internal-skills/scripts/load-jira-env.sh](skills/engineering/setup-internal-skills/scripts/load-jira-env.sh) | Load Jira vars from `.env` (canonical; [scripts/load-jira-env.sh](scripts/load-jira-env.sh) is a shim) |
| [scripts/cleanup-legacy-skills.sh](scripts/cleanup-legacy-skills.sh) | Remove Matt Pocock / pre-`-it` skill folders from `~/.agents/skills` |
| [scripts/link-skills.sh](scripts/link-skills.sh) | Link from this repo without clone |

## What not to do

- Do not duplicate skill bodies into `AGENTS.md` — skills stay in `skills/**/SKILL.md`.
- Do not list `personal/`, `in-progress/`, or `deprecated/` skills in README or plugin.json.
- Prefer editing **AGENTS.md** over forking rules into each tool; update tool stubs when conventions change.
