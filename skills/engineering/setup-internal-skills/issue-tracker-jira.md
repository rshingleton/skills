# Issue tracker: Jira

Issues and Epics for this repo live as Jira issues. Use the Jira REST API v2 via `curl` for all operations.

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

Before Jira `curl` in a shell, run from the application repo (so its `.env` wins):

```bash
# Canonical (bundled with this skill):
source skills/engineering/setup-internal-skills/scripts/load-jira-env.sh

# Installed clone — same script via repo-root shim:
source ~/.local/share/ai-skills/scripts/load-jira-env.sh
```

The loader checks: `JIRA_ENV_FILE` (if set), then `./.env`, then `~/.agents/.env`, then `~/.config/ai-skills/.env`.

**Shell exports.** Alternatively `export JIRA_BASE_URL=...` etc. in your profile.

**Agents.** Before calling the Jira API, ensure all three variables are set. If the shell may not have them, `source` the loader script or read the `.env` file and export values for the session. Do not print tokens in chat output.

Optional project alias mapping (matching the doc-manager `PROJECT_<ALIAS>_KEY` convention):

| Variable | Purpose |
|---|---|
| `PROJECT_<ALIAS>_KEY` | Map a short alias to a real project key. E.g. `PROJECT_ISOFT_KEY=ISFONE`. |

## API Base

```
$JIRA_BASE_URL/rest/api/2
```

All calls use `Authorization: Bearer $JIRA_API_TOKEN` and `Content-Type: application/json`.

## Helper functions (copy into shell before Jira work)

