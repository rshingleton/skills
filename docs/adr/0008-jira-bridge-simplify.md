# ADR-0008: Jira Bridge Simplification — Connector-First Refactor

**Status:** Accepted
**Date:** 2026-08-03
**Author:** Russell Shingleton
**Related:** ADR-0007 (Jira Connector Bridge), OSS-299 (Update ai-skills to use Jira/Confluence MCP connectors)

**Execution Notes:**
- Documentation consolidated into `to-jira/OPERATIONS.md` (171 lines); `from-jira/COMMANDS.md`
  deleted, its unique content (Jira-key resolution) migrated in
- Integration test suite added: `scripts/jira-connector-bridge.test.sh`, 36 assertions
- `to-jira.sh` removed entirely rather than reduced to a stub -- verified nothing referenced it
  before deletion; no backward-compatibility issue materialized (see the corrected Risks row
  below, which originally assumed a more cautious path)
- `implement-it` and `verify-it` now source the bridge directly; `plan-it` and `from-jira` were
  already doing so before this refactor
- `to-jira` skill itself was kept, not removed or deprecated -- it retains unique value as the
  ad-hoc `create` flow entry point and the canonical bridge reference doc
- Watcher policy decision changed mid-implementation from "accept as bash-only limitation" (the
  plan as originally written below) to full removal from the connector-first interface. This is
  narrower than it sounds: `_jira_apply_watcher_policy` still runs automatically inside several
  bash write helpers in `jira-helpers.sh`, which stayed out of this refactor's file scope. See
  Decision #5 and its Rationale below, both corrected to state this precisely after an audit
  caught the original wording overclaiming full removal.
- Audit findings (one blocking, three non-blocking) all resolved before this ADR was accepted;
  see `docs/planning/jira-bridge-simplify/audit-report.md` before that directory was compacted

## Context

The ai-skills project has evolved from a bash-only Jira integration (curl + helpers) to a connector-first architecture with Jira MCP connector support. During this transition, a bridge layer (`jira-connector-bridge.sh`) was introduced to route between connector (preferred) and bash helpers (fallback).

**Current State:**
- Bridge exists and works (detection + routing)
- Documentation duplicated across `OPERATIONS.md` and `COMMANDS.md` (400+ lines)
- to-jira.sh wrapper adds unnecessary indirection
- Echo pattern is confusing (outputs tool calls, agent executes them)
- Skill coupling: implement-it, verify-it depend on /to-jira skill availability

**Problem:**
- Documentation maintenance burden (same ops explained 3 times)
- Architecture unclear to new contributors
- Skill coupling reduces resilience
- to-jira.sh adds no real value

## Decision

**Simplify the Jira operations architecture to be connector-first with optional bash fallback.**

### Specific Decisions

1. **Consolidate documentation** (OPERATIONS.md + COMMANDS.md)
   - Single authoritative reference (~150-180 lines)
   - Primary: Bridge usage (connector-first)
   - Secondary: Bash fallback (OSS/offline reference)

2. **Document echo pattern** (not "fix" it)
   - Echo pattern is intentional for agent contexts
   - Bridge outputs tool calls → agent executes them
   - This is NOT a failure mode; it's by design

3. **Add integration tests**
   - Validate bridge detection (all scenarios)
   - Validate both paths (connector echo + bash execution)
   - Ensure error handling is consistent

4. **Simplify routing**
   - Remove to-jira.sh wrapper (or reduce to minimal stub)
   - Skills source bridge directly (reduce skill coupling)
   - Clear "why" in documentation (echo pattern)

5. **Watcher policy: remove from the connector-first interface, not from the bash implementation**
   - Superseded during implementation -- see Rationale below
   - No skill delegates watcher-policy anymore (`to-jira`, `implement-it`, `verify-it`, `plan-it`),
     and the bridge has no dispatch case for it
   - This is interface-layer removal only. `_jira_apply_watcher_policy` (in `jira-helpers.sh`)
     still runs automatically inside `_jira_create_epic`, `_jira_create_task`, `_jira_transition`,
     `_jira_update_description`, and other bash write helpers -- out of this refactor's declared
     file scope, so it was not touched. The bash fallback path still applies watcher policy on
     every write; only the connector path and the documented interface stopped using it.
   - No connector enhancement request planned

### Non-Decisions

