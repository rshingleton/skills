# Coding Standards & Style — Repo Overrides

**Baseline:** `implement-it/STANDARDS.md` defines language-agnostic standards (spec-bound, minimal surface, seam discipline, file hygiene, etc.). This file provides repo-specific overrides and points to language-specific extensions.

## How layers stack

1. `implement-it/STANDARDS.md` — generic standards (always apply first)
2. `coding-standards.md` — this file, repo-wide overrides (applied next)
3. `coding-standards-<lang>.md` — per-language rules (applied last, highest priority)

If this file is empty for a given rule, the baseline from STANDARDS.md stands.

## Repo-wide overrides

This repo (ai-skills) is a Markdown + Bash monorepo of composable AI agent skill definitions.

### File structure

- Every shipped skill lives under `skills/<bucket>/<name>/SKILL.md`
- Bucket README.md at `skills/<bucket>/README.md` lists all skills in that bucket
- Bundled resources (scripts, templates, reference files) live alongside SKILL.md in the same directory
- Top-level script files go under `scripts/`

### Frontmatter

Every SKILL.md must have YAML frontmatter:
- `name:` — lowercase kebab-case, matches parent directory name
- `description:` — single paragraph, starts with "Use when..."

### Line length

- Code blocks in SKILL.md: 100 characters max (tighter than baseline 120)
- Prose: 72 characters (matches baseline)
- Shell scripts (.sh): follow ShellCheck conventions, 100 chars max

### Secrets baseline

`.secrets.baseline` — if present, compare new diffs against it. Never commit new secrets.

### Copyright header

Required on all new `.sh` files. Optional on `.md` files unless siblings in same directory have one.