| Function | Defined in | Use |
|----------|------------|-----|
| `_jira_apply_watcher_policy` | [jira-notifications.md](jira-notifications.md) | After every create / PUT / transition / comment |
| `_jira_set_assignee` | Below | Before implement / verify transitions when `JIRA_ASSIGNEE` set |
| `resolve_jira_parent_epic` | [Default Epic](#default-epic-optional) | Before `/plan-it --jira` creates |
| `_jira_phase_key` | Below | Read Jira key for current phase from `jira.md` |
| `_jira_wiki_body` | [jira-description-style.md](jira-description-style.md) | Optional markdown → wiki sed helper |
| `_jira_timetracking_fields` | [Time estimates](#time-estimates-timetracking) | Build `timetracking` object for `POST /issue` |

## Notification suppression (required on writes)

Follow [jira-notifications.md](jira-notifications.md) on **every** create, update, transition, and comment (same as doc-manager):

1. Append **`?notifyUsers=false`** to the URL.
2. Apply watcher policy: **remove** `JIRA_WATCHER_IGNORE` (or PAT from `JIRA_EMAIL`); **add** `JIRA_WATCHER_USERNAME` on creates ([jira-notifications.md](jira-notifications.md)).

Skips cause watcher email noise to service accounts and shared inboxes.

## Description style (required on create)

All **`summary`** and **`description`** fields on `POST /issue` must follow [jira-description-style.md](jira-description-style.md): **Jira wiki markup** (`h2.`, `*` bullets) — **never** markdown `##` or `- [ ]` in the POST body. Structured and detailed; no AI essay prose.

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
| `/triage` | Only when **creating** a new Jira issue — ask maintainer for hours |

**Duration format:** Jira duration strings — prefer **`{N}h`** for whole hours (`2h`, `8h`). Fractional hours: `30m`, `1h 30m`. Do not send raw numbers without a unit.

On create, set **`originalEstimate`** and **`remainingEstimate`** to the **same** value (remaining is updated as work logs).

**Omit** `timetracking` when no estimate is known and `JIRA_DEFAULT_ESTIMATE_HOURS` is unset.

### Resolve hours for a phase

1. `estimate_hours:` in `docs/planning/<id>/phase-N/ai-prompt.md` frontmatter (number).
2. Else `JIRA_DEFAULT_ESTIMATE_HOURS` from env.
3. Else ask once per phase during `/plan-it --jira` publish (record in frontmatter + `jira.md` **Est.** column).

### Shell helper

```bash
# Usage: _jira_hours_to_duration 4  → 4h
# Usage: _jira_timetracking_fields 4  → JSON fragment for jq --argjson
_jira_hours_to_duration() {
  local h="${1:-}"
  [ -z "$h" ] && return 1
  case "$h" in
    *h|*m|*d|*w) echo "$h" ;;  # already Jira duration
    *.*) printf '%sm' "$(echo "$h * 60" | bc 2>/dev/null | cut -d. -f1)" ;;
    *) echo "${h}h" ;;
  esac
}

_jira_timetracking_fields() {
  local dur
  dur="$(_jira_hours_to_duration "$1")" || return 1
  jq -n --arg o "$dur" --arg r "$dur" \
    '{timetracking: {originalEstimate: $o, remainingEstimate: $r}}'
}
```

### jq create (Task + Epic link + estimate + assignee)

```bash
EST_HOURS=$(awk -F': *' '/^estimate_hours:/{gsub(/[" \t]/,"",$2); print $2; exit}' \
  "docs/planning/${PLAN_ID}/phase-1/ai-prompt.md")
[ -z "$EST_HOURS" ] && EST_HOURS="${JIRA_DEFAULT_ESTIMATE_HOURS:-}"

PAYLOAD=$(jq -n \
  --arg project "$JIRA_PROJECT_KEY" \
  --arg summary "Phase 1 title" \
  --arg body "$BODY" \
  --arg epic "$EPIC_KEY" \
  --arg assignee "${JIRA_ASSIGNEE:-}" \
  '{
    fields: ({
      project: {key: $project},
      summary: $summary,
      description: $body,
      issuetype: {name: "Task"},
      customfield_10880: $epic,
      labels: ["ai-generated"]
    } + (if $assignee != "" then {assignee: {name: $assignee}} else {} end))
  }')

if [ -n "$EST_HOURS" ]; then
  DUR=$(_jira_hours_to_duration "$EST_HOURS")
  PAYLOAD=$(echo "$PAYLOAD" | jq --arg o "$DUR" --arg r "$DUR" \
    '.fields.timetracking = {originalEstimate: $o, remainingEstimate: $r}')
fi

curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
  -d "$PAYLOAD"
```

After POST, `_jira_apply_watcher_policy "$KEY" create`.

**Sync-only** (`--jira --sync-only`) does not backfill estimates on existing issues — use Jira UI or a manual PUT if needed.

## Assignee (`JIRA_ASSIGNEE`)

When `JIRA_ASSIGNEE` is set (e.g. `alice`), include assignee on **creates** and set/update on **Doc Cycle** Jira writes:

| Skill | When |
|-------|------|
| `/implement-it` | Before transitioning linked issue to In Progress |
| `/verify-it` | Before comment/transition when closing or updating linked issue |
| `/plan-it --jira` | Optional on `POST` create (`fields.assignee.name`) |
| `/triage` | Optional on `PUT` when taking ownership of triage |

`/audit-it` does not call Jira.

**Phase key from plan** (implement-it / verify-it):

```bash
# Usage: _jira_phase_key "<plan-id>" "phase-1"
_jira_phase_key() {
  local plan="$1" phase="$2" f="docs/planning/${plan}/jira.md"
  [ -f "$f" ] || return 1
  awk -F'|' -v p="$phase" '
    $0 ~ "\\| *" p " *\\|" {
      gsub(/^[ \t]+|[ \t]+$/, "", $3)
      if ($3 != "" && $3 !~ /^Jira$/) print $3
      exit
    }
  ' "$f"
}
```

**Assign existing issue** (after any PUT, run watcher policy):

```bash
_jira_set_assignee() {
  local key="$1"
  [ -z "${JIRA_ASSIGNEE:-}" ] || [ -z "$key" ] && return 0
  curl -s -o /dev/null -X PUT \
    -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    "$JIRA_BASE_URL/rest/api/2/issue/${key}?notifyUsers=false" \
    -d "{\"fields\": {\"assignee\": {\"name\": \"${JIRA_ASSIGNEE}\"}}}"
  _jira_apply_watcher_policy "$key" update
}
```

**On create** (jq — omit assignee key when unset):

```bash
# Inside fields: add assignee only when JIRA_ASSIGNEE is set
# assignee: (if $assignee != "" then {name: $assignee} else null end)
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
| 5 | This file | **default_epic:** `MT-100` below |

**default_epic:** ``

When all are empty, Tasks are created without Epic Link unless the user passes `--parent`.

**Agents:** If `JIRA_DEFAULT_EPIC` is set but the user or plan context implies a different Epic, use **`--parent`** — never override an explicit `--parent` with the env default.

### Resolving the parent Epic (agents)

Before POSTing Tasks, resolve the Epic key (equivalent logic in any language):

```bash
# Usage: resolve_jira_parent_epic "<--parent or empty>" "<plan-id or slug or empty>"
resolve_jira_parent_epic() {
  local flag_parent="$1" id="$2" k=""
  if [ -n "$flag_parent" ]; then echo "$flag_parent"; return; fi
  if [ -n "$id" ] && [ -f "docs/planning/${id}/jira.md" ]; then
    k=$(awk -F': *' '/^epic_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/planning/${id}/jira.md")
    [ -n "$k" ] && echo "$k" && return
  fi
  if [ -n "$id" ] && [ -f "docs/issues/${id}.md" ]; then
    k=$(awk -F': *' '/^jira_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/issues/${id}.md")
    [ -n "$k" ] && echo "$k" && return
  fi
  if [ -n "$id" ] && [ -f "docs/issues/${id}/epic.md" ]; then
    k=$(awk -F': *' '/^jira_key:/{gsub(/[" \t]/,"",$2); print $2; exit}' "docs/issues/${id}/epic.md")
    [ -n "$k" ] && echo "$k" && return
  fi
  if [ -n "${JIRA_DEFAULT_EPIC:-}" ]; then echo "$JIRA_DEFAULT_EPIC"; return; fi
  if [ -f docs/agents/issue-tracker.md ]; then
    k=$(grep -E '^\*\*default_epic:\*\*|^default_epic:' docs/agents/issue-tracker.md \
      | sed -n 's/.*`\([^`]*\)`.*/\1/p' | head -1)
    [ -n "$k" ] && echo "$k" && return
  fi
}
```

When a resolved Epic exists, set `customfield_10880` on Task creates. Tell the user which Epic was used when it was not passed explicitly.

After `/plan-it --jira` creates an Epic, suggest adding `JIRA_DEFAULT_EPIC=<key>` to the project `.env` if the team wants that Epic as the ongoing default.

## Conventions

- **Create an issue** (normal — use a heredoc for the body):
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
    -d '{
      "fields": {
        "project": {"key": "'"$JIRA_PROJECT_KEY"'"},
        "summary": "Issue title",
        "description": "Issue body in text or ADF",
        "issuetype": {"name": "Task"}
      }
    }'
  ```

  Then apply watcher policy (best-effort; [jira-notifications.md](jira-notifications.md)):

  ```bash
  _jira_apply_watcher_policy "<NEW_KEY>" create
  ```

  See [jira-notifications.md](jira-notifications.md) for the helper and rationale.

- **Create an issue with multi-line body** (use `jq` to build JSON safely):
  ```bash
  BODY=$(cat <<'ISSUEBODY'
  h2. What

  * Concrete behavior here

  h2. Done when

  * Testable outcome

  h2. Blocked

  None
  ISSUEBODY
  )
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
    -d "$(jq -n \
      --arg project "$JIRA_PROJECT_KEY" \
      --arg summary "Issue title" \
      --arg body "$BODY" \
      --arg est "${JIRA_DEFAULT_ESTIMATE_HOURS:-}" \
      '{
        fields: ({
          project: {key: $project},
          summary: $summary,
          description: $body,
          issuetype: {name: "Task"},
          labels: ["ai-generated"]
        } + (if $est != "" then {
          timetracking: {
            originalEstimate: ($est + "h"),
            remainingEstimate: ($est + "h")
          }
        } else {} end))
      }')"
  ```

  Issue `issuetype` values: `Task`, `Story`, `Bug`, `Epic`, `Sub-task`, `Improvement`. See [Time estimates](#time-estimates-timetracking) for per-phase hours.

- **Create an Epic**:
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue?notifyUsers=false" \
    -d '{
      "fields": {
        "project": {"key": "'"$JIRA_PROJECT_KEY"'"},
        "summary": "Epic title",
        "description": "Epic body",
        "issuetype": {"name": "Epic"},
        "customfield_10881": "Epic name"
      }
    }'
  ```

- **Create a Task linked to an Epic**:
  Add `"customfield_10880": "EPIC-123"` to the fields.

- **Read an issue**:
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    "$JIRA_BASE_URL/rest/api/2/issue/<KEY>"
  ```

- **Read issue comments**:
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    "$JIRA_BASE_URL/rest/api/2/issue/<KEY>/comment"
  ```

- **List issues by JQL**:
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    "$JIRA_BASE_URL/rest/api/2/search?jql=project+%3D+$JIRA_PROJECT_KEY+AND+status+%3D+%22Open%22&maxResults=20"
  ```

- **List Tasks under an Epic** (sync back to local — full flow in [jira-epic-sync.md](jira-epic-sync.md)):
  ```bash
  curl -s -G -H "Authorization: Bearer $JIRA_API_TOKEN" \
    --data-urlencode "jql=cf[10880] = EPIC-123 AND issuetype = Task ORDER BY created ASC" \
    --data-urlencode "maxResults=100" \
    --data-urlencode "fields=summary,key" \
    "$JIRA_BASE_URL/rest/api/2/search"
  ```

- **Comment on an issue**:
  ```bash
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue/<KEY>/comment?notifyUsers=false" \
    -d '{"body": "Comment text here"}'
  ```

- **Transition issue status**:
  ```bash
  TRANSITIONS=$(curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    "$JIRA_BASE_URL/rest/api/2/issue/<KEY>/transitions")
  TID=$(echo "$TRANSITIONS" | jq -r '.transitions[] | select(.name == "<Target Status>") | .id')
  curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" \
    -H "Content-Type: application/json" \
    -X POST \
    "$JIRA_BASE_URL/rest/api/2/issue/<KEY>/transitions?notifyUsers=false" \
    -d "{\"transition\": {\"id\": \"$TID\"}}"
  ```

## Triage state mapping

| Triage role | Jira status | Jira label |
|---|---|---|
| `needs-triage` | `Open` | `needs-triage` |
| `needs-info` | `On Hold` | `needs-info` |
| `ready-for-agent` | `Open` | `ready-for-agent` |
| `ready-for-human` | `Open` | `ready-for-human` |
| `wontfix` | `Closed` | `wontfix` |

## When a skill says "publish to the issue tracker"

Create a Jira issue via `curl` POST to `/rest/api/2/issue?notifyUsers=false`, then remove the API user from watchers per [jira-notifications.md](jira-notifications.md).

## When a skill says "fetch the relevant ticket"

Run `curl` to GET the issue by key and parse with `jq`. Fetch comments separately.
