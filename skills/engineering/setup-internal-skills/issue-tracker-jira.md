# Issue tracker: Jira

Issues and Epics for this repo live as Jira issues. Skills delegate all Jira write operations to `to-jira`; this doc documents how `to-jira` works internally. For read-only fetch operations, skills use `from-jira` or direct `curl` GET.

## Quick start (agents)

One command loads env vars **and** all helper functions:

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
```

For this ai-skills repo itself:

```bash
source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh
```

Now you have `JIRA_BASE_URL`, `JIRA_API_TOKEN`, `JIRA_PROJECT_KEY` plus functions like `_jira_phase_key`, `_jira_apply_watcher_policy`, `_jira_timetracking_fields`, `_jira_wiki_body`, etc.

If the command sourced a `.env` file it reports which one (`JIRA_ENV_VERBOSE=1` for detail).

## Environment variables

The skills read these from the environment:

| Variable | Purpose |
|---|---|
| `JIRA_BASE_URL` | Jira instance base URL (e.g. `https://jira.example.com`). |
| `JIRA_API_TOKEN` | Personal access token (Bearer auth in `Authorization` header). |
| `JIRA_PROJECT_KEY` | Jira project key where issues live (e.g. `your-project-key`). |
| `JIRA_EMAIL` | Optional. **Not sent on API calls** — if `JIRA_WATCHER_IGNORE` is unset, remove `${JIRA_EMAIL%%@*}` from watchers after writes (PAT self-unwatch; doc-manager pattern). |
| `JIRA_WATCHER_IGNORE` | Optional. Comma-separated Jira usernames to **remove** from watchers after each write (`DELETE .../watchers?username=...`). When set, replaces the `JIRA_EMAIL` default. |
| `JIRA_WATCHER_USERNAME` | Optional. Comma-separated Jira usernames to **add** as watchers after each **create** (`POST .../watchers`). |
| `JIRA_DEFAULT_EPIC` | Optional. Default parent Epic key for new Tasks when skills omit `--parent` (see [Default Epic](#default-epic-optional)). |
| `JIRA_ASSIGNEE` | Optional. Jira **username** (`assignee.name`) for agent-owned work. Set on creates and on Doc Cycle updates (`/implement-it`, `/verify-it`). Omit to leave assignee unchanged. |
| `JIRA_DEFAULT_ESTIMATE_HOURS` | Optional. Fallback hours for Task **create** when phase/issue has no `estimate_hours` (e.g. `4` → `"4h"`). Omit to skip timetracking on create. |

### Loading credentials

**`.env` file (recommended).** Copy [`.env.example`](../../../.env.example) from the ai-skills repo to one of:

| Path | Scope | Precedence |
|------|--------|------------|
| `.env` at the application repo root | Per project | **Highest** (when cwd is that repo) |
| `~/.agents/.env` | Beside installed skills | |
| `~/.config/ai-skills/.env` | User-wide default | Lowest |

Set `JIRA_PROJECT_KEY` to your Jira project key and `JIRA_API_TOKEN` in that file. Do not commit tokens.

**One source command from any consumer repo:**

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
```

This finds the closest `.env` via `$JIRA_ENV_FILE` → `./.env` → `~/.agents/.env` → `~/.config/ai-skills/.env`, then sources the helper functions. The `./.env` at the application repo root wins when present — per-project credentials take precedence.

**Shell exports.** Alternatively `export JIRA_BASE_URL=...` etc. in your profile.

**Detecting the script path.** If `~/.agents/skills/setup-internal-skills/` does not exist, check for the clone at `~/.local/share/ai-skills/skills/engineering/setup-internal-skills/scripts/load-jira-env.sh`. If neither exists, the skills are not installed; run `/setup-internal-skills` first.

Optional project alias mapping (matching the doc-manager `PROJECT_<ALIAS>_KEY` convention):

| Variable | Purpose |
|---|---|
| `PROJECT_<ALIAS>_KEY` | Map a short alias to a real project key. E.g. `PROJECT_ISOFT_KEY=ISFONE`. |

## API Base

```
$JIRA_BASE_URL/rest/api/2
```

All calls use `Authorization: Bearer $JIRA_API_TOKEN` and `Content-Type: application/json`.

## Helper functions

All Jira shell helpers are in a single source-able script. They become available automatically when you source `load-jira-env.sh`, or you can source directly:

```bash
source ~/.agents/skills/setup-internal-skills/scripts/jira-helpers.sh
```

| Function | Use |
|----------|------|
| `_jira_require_env` | Validate `JIRA_BASE_URL` + `JIRA_API_TOKEN` are set |
| `_jira_comment` | POST comment, `notifyUsers=false` |
| `_jira_transition` | GET transitions → POST status change → watcher policy |
| `_jira_create_epic` | POST a new Epic, watcher policy, echoes key |
| `_jira_create_task` | POST a new Task (Epic Link, timetracking, assignee), echoes key |
| `_jira_update_issue` | PUT partial field update, watcher policy |
| `_jira_set_labels` | GET labels → append → PUT, watcher policy |
| `_jira_fetch_issue` | GET issue JSON (selectable fields) |
| `_jira_fetch_comments` | GET comments JSON |
| `_jira_search` | GET JQL search (max results, field select) |
| `_jira_set_assignee` | PUT assignee (no watcher policy — call separately) |
| `_jira_apply_watcher_policy` | Remove ignored + optionally add watchers |
| `_jira_phase_key` | Read Jira key for phase from `jira.md` |
| `_jira_timetracking_fields` | Build `timetracking` JSON from hours |
| `_jira_hours_to_duration` | Convert number to Jira duration string |
| `_jira_wiki_body` | Markdown → Jira wiki markup (sed) |
| `resolve_jira_parent_epic` | Resolve parent Epic from flags, env, or `jira.md` |
| `_jira_ensure_project_key` | Infer `JIRA_PROJECT_KEY` from a known Jira key |

## Notification suppression (required on writes)

Follow `~/.agents/skills/setup-internal-skills/jira-notifications.md` on **every** create, update, transition, and comment (same as doc-manager):

1. Append **`?notifyUsers=false`** to the URL.
2. Call `_jira_apply_watcher_policy "$KEY" create` after creates, `_jira_apply_watcher_policy "$KEY" update` after updates/transitions/comments.

Skips cause watcher email noise to service accounts and shared inboxes.

Note: `_jira_set_assignee` does **not** call watcher policy — call `_jira_apply_watcher_policy` separately after assignee changes.

### Known notification leakage — auto-watch

Jira **auto-adds the PAT owner** as a watcher to any issue they create. This triggers a separate "you are now watching" notification that `?notifyUsers=false` on the create request does **not** suppress. The watcher policy removes the PAT owner after the fact, but the auto-watch notification fires at create time and cannot be prevented via API.

**Belt-and-suspenders:** some Jira Server versions also respect `notifyUsers` as a **field in the request body** on issue create. Adding it alongside the query parameter provides extra coverage:

```json
{
  "fields": {...},
  "notifyUsers": false
}
```

This is not standard across all Jira DC versions, so always keep the query parameter too.

**Most reliable mitigation:** disable "Watching" email notifications for the PAT owner's Jira user account (User profile → Notification settings → Watching → off). This eliminates the auto-watch notification at the source regardless of API behavior.

## Description style (required on create)

All **`summary`** and **`description`** fields on `POST /issue` must follow `~/.agents/skills/setup-internal-skills/jira-description-style.md`: **Jira wiki markup** (`h2.`, `*` bullets) — **never** markdown `##` or `- [ ]` in the POST body. Structured and detailed; no AI essay prose.

Use `_jira_wiki_body <file>` to convert markdown to wiki markup.

## Time estimates (`timetracking`)

On **Task** (and **Story** / **Bug**) **create**, set **Original** and **Remaining** estimate so Jira time tracking works. Use the REST **`timetracking`** object (Jira Server / DC v2):

```json
{
  "fields": {
    "timetracking": {
      "originalEstimate": "2h",
      "remainingEstimate": "2h"
    }
  }
}
```

| Skill | When |
|-------|------|
| `/plan-it --jira` | Each new phase Task — hours from `phase-N/ai-prompt.md` `estimate_hours:` or ask during publish |
| `/issue-it` + `/plan-it --from-issues` | Capture locally, then evaluate during intake; plan-it creates Jira phase Tasks on publish |

**Duration format:** Jira duration strings — prefer **`{N}h`** for whole hours (`2h`, `8h`). Fractional hours: `30m`, `1h 30m`. Do not send raw numbers without a unit.

On create, set **`originalEstimate`** and **`remainingEstimate`** to the **same** value (remaining is updated as work logs).

**Omit** `timetracking` when no estimate is known and `JIRA_DEFAULT_ESTIMATE_HOURS` is unset.

### Resolve hours for a phase

1. `estimate_hours:` in `docs/planning/<id>/phase-N/ai-prompt.md` frontmatter (number).
2. Else `JIRA_DEFAULT_ESTIMATE_HOURS` from env.
3. Else ask once per phase during `/plan-it --jira` publish (record in frontmatter + `jira.md` **Est.** column).

### Using the helpers

```bash
_jira_hours_to_duration 4    # → 4h
_jira_hours_to_duration 2.5  # → 150m
_jira_timetracking_fields 4  # → {"timetracking":{"originalEstimate":"4h","remainingEstimate":"4h"}}
```

### Create a Task with Epic link + estimate + assignee

```bash
EST_HOURS=$(awk -F': *' '/^estimate_hours:/{gsub(/[" \t]/,"",$2); print $2; exit}' \
  "docs/planning/${PLAN_ID}/phase-1/ai-prompt.md")
[ -z "$EST_HOURS" ] && EST_HOURS="${JIRA_DEFAULT_ESTIMATE_HOURS:-}"

_jira_create_task "$JIRA_PROJECT_KEY" "Phase 1 title" "$BODY_FILE" "$EPIC_KEY" "$EST_HOURS" "${JIRA_ASSIGNEE:-}"
```

After POST, `_jira_apply_watcher_policy "$KEY" create`.

**Sync-only** (`--jira --sync-only`) does not backfill estimates on existing issues — use Jira UI or a manual PUT if needed.

## Assignee (`JIRA_ASSIGNEE`)

When `JIRA_ASSIGNEE` is set (e.g. `alice`), include assignee on **creates** and set/update on **Doc Cycle** Jira writes. `_jira_set_assignee` does NOT apply watcher policy — call `_jira_apply_watcher_policy "$KEY" update` separately after the assignee PUT.

| Skill | When |
|-------|------|
| `/implement-it` | Before transitioning linked issue to In Progress |
| `/verify-it` | Before comment/transition when closing or updating linked issue |
| `/plan-it --jira` | Optional on `POST` create (`fields.assignee.name`) |
| `/plan-it --from-issues` | During intake evaluation of Jira items (labels, transitions, comments) |

`/audit-it` does not call Jira.

**Phase key from plan** (implement-it / verify-it):

```bash
_jira_phase_key "<plan-id>" "phase-1"
```

The helper lives in `jira-helpers.sh` (sourced via `load-jira-env.sh`).

**Set assignee on an existing issue** (does NOT apply watcher policy):

```bash
_jira_set_assignee "$KEY"
```

Then apply watcher policy if needed:
```bash
_jira_apply_watcher_policy "$KEY" update
```

## Epic custom fields

These standard Jira custom fields are used when creating or linking Epics:

| Field | Customfield ID | Used by |
|---|---|---|
| **Epic Name** | `customfield_10881` | `/plan-it --jira` when creating an Epic. Set to the Epic's summary/title. |
| **Epic Link** | `customfield_10880` | `/plan-it --jira` with `--parent` or default Epic. Links the Task to the parent Epic. |

If your Jira instance uses different customfield IDs, update them in the skill files or at `docs/agents/issue-tracker.md`.

## Default Epic (optional)

Use a default parent Epic so `/plan-it --jira` can link phase Tasks without passing `--parent` every time.

| Priority | Source | Example |
|----------|--------|---------|
| 1 | **`--parent` on the skill invocation** | `/plan-it --jira my-plan --parent MT-100` — **always overrides `.env`** |
| 2 | Plan Jira map | `epic_key:` in `docs/planning/<plan-id>/jira.md` |
| 3 | Intake file | `jira_key:` on `docs/issues/<slug>.md` or `sources/*.md` |
| 4 | Project `.env` | `JIRA_DEFAULT_EPIC=MT-100` |
| 5 | This file | **default_epic:** `` below |

**default_epic:** ``

When all are empty, Tasks are created without Epic Link unless the user passes `--parent`.

**Agents:** If `JIRA_DEFAULT_EPIC` is set but the user or plan context implies a different Epic, use **`--parent`** — never override an explicit `--parent` with the env default.

### Resolving the parent Epic (agents)

Before POSTing Tasks, resolve the Epic key:

```bash
resolve_jira_parent_epic "<--parent or empty>" "<plan-id or slug or empty>"
```

The helper lives in `jira-helpers.sh`. When a resolved Epic exists, set `customfield_10880` on Task creates. Tell the user which Epic was used when it was not passed explicitly.

After `/plan-it --jira` creates an Epic, suggest adding `JIRA_DEFAULT_EPIC=<key>` to the project `.env` if the team wants that Epic as the ongoing default.

## Conventions

All operations delegate to `_jira_*` helpers (sourced via `load-jira-env.sh`):

| Operation | Helper |
|-----------|--------|
| Create a Task | `_jira_create_task "$JIRA_PROJECT_KEY" "summary" "body_file.md"` |
| Create an Epic | `_jira_create_epic "$JIRA_PROJECT_KEY" "Epic title"` |
| Create a Task linked to an Epic | `_jira_create_task "$JIRA_PROJECT_KEY" "summary" "body_file.md" "EPIC-123"` |
| Read an issue | `_jira_fetch_issue "KEY-123"` |
| Read issue comments | `_jira_fetch_comments "KEY-123"` |
| List issues by JQL | `_jira_search "project = KEY AND status = Open" 20` |
| List Tasks under an Epic | `_jira_search "cf[10880] = EPIC-123 AND issuetype = Task" 100` |
| Comment on an issue | `_jira_comment "KEY-123" "Comment text"` |
| Transition issue status | `_jira_transition "KEY-123" "Done"` |
| Set assignee | `_jira_set_assignee "KEY-123"` |
| Apply watcher policy | `_jira_apply_watcher_policy "KEY-123" create` (or `update`) |
| **Dry-run any operation** | `_jira_curl POST --dry-run "$JIRA_BASE_URL/rest/api/2/issue" -d '{}'` |

Dry-run: pass `--dry-run` as the second arg to `_jira_curl` to preview the
method, URL, and truncated payload without executing. Works with any HTTP
method. Not available on the higher-level helpers — call `_jira_curl` directly
for dry-run.

Issue `issuetype` values: `Task`, `Story`, `Bug`, `Epic`, `Sub-task`, `Improvement`.

## Triage state mapping

| State | Jira status | Jira label |
|-------|-------------|------------|
| `intake` | `Open` | `intake` |
| `ready-for-plan` | `Open` | `ready-for-plan` |
| `wontfix` | `Closed` | `wontfix` |

## When a skill says "publish to the issue tracker"

Delegate to `to-jira`: `/to-jira create <path>`. The raw API pattern (POST `/rest/api/2/issue?notifyUsers=false` + watcher policy) is what `to-jira` executes internally.

## When a skill says "fetch the relevant ticket"

`_jira_fetch_issue "<KEY>"` to get issue JSON, `_jira_fetch_comments "<KEY>"` for comments. Parse with `jq`.
