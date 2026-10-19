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

**Reuse before writing.** Take the first rung that fully works:

1. Does it need to exist? Skip options and flexibility nobody asked for, and name them under Skipped in the handoff (§4).
2. Already in this codebase (a helper, service, pattern)? Use it the way the surrounding code does.
3. In the standard library or the platform? Use it, unless the project has its own.
4. In an installed dependency? Use it. Never add a dependency for a few lines.
5. Only then write it: the minimum code that passes the tests.

**Bugs in shared code.** Before editing a function other code calls, grep every caller, then fix the root cause once in the shared code instead of patching each call site.

**Recorded shortcuts.** A shortcut with a known limit gets a comment in this form, in the file's comment syntax:

```text
// shortcut: <the limit>, <when to upgrade>
// shortcut: reads the whole file into memory, stream it once inputs pass 50 MB
```

Name both parts. `/doc-it` collects these markers into its tech-debt ledger, `/verify-it` offers a marker with no upgrade trigger to the inbox, and `/audit-it` treats a marker that names its limit as a recorded decision.

**Secrets.** No hardcoded keys, tokens, or passwords. Do not create or stage `.env` / `.env.*`. No plaintext credentials in connection strings. Never leave credential placeholders in comments (`// TODO: insert API key`).

## 3. Pre-handoff self-check

Before signaling phase complete:

```text
[ ] Every acceptance criterion in ai-prompt.md is met
[ ] No behaviour beyond ai-prompt / linked ADR scope
[ ] Full test suite + lint/format/type-check green
[ ] No secrets, credential comments, or env files in the diff
[ ] Every known-limit shortcut carries `shortcut: <the limit>, <when to upgrade>`
[ ] GLOSSARY.md vocabulary and ADRs respected; conflicts surfaced to user
[ ] execution-notes.md holds the phase's Base ref
```

Fix failures before handoff, then commit the phase (SKILL.md §4). `/audit-it` then reviews the diff against the repo's standards independently; `/verify-it` finalizes docs only on audit PASS. For branch review or org PR gates, use `/code-review` or `/internal-compliance`.

## 4. Handoff message

The `Phase {N} Complete` message (SKILL.md §4 and §5) opens with what happened: the phase, its commit's short hash, and one clause on what it delivers. Before the next step it carries one line:

```text
Skipped: <scope or options left out, or none>. Not checked: <what no test or tool verified, or none>. Risk: <what the user must know, or none>.
```

Its last line says what to do next. Before sending, reread the first and last lines alone: together they must tell the user what happened and what to do.
