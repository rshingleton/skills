---
name: verify-it
description: >
  Doc Cycle docs-finalize phase. After audit-it passes, finalizes the plan's
  docs: accepts the ADRs it linked, merges GLOSSARY.md, writes the changelog
  entry, and removes the planning directory. Does NOT audit, stage, or commit.
  Use after an audit-it PASS, or when user says verify-it, verify it, verify,
  close phase, finalize.
---

Finalizes docs after an audit PASS. It never audits implement-it output itself; without a
passing audit report it stops and tells the user to run `/audit-it`.

Three modes:

| Mode | When | What it does |
|------|------|-------------|
| **Full verify** (default) | After **all** phases + Full or Per-phase audit PASS | Finalize linked ADRs, GLOSSARY, changelog; extract essence from planning docs, discard artifacts |
| **Incremental close** | `--phase phase-N` after Single-phase audit PASS | Per-phase ADR notes, GLOSSARY, Jira resolution; no changelog or compression |
| **Retroactive cleanup** | `--retro` anytime | Sweep historic `docs/archive/planning/` and orphaned `docs/planning/` dirs, backfill ADRs, delete artifacts |

## Quick start

```text
/verify-it
```

After audit PASS:
→ Finalizes the plan's linked ADRs (if any), GLOSSARY.md, changelog
→ Extracts any missing decisions from planning docs into those ADRs or the changelog, discards `docs/planning/{ID}/`

Incremental: `/verify-it --phase phase-1` (after `audit-it --phase phase-1` PASS)
Retroactive: `/verify-it --retro` (sweep historic archives, no audit needed)

## Workflow

### 1. Require audit PASS

#### Full verify

Before any durable doc edits, `/audit-it` must have completed [PHASE-AUDIT.md](../audit-it/PHASE-AUDIT.md) across **all** implemented phases.

- Read `docs/planning/{ID}/audit-report.md`. The verdict is its closing `Verdict:` line; ignore the PASS and FAIL marks on section lines, result tables and quoted code-review reports.
- **Verdict FAIL** → Stop. Report blocking findings. User returns to `/implement-it`. Do not proceed.
- **Verdict PASS** → Continue. Carry **non-blocking notes** into the execution notes (step 2).

If no `audit-report.md` exists, stop and tell the user to run `/audit-it`. Do not audit in this session.

#### Incremental close (`--phase phase-N`)

- Read `docs/planning/{ID}/audit-report-{phase-N}.md`, by its closing `Verdict:` line as above
- **Missing or FAIL** → Stop. Run `/audit-it --phase phase-N` first. Do not proceed.
- **PASS** → Continue. Carry non-blocking notes into the execution notes.

### 2. Durable update

The plan's ADRs are the ones its README links and that exist under `docs/adr/`. Touch no other
ADR, and do not create one to have somewhere to put notes. A plan may link none.

| Step | Full verify | Incremental close (`--phase`) |
|------|-------------|-------------------------------|
| **ADR** (plan links one or more) | `Proposed` → `Accepted`. Add execution notes from audit. | Add execution notes from audit. **Do not** change status (stays `Proposed` until full verify). |
| **No ADR** (plan links none) | Write the execution notes into the plan's changelog entry. | Nothing to write; the notes go into the changelog at full verify. |
| **GLOSSARY.md** | Merge new terminology. | Merge new terminology (same). |
| **Changelog** | Append one technical summary for the completed plan (plus execution notes when no ADR). | **Skip**: final changelog written at full verify. |

See [EXAMPLES.md](EXAMPLES.md) for concrete before/after diffs.

**Shortcut markers (full verify only):** list the `shortcut:` markers the plan's diff added and offer each `no-trigger` one to `/issue-it` (`source: verify-it`), per [SHORTCUTS.md](SHORTCUTS.md).

### 3. Compact -- extract essence, discard artifacts

**Full verify only.** Not run during incremental close.

Planning docs are intermediate work product. The durable records are the plan's ADRs, if any (decision rationale), and the changelog (what shipped). Compact by extracting anything missing from those, then discarding.

- **Review ADRs:** For each ADR linked from the plan, confirm it captures the decision, context, and consequences. If the planning directory reveals additional architectural context or trade-off rationale not yet in the ADR, backfill it. With no linked ADR, the changelog entry carries the plan's execution notes and decisions.
- **Review changelog:** Confirm the changelog entry covers what was shipped. If planning docs surfaced unrecorded deliverables, add them.
- **Discard:** Remove `docs/planning/{ID}/` entirely. No archive -- the durable core (ADRs, changelog) holds everything worth keeping.

See [EXAMPLES.md](EXAMPLES.md) for examples.

### 4. Tracker update

If any row in `jira.md` has a Jira key, follow [JIRA-RESOLUTION.md](JIRA-RESOLUTION.md) for the per-key resolution loop. The tracker config may say "local" while `jira.md` has keys — still proceed.

### 5. Retroactive cleanup (`--retro`)

Follow [RETRO-CLEANUP.md](RETRO-CLEANUP.md) to sweep historic artifacts. No audit required.

### 6. Conclusion and next skill

Close with the message for the mode in [CLOSING.md](CLOSING.md): first line what happened, last line what to do next.

## Core Tenets

- **Audit-first:** No durable doc updates until `audit-report.md` verdict is PASS. Never audit in this session.
- **Read-only code:** No production code changes — documentation files only.
- **Decoupled:** Do not stage or commit changes.
