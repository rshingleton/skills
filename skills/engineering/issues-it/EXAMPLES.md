# Issues It — Examples

## Review defer

```text
/issues-it
```

> "Defer CSV edge-case handling until after auth ships."

→ `docs/issues/defer-csv-edge-cases.md`, `type: defer`, `source: review`.

## Plan from intake

```text
/plan-it --from-issues docs/issues/auth-bug.md docs/issues/defer-csv-edge-cases.md --jira
```

→ inbox files moved to `docs/planning/auth-v2/sources/`; `jira.md` with phase ↔ CDS-* keys.

## Triage intake

```text
/triage docs/issues/auth-bug.md
```

→ updates `status` + `## Comments` per triage roles; when `ready-for-plan`, hand off to plan-it.

## Mark backlog ready for plan

Mark files `status: ready-for-plan`, then:

```text
/plan-it --from-issues ready
```
