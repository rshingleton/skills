# Platform audit (existing repos)

Run during `/setup-internal-skills` **Explore** and before writing platform files.

## Inventory

Record what exists:

| Path | Present? | Notes |
|------|----------|-------|
| `AGENTS.md` | | Open standard — **always** ensure + update `## Agent skills` |
| `CLAUDE.md` | | Pointer only; do not duplicate rules |
| `opencode.json` | | Merge `instructions` to include `AGENTS.md` |
| `.github/copilot-instructions.md` | | Copilot-specific — **inspect and patch** |
| `.cursor/rules/*.mdc` | | List filenames; Cursor also reads root `AGENTS.md` |
| `.cursorrules` | | Legacy — note; prefer `AGENTS.md` |

## Cursor

**Source:** [cursor.com/docs/context/rules](https://cursor.com/docs/context/rules) — AGENTS.md is a **native** rule type (not legacy). Cursor also supports `.cursor/rules/` (`.md`/`.mdc` with globs / `alwaysApply`) and nested `AGENTS.md` in subdirectories.

**Default for `/setup-internal-skills`:** ensure root **`AGENTS.md`** + `docs/agents/`. Do **not** create `.cursor/rules/agents.mdc` for skill/issue-tracker config — that belongs in `AGENTS.md`.

If `.cursor/rules/` exists:

1. List `.md` / `.mdc` files (note legacy `.cursorrules` if present — recommend migration).
2. Distinguish **file-scoped** rules (globs, framework patterns) from **project-wide** agent/skills instructions.
3. If project-wide rules **duplicate** `## Agent skills` / `docs/agents/` content, recommend consolidating into `AGENTS.md` and trimming the rule.
4. If duplicate overlap exists, offer (with approval) a one-liner in the Cursor rule: `Follow AGENTS.md for agent skills and issue-tracker setup.`
5. **Do not delete** user rules.

**Coexistence is normal:** teams may use `AGENTS.md` for cross-tool conventions and `.cursor/rules/` for Cursor-specific scoping. That is aligned with Cursor’s docs.

**Not covered by rules:** Cursor Tab and Inline Edit (Cmd/Ctrl+K) — only Agent chat loads AGENTS.md / project rules.

## GitHub Copilot

If `.github/copilot-instructions.md` **exists**:

1. Read the full file.
2. Check for links or mentions of `AGENTS.md` and `docs/agents/`.
3. If missing, **append** [copilot-agent-skills-snippet.md](./templates/copilot-agent-skills-snippet.md) (or merge equivalent prose). Preserve all existing content.
4. If it already points at `AGENTS.md`, report "Copilot OK" and make no change unless stale.

If **missing** and the team uses Copilot, offer to create from [copilot-instructions.md](./templates/copilot-instructions.md).

## OpenCode

If `opencode.json` exists, merge `instructions` array to include `"AGENTS.md"` (and `"CONTEXT.md"` if present) without removing other entries.

If missing, offer [templates/opencode.json](./templates/opencode.json).

## Claude Code

If `CLAUDE.md` exists and is more than a short pointer to `AGENTS.md`, warn about duplication.

If missing and user uses Claude, offer a pointer file only:

```markdown
# Claude Code

See [AGENTS.md](./AGENTS.md).
```
