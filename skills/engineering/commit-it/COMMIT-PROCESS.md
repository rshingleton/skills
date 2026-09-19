# Commit-it — Stage, message, commit (push on approval)

## Stage

One commit per Jira key. If the working tree has changes for multiple issues,
commit each group separately.

Present `git status --short` and identify which changes belong to the current
Jira key. Ask the user to confirm the file set. If unrelated changes are
present, warn and suggest separate commits.

## Jira key resolution

Commit messages must be prefixed with a Jira key (`CDS-135: <msg>`).
Read `docs/planning/{ID}/jira.md`:

| Scenario | Key to use |
|----------|-----------|
| Incremental close (`--phase phase-N`) | That phase's row in `## Phase tasks` |
| Full close, Epic exists | `epic_key` from frontmatter |
| Full close, no Epic | First phase key from `## Phase tasks` |

If `jira.md` is missing or keys empty, ask the user.

## Commit message

Format:

```
{JIRA-KEY}: <short summary>

<bullet-points>
```

Ask the user to confirm or edit. Do not push without approval.

Execute:

```bash
git commit -m "<title>" -m "<body>"
```

## Push and PR

Check the current branch:

```bash
git branch --show-current
```

If on `main` or `master`, ask to create a feature branch. Derive the name
from the plan title or commit message (`<type>/<short-description>`):

```bash
git checkout -b <branch-name>
```

If already on a feature branch:

**Ask the user to confirm pushing to the remote.** Do not push without
explicit approval. Present the branch name and remote. Only proceed when
the user says yes.

```bash
git push -u origin HEAD
```

**Optional PR** — only if the user asks (unprompted; do not offer):

```bash
gh pr create --title "<title>" --body "<summary>"
```

## Multi-phase plans with incremental close

If `/verify-it --phase` was used and phases remain, the tree may contain
next-phase changes. Offer:

- **Commit finished work now** (risks mixing phases — not recommended)
- **Wait until all phases are implemented, audited, and verified**

Defer to user preference.
