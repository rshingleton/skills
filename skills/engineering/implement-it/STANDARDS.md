# Standards & Code Discipline

Apply **while coding** and re-check **before handoff**. PR-level gates remain `/internal-compliance` and `/review`. Doc Cycle: `/plan-it` → `/implement-it` (every phase) → `/audit-it` → `/verify-it`.

## 1. Discover standards (before first edit)

Scan once per phase for how this repo expects code to be written:

| Source | Use for |
|--------|---------|
| `CONTRIBUTING.md`, `CLAUDE.md`, `AGENTS.md` | Process and agent conventions |
| `STYLE.md`, `STANDARDS.md`, `STYLEGUIDE.md` | Explicit style rules |
| `CONTEXT.md`, `CONTEXT-MAP.md` | Domain vocabulary in APIs and test names |
| `docs/adr/` (relevant to this area) | Architectural constraints |
| `.editorconfig`, `eslint`/`biome`/`prettier`/`ruff` configs | Machine-enforced formatting |

Also skim, when present: `SECURITY_POLICY.md`, `.compliance-rules/`, `docs/agents/compliance/`.

**`.compliance-rules/` layering** (if present): `coding-standards.md` defines repo-specific overrides to this file, and `coding-standards-<lang>.md` files add per-language rules. Later files override earlier ones.

**Run** the project's test, lint, and format commands. Do not manually re-check what tooling already enforces.

## 2. While coding

**Spec-bound.** `ai-prompt.md` is the contract — only what it and linked ADRs require. No scope creep; no drive-by refactors in files outside the phase scope.

**Match the repo.** Read surrounding code before editing. Match naming, imports, layout, error-handling patterns, and comment density.

**Minimal surface.** Smallest change that satisfies the current test. No speculative features or "while I'm here" cleanup.

**Comments.** Explain non-obvious *why*, not obvious *what*. Never leave credential placeholders in comments (`// TODO: insert API key`).

**Compliance rules.** If `.compliance-rules/` exists at repo root, read all rule files and apply them **on every TDD cycle** (Red→Green→Refactor). Treat HIGH-severity rules as blocking — fix before proceeding to the next step. Do not defer compliance to handoff.

**Secrets.** No hardcoded keys, tokens, or passwords. Do not create or stage `.env` / `.env.*`. No plaintext credentials in connection strings.

**Dependencies.** If manifests change: no `"*"` or unbounded `>=` ranges; no unofficial registries; cross-check `.dependency-audit.json` when it exists.

**Module depth.** Each new module should earn its keep — imagine deleting it. If behaviour vanishes, the module is a pass-through (shallow). If behaviour redistributes across N callers, it's earning depth.

**Seam discipline.** Every interface needs at least two adapters (production + test). A seam with one adapter is speculative indirection.

**Test surface.** Tests exercise the module through its public interface. If a test must know internals to set up or assert, the interface is wrong.

**File hygiene** (unless repo lint config overrides):

- UTF-8; LF line endings (see `.gitattributes`)
- `.sh` executable; other files not accidentally `+x`
- Copyright header on new files when siblings in that directory have one
- ~120 characters per line of code unless config says otherwise

## 3. Pre-handoff self-check

Before signaling phase complete:

```
[ ] Every acceptance criterion in ai-prompt.md is met
[ ] No behaviour beyond ai-prompt / linked ADR scope
[ ] Full test suite + lint/type-check green
[ ] Diff aligns with standards docs from §1
[ ] No secrets, credential comments, or env files in the diff
[ ] Compliance rules at `.compliance-rules/` (if present) are satisfied
[ ] New dependencies (if any) comply with policy
[ ] CONTEXT.md vocabulary and ADRs respected; conflicts surfaced to user
[ ] Deletion test passed for each new module
[ ] Every new seam has production + test adapters; no speculative single-adapter seams
[ ] Tests exercise modules through their public interface, not internal knowledge
```

Fix failures before handoff. After handoff, `/audit-it` re-audits independently; `/verify-it` finalizes docs only on audit PASS. For branch review or org PR gates, use `/review` or `/internal-compliance`.
