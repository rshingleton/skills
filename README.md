# Internal Skills (ai-skills)

**Canonical repository:** [https://github.com/rshingleton/skills.git](https://github.com/rshingleton/skills.git)

Agent skills tailored to my daily engineering workflow: refactoring existing codebases, adding features, and addressing tech debt across projects tracked in Bitbucket and Jira. The `issue-it` intake skill, the broader Doc Cycle (`plan-it` → `implement-it` → `audit-it` → `verify-it` → `commit-it`), and introspective skills (`doc-it`, `zoom-out`, `improve-codebase-architecture`) grew out of real needs I hit working with codebases I didn't have full architectural knowledge of.

**Agent-assisted coding is becoming more mainstream.** Teams use coding agents for implementation, exploration, and documentation with growing acceptance in day-to-day engineering. These skills are not a substitute for engineering judgment. They are meant to **supplement** knowledge and practice, not replace it. The successful engineer uses agents to move faster on well-understood work, then applies **eyes-on** review: read the diff, run the tests, question the design. Manual auditing of agent-produced code is **always** recommended before anything ships.

### Purpose

Each skill is a focused workflow in `SKILL.md` that an agent loads when invoked by name (for example `/plan-it` or `/commit-it`). Together they cover alignment and shared vocabulary (`/grill-with-docs`, `/grill-me`), intake and planning (`/issue-it`, `/plan-it`), implementation with tests (`/implement-it`, `/tdd`, `/diagnose`), independent audit (`/audit-it`), durable documentation after a plan (`/verify-it`), closing out the work (`/commit-it`), and **baseline codebase reference** (`/doc-it` → `docs/reference/` and `docs/reference-audit/`). Engineering skills target day-to-day code work; productivity skills cover general workflow. The [skill map](#skill-map--planning-slicing-executing) and [reference](#reference) sections list everything that ships in this repo.

### Usage guidelines

1. **Install once** on your machine using the [quickstart](#quickstart-30-second-setup) below. Skills land in `~/.agents/skills` (and `~/.claude/skills` for Claude Code) — loaded natively by Cursor, OpenCode, Gemini/agy, and Claude Code. Copilot doesn't load `SKILL.md` automatically; it gets a pointer to `AGENTS.md` instead (see [Agent platforms](#agent-platforms)).
2. **Configure each application repo** with `/setup-internal-skills`. That seeds `AGENTS.md`, `docs/agents/`, intake inbox `docs/issues/`, and plans under `docs/planning/`.
3. **Compose skills for the task.** You are not required to run a fixed pipeline. Capture work in the **inbox** (`/issue-it` or audit skills → [audit-to-issues](./skills/engineering/setup-internal-skills/audit-to-issues.md)), then **`/plan-it --from-issues` evaluates and grills** before scaffolding. The **Doc Cycle** is `/plan-it` → `/implement-it` (each phase) → `/audit-it` → `/verify-it` → `/commit-it`. Optional Jira phase keys: `/plan-it --jira` → `jira.md`.
4. **Keep humans in the loop.** Treat agent output as a draft. Read diffs, run tests, and check spec fit before merge. Skills like `/audit-it` and `/internal-compliance` support review; they do not replace it.

## Agent platforms

Instructions use the open **`AGENTS.md`** format, loaded natively by every tool in the table below except Copilot. See [AGENTS.md](./AGENTS.md) and [docs/AGENT-PLATFORMS.md](./docs/AGENT-PLATFORMS.md).

| Tool | Config |
|------|--------|
| OpenCode | [opencode.json](./opencode.json) |
| Cursor | [.cursor/rules/](./.cursor/rules/) |
| GitHub Copilot | [.github/copilot-instructions.md](./.github/copilot-instructions.md) — points at `AGENTS.md`; does not load `SKILL.md` automatically |
| Claude Code | [CLAUDE.md](./CLAUDE.md). Skills installed to `~/.claude/skills/` via [scripts/skills.sh](scripts/skills.sh). Plugin: [.claude-plugin/plugin.json](./.claude-plugin/plugin.json) |
| Gemini / agy | Loads `AGENTS.md` natively — no config file needed. See [docs/AGENT-PLATFORMS.md](./docs/AGENT-PLATFORMS.md#gemini-agy-antigravity) for skill-path details |

## Quickstart (30-second setup)

**VPN or on-site required.** The repo is readable without credentials on the network.

### Option A — one-liner (recommended)

Installs into `~/.agents/skills` and caches a clone at `~/.local/share/ai-skills`:

```bash
bash <(curl -fsSL 'https://raw.githubusercontent.com/rshingleton/skills/main/scripts/skills.sh')
```

Re-run the same command anytime to pull `main` and refresh symlinks.

**Migrating from Matt Pocock / custom `implement`, `verify`, `audit-engineering`?** Preview removals, then install with cleanup:

```bash
# Preview what will be deleted from ~/.agents/skills
bash <(curl -fsSL 'https://raw.githubusercontent.com/rshingleton/skills/main/scripts/cleanup-legacy-skills.sh')

# Remove legacy folders, then install internal skills
CLEANUP_LEGACY=1 bash <(curl -fsSL 'https://raw.githubusercontent.com/rshingleton/skills/main/scripts/skills.sh')
```

Or from a clone: `bash scripts/cleanup-legacy-skills.sh` (dry-run) / `bash scripts/cleanup-legacy-skills.sh --yes`.

### Option B — from a git clone

```bash
git clone https://github.com/rshingleton/skills.git
cd ai-skills
bash scripts/skills.sh
```

### Jira credentials (when using Jira skills)

Skills that call the Jira API need `JIRA_BASE_URL`, `JIRA_API_TOKEN`, and `JIRA_PROJECT_KEY`. Use either exports or a `.env` file (see [.env.example](./.env.example)).

**Optional variables** (loaded by [load-jira-env.sh](./scripts/load-jira-env.sh); not used for Bearer auth except where noted):

| Variable | Purpose |
|----------|---------|
| `JIRA_DEFAULT_EPIC` | Parent Epic for `/plan-it --jira` when `--parent` is omitted ([details](./skills/engineering/setup-internal-skills/issue-tracker-jira.md#default-epic-optional)) |
| `JIRA_WATCHER_IGNORE` | Comma-separated usernames to **remove** from watchers after each write (`DELETE`) |
| `JIRA_WATCHER_USERNAME` | Comma-separated usernames to **add** as watchers after each create (`POST`) |
| `JIRA_EMAIL` | If `JIRA_WATCHER_IGNORE` is unset, remove the PAT owner (`${JIRA_EMAIL%%@*}`) after writes — doc-manager pattern |
| `JIRA_ASSIGNEE` | Jira username for `assignee` on agent creates and Doc Cycle updates (`/implement-it`, `/verify-it`) |
| `JIRA_DEFAULT_ESTIMATE_HOURS` | Default hours on Jira Task **create** (`/plan-it --jira`) when no per-phase `estimate_hours` |
| `JIRA_AUTH_TYPE` | `bearer` (default) or `basic` — auth style for Jira API calls |

Watcher policy and `notifyUsers=false`: [jira-notifications.md](./skills/engineering/setup-internal-skills/jira-notifications.md). Jira descriptions: [jira-description-style.md](./skills/engineering/setup-internal-skills/jira-description-style.md) (**wiki markup**, not markdown). Re-sync phase ↔ keys: `/plan-it <plan-id> --jira --sync-only` ([jira-epic-sync.md](./skills/engineering/setup-internal-skills/jira-epic-sync.md)).

**Option 1: `.env` file (recommended)**

```bash
mkdir -p ~/.config/ai-skills
cp .env.example ~/.config/ai-skills/.env   # from your ai-skills clone
# Edit ~/.config/ai-skills/.env and set JIRA_API_TOKEN

source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
```

A `.env` in the **application repo root** takes precedence over user-wide files when you run the loader from that repo. Also supported: `~/.agents/.env`, `~/.config/ai-skills/.env`. Override the path with `JIRA_ENV_FILE=/path/to/.env`.

**Option 2: shell exports**

```bash
export JIRA_BASE_URL="https://jira.example.com"
export JIRA_API_TOKEN="your-jira-pat"
export JIRA_PROJECT_KEY="your-project-key"
```

Agents running Jira `curl` commands should `source` the loader (or read the `.env` file) before calling the API. API patterns and `notifyUsers=false`: [issue-tracker-jira.md](./skills/engineering/setup-internal-skills/issue-tracker-jira.md). Watcher suppression: [jira-notifications.md](./skills/engineering/setup-internal-skills/jira-notifications.md).

### Configure application repos

Run `/setup-internal-skills` in your **application repo** (in Cursor, Copilot, or OpenCode). It will:
   - Write **`AGENTS.md`** and `docs/agents/` (open format; intake in `docs/issues/`, plans in `docs/planning/`)
   - Optionally add `opencode.json`, Copilot instructions, or Cursor rules
   - Ask about triage labels and domain doc layout
   - Check for `CONTRIBUTING.md` and `SECURITY_POLICY.md`

You are ready to invoke skills in that repo.

## Why These Skills Exist

These skills fix common failure modes I see with coding agents.

### #1: The Agent Didn't Do What I Want

> "No-one knows exactly what they want"
>
> David Thomas & Andrew Hunt, [The Pragmatic Programmer](https://www.amazon.co.uk/Pragmatic-Programmer-Anniversary-Journey-Mastery/dp/B0833F1T3V)

**The Problem**. The most common failure mode in software development is misalignment. You think the dev knows what you want. Then you see what they've built - and you realize it didn't understand you at all.

This is just the same in the AI age. There is a communication gap between you and the agent. The fix for this is a **grilling session** - getting the agent to ask you detailed questions about what you're building.

**The Fix** is to use:

- [`/grill-me`](./skills/productivity/grill-me/SKILL.md) - for non-code uses
- [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md) - same as [`/grill-me`](./skills/productivity/grill-me/SKILL.md), but adds more goodies (see below)

These are my most popular skills. They help you align with the agent before you get started, and think deeply about the change you're making. Use them _every_ time you want to make a change.

### #2: The Agent Is Way Too Verbose

> With a ubiquitous language, conversations among developers and expressions of the code are all derived from the same domain model.
>
> Eric Evans, [Domain-Driven-Design](https://www.amazon.co.uk/Domain-Driven-Design-Tackling-Complexity-Software/dp/0321125215)

**The Problem**: At the start of a project, devs and the people they're building the software for (the domain experts) are usually speaking different languages.

I felt the same tension with my agents. Agents are usually dropped into a project and asked to figure out the jargon as they go. So they use 20 words where 1 will do.

**The Fix** for this is a shared language. It's a document that helps agents decode the jargon used in the project.

<details>
<summary>
Example
</summary>

Here's an example [`CONTEXT.md`](https://github.com/mattpocock/course-video-manager/blob/076a5a7a182db0fe1e62971dd7a68bcadf010f1c/CONTEXT.md), from my `course-video-manager` repo. Which one is easier to read?

- **BEFORE**: "There's a problem when a lesson inside a section of a course is made 'real' (i.e. given a spot in the file system)"
- **AFTER**: "There's a problem with the materialization cascade"

This concision pays off session after session.

</details>

This is built into [`/grill-with-docs`](./skills/engineering/grill-with-docs/SKILL.md). It's a grilling session, but that helps you build a shared language with the AI, and document hard-to-explain decisions in ADR's.

It's hard to explain how powerful this is. It might be the single coolest technique in this repo. Try it, and see.

> [!TIP]
> A shared language has many other benefits than reducing verbosity:
>
> - **Variables, functions and files are named consistently**, using the shared language
> - As a result, the **codebase is easier to navigate** for the agent
> - The agent also **spends fewer tokens on thinking**, because it has access to a more concise language

### #3: The Code Doesn't Work

> "Always take small, deliberate steps. The rate of feedback is your speed limit. Never take on a task that's too big."
>
> David Thomas & Andrew Hunt, [The Pragmatic Programmer](https://www.amazon.co.uk/Pragmatic-Programmer-Anniversary-Journey-Mastery/dp/B0833F1T3V)

**The Problem**: Let's say that you and the agent are aligned on what to build. What happens when the agent _still_ produces crap?

It's time to look at your feedback loops. Without feedback on how the code it produces actually runs, the agent will be flying blind.

**The Fix**: You need the usual tranche of feedback loops: static types, browser access, and automated tests.

For automated tests, a red-green-refactor loop is critical. This is where the agent writes a failing test first, then fixes the test. This helps give the agent a consistent level of feedback that results in far better code.

I've built a **[`/tdd`](./skills/engineering/tdd/SKILL.md) skill** you can slot into any project. It encourages red-green-refactor and gives the agent plenty of guidance on what makes good and bad tests.

For debugging, I've also built a **[`/diagnose`](./skills/engineering/diagnose/SKILL.md)** skill that wraps best debugging practices into a simple loop.

### #4: We Built A Ball Of Mud

> "Invest in the design of the system _every day_."
>
> Kent Beck, [Extreme Programming Explained](https://www.amazon.co.uk/Extreme-Programming-Explained-Embrace-Change/dp/0321278658)

> "The best modules are deep. They allow a lot of functionality to be accessed through a simple interface."
>
> John Ousterhout, [A Philosophy Of Software Design](https://www.amazon.co.uk/Philosophy-Software-Design-2nd/dp/173210221X)

**The Problem**: Most apps built with agents are complex and hard to change. Because agents can radically speed up coding, they also accelerate software entropy. Codebases get more complex at an unprecedented rate.

**The Fix** for this is a radical new approach to AI-powered development: caring about the design of the code.

This is built in to every layer of these skills:

- [`/plan-it`](./skills/engineering/plan-it/SKILL.md) quizzes you about which modules you're touching before creating a plan
- [`/issue-it`](./skills/engineering/issue-it/SKILL.md) captures inbox intake; [`/plan-it`](./skills/engineering/plan-it/SKILL.md) always grills, then scaffolds phases and optional `jira.md`
- [`/zoom-out`](./skills/engineering/zoom-out/SKILL.md) gives a quick chat map of unfamiliar code
- [`/doc-it`](./skills/engineering/doc-it/SKILL.md) writes durable `docs/reference/` and a sliced `docs/reference-audit/` (tech debt, testing, architecture) when you need a real baseline

[`/improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) grills one deepening candidate; pair it with `/doc-it` when the repo needs both maps and a written backlog.

### Summary

Software engineering fundamentals matter more than ever. These skills are my best effort at condensing these fundamentals into repeatable practices, to help you ship the best apps of your career. Enjoy.

## About this fork

This repository is a fork tailored to my specific development workflow. After using the original skills for several weeks I found myself modifying and adding skills to match how I actually work — refactoring existing codebases, adding features, and addressing tech debt. Most requests come through Bitbucket, Jira, and a few other intake sources; the `issue-it` skill and the broader Doc Cycle (`plan-it` → `implement-it` → `audit-it` → `verify-it` → `commit-it`) grew out of that pattern. The introspective skills (`doc-it`, `zoom-out`, `improve-codebase-architecture`) are especially useful when picking up unfamiliar or legacy code — they build a map before you start changing things. Everything here works for me; it may or may not fit your setup, but the intent is to share a concrete, opinionated toolset rather than a generic framework.

## Issue tracking — three layers

| Layer | Path | Skills |
|-------|------|--------|
| **Inbox** | `docs/issues/*.md` | `/issue-it` (capture), audit → [audit-to-issues](./skills/engineering/setup-internal-skills/audit-to-issues.md) |
| **Plan** | `docs/planning/<id>/` | `/plan-it` — **always grills**, then phases + `sources/` (moved intake) |
| **Jira map** | `docs/planning/<id>/jira.md` | `/plan-it --jira` only — not issue-it |

At plan creation, `--from-issues` **moves** inbox files to `docs/planning/<id>/sources/` so the inbox stays unplanned-only. Phase Tasks and time estimates (`estimate_hours`, `timetracking`) are set when publishing Jira.

**Intake evaluation is built into plan-it.** `/plan-it --from-issues` handles both evaluation and planning in one session. Items at `status: intake` get triage-style assessment (codebase exploration, reproduction, clarifying questions) before the grill. Items at `ready-for-plan` go straight to the grill. No separate `/triage` step needed.

## Skill map — planning, slicing, executing

| | `/issue-it` | `/plan-it` |
|---|---|---|
| **Purpose** | Capture intake only | Evaluate intake + grill + scaffold phases; publish Jira map |
| **Output** | `docs/issues/<slug>.md` | `docs/planning/<id>/` + `sources/` + `jira.md` |
| **When** | New bug, defer, todo, feature | Plan design; **phase Jira** via `--jira` only |
| **Flags** | — | `--from-issues`, `--jira`, `--jira --sync-only`, `--parent` |

**Execution & close:**

| | `/implement-it` | `/audit-it` | `/verify-it` | `/commit-it` |
|---|---|---|---|---|
| **Does** | TDD per plan phase | Phase audit (spec, standards, compliance, architecture) | Durable docs after audit PASS | Commit locally, ask before push |
| **Jira** | Assignee + In Progress when `JIRA_ASSIGNEE` set | — | Assignee + close (transition to "Done") | — |

**Doc Cycle (plan-it–driven):** `/plan-it` → `/implement-it` (each phase) → `/audit-it` → `/verify-it` → `/commit-it`

**Codebase reference (onboarding or unfamiliar repo):**

| Skill | Writes | Use when |
|-------|--------|----------|
| **`/doc-it`** | `docs/reference/` + `docs/reference-audit/` | Baseline maps plus sliced audit (`tech-debt.md`, `testing.md`, `architecture.md`, `follow-ups.md`). Two phases in one skill. |
| `/zoom-out` | *(chat only)* | Quick orientation; no files. |
| `/audit-it` (repo) | `docs/AUDIT.md` | Tech-debt / simplification lens after you already know the repo. |
| `/verify-it` | ADRs, `CONTEXT.md`, changelog | **After** implementation of a plan, not discovery. |

**Typical flows:**

```
Ad-hoc plan:     /plan-it  →  grill  →  phases  →  Doc Cycle
Intake → plan:   /issue-it  →  /plan-it --from-issues  →  Doc Cycle
With Jira:       …  →  /plan-it --from-issues --jira  →  implement-it  →  audit-it  →  verify-it  →  commit-it
Incremental:     …  →  implement phase-N  →  audit-it --phase phase-N  →  verify-it --phase phase-N  →  …  →  full audit  →  full verify  →  commit-it
Audit backlog:   /doc-it  →  audit-to-issues  →  /plan-it --from-issues
Re-sync Jira:    /plan-it <id> --jira --sync-only   (keys in jira.md only)
Jira → plan:     /from-jira CDS-142                  (fetch Jira → grill → scaffold plan)
Issue → Jira:    /to-jira docs/issues/bug.md          (push single intake item to Jira)
Unfamiliar repo: /doc-it  →  follow-ups  →  issue-it / plan-it --from-issues
```

**Email / ServiceNow (org):** paste request in project repo → `/issue-it` → review `docs/issues/<slug>.md` → `/plan-it --from-issues` → `/plan-it <id> --jira [--parent EPIC]` (override `.env` default Epic). See [SCENARIO-EMAIL-SERVICENOW.md](./skills/engineering/setup-internal-skills/SCENARIO-EMAIL-SERVICENOW.md).

Deprecated: `/to-epic`, `/to-jiras`, `/promote-to-jira`, `/issue-it --jira` — use `/to-jira` or `/plan-it --jira` instead ([issue-it](./skills/engineering/issue-it/SKILL.md)).

## Reference

### Engineering

Skills I use daily for code work.

- **[audit-it](./skills/engineering/audit-it/SKILL.md)** — Doc Cycle audit phase; repo reviews write `docs/AUDIT.md`. Gates verify-it.
- **[commit-it](./skills/engineering/commit-it/SKILL.md)** — Doc Cycle close phase; commit locally, push only after user approval.
- **[diagnose](./skills/engineering/diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions.
- **[doc-it](./skills/engineering/doc-it/SKILL.md)** — **Baseline codebase documentation:** Phase 1 writes `docs/reference/`. Phase 2 writes `docs/reference-audit/` (`tech-debt.md`, `testing.md`, `architecture.md`, `follow-ups.md`, index `README.md`). Not `/verify-it` or `/zoom-out`.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `CONTEXT.md` and ADRs inline.
- **[implement-it](./skills/engineering/implement-it/SKILL.md)** — Doc Cycle implement phase. TDD with repo standards. Transitions Jira to "In Progress" on start.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in a codebase, informed by `CONTEXT.md` and `docs/adr/`; optional intake issues via [audit-to-issues](./skills/engineering/setup-internal-skills/audit-to-issues.md).
- **[internal-compliance](./skills/engineering/internal-compliance/SKILL.md)** — Pre-flight compliance check against internal security linting rules before finalizing any PR.
- **[plan-it](./skills/engineering/plan-it/SKILL.md)** — Doc Cycle plan phase. Always grills; phases, ADRs, `--from-issues` (moves intake to `sources/`), optional Jira → `jira.md`.
- **[prototype](./skills/engineering/prototype/SKILL.md)** — Build a throwaway prototype to flesh out a design.
- **[setup-internal-skills](./skills/engineering/setup-internal-skills/SKILL.md)** — Per-repo config; **default** local issues in `docs/issues/`. Run once per repo.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Test-driven development with red-green-refactor loop.
- **[issue-it](./skills/engineering/issue-it/SKILL.md)** — Pre-plan intake under `docs/issues/`.
- **[to-jira](./skills/engineering/to-jira/SKILL.md)** — Ad-hoc Jira handler and bridge reference: create, transition, resolve, comment, assign. Other skills source the connector bridge directly rather than delegating here.
- **[from-jira](./skills/engineering/from-jira/SKILL.md)** — Create a Doc Cycle plan from a Jira issue — no inbox step.
- **[verify-it](./skills/engineering/verify-it/SKILL.md)** — Doc Cycle verify phase. Finalizes ADRs, CONTEXT.md, changelog, and planning cleanup. Optionally close Jira issues.
- **[zoom-out](./skills/engineering/zoom-out/SKILL.md)** — Get broader context on unfamiliar code.

### Productivity

General workflow tools, not code-specific.

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler while keeping full technical accuracy.
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[write-a-skill](./skills/productivity/write-a-skill/SKILL.md)** — Create new skills with proper structure, progressive disclosure, and bundled resources.

## Credits

This is a **highly modified fork** of [mattpocock/skills](https://github.com/mattpocock/skills) (MIT License), originally created by [Matt Pocock](https://github.com/mattpocock). Canonical home: [ai-skills on Bitbucket](https://github.com/rshingleton/skills.git).

**Fork maintainer:** Russ Shingleton — you@example.com

This is a personal tool built for my workflow. Questions and feedback are welcome — I'll do my best to respond when I can.

### License

This fork carries forward the original MIT License. See [LICENSE](./LICENSE).
