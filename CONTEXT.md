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
Doc Cycle orchestration under `docs/planning/<id>/` — phases, `ai-prompt.md`, ADR draft. Produced by `/plan-it`. Optional **`jira.md`** maps phases to Jira keys.

**Epic** (Jira):
Jira Epic issue linking phase Tasks. Referenced in `jira.md` as `epic_key`. Not a duplicate spec file under `docs/issues/`.
_Avoid_: PRD, product requirements document

**Triage role**:
State machine (`intake` → `ready-for-plan` → `wontfix`) mapped to local inbox `status:` or Jira labels by `/plan-it` intake evaluation. See `~/.agents/skills/setup-internal-skills/triage-labels.md`.

## Relationships

- **Issue tracker** holds intake **Issues** until planned
- A **Plan** holds moved intake under **`sources/`**, lists them in README `## Sources`, and owns **`jira.md`** when published to Jira
- **implement-it** / **verify-it** read phase Jira keys from **`jira.md`** (`_jira_phase_key` helper in [issue-tracker-jira.md](skills/engineering/setup-internal-skills/issue-tracker-jira.md)), not from intake files
- **plan-it** `--jira --sync-only` re-pulls Epic Task keys into `jira.md` without re-grilling
- **plan-it** handles intake evaluation and planning in one session — triage-style assessment then the grill
- **plan-it**, **implement-it**, **verify-it**, and **from-jira** each source `scripts/jira-connector-bridge.sh` directly for their own Jira operations rather than delegating to `to-jira` as a skill -- **to-jira** remains the ad-hoc entry point for one-off operations and the canonical reference for the bridge interface (see `to-jira/OPERATIONS.md`). API operations are callable `_jira_*` functions in `jira-helpers.sh` (sourced via `load-jira-env.sh`)

## Flagged ambiguities

- "backlog" — resolved: use **Issue tracker** for the tool; intake files for pre-plan work.
- Plan phase tasks under `docs/issues/.../tasks/` — **retired**; use `docs/planning/` + `jira.md` only.
