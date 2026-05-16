# Promote to Jira — Examples

## Promote a feature folder

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

Result: Epic `MT-100`, tasks `MT-101` / `MT-102`; frontmatter on each file updated.

## Promote with a plan cross-link

```text
/promote-to-jira widget-parser --plan widget-parser
```

Reads `docs/planning/widget-parser/README.md` for phase context; writes Jira section into plan README.

## Tasks only under existing Epic

```text
/promote-to-jira widget-parser --parent MT-100
```

Skips Epic creation; links new Tasks to `MT-100`.
