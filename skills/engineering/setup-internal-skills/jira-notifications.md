# Jira notification suppression

Required for **every Jira write** from agent skills (`/plan-it --jira`, `/plan-it --from-issues`, `/implement-it`, `/verify-it`). Same approach as **doc-manager** (`notifyUsers=false` + watcher policy after writes). **Creates:** also follow [jira-description-style.md](jira-description-style.md) (dense structured summaries/descriptions).

## 1. `notifyUsers=false` on all writes

Append the query parameter to **every** mutating request. Do not skip on Epic vs Task.

| Operation | Method | URL pattern |
|-----------|--------|-------------|
| Create Epic or Task | POST | `/rest/api/2/issue?notifyUsers=false` |
| Update fields | PUT | `/rest/api/2/issue/{key}?notifyUsers=false` |
| Transition | POST | `/rest/api/2/issue/{key}/transitions?notifyUsers=false` |
| Comment | POST | `/rest/api/2/issue/{key}/comment?notifyUsers=false` |

GET and search JQL do not use this parameter.

## 2. Watcher policy (after writes)

Jira adds the **PAT owner** as a watcher on create/update. `notifyUsers=false` only suppresses email for that request. Use env vars to **remove** unwanted watchers and **add** intended ones.

| Variable | API | Purpose |
|----------|-----|---------|
| `JIRA_WATCHER_IGNORE` | `DELETE .../watchers?username=` | Comma-separated Jira usernames to **remove** after each write (e.g. service account). |
| `JIRA_WATCHER_USERNAME` | `POST .../watchers` | Comma-separated Jira usernames to **add** as watchers after each **create** (optional). |
| `JIRA_EMAIL` | (fallback for IGNORE) | If `JIRA_WATCHER_IGNORE` is unset, remove `${JIRA_EMAIL%%@*}` (PAT owner; doc-manager default). |

- If **`JIRA_WATCHER_IGNORE`** is set, only those usernames are removed (`JIRA_EMAIL` is not auto-added unless listed).
- If **`JIRA_WATCHER_IGNORE`** is unset and **`JIRA_EMAIL`** is set, remove the email local-part once (PAT self-unwatch).
- **`JIRA_WATCHER_USERNAME`** is independent — use for humans/teams who should watch agent-created issues.

### Helpers (agents)

```bash
# Comma- or space-separated list → words
_jira_split_usernames() { echo "${1//,/ }"; }

_jira_remove_ignored_watchers() {
  local key="$1" users="" u
  if [ -n "${JIRA_WATCHER_IGNORE:-}" ]; then
    users="$(_jira_split_usernames "$JIRA_WATCHER_IGNORE")"
  elif [ -n "${JIRA_EMAIL:-}" ]; then
    users="${JIRA_EMAIL%%@*}"
  fi
  for u in $users; do
    [ -z "$u" ] && continue
    curl -s -o /dev/null -X DELETE \
      -H "Authorization: Bearer $JIRA_API_TOKEN" \
      "$JIRA_BASE_URL/rest/api/2/issue/${key}/watchers?username=${u}" 2>/dev/null || true
  done
}

_jira_add_watchers() {
  local key="$1" u
  [ -z "${JIRA_WATCHER_USERNAME:-}" ] && return 0
  for u in $(_jira_split_usernames "$JIRA_WATCHER_USERNAME"); do
    [ -z "$u" ] && continue
    curl -s -o /dev/null -X POST \
      -H "Authorization: Bearer $JIRA_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$(jq -n --arg u "$u" '$u')" \
      "$JIRA_BASE_URL/rest/api/2/issue/${key}/watchers" 2>/dev/null || true
  done
}

# After create: remove ignored, then add watchers. After update/transition: remove only.
_jira_apply_watcher_policy() {
  local key="$1" mode="${2:-create}"
  _jira_remove_ignored_watchers "$key"
  [ "$mode" = "create" ] && _jira_add_watchers "$key"
}

# Legacy alias used in skill examples
_remove_jira_watcher() { _jira_apply_watcher_policy "$1" "update"; }
```

Call `_jira_apply_watcher_policy "$KEY" create` after **POST** create; `_jira_apply_watcher_policy "$KEY" update` after PUT, transition, or comment.

## Checklist (agents)

After each Jira write batch:

1. Every POST/PUT used `?notifyUsers=false`.
2. Ignored usernames removed per `JIRA_WATCHER_IGNORE` / `JIRA_EMAIL`.
3. On creates, `JIRA_WATCHER_USERNAME` users added when set.
4. Tokens and usernames were not printed in chat.

## Reference

doc-manager: `POST /issue?notifyUsers=false`, then `DELETE .../watchers?username=...` for the PAT owner.
