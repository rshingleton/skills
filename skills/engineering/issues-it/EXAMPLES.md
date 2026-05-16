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

→ `docs/planning/auth-v2/`, `## Sources`, `jira.md` with phase ↔ CDS-* keys.

## Groom backlog

Mark files `status: ready-for-plan`, then:

```text
/plan-it --from-issues ready
```
