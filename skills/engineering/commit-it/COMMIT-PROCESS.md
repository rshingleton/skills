# commit-it: docs commit, push and PR on approval

## Stage

Stage only what `/verify-it` changed, by path:

```bash
git add docs/adr/ GLOSSARY.md <changelog file>
git add <each docs/issues/*.md verify-it filed>   # shortcut issues, if any
git add -A docs/planning/{ID}/   # records the planning removal
```

Present `git status --short` and ask the user to confirm the file set. If
anything else is uncommitted, leave it unstaged and say so.

## Key resolution

Prefix the message with one key, read from `docs/planning/{ID}/jira.md`. If
verify-it already removed the planning directory, read it from the last
commit: `git show HEAD:docs/planning/{ID}/jira.md`.

| Scenario | Key to use |
|----------|-----------|
| Epic exists | `epic_key` from frontmatter |
| No Epic, phase keys exist | First phase key from `## Phase tasks` |
| No `jira.md` or no keys | The plan ID, `{ID}` |

## Commit message

Format:

```
{KEY}: <short summary of the docs closed>

<bullet-points>
```

Ask the user to confirm or edit, then:

```bash
git commit -m "<title>" -m "<body>"
```

## Squash (optional)

Before pushing, offer once to squash the integration branch into one commit.
Recommend keeping the phase commits when the PR will be squash-merged anyway.

Offer it only when all of these hold:

- The current branch is not `main` or `master`.
- None of the branch's commits are on the remote yet
  (`git log @{u}..HEAD` lists them all, or the branch has no upstream).
- The tree is clean after the docs commit.

On a yes:

```bash
base=$(git merge-base main HEAD)
git log --format='%s' "$base"..HEAD   # phase subjects, for the body
git reset --soft "$base"
git commit -m "{KEY}: <plan summary>" -m "<one bullet per phase subject>"
```

`{KEY}` follows the key resolution above. Show the message for approval
before committing, as for the docs commit. On a no, leave the history as is.

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

**Optional PR**, only if the user asks (do not offer):

```bash
gh pr create --title "<title>" --body "<summary>"
```
