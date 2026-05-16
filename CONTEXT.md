# Internal Skills (ai-skills)

A collection of agent skills (slash commands and behaviors) for engineering workflows. Skills are organized into buckets and consumed by per-repo configuration emitted by `/setup-internal-skills`.

Canonical repo: [ai-skills](https://github.com/rshingleton/skills.git) on Bitbucket. Descended from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT License).

## Language

**Issue tracker**:
The tool that hosts a repo's issues — by default local markdown under `docs/issues/`, or Jira after `/promote-to-jira`. Skills like `/to-jiras`, `/to-epic`, `/plan-it`, `/implement-it`, `/verify-it`, `/promote-to-jira`, and `/triage` read from and write to it per `docs/agents/issue-tracker.md`.
_Avoid_: backlog manager, backlog backend, issue host

**Epic**:
The top-level feature specification for a body of work — local file `docs/issues/<feature-slug>/epic.md` (`type: epic` in frontmatter) or a Jira Epic issue. Produced by `/to-epic`. Tasks slice the Epic into implementable vertical bullets via `/to-jiras`.
_Avoid_: PRD, product requirements document

**Issue**:
A single tracked unit of work inside an **Issue tracker** — a bug, task, Epic, or slice produced by `to-jiras` or `plan-it`.
_Avoid_: ticket (use only when quoting external systems that call them tickets)

**Triage role**:
A canonical state-machine label applied to an **Issue** during triage (e.g. `needs-triage`, `ready-for-afk`). Each role maps to a real label string in the **Issue tracker** via `docs/agents/triage-labels.md`.

## Relationships

- An **Issue tracker** holds many **Issues**
- An **Issue** carries one **Triage role** at a time

## Flagged ambiguities

- "backlog" was previously used to mean both the *tool* hosting issues and the *body of work* inside it — resolved: the tool is the **Issue tracker**; "backlog" is no longer used as a domain term.
- "backlog backend" / "backlog manager" — resolved: collapsed into **Issue tracker**.