- Keep bridge for fallback flexibility (don't eliminate it)
- Keep bash helpers as reference (support OSS/offline scenarios)

## Rationale

**Why consolidate documentation?**
- Same operations explained 3 times (connector path + bash path + bridge routing)
- Maintenance burden: change one signature → update 2+ places
- New contributors confused by triple documentation
- Single reference is clearer, easier to maintain

**Why document echo pattern instead of "fixing" it?**
- Echo pattern is not a bug; it's intentional
- Bash cannot directly invoke MCP tools
- Agent execution context CAN invoke MCP tools
- Bash outputs tool call → agent executes it
- This is the correct design for agent contexts

**Why remove to-jira.sh?**
- Thin wrapper around bridge
- No business logic added
- Increases indirection without benefit
- Skills can source bridge directly
- Simpler architecture

**Why direct bridge sourcing in skills?**
- Reduces coupling (no /to-jira skill dependency)
- More resilient (works even if skill system changes)
- Clearer (direct bridge call vs indirect skill call)
- Closer to actual operation

**Why remove watcher policy instead of accepting it as a bash-only limitation?**
- The bash-only workaround was itself the problem: it forced a fallback to bash on every
  create/resolve, defeating the connector-first goal this refactor exists to achieve
- No skill's workflow depends on watcher notifications functioning -- removing the delegation
  path costs nothing observable to plan-it, implement-it, or verify-it
- Simpler than either alternative below: no connector enhancement to request, no N+2-call
  workaround to maintain
- Note this is narrower than "watcher policy is gone" -- see Decision #5 above for what actually
  changed at the bash-helper level versus the interface

## Alternatives Considered

**Alternative 1: Eliminate bridge, go connector-only**
- Pros: Simplest possible (one path)
- Cons: Breaks OSS/offline scenarios, reduces flexibility, too aggressive
- Rejected: Fallback is justified

**Alternative 2: Keep dual documentation, improve side-by-side**
- Pros: Readers can compare connector vs bash
- Cons: Maintenance burden remains, confusion about which to use
- Rejected: Consolidation is cleaner

**Alternative 3: Make bridge execute directly (not echo)**
- Pros: More intuitive (bridge actually does something)
- Cons: Can't work in agent contexts (bash can't call MPC)
- Rejected: Echo pattern is correct for this environment

**Alternative 4: Batch watcher operations with multiple individual connector calls**
- Pros: No bash fallback needed
- Cons: N+2 API calls, rate limit risk, slower
- Rejected: adds complexity for a feature nothing depends on; removal is simpler

**Alternative 5: Accept watcher policy as a bash-only limitation (original plan)**
- Pros: Keeps the feature working for whoever relies on it
- Cons: Forces a bash fallback on every write operation, defeating connector-first
- Rejected: the fallback cost outweighed the feature's value; removed instead

## Implications

**Short-term:**
- Document consolidation reduces duplication (~250 lines deleted)
- Bridge simplification (header + examples)
- Skills updated (implement-it, verify-it source bridge directly)
- Tests added for bridge coverage

**Long-term:**
- Clearer architecture (connector-first with optional bash)
- Easier onboarding (single path to learn)
- Better maintenance (single documentation source)
- Resilient (less skill coupling)

**Risks & Mitigations:**

| Risk | Mitigation |
|------|-----------|
| Remove to-jira.sh too aggressively | Verified no callers before deleting (see Execution Notes); removed entirely, no stub needed |
| Break existing workflows | Run integration tests before merging; test all Jira ops |
| Documentation not clear enough | Include examples, diagrams, rationale in ADR + CONTEXT.md |
| Echo pattern still confuses contributors | Document deeply; add usage examples showing how it works |

## Success Criteria

- Single consolidated Jira operations reference (no duplication)
- Echo pattern documented with rationale + examples
- Integration tests passing (all paths, all operations)
- Skills simplified (direct bridge sourcing, no skill coupling)
- New contributors can explain "why echo pattern" after reading docs
- Watcher policy decision documented + ADR updated

## Follow-up Items

- [ ] Monitor bridge usage; refactor if pattern breaks in real use
- [ ] Collect feedback from contributors on clarity improvements
- [x] Consider deprecation timeline for /to-jira skill -- resolved: kept, not deprecated (see
      Execution Notes)

## References

- ADR-0007: Jira Connector Bridge (prior architectural decision, updated with this refactor's
  execution notes)
- OSS-299: Update ai-skills to use Jira/Confluence MCP connectors (initiative)
- `docs/planning/jira-bridge-simplify/`: compacted at verify-it; this ADR and ADR-0007 hold the
  durable record
