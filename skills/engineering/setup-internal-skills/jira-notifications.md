# Jira notification suppression

Required for **every Jira write** from agent skills (`/to-epic`, `/to-jiras`, `/plan-it`, `/promote-to-jira`, `/triage`, `/implement-it`, `/verify-it`). Same approach as **doc-manager** (`notifyUsers=false` + remove API user from watchers).

## 1. `notifyUsers=false` on all writes

Append the query parameter to **every** mutating request. Do not skip on Epic vs Task.

| Operation | Method | URL pattern |
|-----------|--------|-------------|
| Create Epic or Task | POST | `/rest/api/2/issue?notifyUsers=false` |
| Update fields | PUT | `/rest/api/2/issue/{key}?notifyUsers=false` |
| Transition | POST | `/rest/api/2/issue/{key}/transitions?notifyUsers=false` |
| Comment | POST | `/rest/api/2/issue/{key}/comment?notifyUsers=false` |

GET and search JQL do not use this parameter.

## 2. Remove the API user from watchers (after writes)

Jira adds the **PAT owner** (not the email in any header — skills use `Authorization: Bearer` only) as a **watcher** on create/update. `notifyUsers=false` only suppresses email for that request; the account still receives mail on later changes unless unwatched.

Set **`JIRA_WATCHER_USERNAME`** or **`JIRA_EMAIL`** in `.env` so agents know which username to pass to the DELETE endpoint. Example (doc-manager service account): `JIRA_EMAIL=dashboard@example.com` → watcher user `dashboard`. If you already know the Jira username, set `JIRA_WATCHER_USERNAME` alone.

Immediately after a successful **create**, or any **PUT** / **transition** that changes the issue:

```bash
# Username: JIRA_WATCHER_USERNAME, or local-part of JIRA_EMAIL (doc-manager default)
WATCHER_USER="${JIRA_WATCHER_USERNAME:-${JIRA_EMAIL%%@*}}"

curl -s -o /dev/null -w "%{http_code}" -X DELETE \
  -H "Authorization: Bearer $JIRA_API_TOKEN" \
  "$JIRA_BASE_URL/rest/api/2/issue/<KEY>/watchers?username=${WATCHER_USER}"
```

- **Best-effort:** 404 is fine (not watching). Do not fail the parent operation if DELETE errors.
- Set `JIRA_WATCHER_USERNAME` when the Jira username is not the email prefix (e.g. email `svc-doc@example.com` but Jira user `svc-doc-manager`).

## Checklist (agents)

After each Jira write batch:

1. Every POST/PUT used `?notifyUsers=false`.
2. Each new or touched issue key got a watcher DELETE for the API user.
3. Tokens and watcher usernames were not printed in chat.

## Reference

doc-manager: `JiraClient.create_issue` / `update_issue` in `doc-manager` (`POST /issue?notifyUsers=false`, then `DELETE .../watchers?username=...`).
