---
name: setup-internal-skills
description: >
  Scaffold AGENTS.md (open format), docs/agents/, and optional tool configs
  (opencode.json, copilot-instructions, cursor rules) so engineering skills
  know issue tracker (local docs/issues/ by default), triage, and domain docs.
  Run before issue-it, plan-it, implement-it, verify-it, or
  when issue-tracker context is missing.
disable-model-invocation: true
---

# Setup Internal Skills

Scaffold per-repo configuration the engineering skills assume:

- **Issue tracker** — intake in `docs/issues/` (default); Jira via `docs/planning/<id>/jira.md` when opted in
- **Triage labels** — canonical triage role strings
- **Domain docs** — `CONTEXT.md`, ADRs, consumer rules
- **Compliance policies** — paths for `/internal-compliance`

Prompt-driven skill. Explore, confirm with the user, then write.

## Process

### 1. Explore

Read whatever exists; don't assume:

- `git remote -v` — for **this skills repo**, expect `https://github.com/rshingleton/skills.git`; for app repos, verify `github.com/rshingleton/skills` when applicable
- **Open standard:** `AGENTS.md`, `opencode.json`
- **Cursor:** `.cursor/rules/*.mdc`, legacy `.cursorrules` (Cursor also loads root `AGENTS.md` — see [PLATFORM-AUDIT.md](./PLATFORM-AUDIT.md))
- **Copilot:** `.github/copilot-instructions.md` (read full file if present)
- **Claude:** `CLAUDE.md` (pointer only — see PLATFORM-AUDIT.md). Skills: `~/.claude/skills/` (global) or `.claude/skills/` (per-project). Skills installed via `scripts/skills.sh` or `scripts/link-skills.sh` now populate both `~/.agents/skills/` and `~/.claude/skills/`
- **Gemini / agy:** no config file needed — loads `AGENTS.md` natively. Gemini migrating to `agy` CLI. Skills: `<project>/.agents/skills/` (workspace, preferred for agy — other tools use `~/.agents/skills/` instead), `~/.gemini/antigravity-cli/skills/`, `~/.gemini/skills/`
- `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `src/*/docs/adr/`
- `docs/agents/issue-tracker.md` — prior setup output? (only file written here)
- `docs/issues/` — local issue tracker in use
- `.scratch/` — legacy local tracker (migrate to `docs/issues/`)
- `docs/planning/` — Doc Cycle plans
- `CONTRIBUTING.md`, `SECURITY_POLICY.md`, `.compliance-rules/`
- Default branch — expect `main` (override if your team uses another)
- `JIRA_*` env vars — only required if user chooses Jira or uses `/plan-it --jira`

### 2. Present findings and ask

Summarise present vs missing. Walk **one section at a time** with explainer + default.

**Section A — Issue tracker.**

> Where issues live. Skills read/write via `docs/agents/issue-tracker.md`. Local tracking keeps planning and slices in-repo until you explicitly push to Jira.

**Default: Local markdown** — inbox `docs/issues/*.md`; plans under `docs/planning/` ([issue-tracker-local.md](./issue-tracker-local.md)).

Choices:

- **Local markdown** (recommended) — `docs/issues/` for intake; `docs/planning/` for plans. `/issue-it` captures intake; `/plan-it --from-issues` + optional `--jira`.
- **Jira** — issues in Jira API ([issue-tracker-jira.md](./issue-tracker-jira.md)). Requires `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` (export or `.env`; see issue-tracker doc).
- **Other** — user describes workflow; record as prose in `issue-tracker.md`.

**Section B — Triage state machine.**

Three states: `intake` → `ready-for-plan` → `wontfix`.

- **Local:** `status` in issue frontmatter + `## Comments`
- **Jira:** status + labels — see `issue-tracker-jira.md`

**Section C — Domain docs.**

Single-context (`CONTEXT.md` + `docs/adr/`) vs multi-context (`CONTEXT-MAP.md`).

**Section D — Compliance policies.**

Paths to `CONTRIBUTING.md`, `SECURITY_POLICY.md`, `.compliance-rules/`.

**Section E — Agent platforms.**

> **AGENTS.md** is the open standard (**Cursor**, **Copilot**, Claude, Gemini/agy, OpenCode). Tool-specific files are audited, not blindly overwritten. Follow [PLATFORM-AUDIT.md](./PLATFORM-AUDIT.md).

Report the inventory table from PLATFORM-AUDIT (what exists, what will change).

**Always:** create or update `AGENTS.md` + write `docs/agents/issue-tracker.md` (merge `## Agent skills` block from [templates/AGENTS.md](./templates/AGENTS.md)).

**Cursor (existing repos):**

- Cursor **natively** loads **`AGENTS.md`** ([Cursor rules docs](https://cursor.com/docs/context/rules)) — ensure root file + `## Agent skills` block; nested `AGENTS.md` optional for subdirs.
- `.cursor/rules/` is optional (globs / `alwaysApply`); audit for duplicate skill config, do not auto-create `agents.mdc`.
- See [PLATFORM-AUDIT.md](./PLATFORM-AUDIT.md) for full Cursor audit steps.

**Copilot (existing repos):**

- If `.github/copilot-instructions.md` **exists:** read it; if it does not reference `AGENTS.md` / `docs/agents/`, **append** [templates/copilot-agent-skills-snippet.md](./templates/copilot-agent-skills-snippet.md) — preserve existing content.
- If **missing:** offer [templates/copilot-instructions.md](./templates/copilot-instructions.md).

**OpenCode (optional):** if `opencode.json` exists and the team uses OpenCode, merge `instructions` to include `AGENTS.md`. Otherwise skip.

**Claude:** pointer-only `CLAUDE.md` if missing and user wants it — never duplicate `AGENTS.md` body. Skills installed via `scripts/skills.sh` or `scripts/link-skills.sh` live in both `~/.agents/skills/` and `~/.claude/skills/` — the installer handles this automatically.

**Gemini / agy:** no tool-specific file needed — `AGENTS.md` is read natively. Gemini migrating to `agy` (antigravity) CLI. Skills: workspace `<project>/.agents/skills/` (agy-preferred — distinct from other tools' `~/.agents/skills/`), `~/.gemini/antigravity-cli/skills/`, `~/.gemini/skills/`. Ensure `## Agent skills` block is present.

### 3. Confirm default branch

Expect `main`; note if remote differs.

### 4. Confirm and edit

Draft for user review:

- `AGENTS.md` with `## Agent skills` block
- `docs/agents/issue-tracker.md` (per-repo tracker config — only file written to `docs/agents/`)
- Optional `docs/agents/compliance.md`
- Optional platform files from Section E

### 5. Migrate from old layout (re-run only)

When re-running on a repo with a prior setup, migrate files and update references:

**Step A — Validate AGENTS.md references (always).** Scan `AGENTS.md` for old paths:
- `docs/agents/triage-labels.md` → `~/.agents/skills/setup-internal-skills/triage-labels.md`
- `docs/agents/domain.md` → `~/.agents/skills/setup-internal-skills/domain.md`

Report any stale entries found and update them. If none, skip.

**Step B — Clean up stale docs/agents/ files.** Check for:
`docs/agents/triage-labels.md`, `docs/agents/domain.md`, `docs/agents/jira-helpers.sh`, `docs/agents/jira-notifications.md`, `docs/agents/jira-description-style.md`.

**If any exist:** present the list and ask:
> Found {N} file(s) from a previous setup that are now read from the installed skill path. Remove them? (Y/n)

If yes, delete the files.

### 6. Write

**AGENTS.md:** Create from [templates/AGENTS.md](./templates/AGENTS.md) if missing; otherwise update the `## Agent skills` block in place.

**Agent skills block (local default):**

```markdown
## Agent skills

### Issue tracker

Intake: `docs/issues/` (`/issue-it`). Plans: `docs/planning/` (`/plan-it` evaluates + grills; `--from-issues` → `sources/`). Phase Jira: `/plan-it --jira` → `jira.md` only (`--parent` overrides `JIRA_DEFAULT_EPIC`).

### Triage labels

Three states: `intake` → `ready-for-plan` → `wontfix`. See `~/.agents/skills/setup-internal-skills/triage-labels.md` (or `~/.claude/skills/setup-internal-skills/triage-labels.md` for Claude Code).

### Domain docs

[single-context | multi-context]. See `~/.agents/skills/setup-internal-skills/domain.md` (or `~/.claude/skills/setup-internal-skills/domain.md` for Claude Code).
```

For **Jira** tracker, say "Jira REST API"; plans use `docs/planning/<id>/jira.md` via `/plan-it --jira`.

Seed files (per-repo config only — canonical docs reference installed skill path):

- Local → copy [issue-tracker-local.md](./issue-tracker-local.md) to `docs/agents/issue-tracker.md`
- Jira → copy [issue-tracker-jira.md](./issue-tracker-jira.md) to `docs/agents/issue-tracker.md`. Point users at `~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh` for credentials + helpers.

Do **not** copy `triage-labels.md`, `domain.md`, `jira-helpers.sh`, `jira-notifications.md`, or `jira-description-style.md` to `docs/agents/`. Skills read these directly from the installed skills path (`~/.agents/skills/setup-internal-skills/` or `~/.claude/skills/setup-internal-skills/` for Claude Code). When Jira is the tracker, add this note to `docs/agents/issue-tracker.md`:

```
Canonical docs: `~/.agents/skills/setup-internal-skills/` or `~/.claude/skills/setup-internal-skills/` (jira-helpers.sh, jira-notifications.md, jira-description-style.md, triage-labels.md, domain.md)
```

When choosing local, create `docs/issues/` if missing and seed [docs-issues-README.md](./docs-issues-README.md) as `docs/issues/README.md`.

**Platform audit:** Apply [PLATFORM-AUDIT.md](./PLATFORM-AUDIT.md) — patch Copilot in place, ensure `AGENTS.md` works for Cursor, report `.cursor/rules/` without creating redundant `.mdc` files unless requested. OpenCode is optional — only merge config if the team uses it.

### 7. Done

Tell the user setup is complete.

**Local default:**

> Intake: `docs/issues/` (`/issue-it`). Plan: `/plan-it` (always grills; `--from-issues` evaluates intake). Phase Jira: `/plan-it --jira` → `jira.md`.
>
> Doc Cycle: `/plan-it` → `/implement-it` → `/audit-it` → `/verify-it`.
>
> Email/ServiceNow: [SCENARIO-EMAIL-SERVICENOW.md](./SCENARIO-EMAIL-SERVICENOW.md). Unfamiliar codebase: `/doc-it`.

**If Jira chosen:** remind them to set `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` (shell export or `.env` per [issue-tracker-jira.md](./issue-tracker-jira.md#loading-credentials)), plus optional `JIRA_DEFAULT_EPIC`, `JIRA_ASSIGNEE`, `JIRA_DEFAULT_ESTIMATE_HOURS`, or `default_epic` in `docs/agents/issue-tracker.md`, and optional watcher env vars (`~/.agents/skills/setup-internal-skills/jira-notifications.md` or `~/.claude/skills/setup-internal-skills/jira-notifications.md` for Claude Code).

They can edit `docs/agents/issue-tracker.md` and `AGENTS.md` later; re-run setup to switch trackers.

Mention [AGENT-PLATFORMS.md](../../../docs/AGENT-PLATFORMS.md) in this skills repo for platform-specific setup (Cursor, Copilot, Claude, optional OpenCode).
