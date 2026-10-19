# Standards While Coding

What the implementer does while writing code. Judgement-call standards (matching the repo, module depth, seams, test surface) are enforced at review: `/audit-it` passes [audit-it/REVIEW-STANDARDS.md](../audit-it/REVIEW-STANDARDS.md) and the repo's `.compliance-rules/` to `code-review`. Doc Cycle: `/plan-it` → `/implement-it` (every phase) → `/audit-it` → `/verify-it`.

## 1. Discover standards and tooling (before first edit)

Scan once per phase for how this repo expects code to be written and checked:

| Source | Use for |
|--------|---------|
| `CONTRIBUTING.md`, `CLAUDE.md`, `AGENTS.md` | Process and agent conventions |
| `STYLE.md`, `STANDARDS.md`, `STYLEGUIDE.md` | Explicit style rules |
| `GLOSSARY.md`, `GLOSSARY-MAP.md` | Domain vocabulary in APIs and test names |
| `docs/adr/` (relevant to this area) | Architectural constraints |
| `.editorconfig`, `eslint`/`biome`/`prettier`/`ruff` configs, `package.json` scripts, CI workflow | The test, lint, format, and type-check commands |

**Run** the project's test, lint, and format commands. Do not manually re-check what tooling already enforces. `.compliance-rules/` is checked at audit, not on every step.

## 2. While coding

**Spec-bound.** `ai-prompt.md` is the contract: only what it and linked ADRs require. No scope creep; no drive-by refactors in files outside the phase scope.

**Secrets.** No hardcoded keys, tokens, or passwords. Do not create or stage `.env` / `.env.*`. No plaintext credentials in connection strings. Never leave credential placeholders in comments (`// TODO: insert API key`).

## 3. Pre-handoff self-check

Before signaling phase complete:

```text
[ ] Every acceptance criterion in ai-prompt.md is met
[ ] No behaviour beyond ai-prompt / linked ADR scope
[ ] Full test suite + lint/format/type-check green
[ ] No secrets, credential comments, or env files in the diff
[ ] GLOSSARY.md vocabulary and ADRs respected; conflicts surfaced to user
```

Fix failures before handoff. `/audit-it` then reviews the diff against the repo's standards independently; `/verify-it` finalizes docs only on audit PASS. For branch review or org PR gates, use `/code-review` or `/internal-compliance`.
