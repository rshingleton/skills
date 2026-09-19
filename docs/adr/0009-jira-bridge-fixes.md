# ADR-0009: Jira Bridge Fixes -- Transition Echo Shape and Watcher-Policy Exit Code

**Status:** Accepted
**Date:** 2026-08-11
**Author:** Russell Shingleton
**Related:** ADR-0007 (Jira Connector Bridge), ADR-0008 (Jira Bridge Simplify)

## Context

A live smoke test of `scripts/jira-connector-bridge.sh` and `jira-helpers.sh` against the real
OSS Jira project (not the mocked test suite) surfaced two pre-existing bugs, neither introduced
by ADR-0008's refactor -- that plan deliberately left `jira-helpers.sh` untouched.

1. The connector-path `transition` echo in `jira_bridge_transition()` assumes
   `jira_get_transitions` returns `{"transitions": [...]}`. The real MCP tool returns a bare
   array of flat `{"id", "name"}` objects -- no nested `"to"` object at all, unlike the REST API
   shape the bash-fallback path uses.
2. `_jira_apply_watcher_policy` in `jira-helpers.sh` returns the exit status of a false `&&`
   condition on every `update`-mode call (transition, comment, description update), masking a
   real HTTP success as a shell failure to every caller checking `$?`.

## Decision

1. **Fix the transition echo to match the real response shape, and filter on `.name`.**
   Revised during phase 3's live re-verification (see Execution Notes): a live call against
   OSS-322 showed the MCP tool's actual response has no `.to` object at all --
   `[{"id": 11, "name": "Open"}, ...]`, flat `id`/`name` pairs only. `.to.name` matches nothing
   against this shape. In this tool's output, `.name` already *is* the destination status name
   (not the transition action's own name, e.g. "Start Progress") -- so filtering on `.name` here
   correctly matches what callers pass (`"In Progress"`, `"Done"`) without reintroducing the
   transition-name-vs-status-name ambiguity that motivated avoiding `.name` in the first draft of
   this decision. That ambiguity is real for the REST API shape the bash-fallback path uses
   (which does nest `to.name`), not for this MCP tool's flatter shape.
2. **Fix `_jira_apply_watcher_policy`'s return value once, at the shared function.** Every
   affected caller (`_jira_transition`, `_jira_update_description`, others) inherits the fix
   automatically rather than needing independent patches, since the root cause is centralized.

## Rationale

**Why `.name` over `.to.name`, despite the original concern?** The original planning session
worried that `.name` (the transition's own name, e.g. "Start Progress") and the destination
status name (e.g. "In Progress") could diverge, and reasoned from the bash-fallback path's REST
API shape -- which nests `to.name` -- that `.to.name` was the safer field to key on. Live
verification against a real issue (OSS-322) showed that reasoning didn't transfer: the MCP
tool's `jira_get_transitions` response has no `.to` object at all, only flat `{"id", "name"}`
pairs, and in that shape `.name` is already the destination status. `.to.name` doesn't just fail
to add safety here -- it matches nothing, silently breaking every transition call. The two Jira
access paths (REST API vs. this MCP tool) expose different response shapes for the same
underlying data; each path's filter has to match its own shape, not the other's.

**Why fix the shared function instead of each caller?** The bug isn't logic duplicated
per-caller; it's the shared function returning the wrong thing once. One fix, one place,
verified by auditing (not separately fixing) every caller afterward.

## Alternatives Considered

**Filter on `.to.name` in the connector path, to match the bash path's field name:** the original
decision in this ADR's first draft; rejected after phase 3's live re-verification showed the MCP
tool's response has no `.to` object, so `.to.name` matches nothing. Kept `.name` for the
connector path and `.to.name` for the bash path -- each matches its own actual response shape;
forcing field-name consistency across two genuinely different shapes would have meant picking a
field that doesn't exist in one of them.

**Patch each caller of `_jira_apply_watcher_policy` to ignore its exit code:** rejected -- treats
a symptom at every call site instead of the one-line root cause; new callers would inherit the
bug again.

## Consequences

- `scripts/jira-connector-bridge.sh` and its test suite change for the transition-echo fix
  (ADR-0007/0008 scope).
- `jira-helpers.sh` changes for the first time since ADR-0002 -- previously untouched by the
  connector-first refactor.
- A live re-verification (targeted, not the full original smoke-test matrix) confirms both fixes
  against the real OSS project before this ADR is accepted.

## Execution Notes

Implemented across 3 phases, audited holistically (PASS, no blocking findings), and closed via
this full verify.

- **Phase 1** filtered the connector-path transition echo on `.to.name` per this ADR's original
  draft. **Phase 3's live re-verification against a real OSS issue (OSS-322) found that decision
  wrong**: the MCP tool's actual `jira_get_transitions` response has no `.to` object at all, only
  flat `{"id", "name"}` pairs. `.to.name` matched nothing, so the connector-path transition would
  have silently continued to fail to resolve a transition id -- for a different reason than the
  bug this ADR set out to fix, but just as broken. Per the phase's own guard ("stop and report
  rather than improvising a new fix mid-phase-3"), the implementer stopped and asked before
  changing anything; the user chose to filter on `.name` instead. This ADR's Decision, Rationale,
  and Alternatives Considered above already reflect the corrected `.name` filter, not the
  original `.to.name` draft -- there is no separate "old vs. new" text left to reconcile.
  Re-verified live against a second throwaway issue (OSS-323) after the correction: filter
  resolved to the correct transition id, and the transition took effect. Both throwaway issues
  were deleted after use.
- **Phase 2** fixed `_jira_apply_watcher_policy` as planned (`if`/`fi` plus a trailing
  `return 0`), confirmed live on a real transition (OSS-322, bash-fallback path, `$?` was `0`
  after a genuine HTTP success). Auditing its six callers surfaced a second, related but
  independent exit-code issue: all six still discard their own `_jira_curl` result because
  watcher policy is their last statement -- a real API failure would still report as `$?=0`.
  Confirmed this predates this plan (the "create" mode path already swallowed its own failures
  the same way, via `_jira_add_watchers`'s internal `|| true`). Filed separately rather than
  fixed here, per this phase's own scope guard against expanding into unrelated callers:
  `docs/issues/jira-helpers-write-exit-code-masked-by-watcher-policy.md`.
- **Phase 3** added a "Live smoke test (re-running)" section to `docs/JIRA-OPERATIONS-EXAMPLES.md`
  covering env vars, project choice, targeted-vs-full-matrix guidance, and cleanup -- closing the
  last open item from the original smoke test (`sources/jira-bridge-live-smoke-test.md`).
- Full test suite: 38/38 passing (36 pre-existing + 2 new assertions for the transition-echo fix).
  No production dependency or coding-standard violations found during audit.

## References

- ADR-0007: Jira Connector Bridge
- ADR-0008: Jira Bridge Simplify
- `docs/planning/jira-bridge-fixes/`: plan details (compacted at verify-it)
