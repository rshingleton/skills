---
name: to-jira
description: >
  Central Jira operation handler. All skills delegate Jira API calls here
  instead of duplicating curl commands — create, transition, resolve,
  comment, assign, and watcher-policy. Automatically uses Jira MCP connector
  when available, falls back to curl/bash helpers. Reads docs/issues/<slug>.md or
  docs/planning/<id>/ and creates Jira issues from local artifacts.
  Use when user says to-jira, push to jira, create jira, make jira,
  create jira from issue, or promote to jira.
---

# To Jira

Central Jira operation handler. **All other skills delegate Jira API operations here** — no skill sources credentials or curls Jira directly.

**Default: Jira MCP connector preferred**

When available and authenticated, all operations automatically use the **Jira MCP connector**:
- ✅ No credential setup needed (OAuth handled automatically)
- ✅ Better error handling and retries
- ✅ Markdown → Jira wiki conversion built-in
- ✅ All `to-jira` commands work the same way

**Fallback: Curl/bash helpers**

If the connector is unavailable, operations fall back to bash helper functions from `setup-internal-skills/scripts/jira-helpers.sh`. Both paths are transparent to callers — they invoke `/to-jira` the same way. See [OPERATIONS.md](OPERATIONS.md) for implementation details.

## Quick start

Bare path defaults to `create`:

```text
/to-jira docs/issues/rate-limit-auth.md
/to-jira docs/issues/bug.md --parent CDS-200
/to-jira docs/planning/auth-v2/
```

Other operations:

```text
/to-jira create-epic "Plan Title" <plan-id>
/to-jira create-task <plan-id> phase-1
/to-jira transition KEY-123 "In Progress"
/to-jira resolve KEY-123 "Done"
/to-jira comment KEY-123 "Comment text"
/to-jira assign KEY-123
/to-jira watcher-policy KEY-123 create|update
/to-jira update-description KEY-123 path/to/description.md
```

## Connector availability

This skill automatically uses the **Jira MCP connector** when available and authenticated. The connector provides:

- **Authenticated access** — OAuth handled automatically, no credential setup needed
- **Better error handling** — Built-in retries and clearer error messages
- **Markdown support** — Descriptions are converted to Jira wiki format automatically
- **Fallback** — If the connector is unavailable, operations fall back to curl/bash helpers

### Setup: Add Jira MCP connector globally

Run these commands once to register the connectors:

```bash
claude mcp add --transport http jira https://your-jira-mcp-server.example.com/mcp
claude mcp add --transport http confluence https://your-confluence-mcp-server.example.com/mcp
```

This creates `~/.claude/.mcp.json` with the server URLs. The connectors will be available to all Claude Code CLI sessions across all projects.

### Authentication

Once added, authenticate the connector via Claude Code CLI:

**Interactive setup (recommended):**
```bash
claude /mcp
```

Then:
1. Select "Manage MCP servers"
2. Find "Jira" in the list
3. Click "Authenticate" 
4. Complete the OAuth flow in your browser
5. Return to Claude Code — credentials are cached locally

**Alternative: First use**
- Just try calling `/to-jira` or any Jira operation
- If not authenticated, Claude Code will prompt you to authorize
- Complete OAuth in browser
- Credentials cache for future sessions

**Desktop app users:**
- Authenticate in Claude desktop (UI button)
- CLI sessions will auto-detect and use those cached credentials

See [OPERATIONS.md](OPERATIONS.md) for connector tool signatures and comparison with bash helpers.

## Sourcing credentials (read first)

When using curl/bash helpers, source credentials once:

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
```

This sets `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` and provides all helper functions (`_jira_apply_watcher_policy`, `resolve_jira_parent_epic`, `_jira_timetracking_fields`, `_jira_wiki_body`, `_jira_set_assignee`, etc.).

For this ai-skills repo itself:

```bash
source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh
```

If credentials are missing after sourcing:
- Report the target key(s)
- Suggest checking `.env` at the repo root or `~/.config/ai-skills/.env`
- **Stop** — Jira operations cannot proceed without credentials

Each operation below says "(credentials)" instead of repeating this block. When using the connector, credentials are not required.

## Markdown → Jira wiki conversion (automatic)

All issue bodies are automatically converted from markdown to Jira wiki format before being sent to the API. **No pre-conversion needed** — write your local markdown normally.

**Conversion guarantees:**
- Headings `#`, `##`, `###` → `h1.`, `h2.`, `h3.` (Jira wiki headings)
- Inline code `` `text` `` → `{{text}}` (monospace, syntax-highlighted)
- Bold `**text**` → `*text*` (Jira wiki emphasis)
- Code blocks `` ```lang ... ``` `` → `{code:language=lang}...{code}` (with optional language hint)
- Links `[text](url)` → `text` (URL dropped, text preserved for manual linking)
- Bullets `- ` and task lists `- [ ]` / `- [x]` → `* ` (normalized to Jira bullets)

