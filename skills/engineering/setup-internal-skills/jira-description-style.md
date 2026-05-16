# Jira description style

**Required** for every Jira **create** (`POST /issue`): `summary`, `description`, and triage **create** text that becomes issue body.

**Goal:** Detailed enough that a human or AFK agent can implement without re-reading chat. **Not** chat-caveman fragments. **Not** AI essay prose.

Local `docs/issues/*.md` may stay expansive; **edit for Jira** when posting (`/to-epic`, `/to-jiras`, `/promote-to-jira`, `/plan-it` Jira publish, `/triage` create).

Use [caveman](../../productivity/caveman/SKILL.md) only as a **cut list** (drop filler, hedging, pleasantries) — not as the target voice for Jira.

## What to cut (anti-patterns)

- Openers: "This issue will…", "We need to ensure…", "Please refer to…"
- Restating the summary in the description
- Paragraph walls where bullets work
- Vague AC: "works correctly", "handles errors appropriately"
- Scope creep and design essays in Tasks (put deep design in Epic or `docs/planning/`)

## What to keep (required detail)

- **Concrete behavior** — inputs, outputs, edge cases, error handling
- **Exact names** — APIs, env vars, types, modules (no code dumps unless a short schema/snippet is the spec)
- **Testable acceptance criteria** — `- [ ]` one observable outcome per line
- **Dependencies** — `## Blocked` with keys or "None"
- **Epics:** numbered user stories (one line each is fine); **Implementation decisions** as bullets, not prose chapters

## Summary (title)

- One clear line; prefer &lt; ~100 chars.
- Specific verb + object: `Add OAuth callback handler` not `Implement comprehensive OAuth solution`.
- Articles OK when they aid clarity.

## Description structure

Use these sections when they apply (omit empty ones):

```markdown
## What
…

## Done when
- [ ] …

## Notes
…optional constraints, links to ADR/plan…

## Blocked
…
```

**Tasks:** `What` + `Done when` usually enough.  
**Epics:** add `## User stories`, `## Decisions`, `## Out of scope` as needed — still bullets, still dense.

### Example (Task) — good

```
## What
Login form validates email + password client-side, posts to POST /api/login, maps 401/422 to inline field errors.

## Done when
- [ ] Invalid email format shows error under email field
- [ ] Wrong password shows generic "Invalid credentials" (no account enumeration)
- [ ] Success redirects to /dashboard
- [ ] Unit tests cover validator + error mapping

## Blocked
None
```

### Example (Task) — bad (verbose, low signal)

> This task implements the vertical slice for user authentication. We will need to ensure that the login form validates input correctly and that errors are displayed to the user in a friendly manner. Please refer to the epic for additional context.

### Example (Task) — bad (too thin)

```
## What
Fix login.

## Done when
- [ ] Works
```

## Agent rule

Before `jq --arg body` or heredoc `description`:

1. Start from local task/epic/plan content.
2. **Compress** fluff (caveman cut list).
3. **Preserve** every decision and criterion needed to implement.
4. Do not paste local markdown verbatim if it contains chat tone or duplicate sections.

If local `docs/issues/` is already dense, light edit is enough. If local is a long epic, **summarize into structured Jira sections** — do not drop decisions, do not add filler.
