# Changelog

## 2026-07-07 — Expand Jira wiki conversion in `_jira_wiki_body`

Enhanced `_jira_wiki_body` markdown → wiki conversion with full pattern support:
headings (h1–h3), inline code `{{}}`, bold `*text*`, code blocks with language
hints, links (URL dropped, text preserved), and normalized bullets. Auto-enforcement
verified across 3 write operations (`_jira_create_epic`, `_jira_create_task`,
`_jira_update_description`). Updated `to-jira/SKILL.md` with "automatic conversion"
section, inline comments in `jira-helpers.sh`, and `jira-description-style.md`
guidance (framing changed from "must convert" to "will convert"). Installation
spreads improvement to consumer repos; no breaking changes.

## 2026-06-30 — Consolidate Jira API helpers

9 new shell functions in `jira-helpers.sh` consolidated ~500 lines of duplicated
curl examples across 6 files. All skills now call `_jira_*` functions instead of
reconstructing raw curl from prose. Interactive config prompt added to
`load-jira-env.sh` for first-time setup. `_jira_curl` is the single auth
dispatch point for bearer/basic switching.

## 2026-06-30 — `_jira_curl` method-first, dry-run, error handling

`_jira_curl` redesigned: method as first positional arg (`_jira_curl POST ...`),
`--dry-run` flag for safe preview, and HTTP error capture (non-2xx → stderr +
exit 1). All 14 internal callers migrated. Dry-run example in
`issue-tracker-jira.md`.

## 2026-06-30 — `plan-it/SKILL.md` trim

Extracted intake evaluation, grill, and scaffold sections into
`INTAKE-EVALUATION.md`, `GRILL.md`, `SCAFFOLD.md`. Main SKILL.md reduced
from 214 to 115 lines. No content changes — pure extraction.

## 2026-07-01 — Fix Jira description helpers

`_jira_create_epic` and `_jira_create_task` now convert descriptions through
`_jira_wiki_body` before sending (markdown → wiki markup).
Added `_jira_update_description <key> <file>` helper for post-creation fixes.
Updated OPERATIONS.md with `update-description` reference section and example.

## 2026-07-01 — Fix resolve section code block

`resolve` bash block in OPERATIONS.md now includes `_jira_comment` call,
matching the prose-described two-step flow (transition + optional comment).