**Applied by:** `_jira_wiki_body` helper (in `jira-helpers.sh`), called automatically by:
- `_jira_create_epic` (Epic descriptions)
- `_jira_create_task` (Task descriptions)
- `_jira_update_description` (description updates)

Callers do **not** need to remember to convert — it's guaranteed by the helper functions.

## Default operation: `create`

When invoked with a **bare path** (no subcommand), `/to-jira <path>` runs the `create` flow. Aliases: any invocation that starts with a path or `--parent` flag triggers create.

Parts of this flow ask you questions before acting — Epic linking, phase splitting, and posting all require confirmation.

## Operations

### `create` — Create Jira issue(s) from a local artifact

| Source | Issue type | Behaviour |
|--------|-----------|-----------|
| `docs/issues/<slug>.md` | `Task` (feature/todo/defer) or `Bug` (bug) | Creates one Jira issue from intake body |
| `docs/planning/<id>/` | `Task` or per-phase Tasks | Detects phases and offers single vs per-phase |

#### Phase 1: Epic grill

If `--parent EPIC-KEY` was not passed:

1. Check `JIRA_DEFAULT_EPIC` env var.
2. If found, confirm with the user: *"Link to default Epic {JIRA_DEFAULT_EPIC}? (Y/n)"*. If no, ask for an alternate key or blank for standalone.
3. If not found, ask: *"Link this issue to an Epic? (key or blank)"*.

Resolved Epic key → set `customfield_10880` on the POST payload.

#### Phase 2: Phase detection (plan sources only)

When the source is `docs/planning/<id>/`:

1. Detect phases by listing `phase-*/ai-prompt.md` files.
2. If multiple phases found and an Epic is resolved (or `JIRA_DEFAULT_EPIC` is set), ask:

   > This plan has {N} phase(s). Create a single Task for the whole plan, or one Task per phase? (single/per-phase)

   - **single** → Create one `Task` from the plan README. Write one row in `jira.md` with that key for all phases.
   - **per-phase** → Run `create-task` for each phase under the resolved Epic. Write per-phase rows in `jira.md`.

   If no Epic is resolved, create one `Task` for the whole plan.

#### Phase 3: Create (use helpers, not raw curl)

1. Create Epic: call `_jira_create_epic` (see [OPERATIONS.md](OPERATIONS.md) `create-epic` block)
2. Create Tasks: call `_jira_create_task` per phase (see `create-task` block)
3. Apply watcher policy: `_jira_apply_watcher_policy "$KEY" create`
4. Write Jira key back to source (frontmatter for issues, per-phase rows for plans)

**Always use the helper functions from `jira-helpers.sh`** (sourced via `load-jira-env.sh`) — never construct raw `curl` commands or `jq` payloads yourself. Every helper handles auth, `notifyUsers=false`, error reporting, and watcher policy consistently. See [OPERATIONS.md](OPERATIONS.md) for the bash reference block of each operation.

## Delegation rules

| Skill | Delegates to `to-jira` | What |
|-------|------------------------|------|
| `plan-it` | `create-epic`, `create-task`, `watcher-policy` | Publish phase Tasks to Jira |
| `implement-it` | `transition`, `assign`, `watcher-policy` | Move phase to "In Progress" |
| `verify-it` | `resolve`, `comment`, `transition`, `watcher-policy` | Resolve phase in Jira |
| `from-jira` | `fetch-issue`, `fetch-comments` (via sourced helpers) | Reads FROM Jira — uses `_jira_fetch_issue` / `_jira_fetch_comments` directly since to-jira does not proxy reads |

## When to use

| Use `/to-jira` (this skill) | Other |
|-----------------------------|-------|
| Any Jira create/update/transition/comment | `/from-jira` for reading Jira → local plan |
| Single intake item needs Jira tracking | `/plan-it --jira` for Epic + per-phase Task hierarchy |
| Phase needs transition during implement-it | Direct Jira UI for manual edits |

## Not supported

- No sync direction from Jira back to local (use `/from-jira`)
- No JQL queries or bulk operations
