# Jira Epic sync — pull Tasks into `jira.md`

Use when Jira already has Tasks under an Epic but **`docs/planning/<plan-id>/jira.md`** is empty or incomplete.

**Invocation:** `/plan-it <plan-id> --jira --sync-only` on an **existing** plan (skips grill/rescaffold). Does **not** update remote Jira description text — keys in `jira.md` only.

For **creating** new Tasks (not just syncing), see [JIRA.md](../../plan-it/JIRA.md) — the publish flow creates Epic + Tasks and writes `jira.md`.

## When to run

| Situation | Action |
|-----------|--------|
| `JIRA_DEFAULT_EPIC` already has phase Tasks | `/plan-it --jira <plan-id> --sync-only` |
| Manual Jira setup before local map | Same |

## 1. Resolve Epic key

From `jira.md` frontmatter `epic_key`, `--parent`, or `resolve_jira_parent_epic` ([issue-tracker-jira.md](issue-tracker-jira.md#default-epic-optional)). Write `epic_key` into `jira.md` if newly resolved.

## 2. List Tasks under the Epic

```bash
source ~/.agents/skills/setup-internal-skills/scripts/load-jira-env.sh
EPIC_KEY="CDS-109"
JQL="cf[10880] = ${EPIC_KEY} AND issuetype = Task ORDER BY created ASC"

curl -s -G -H "Authorization: Bearer $JIRA_API_TOKEN" \
  --data-urlencode "jql=${JQL}" \
  --data-urlencode "maxResults=100" \
  --data-urlencode "fields=summary,key,created" \
  "$JIRA_BASE_URL/rest/api/2/search" \
  | jq -r '.issues[] | [.key, .fields.summary] | @tsv'
```

## 3. Match Jira Tasks → plan phases

Targets: `docs/planning/<plan-id>/phase-N/` in order (`phase-1`, `phase-2`, …).

| Rule | Match |
|------|--------|
| **Phase title** | Jira `summary` vs phase heading in `ai-prompt.md` or README phase list |
| **Index** | Only if phase count == Jira Task count — pair by `created ASC` |

Never assign one Jira key to two phases.

## 4. Write `jira.md`

1. Set frontmatter `epic_key` and `epic_summary` (GET Epic `summary` when possible).
2. Write **`## Parent Epic`** table — key, summary, browse link, `parent_source` ([JIRA.md](../../plan-it/JIRA.md)).
3. Update **`## Phase tasks`** table — one row per phase:

```markdown
| phase-1 | CDS-142 | Auth shell | 4h |
| phase-2 | CDS-143 | API wire | 8h |
```

4. Add `## Unmatched` for orphan Jira rows or phases without keys.

## 5. Report

```
Plan: auth-v2
Epic: CDS-109
Synced: 3 phases ← Jira
Created: 0
Unmatched Jira: CDS-145
Unmatched phases: phase-4
```
