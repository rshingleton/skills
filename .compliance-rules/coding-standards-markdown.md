# Coding Standards — Markdown

Applies to all `.md` files in the repo. Extends `coding-standards.md` and `implement-it/STANDARDS.md`.

## Structure

- `SKILL.md` files must use ATX headings (`##`, `###`) — no Setext headings
- One blank line before and after every heading
- Code fences must specify language: ` ```bash `, ` ```markdown `, ` ```text `
- No trailing spaces on any line

## Lists

- Use `-` for unordered lists (never `*`)
- Indent continuation lines 2 spaces
- Ordered lists only for sequential steps where order matters

## Links

- Relative links to files in the same skill directory: `[display](file.md)`
- Relative links to other skills: `[display](../target-skill/SKILL.md)`
- No bare URLs — always use link syntax

## Prohibited

- Em-dashes (`—`) — use `--` instead
- Emoji unless explicitly requested by the user
- HTML tags inside Markdown (no `<div>`, `<span>`, etc.)
- Inline HTML for formatting — use Markdown syntax only
