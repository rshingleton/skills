# Agent platforms

How to use this skills repo with **Cursor**, **GitHub Copilot**, **Claude Code**, **Gemini**, and optionally **OpenCode**.

## Canonical file: `AGENTS.md`

[AGENTS.md](../AGENTS.md) at the repo root is the **open format** project instructions file (same idea as OpenCode rules and Cursor’s `AGENTS.md` convention). Tool-specific files should **point here**, not duplicate maintenance rules.

In **application repos** (after `/setup-internal-skills`), `AGENTS.md` also holds a `## Agent skills` block linking `docs/agents/issue-tracker.md`, intake status labels, and domain layout.

---

## Cursor

**Verified:** [Cursor Rules docs](https://cursor.com/docs/context/rules) list **AGENTS.md** as a first-class rule type (alongside Project, User, and Team rules). Cursor loads it natively — it is not an unofficial workaround.

1. Install skills to `~/.agents/skills` (scripts above).
2. Put shared, cross-tool instructions in root **`AGENTS.md`** (open standard; also used by OpenCode and Copilot). Cursor reads project-root and **nested** `AGENTS.md` files (subdir instructions merge; nearer files take precedence).
3. **`.cursor/rules/`** is Cursor’s structured alternative (`.md` / `.mdc` with `globs`, `alwaysApply`, `@`-mention). Use it for file-scoped or “apply intelligently” rules — not for duplicating `AGENTS.md` / `docs/agents/` skill config. Official docs describe AGENTS.md as the simple alternative when you do not need that metadata.
4. **Legacy:** `.cursorrules` still works but is deprecated — prefer `AGENTS.md` + `.cursor/rules/`.
5. **Scope:** Project/User/Team rules and AGENTS.md apply to **Agent (Chat)**. They do **not** apply to Cursor Tab or Inline Edit (Cmd/Ctrl+K) per Cursor docs.
6. `/setup-internal-skills` **audits** existing `.github/copilot-instructions.md` and `.cursor/rules/` on mature repos; it ensures `AGENTS.md` + `docs/agents/` exist and avoids redundant Cursor-only copies of the same content.

---

## GitHub Copilot

1. [.github/copilot-instructions.md](../.github/copilot-instructions.md) is Copilot-specific (GitHub loads this path).
2. On existing repos, `/setup-internal-skills` **reads** that file and appends a short pointer to `AGENTS.md` + `docs/agents/` if missing — it does not replace your Copilot instructions.
3. Keep Copilot file short; full conventions live in `AGENTS.md`.
4. Copilot does not load `SKILL.md` automatically — reference skill names in chat or use org Copilot skill integration when available.

---

## Claude Code

1. [CLAUDE.md](../CLAUDE.md) points at `AGENTS.md`.
2. [.claude-plugin/plugin.json](../.claude-plugin/plugin.json) lists skill paths for the plugin marketplace / project skills.
3. Legacy workflows that only read `CLAUDE.md` still work via the pointer.

---

---

## Gemini / agy (antigravity)

Gemini loads **`AGENTS.md`** natively as project instructions — no tool-specific config file required. The shared open standard works out of the box.

Gemini is migrating to the **`agy`** (antigravity) CLI. Both use the same `AGENTS.md` standard; no config change needed during migration.

---

## OpenCode (optional)

OpenCode is supported but not required. If using OpenCode:

1. Install skills: `bash scripts/link-skills.sh` from this repo (or `scripts/skills.sh`).
2. Commit [opencode.json](../opencode.json) or merge `instructions` into your global config.
3. OpenCode loads `AGENTS.md` automatically; `CLAUDE.md` is a fallback only if `AGENTS.md` is missing.

Optional global rules: `~/.config/opencode/AGENTS.md` for personal prefs (not committed).

Skills path: `~/.agents/skills/` (same as this repo's linker). See [OpenCode Agent Skills](https://open-code.ai/en/docs/skills).

---

## Per-project setup (all platforms)

Run once per application repository:

```text
/setup-internal-skills
```

Then use engineering skills (`/plan-it`, `/implement-it`, `/audit-it`, `/verify-it`, `/commit-it`, …). Intake: `docs/issues/`; Jira map: `docs/planning/<id>/jira.md` via `/plan-it --jira`.

**Unfamiliar codebase:** run `/doc-it` to create `docs/reference/` and `docs/reference-audit/` before heavy feature work.

**Jira API skills:** set `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` via [`.env.example`](../.env.example) and [scripts/load-jira-env.sh](../scripts/load-jira-env.sh) (project `.env` takes precedence when sourced from the app repo). Optional `JIRA_DEFAULT_EPIC`, `JIRA_ASSIGNEE`, or `default_epic` in `docs/agents/issue-tracker.md` ([default Epic](../skills/engineering/setup-internal-skills/issue-tracker-jira.md#default-epic-optional)). Descriptions: [wiki markup](../skills/engineering/setup-internal-skills/jira-description-style.md) on create. Re-sync keys: `/plan-it <id> --jira --sync-only`. Watcher policy: [jira-notifications.md](../skills/engineering/setup-internal-skills/jira-notifications.md).

---

## Recommended layout (application repo)

```text
AGENTS.md                 # Human + agent entry (## Agent skills block)
docs/agents/              # issue-tracker, jira-notifications, jira-description-style (Jira), triage-labels, domain, compliance
docs/issues/              # pre-plan intake (default)
docs/planning/<id>/jira.md  # phase ↔ Jira (optional)
docs/planning/            # Doc Cycle plans
docs/reference/           # baseline maps (/doc-it Phase 1)
docs/reference-audit/     # sliced review (/doc-it Phase 2)
CONTEXT.md
docs/adr/
.cursor/rules/            # optional extras; Cursor still uses AGENTS.md
.github/copilot-instructions.md   # Copilot-only; setup patches if present
opencode.json             # optional — only needed for OpenCode users
```

Seed template for new app repos: [skills/engineering/setup-internal-skills/templates/AGENTS.md](../skills/engineering/setup-internal-skills/templates/AGENTS.md).
