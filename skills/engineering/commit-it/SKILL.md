---
name: commit-it
description: >
  Doc Cycle — close phase. Stages changes grouped by Jira key, drafts
  commit messages prefixed with that key, and commits locally. Does NOT
  push without asking. Never pushes without user approval. Does NOT replace
  code review. Use after verify-it, or when user says commit-it, commit,
  ship, push.
---

# commit-it

Doc Cycle epilogue: stage working tree changes grouped by Jira key, commit
with a key-prefixed message. Push only after explicit user approval. One
commit per Jira key so audit trails stay clean.

Does **not** push to main/master directly — creates a feature branch if needed.

## Quick start

```text
commit-it
```

From a verified, working tree:
1. `git status --short` — confirm you have changes
2. Offer to run `/internal-compliance`
3. Follow prompts to stage, confirm message, commit, and **ask before push**

## Workflow

### 0. Preflight

Check for working tree changes:

```bash
git status --short
```

If clean, stop. If dirty, gather context from the changelog
(`CHANGELOG.md` or `docs/changelog*`), the most recent ADR
(`docs/adr/`), and reference docs (`docs/reference/`). Planning
directories are discarded after verify -- do not expect them.

### 1. Compliance gate

Always offer to run `/internal-compliance` before staging. If it fails,
stop — do not proceed until compliance issues are resolved.

### 2. Commit

Follow [COMMIT-PROCESS.md](COMMIT-PROCESS.md) to stage files grouped by
Jira key, resolve the key from `jira.md`, draft the commit message, and
execute `git commit`.

### 3. Push

Follow [COMMIT-PROCESS.md § Push & PR](COMMIT-PROCESS.md#push-and-pr) for
branch isolation. **Always ask the user before pushing.** Do not push
without explicit confirmation. Create a pull request only if the user asks
(unprompted).

### Multi-phase plans

If the plan uses incremental close (`/verify-it --phase`) and phases remain,
the tree may contain changes for the next phase. See
[COMMIT-PROCESS.md § Multi-phase](COMMIT-PROCESS.md#multi-phase-plans-with-incremental-close).

## Core Tenets

- **One commit per Jira key** — every commit maps to exactly one issue.
- **Key-prefixed message** — `CDS-135: <msg>` links commits to tickets.
- **Compliance-first** — always gate on `/internal-compliance`.
- **User-confirmed message** — never commit unapproved text.
- **Never push without asking** — push only after explicit user approval, every time.
- **Branch isolation** — never push directly to main/master.
- **No code review replacement** — remind the user to review the diff.
