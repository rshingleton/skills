# Platform audit (existing repos)

Run during `/setup-internal-skills` **Explore** and before writing platform files.

## Inventory

Record what exists:

| Path | Present? | Notes |
|------|----------|-------|
| `AGENTS.md` | | Open standard — **always** ensure + update `## Agent skills` |
| `.cursor/rules/*.mdc` | | List filenames; Cursor also reads root `AGENTS.md` |
| `.cursorrules` | | Legacy — note; prefer `AGENTS.md` |
| `.github/copilot-instructions.md` | | Copilot-specific — **inspect and patch** |
| `CLAUDE.md` | | Pointer only; do not duplicate rules |
| `opencode.json` | | Optional — only if team uses OpenCode |
| `Gemini / agy` | | No config file — loads `AGENTS.md` natively. Gemini migrating to `agy` CLI. Skills: workspace `.agents/skills/`, global `~/.gemini/antigravity-cli/skills/`, shared `~/.gemini/skills/` |

## Cursor

**Source:** [cursor.com/docs/context/rules](https://cursor.com/docs/context/rules) — AGENTS.md is a **native** rule type (not legacy). Cursor also supports `.cursor/rules/` (`.md`/`.mdc` with globs / `alwaysApply`) and nested `AGENTS.md` in subdirectories.

**Default for `/setup-internal-skills`:** ensure root **`AGENTS.md`** + `docs/agents/`. Do **not** create `.cursor/rules/agents.mdc` for skill/issue-tracker config — that belongs in `AGENTS.md`.

If `.cursor/rules/` exists:

1. List `.md` / `.mdc` files (note legacy `.cursorrules` if present — recommend migration).
2. Distinguish **file-scoped** rules (globs, framework patterns) from **project-wide** agent/skills instructions.
3. If project-wide rules **duplicate** `## Agent skills` / `docs/agents/` content, recommend consolidating into `AGENTS.md` and trimming the rule.
4. If duplicate overlap exists, offer (with approval) a one-liner in the Cursor rule: `Follow AGENTS.md for agent skills and issue-tracker setup.`
5. **Do not delete** user rules.

**Coexistence is normal:** teams may use `AGENTS.md` for cross-tool conventions and `.cursor/rules/` for Cursor-specific scoping. That is aligned with Cursor's docs.

**Not covered by rules:** Cursor Tab and Inline Edit (Cmd/Ctrl+K) — only Agent chat loads AGENTS.md / project rules.

## GitHub Copilot

If `.github/copilot-instructions.md` **exists**:

1. Read the full file.
2. Check for links or mentions of `AGENTS.md` and `docs/agents/`.
3. If missing, **append** [copilot-agent-skills-snippet.md](./templates/copilot-agent-skills-snippet.md) (or merge equivalent prose). Preserve all existing content.
4. If it already points at `AGENTS.md`, report "Copilot OK" and make no change unless stale.

If **missing** and the team uses Copilot, offer to create from [copilot-instructions.md](./templates/copilot-instructions.md).

## Claude Code

If `CLAUDE.md` exists and is more than a short pointer to `AGENTS.md`, warn about duplication.

If missing and user uses Claude, offer a pointer file only:

```markdown
# Claude Code

See [AGENTS.md](./AGENTS.md).
```

## Gemini / agy (antigravity)

Gemini loads `AGENTS.md` as project instructions natively — no tool-specific config file needed. If the team uses Gemini, ensure the `AGENTS.md` `## Agent skills` block is up to date. No Gemini-specific file to create or patch.

Gemini is migrating to the **`agy`** (antigravity) CLI. Both read `AGENTS.md` the same way; no config change needed.

**agy skill lookup** — workspace always wins:
1. `<project>/.agents/skills/{name}/SKILL.md` — **prefer over all other places**
2. `~/.gemini/antigravity-cli/skills/{name}/SKILL.md` — global fallback
3. `~/.gemini/skills/{name}/SKILL.md` — shared fallback

## OpenCode (optional)

Only configure if the team explicitly uses OpenCode. If `opencode.json` exists and is in use, merge `instructions` array to include `"AGENTS.md"` (and `"CONTEXT.md"` if present) without removing other entries. If missing, skip — no template needed unless team requests it.
