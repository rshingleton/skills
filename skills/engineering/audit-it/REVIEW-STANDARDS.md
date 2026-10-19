# Review Standards

Baseline standards the Standards axis of `code-review` checks during `/audit-it`, alongside the repo's documented standards and `.compliance-rules/coding-standards*.md`. A documented repo standard overrides this file. Skip anything tooling already enforces.

Rules marked *mechanical* could be a lint rule or hook; list a violation of one under "Guardrail candidates" in the audit report. The rest are judgement calls.

## Fit

**Match the repo.** The diff matches the surrounding code's naming, imports, layout, error-handling patterns, and comment density.

**Minimal surface.** The smallest change that satisfies the phase's tests. No speculative features or "while I'm here" cleanup.

**Comments.** Comments explain a non-obvious *why*, not an obvious *what*.

**Dependencies** (*mechanical*). If manifests change: no `"*"` or unbounded `>=` ranges; no unofficial registries; cross-check `.dependency-audit.json` when it exists.

## Design

**Module depth.** Each new module earns its keep: imagine deleting it. If behaviour vanishes, the module is a pass-through (shallow). If behaviour redistributes across N callers, it earns its depth.

**Seam discipline.** Every interface has at least two adapters (production and test). A seam with one adapter is speculative indirection.

**Test surface.** Tests exercise the module through its public interface. If a test must know internals to set up or assert, the interface is wrong.

**Recorded shortcuts.** A `shortcut: <the limit>, <when to upgrade>` comment that names its limit is a recorded decision, not a finding, here and in audit-it's own Architecture checks. Flag it only when the load the plan, ADR, or code states already crosses that limit, and cite where. A marker with no upgrade trigger is not a finding either; `/verify-it` routes it to the inbox.

## File hygiene (*mechanical*)

Unless the repo's lint config overrides:

- UTF-8; LF line endings (see `.gitattributes`)
- `.sh` executable; other files not accidentally `+x`
- Copyright header on new files when siblings in that directory have one
- About 120 characters per line of code unless config says otherwise
