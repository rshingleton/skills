# Promote to Jira — Examples

## Promote a feature folder (epic + tasks)

Local tree:

```
docs/issues/widget-parser/
├── epic.md
└── tasks/
    ├── 01-parse-core.md
    └── 02-cli-entry.md
```

```text
/promote-to-jira widget-parser
```

Result: Epic `CDS-100`, tasks `CDS-101` / `CDS-102`; frontmatter on each file updated.

## Tasks only under existing Epic (no local epic.md)

```
docs/issues/cds-130/tasks/
├── 01-….md
└── …
```

```text
/promote-to-jira cds-130 --parent CDS-109
```

Or with env: `JIRA_DEFAULT_EPIC=CDS-109` and no `--parent`. Skips Epic creation; links Tasks to `CDS-109`.

## Promote with a plan cross-link

```text
/promote-to-jira widget-parser --plan widget-parser
```

**Requires** `docs/planning/widget-parser/README.md`. If that path is missing, promote issues anyway and report that the plan README was not updated.

## Dry run

```text
/promote-to-jira cds-130 --dry-run
```

Lists tasks and Epic resolution without calling Jira.
