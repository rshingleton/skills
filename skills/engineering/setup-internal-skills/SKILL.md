---
name: setup-internal-skills
description: >
  Scaffold AGENTS.md (open format), docs/agents/, and optional tool configs
  (opencode.json, copilot-instructions, cursor rules) so engineering skills
  know issue tracker (local docs/issues/ by default), triage, and domain docs.
  Run before issues-it, plan-it, implement-it, verify-it, triage, or
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
- **Copilot:** `.github/copilot-instructions.md` (read full file if present)
- **Cursor:** `.cursor/rules/*.mdc`, legacy `.cursorrules` (Cursor also loads root `AGENTS.md` — see [PLATFORM-AUDIT.md](./PLATFORM-AUDIT.md))
- **Claude:** `CLAUDE.md` (pointer only)
- `CONTEXT.md`, `CONTEXT-MAP.md`, `docs/adr/`, `src/*/docs/adr/`
- `docs/agents/` — prior setup output?
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

**Default: Local markdown** — `docs/issues/<feature-slug>/` ([issue-tracker-local.md](./issue-tracker-local.md)).

Choices:

- **Local markdown** (recommended) — `docs/issues/` for intake; `docs/planning/` for plans. `/issues-it` captures intake; `/plan-it --from-issues` + optional `--jira`.
- **Jira** — issues in Jira API ([issue-tracker-jira.md](./issue-tracker-jira.md)). Requires `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` (export or `.env`; see issue-tracker doc).
- **Other** — user describes workflow; record as prose in `issue-tracker.md`.

**Section B — Triage label vocabulary.**

Five canonical roles: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`.

- **Local:** `status` in issue frontmatter + `## Comments`
- **Jira:** status + labels — see `issue-tracker-jira.md`

**Section C — Domain docs.**

Single-context (`CONTEXT.md` + `docs/adr/`) vs multi-context (`CONTEXT-MAP.md`).

**Section D — Compliance policies.**

Paths to `CONTRIBUTING.md`, `SECURITY_POLICY.md`, `.compliance-rules/`.

**Section E — Agent platforms.**

> **AGENTS.md** is the open standard (OpenCode, **Cursor**, Copilot, Claude). Tool-specific files are audited, not blindly overwritten. Follow [PLATFORM-AUDIT.md](./PLATFORM-AUDIT.md).

Report the inventory table from PLATFORM-AUDIT (what exists, what will change).

**Always:** create or update `AGENTS.md` + `docs/agents/` (merge `## Agent skills` block from [templates/AGENTS.md](./templates/AGENTS.md)).

**Cursor (existing repos):**

- Cursor **natively** loads **`AGENTS.md`** ([Cursor rules docs](https://cursor.com/docs/context/rules)) — ensure root file + `## Agent skills` block; nested `AGENTS.md` optional for subdirs.
- `.cursor/rules/` is optional (globs / `alwaysApply`); audit for duplicate skill config, do not auto-create `agents.mdc`.
- See [PLATFORM-AUDIT.md](./PLATFORM-AUDIT.md) for full Cursor audit steps.

**Copilot (existing repos):**

- If `.github/copilot-instructions.md` **exists:** read it; if it does not reference `AGENTS.md` / `docs/agents/`, **append** [templates/copilot-agent-skills-snippet.md](./templates/copilot-agent-skills-snippet.md) — preserve existing content.
- If **missing:** offer [templates/copilot-instructions.md](./templates/copilot-instructions.md).

**OpenCode:** merge `opencode.json` `instructions` to include `AGENTS.md`, or offer [templates/opencode.json](./templates/opencode.json) if absent.

**Claude:** pointer-only `CLAUDE.md` if missing and user wants it — never duplicate `AGENTS.md` body.

### 3. Confirm default branch

Expect `main`; note if remote differs.

### 4. Confirm and edit

Draft for user review:

- `AGENTS.md` with `## Agent skills` block
- `docs/agents/issue-tracker.md`, `triage-labels.md`, `domain.md`, optional `compliance.md`
- Optional platform files from Section E

### 5. Write

**AGENTS.md:** Create from [templates/AGENTS.md](./templates/AGENTS.md) if missing; otherwise update the `## Agent skills` block in place.

**Agent skills block (local default):**

```markdown
## Agent skills

### Issue tracker

Intake under `docs/issues/`. Plans under `docs/planning/`. Jira: `/plan-it --jira` → `jira.md`.

### Triage labels

Five canonical roles. See `docs/agents/triage-labels.md`.

### Domain docs

[single-context | multi-context]. See `docs/agents/domain.md`.
```

For **Jira** tracker, say "Jira REST API"; plans use `docs/planning/<id>/jira.md` via `/plan-it --jira`.

Seed files:

- Local → copy [issue-tracker-local.md](./issue-tracker-local.md) to `docs/agents/issue-tracker.md`
- Jira → copy [issue-tracker-jira.md](./issue-tracker-jira.md) to `docs/agents/issue-tracker.md`, [jira-notifications.md](./jira-notifications.md) to `docs/agents/jira-notifications.md`, and [jira-description-style.md](./jira-description-style.md) to `docs/agents/jira-description-style.md`. Point users at [scripts/load-jira-env.sh](./scripts/load-jira-env.sh) (or repo `scripts/load-jira-env.sh` shim) for credentials.
- [triage-labels.md](./triage-labels.md), [domain.md](./domain.md)

When choosing local, create `docs/issues/` if missing and seed [docs-issues-README.md](./docs-issues-README.md) as `docs/issues/README.md`.

**Platform audit:** Apply [PLATFORM-AUDIT.md](./PLATFORM-AUDIT.md) — patch Copilot in place, merge OpenCode config, report Cursor rules without creating redundant `.mdc` files unless requested.

### 6. Done

Tell the user setup is complete.

**Local default:**

> Intake goes in `docs/issues/` (`/issues-it`). Plans in `docs/planning/` (`/plan-it`). Jira map in `jira.md` (`/plan-it --jira`).
>
> Doc Cycle: `/plan-it` → `/implement-it` (each phase) → `/audit-it` → `/verify-it`.
>
> Unfamiliar codebase: `/doc-it` → `docs/reference/` + `docs/reference-audit/`.

**If Jira chosen:** remind them to set `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` (shell export or `.env` per [issue-tracker-jira.md](./issue-tracker-jira.md#loading-credentials)), plus optional `JIRA_DEFAULT_EPIC`, `JIRA_ASSIGNEE`, or `default_epic` in `docs/agents/issue-tracker.md`, and optional watcher env vars ([jira-notifications.md](./jira-notifications.md)).

They can edit `docs/agents/*.md` and `AGENTS.md` later; re-run setup to switch trackers.

Mention [AGENT-PLATFORMS.md](../../../docs/AGENT-PLATFORMS.md) in this skills repo for OpenCode / Cursor / Copilot / Claude setup.
