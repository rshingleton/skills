---
status: Accepted
decision_id: 0006
title: Jira Wiki Conversion — Markdown Patterns & Auto-Enforcement
created: 2026-07-07
accepted: 2026-07-07
---

# ADR 0006: Jira Wiki Conversion — Markdown Patterns & Auto-Enforcement

## Context

The Jira API v2 (wiki markup) accepts `h1.`, `h2.`, `*bold*`, `{{code}}`, and `||table||` format. Our skills create Jira issues from markdown-formatted descriptions (plans, issue bodies, etc.).

**Problem:** `_jira_wiki_body` (in `jira-helpers.sh`) only partially converts markdown (headings, bullets), missing inline code, bold, tables, and code blocks. Worse, `_jira_create_task` does not call it—raw markdown gets POSTed, rendering as literal text in Jira.

## Decision

1. **Expand `_jira_wiki_body`** to convert all common markdown patterns:
   - Headers: `#` → `h1.`, `##` → `h2.`, `###` → `h3.`
   - Inline code: `` `text` `` → `{{text}}`
   - Bold: `**text**` → `*text*`
   - Tables: markdown pipe tables → Jira `||col||` format
   - Code blocks: triple backticks → `{code}...{code}`
   - Bullets: `-` and `*` → `* ` (already working)

2. **Auto-enforce in `_jira_create_task`:**
   - Call `_jira_wiki_body` before POST
   - No caller needs to remember or pre-convert
   - Guarantees all bodies are wiki-formatted

3. **Document the contract:**
   - Update `to-jira/SKILL.md`
   - Inline comments in `jira-helpers.sh`
   - Update `jira-description-style.md`

## Consequences

**Benefits:**
- Jira issues render correctly (bold, code, tables)
- Callers can write plain markdown without extra work
- Single source of truth for conversion logic
- Prevents future markdown-POSTing bugs

**Tradeoffs:**
- Slightly larger `_jira_wiki_body` (regex-heavy)
- If edge cases arise (nested tables, escaped chars), may need refinement
- Installation spreads the fix to consumer repos automatically

## Alternatives considered

- Move conversion to a Python/Go tool — too heavy for this monorepo
- Document "always call `_jira_wiki_body`" — weak; relies on manual discipline
- Add lint rules to catch raw markdown POSTs — helpful but doesn't fix existing issues

## Next steps

1. Audit call sites (Phase 1) ✅
2. Implement expanded conversion (Phase 2) ✅
3. Update docs and comments (Phase 3) ✅

## Execution Notes (Audit Verified)

**Audit date:** 2026-07-07
**Verdict:** PASS (all 3 phases)

**Implementation summary:**
- Phase 1: Audited 3 call sites (`_jira_create_epic`, `_jira_create_task`, `_jira_update_description`). Identified 9 markdown → wiki conversion patterns missing from current implementation.
- Phase 2: Expanded `_jira_wiki_body` with awk/sed pipeline to handle h1–h3, inline code, bold, code blocks, links, and bullets. All 3 write functions already call `_jira_wiki_body` (auto-enforcement verified). Manual testing confirmed correct conversion.
- Phase 3: Updated `to-jira/SKILL.md` with new "Markdown → Jira wiki conversion (automatic)" section. Enhanced inline comments in `jira-helpers.sh` for both functions. Rewrote `jira-description-style.md` conversion section; changed framing from "must convert" to "will convert automatically." Moved intake item to plan sources.

**Audit findings:**
- No architectural debt introduced (minimal, necessary changes)
- Shell code follows all compliance and coding standards
- No secrets, .env files, or dangerous constructs
- Documentation clearly communicates the auto-conversion contract across three key files
- Edge cases (nested brackets) handled gracefully

**Installation impact:**
- Fix ships with next `/setup-internal-skills` run in consumer repos
- Automatically improves Jira issue formatting (h1–h3, code, bold, etc.)
- No breaking changes to calling code (conversion is backwards compatible)
