# Jira Skill Interactions — Difficulties & Improvements

Observed during DASH-4185 admin vault page Jira task creation.

## Status

- `notifyUsers=false` consistency: **Resolved** — all helpers now include `?notifyUsers=false`. See `0002-consolidate-jira-api-helpers`.
- Transition verbosity: **Mitigated** — `_jira_transition` wraps the two-round-trip flow. See `0002-consolidate-jira-api-helpers`.
- implement-it/verify-it Jira integration: **Partially addressed** — helpers exist (`_jira_transition`, `_jira_comment`, `_jira_set_assignee`) but no auto-hook added.
- Remaining items (dry-run, error handling, custom field IDs, watcher feedback, batch create): **Open**.

## Difficulties

### 1. `_jira_curl` calling convention is unintuitive

The function is a curl auth wrapper, but the documented convention `_jira_curl POST "$URL"` fails — `POST` is passed to curl without `-X`, producing `Could not resolve host: POST`. The working convention:

```bash
echo "$payload" | _jira_curl -s -X POST "$URL" -H "Content-Type: application/json" -d @-
```

This requires piping. The wrapper does not accept HTTP method as a positional argument.

### 2. `_jira_wiki_body` file-arg requirement not documented

Takes a file path argument, not stdin. Passing heredoc content fails silently (sed reads from /dev/null). First attempt with inline markdown produced empty BODY with a sed error. Must write content to a temp file first.

### 3. Custom field IDs are magic strings

`customfield_10880` for Epic link is hardcoded in multiple places across skills. No discovery mechanism or documentation. If Jira instance is reconfigured or custom field IDs change, every skill breaks simultaneously with no obvious error.

### 4. No dry-run / test mode

Every POST is live against production Jira. No `--dry-run` flag. No way to preview the payload before sending. The `notifyUsers=false` flag helps but doesn't prevent issue creation.

### 5. Error handling is thin

HTTP 415 returns raw XML with no guidance on how to fix. The 415 in this session was caused by a missing `Content-Type: application/json` header — but the error message gave no hint.

Error responses from `_jira_curl` are printed to stdout, not captured or parsed. No retry logic for transient failures.

### 6. Watcher policy has no feedback

`_jira_apply_watcher_policy` returns no output on success or failure. After calling it, you don't know whether watchers were added, skipped, or if the function failed entirely.

### 7. Transition flow is fragile and verbose

Status transitions require: `GET /transitions` → parse JSON to find target status ID → `POST /transitions` with the ID. Two round-trips. The target status name must match Jira's exact spelling. If the workflow has multiple transitions to the same status (e.g., "In Progress" from different source statuses), `head -1` picks whichever Jira returns first, which may not be the correct one.

### 8. implement-it / verify-it Jira integration is manual

Both skills mention Jira transitions in their specs, but `to-jira` is an external skill that must be invoked separately. There is no automatic hook: when implement-it starts, the agent/user must remember to run `/to-jira transition DASH-4198 "In Progress"` or `/to-jira assign DASH-4198`. This is easy to forget.

### 9. `notifyUsers=false` inconsistency

Some curl snippets in OPERATIONS.md include `?notifyUsers=false` in the URL, others omit it. For issue creation, it's in the URL. For transitions and comments, it's sometimes present, sometimes not.

## Suggested Improvements

### 1. Fix `_jira_curl` convention

Accept HTTP method as first positional arg:

```bash
_jira_curl() {
    local method="${1:-GET}"; shift
    curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" -X "$method" "$@"
}
```

Usage: `_jira_curl POST "$URL" -d "$payload"`

### 2. Add dry-run to jira-helpers

Export a `JIRA_DRY_RUN=true` flag. When set, every `_jira_curl` call prints the method + URL + truncated payload instead of executing. Output a green "DRY RUN — no changes made." at the end.

```bash
_jira_curl() {
    local method="${1:-GET}"; shift
    if [ "${JIRA_DRY_RUN:-false}" = "true" ]; then
        echo "[DRY RUN] $method $1"
        echo "PAYLOAD: $(echo "$*" | jq -c '{summary: .fields.summary, issuetype: .fields.issuetype}' 2>/dev/null || echo "$*" | head -c 200)"
        return 0
    fi
    curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" -X "$method" "$@"
}
```

### 3. Document custom field IDs

Add a `custom-fields.md` reference alongside `jira-helpers.sh`:

```markdown
# Jira Custom Fields (DASH project)

| Field | ID | Purpose |
|-------|-----|---------|
| Epic Link | customfield_10880 | Links Task/Bug to parent Epic |
```

Or better, read from environment variables:

```bash
JIRA_FIELD_EPIC_LINK="${JIRA_FIELD_EPIC_LINK:-customfield_10880}"
```

### 4. Standardize `notifyUsers=false`

Add it to the `_jira_curl` wrapper automatically for POST/PUT/DELETE:

```bash
_jira_curl() {
    local method="$1"; shift
    local url="$1"; shift
    # Prepend notifyUsers=false to query string for mutating methods
    case "$method" in
        POST|PUT|DELETE)
            url="${url}${url#*\\? }&notifyUsers=false}"
            ;;
    esac
    curl -s -H "Authorization: Bearer $JIRA_API_TOKEN" -X "$method" "$url" "$@"
}
```

### 5. Auto-capture responses

Wrap `_jira_curl` to capture HTTP status + response body and surface non-2xx errors with actionable messages:

```bash
_jira_curl() {
    local response code
    response=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $JIRA_API_TOKEN" "$@")
    code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
    if [ "$code" -lt 200 ] || [ "$code" -ge 300 ]; then
        echo "Jira API error ($code):" >&2
        echo "$body" | jq -r '.errorMessages // .message // "Unknown error"' >&2
        return 1
    fi
    echo "$body"
}
```

### 6. implement-it should auto-transition Jira

If `docs/planning/{ID}/jira.md` has a key for the current phase, implement-it should auto-run:

```text
/to-jira transition <KEY> "In Progress"
/to-jira assign <KEY>
```

This should happen at the start of implement-it, with user confirmation:

> Transition DASH-4198 to "In Progress" and assign to you? (y/N)

If JIRA_ASSIGNEE is set in `.env`, use it automatically.

### 7. verify-it should auto-resolve Jira

Similarly, at phase end:

```text
/to-jira transition <KEY> "Done"
/to-jira comment <KEY> "Phase complete: ..."
```

### 8. Watcher policy should report

At minimum print a summary:

```text
Watchers added: user1, user2
Watchers removed (ignored): deprecated-bot
```

### 9. Batch creation for multi-phase plans

When creating Tasks under an Epic, POST all phases in parallel (they're independent), then collect keys. Saves N-1 round-trips for an N-phase plan.
