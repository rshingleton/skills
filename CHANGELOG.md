# Changelog

## 2026-08-11 -- Jira Bridge Fixes: transition echo shape and watcher-policy exit code

- **Bug fix:** `jira_bridge_transition()`'s connector-path echo assumed
  `jira_get_transitions` returned `{"transitions": [...]}` and filtered on the wrong field. Live
  testing showed the real MCP tool returns a bare array of flat `{"id", "name"}` objects with no
  nested `.to` -- fixed the echo to match, filtering on `.name` (already the destination status
  name in this shape).
- **Bug fix:** `_jira_apply_watcher_policy` in `jira-helpers.sh` returned the exit status of a
  false `&&` condition on every update-mode call (transition, comment, description update),
  masking real HTTP successes as shell failures. Restructured as an explicit `if`/`fi` with a
  trailing `return 0`.
- **Tests:** `scripts/jira-connector-bridge.test.sh` grew 2 assertions (38 total) covering the
  corrected filter and the removed `.transitions[]` assumption; added a reusable
  `_assert_not_contains` helper.
- **Live re-verification:** both fixes confirmed against real throwaway issues in the OSS
  project (created, exercised, deleted) rather than just the mocked test suite.
- **Docs:** Added a "Live smoke test (re-running)" section to `docs/JIRA-OPERATIONS-EXAMPLES.md`.
- **Follow-up filed, not fixed here:** all six `jira-helpers.sh` write functions still mask real
  API failures as success because watcher policy is their unconditional last statement -- see
  `docs/issues/jira-helpers-write-exit-code-masked-by-watcher-policy.md`.
- See ADR-0009 for full rationale.

## 2026-08-10 -- Jira Bridge Simplify: connector-first cleanup

- **Docs:** Consolidated `to-jira/OPERATIONS.md` and `from-jira/COMMANDS.md` into one 171-line
  bridge-first reference; `COMMANDS.md` deleted.
- **Tests:** Added `scripts/jira-connector-bridge.test.sh` (36 assertions) covering connector
  detection, both the connector-echo and bash-fallback paths, credential-sourcing failure, and
  error handling for the bridge script.
- **Routing:** Removed `skills/engineering/to-jira/to-jira.sh` -- a thin, uncalled wrapper around
  the bridge. Documented the bridge's echo-pattern design decision in its own header and in
  `to-jira/SKILL.md`. Added `docs/JIRA-OPERATIONS-EXAMPLES.md`.
- **Skill coupling:** `implement-it` and `verify-it` now source `jira-connector-bridge.sh`
  directly instead of delegating Jira operations through the `/to-jira` skill. `plan-it` and
  `from-jira` were already doing so. `to-jira` itself is kept as the ad-hoc entry point and
  bridge reference, not removed.
- **Watcher policy:** Removed from the connector-first interface (bridge dispatch, `to-jira`, and
  every skill that used to delegate to it) rather than kept as a documented bash-only limitation.
  Note the bash-helper implementation (`jira-helpers.sh`) still applies it automatically as a
  pre-existing side effect of writes -- that file was out of this refactor's scope.
- See ADR-0007 and ADR-0008 for full rationale.

## 2026-07-07 -- Expand Jira wiki conversion in `_jira_wiki_body`

Enhanced `_jira_wiki_body` markdown -> wiki conversion with full pattern support:
headings (h1-h3), inline code `{{}}`, bold `*text*`, code blocks with language
hints, links (URL dropped, text preserved), and normalized bullets. Auto-enforcement
verified across 3 write operations (`_jira_create_epic`, `_jira_create_task`,
`_jira_update_description`). Updated `to-jira/SKILL.md` with "automatic conversion"
section, inline comments in `jira-helpers.sh`, and `jira-description-style.md`
guidance (framing changed from "must convert" to "will convert"). Installation
spreads improvement to consumer repos; no breaking changes.

## 2026-06-30 -- Consolidate Jira API helpers

9 new shell functions in `jira-helpers.sh` consolidated ~500 lines of duplicated
curl examples across 6 files. All skills now call `_jira_*` functions instead of
reconstructing raw curl from prose. Interactive config prompt added to
`load-jira-env.sh` for first-time setup. `_jira_curl` is the single auth
dispatch point for bearer/basic switching.

## 2026-06-30 -- `_jira_curl` method-first, dry-run, error handling

`_jira_curl` redesigned: method as first positional arg (`_jira_curl POST ...`),
`--dry-run` flag for safe preview, and HTTP error capture (non-2xx -> stderr +
exit 1). All 14 internal callers migrated. Dry-run example in
`issue-tracker-jira.md`.

## 2026-06-30 -- `plan-it/SKILL.md` trim

Extracted intake evaluation, grill, and scaffold sections into
`INTAKE-EVALUATION.md`, `GRILL.md`, `SCAFFOLD.md`. Main SKILL.md reduced
from 214 to 115 lines. No content changes -- pure extraction.

## 2026-07-01 -- Fix Jira description helpers

`_jira_create_epic` and `_jira_create_task` now convert descriptions through
`_jira_wiki_body` before sending (markdown -> wiki markup).
Added `_jira_update_description <key> <file>` helper for post-creation fixes.
Updated OPERATIONS.md with `update-description` reference section and example.

## 2026-07-01 -- Fix resolve section code block

`resolve` bash block in OPERATIONS.md now includes `_jira_comment` call,
matching the prose-described two-step flow (transition + optional comment).
