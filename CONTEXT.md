# Internal Skills (ai-skills)

A collection of agent skills (slash commands and behaviors) for engineering workflows. Skills are organized into buckets and consumed by per-repo configuration emitted by `/setup-internal-skills`.

Canonical repo: [ai-skills](https://github.com/rshingleton/skills.git) on Bitbucket. Descended from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT License).

## Language

**Issue tracker**:
Pre-plan intake under `docs/issues/` (local markdown) plus optional Jira for published plans. Intake via `/issues-it`; plans and Jira maps via `/plan-it`; execution via `/implement-it` / `/verify-it` per `docs/agents/issue-tracker.md`.
_Avoid_: backlog manager, backlog backend, issue host

**Issue (intake)**:
A single pre-plan item — bug, defer, todo, or feature request in `docs/issues/<slug>.md`. Captured from review, grill, doc-it, or user report. Becomes a **Plan** via `/plan-it --from-issues`.
_Avoid_: using "issue" for a plan phase or Jira task

**Plan**:
Doc Cycle orchestration under `docs/planning/<id>/` — phases, `ai-prompt.md`, ADR draft. Produced by `/plan-it`. Optional **`jira.md`** maps phases to Jira keys.

**Epic** (Jira):
Jira Epic issue linking phase Tasks. Referenced in `jira.md` as `epic_key`. Not a duplicate spec file under `docs/issues/`.
_Avoid_: PRD, product requirements document

**Triage role**:
Canonical state on **intake** issues (`intake`, `ready-for-plan`, `planned`, …) and Jira labels when using `/triage`. See `docs/agents/triage-labels.md`.

## Relationships

- **Issue tracker** holds intake **Issues** until planned
- A **Plan** may list intake paths in `## Sources` and owns **`jira.md`** when published to Jira
- **implement-it** / **verify-it** read phase Jira keys from **`jira.md`** (`_jira_phase_key` helper in [issue-tracker-jira.md](skills/engineering/setup-internal-skills/issue-tracker-jira.md)), not from intake files
- **plan-it** `--jira --sync-only` re-pulls Epic Task keys into `jira.md` without re-grilling

## Flagged ambiguities

- "backlog" — resolved: use **Issue tracker** for the tool; intake files for pre-plan work.
- Plan phase tasks under `docs/issues/.../tasks/` — **retired**; use `docs/planning/` + `jira.md` only.
