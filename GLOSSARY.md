# ai-skills

A collection of agent skills (slash commands and behaviors) for engineering workflows. Skills are organized into buckets and consumed by per-repo configuration emitted by `/setup-internal-skills`.

Canonical repo: [ai-skills](https://github.com/rshingleton/skills.git) on GitHub. Descended from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT License).

## Language

**Issue tracker**:
Pre-plan **inbox** under `docs/issues/` (local markdown); optional Jira for published plans in `jira.md`. Capture: `/issue-it` or [audit-to-issues](skills/engineering/setup-internal-skills/audit-to-issues.md). Plan: `/plan-it` (always grills; `--from-issues` moves intake to `sources/`). Execution: `/implement-it` / `/verify-it` per `docs/agents/issue-tracker.md`.
_Avoid_: backlog manager, backlog backend, issue host

**Issue (intake)**:
A single pre-plan item — bug, defer, todo, or feature request as one `docs/issues/<slug>.md` file. `/plan-it --from-issues` **moves** it to `docs/planning/<id>/sources/` so the inbox stays unplanned-only.
_Avoid_: using "issue" for a plan phase or Jira task

**Plan**:
Doc Cycle orchestration under `docs/planning/<id>/`: phases, `ai-prompt.md`, and an ADR draft under `docs/adr/` only when one is warranted (ADR-0012). Produced by `/plan-it`. Optional **`jira.md`** maps phases to Jira keys.

**Seam** (plan):
A test boundary agreed during `/plan-it` and recorded in the phase prompt's `## Seams` section, each with a note on what tests there catch and miss. `/implement-it` passes them to `tdd` as already agreed.
_Avoid_: test point, hook

**Base ref**:
The commit a phase branched from, written as `Base ref:` in that phase's `execution-notes.md`. A Single-phase audit reads the phase's prefixed commits since it (ADR-0011).
_Avoid_: start ref, baseline

**Frontier**:
The phases of a plan whose blocking phases are all merged. `/implement-it {ID}` builds every frontier phase, in parallel when there is more than one.
_Avoid_: ready queue, next phases

**Integration branch**:
The branch every phase of a plan merges into: the current branch unless it is `main`, else `plan/{ID}`.
_Avoid_: plan branch, feature branch

**Phase branch**:
One phase's own branch, `plan/{ID}--phase-N`, built in its own worktree and merged into the integration branch.
_Avoid_: ticket branch

**Audit mode**:
One of `/audit-it`'s four passes: **Full audit** (the plan's combined diff, the gate on `/verify-it`), **Per-phase audit** (`--phases`, each phase on its own, compiled), **Single-phase audit** (`--phase phase-N`, early feedback), **Repo audit** (`repo`, not tied to a plan).
_Avoid_: phase audit, multi-phase audit, holistic audit

**Shortcut marker**:
A code comment `shortcut: <the limit>, <when to upgrade>` recording a deliberate shortcut. `/audit-it` treats it as a recorded decision, `/doc-it` lists it in the tech-debt ledger, and `/verify-it` offers a `no-trigger` one (no upgrade condition) to `/issue-it`.
_Avoid_: TODO, hack

**Guardrail candidate**:
A violated rule that is mechanical (a fixed pattern, banned API, import shape, file-location rule), listed in an audit report as a candidate lint rule or hook. Listed only; building it is separate work.

**Epic** (Jira):
Jira Epic issue linking phase Tasks. Referenced in `jira.md` as `epic_key`. Not a duplicate spec file under `docs/issues/`.
_Avoid_: PRD, product requirements document

**Triage role**:
State machine (`intake` → `ready-for-plan` → `wontfix`) mapped to local inbox `status:` or Jira labels by `/plan-it` intake evaluation. See `~/.agents/skills/setup-internal-skills/triage-labels.md`.

## Relationships

- **Issue tracker** holds intake **Issues** until planned
- A **Plan** holds moved intake under **`sources/`**, lists them in README `## Sources`, and owns **`jira.md`** when published to Jira
- **implement-it** / **verify-it** read phase Jira keys from **`jira.md`** (`_jira_phase_key` helper in [issue-tracker-jira.md](skills/engineering/setup-internal-skills/issue-tracker-jira.md)), not from intake files
- **implement-it** commits each phase, prefixed with its Jira key or `{ID} phase-N`; **commit-it** commits only the docs **verify-it** changed (ADR-0011)
- **plan-it** `--jira --sync-only` re-pulls Epic Task keys into `jira.md` without re-grilling
- **plan-it**, **implement-it** and **audit-it** call canonical skills for generic methods (`grilling` and `domain-modeling`; `tdd` and `diagnosing-bugs`; `code-review`) and keep only Doc Cycle specifics (ADR-0010)
- **plan-it** handles intake evaluation and planning in one session — triage-style assessment then the grill
- **plan-it**, **implement-it**, **verify-it**, and **from-jira** each source the connector bridge (canonically `setup-internal-skills/scripts/jira-connector-bridge.sh`, installed alongside `load-jira-env.sh`; `scripts/jira-connector-bridge.sh` at the repo root is a dev-convenience shim over it) directly for their own Jira operations rather than delegating to `to-jira` as a skill -- **to-jira** remains the ad-hoc entry point for one-off operations and the canonical reference for the bridge interface (see `to-jira/OPERATIONS.md`). API operations are callable `_jira_*` functions in `jira-helpers.sh` (sourced via `load-jira-env.sh`)

## Flagged ambiguities

- "backlog" — resolved: use **Issue tracker** for the tool; intake files for pre-plan work.
- Plan phase tasks under `docs/issues/.../tasks/` — **retired**; use `docs/planning/` + `jira.md` only.
