# Issue It — Examples

## Review defer

```text
/issue-it
```

> "Defer CSV edge-case handling until after auth ships."

→ `docs/issues/defer-csv-edge-cases.md`, `type: defer`, `source: review`.

## Plan from intake

```text
/plan-it --from-issues docs/issues/auth-bug.md docs/issues/defer-csv-edge-cases.md --jira
```

→ inbox files moved to `docs/planning/auth-v2/sources/`; `jira.md` with phase ↔ CDS-* keys.

## Evaluate intake during plan-it

```text
/plan-it --from-issues docs/issues/auth-bug.md
```

→ evaluates `status: intake` items, updates `## Comments`, recommends role; on `ready-for-plan` proceeds to The Grill. No separate `/triage` step.

## Mark intake items ready for plan

Mark files `status: ready-for-plan`, then:

```text
/plan-it --from-issues ready
```
