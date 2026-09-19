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
| Add watcher | POST | `/rest/api/2/issue/{key}/watchers?notifyUsers=false` |
| Remove watcher | DELETE | `/rest/api/2/issue/{key}/watchers?username={u}&notifyUsers=false` |

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

## 3. Known notification leakage via auto-watch

Jira **auto-adds the PAT owner** as a watcher to any issue they create. This triggers a separate notification event that `notifyUsers=false` on the create request does **not** suppress. Our watcher policy removes the PAT owner after the fact, but the initial auto-watch notification may have already been sent.

This affects only the **PAT owner** (not other watchers) and only on **issue create** (not on updates/transitions).

**Mitigations:**

- **Disable email notifications for the PAT owner's Jira account.** In Jira user preferences → Notification settings, turn off "Watching" notifications. This prevents auto-watch emails regardless of API parameters. This is the most reliable fix.
- **Use a dedicated service account** for the API token with email notifications globally disabled in Jira user preferences.
- The `?notifyUsers=false` parameter is also added to the watchers DELETE and POST calls (see [jira-helpers.sh](./scripts/jira-helpers.sh)) to suppress any notification the watchers endpoint itself might trigger.

## Helper functions

All watcher helpers are in **`jira-helpers.sh`** (sourced automatically via `load-jira-env.sh`):

| Function | Purpose |
|----------|---------|
| `_jira_apply_watcher_policy "$KEY" create` | After POST create — removes ignored + adds watchers |
| `_jira_apply_watcher_policy "$KEY" update` | After PUT, transition, or comment — remove ignored only |
| `_jira_remove_ignored_watchers "$KEY"` | Remove per `JIRA_WATCHER_IGNORE` / `JIRA_EMAIL` |
| `_jira_add_watchers "$KEY"` | Add per `JIRA_WATCHER_USERNAME` |

These are defined in `scripts/jira-helpers.sh` alongside the other Jira helpers.

## Checklist (agents)

After each Jira write batch:

1. Every POST/PUT used `?notifyUsers=false` — including watchers add/remove.
2. Ignored usernames removed per `JIRA_WATCHER_IGNORE` / `JIRA_EMAIL`.
3. On creates, `JIRA_WATCHER_USERNAME` users added when set.
4. Tokens and usernames were not printed in chat.
5. For the PAT owner's auto-watch email: not suppressible via API — requires disabling "Watching" notifications on the PAT owner's Jira user account.

## Reference

doc-manager: `POST /issue?notifyUsers=false`, then `DELETE .../watchers?username=...` for the PAT owner.
