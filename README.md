# Internal Skills (ai-skills)

**Canonical repository:** [https://github.com/rshingleton/skills.git](https://github.com/rshingleton/skills.git) (Bitbucket, VPN required)

Descended from [mattpocock/skills](https://github.com/mattpocock/skills) (MIT License), adapted for our internal workflow.

My agent skills that I use every day to do real engineering - not vibe coding.

Developing real applications is hard. Approaches like GSD, BMAD, and Spec-Kit try to help by owning the process. But while doing so, they take away your control and make bugs in the process hard to resolve.

These skills are designed to be small, easy to adapt, and composable. They work with any model. They're based on decades of engineering experience. Hack around with them. Make them your own. Enjoy.

## Agent platforms

Instructions use the open **`AGENTS.md`** format (OpenCode, Cursor, Copilot, Claude Code). See [AGENTS.md](./AGENTS.md) and [docs/AGENT-PLATFORMS.md](./docs/AGENT-PLATFORMS.md).

| Tool | Config |
|------|--------|
| OpenCode | [opencode.json](./opencode.json) |
| Cursor | [.cursor/rules/](./.cursor/rules/) |
| GitHub Copilot | [.github/copilot-instructions.md](./.github/copilot-instructions.md) |
| Claude Code | [CLAUDE.md](./CLAUDE.md) + [.claude-plugin/plugin.json](./.claude-plugin/plugin.json) |

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

### Option C — symlink from your working copy

If you develop skills locally and want live symlinks into your checkout:

```bash
bash /path/to/ai-skills/scripts/link-skills.sh
```

**Make sure you select `/setup-internal-skills`**.

3. Set the required environment variables:

```bash
# Required for Jira integration
export JIRA_BASE_URL="https://jira.example.com"
export JIRA_API_TOKEN="your-jira-pat"
export JIRA_PROJECT_KEY="MT"
```

4. Run `/setup-internal-skills` in your **application repo** (in Cursor, Copilot, or OpenCode). It will:
   - Write **`AGENTS.md`** and `docs/agents/` (open format; local issues in `docs/issues/` by default)
   - Optionally add `opencode.json`, Copilot instructions, or Cursor rules
   - Ask about triage labels and domain doc layout
   - Check for `CONTRIBUTING.md` and `SECURITY_POLICY.md`

5. Bam - you're ready to go.

## Why These Skills Exist

I built these skills as a way to fix common failure modes I see with Claude Code, Codex, and other coding agents.

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
- [`/to-epic`](./skills/engineering/to-epic/SKILL.md) saves an Epic under `docs/issues/` (or Jira if configured)
- [`/zoom-out`](./skills/engineering/zoom-out/SKILL.md) tells the agent to explain code in the context of the whole system

And crucially, [`/improve-codebase-architecture`](./skills/engineering/improve-codebase-architecture/SKILL.md) helps you rescue a codebase that has become a ball of mud. I recommend running it on your codebase once every few days.

### Summary

Software engineering fundamentals matter more than ever. These skills are my best effort at condensing these fundamentals into repeatable practices, to help you ship the best apps of your career. Enjoy.

## Skill map — planning, slicing, executing

| | `/plan-it` | `/to-epic` | `/to-jiras` |
|---|---|---|---|
| **Purpose** | Grill, design, scaffold phases | Synthesize conversation → Epic | Break into implementable Tasks |
| **Jira output** | Optional: Task (≤3 phases) or Epic+Tasks (larger) | Epic with full Epic body | Tasks (standalone or `--parent EPIC-123`) |
| **Interview?** | Yes, deeply | No — synthesizes | Yes, on granularity |
| **When** | Exploring design, need architecture | Spec is clear, need formal Epic | Ready to assign work |

**Execution & close:**

| | `/implement-it` | `/audit-it` | `/verify-it` |
|---|---|---|---|
| **Does** | TDD per plan phase | Phase audit (spec, standards, compliance, architecture) | Durable docs after audit PASS |
| **Jira** | Auto-transitions to "In Progress" | — | Prompts to close (transition to "Resolved") |

**Doc Cycle (plan-it–driven):** `/plan-it` → `/implement-it` (each phase) → `/audit-it` → `/verify-it`

**Typical flows:**

```
Small change:  /to-jiras → /implement-it → /audit-it → /verify-it
Feature:       /grill-with-docs → /to-epic → /to-jiras --parent EPIC-123 → /implement-it → /audit-it → /verify-it
Large plan:    /grill-with-docs → /plan-it → (publish to Jira) → /implement-it (each phase) → /audit-it → /verify-it
```

## Reference

### Engineering

Skills I use daily for code work.

- **[audit-it](./skills/engineering/audit-it/SKILL.md)** — Doc Cycle audit phase; repo reviews write `docs/AUDIT.md`. Gates verify-it.
- **[diagnose](./skills/engineering/diagnose/SKILL.md)** — Disciplined diagnosis loop for hard bugs and performance regressions.
- **[grill-with-docs](./skills/engineering/grill-with-docs/SKILL.md)** — Grilling session that challenges your plan against the existing domain model, sharpens terminology, and updates `CONTEXT.md` and ADRs inline.
- **[implement-it](./skills/engineering/implement-it/SKILL.md)** — Doc Cycle implement phase. TDD with repo standards. Transitions Jira to "In Progress" on start.
- **[improve-codebase-architecture](./skills/engineering/improve-codebase-architecture/SKILL.md)** — Find deepening opportunities in a codebase, informed by the domain language in `CONTEXT.md` and the decisions in `docs/adr/`.
- **[internal-compliance](./skills/engineering/internal-compliance/SKILL.md)** — Pre-flight compliance check against internal security linting rules before finalizing any PR.
- **[plan-it](./skills/engineering/plan-it/SKILL.md)** — Doc Cycle plan phase. Grill, scaffold planning structure, draft ADRs. Optionally publish phases to Jira.
- **[prototype](./skills/engineering/prototype/SKILL.md)** — Build a throwaway prototype to flesh out a design.
- **[setup-internal-skills](./skills/engineering/setup-internal-skills/SKILL.md)** — Per-repo config; **default** local issues in `docs/issues/`. Run once per repo.
- **[tdd](./skills/engineering/tdd/SKILL.md)** — Test-driven development with red-green-refactor loop.
- **[to-epic](./skills/engineering/to-epic/SKILL.md)** — Epic as local `epic.md` or Jira Epic.
- **[to-jiras](./skills/engineering/to-jiras/SKILL.md)** — Vertical-slice tasks in `docs/issues/` or Jira.
- **[promote-to-jira](./skills/engineering/promote-to-jira/SKILL.md)** — Push local issues and optional plans to Jira.
- **[triage](./skills/engineering/triage/SKILL.md)** — Triage issues through a state machine (Jira issue tracker).
- **[verify-it](./skills/engineering/verify-it/SKILL.md)** — Doc Cycle verify phase. Finalizes ADRs, CONTEXT.md, changelog, and planning cleanup. Optionally close Jira issues.
- **[zoom-out](./skills/engineering/zoom-out/SKILL.md)** — Get broader context on unfamiliar code.

### Productivity

General workflow tools, not code-specific.

- **[caveman](./skills/productivity/caveman/SKILL.md)** — Ultra-compressed communication mode. Cuts token usage ~75% by dropping filler while keeping full technical accuracy.
- **[grill-me](./skills/productivity/grill-me/SKILL.md)** — Get relentlessly interviewed about a plan or design until every branch of the decision tree is resolved.
- **[handoff](./skills/productivity/handoff/SKILL.md)** — Compact the current conversation into a handoff document so another agent can continue the work.
- **[write-a-skill](./skills/productivity/write-a-skill/SKILL.md)** — Create new skills with proper structure, progressive disclosure, and bundled resources.

## Credits

This repository is an **internal adaptation** of [mattpocock/skills](https://github.com/mattpocock/skills) (MIT License), originally created by [Matt Pocock](https://github.com/mattpocock). Canonical home: [ai-skills on Bitbucket](https://github.com/rshingleton/skills.git).

We are grateful for the original work and have adapted it for our internal workflow. The core skills, design philosophy, and documentation structure remain largely based on Matt's original repository.

**All support requests should be directed to the internal Tools Team** — please do not file issues against the upstream repository for fork-specific modifications.

### License

This fork carries forward the original MIT License. See [LICENSE](./LICENSE).
