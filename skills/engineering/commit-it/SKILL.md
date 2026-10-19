---
name: commit-it
description: >
  Doc Cycle close phase. Runs the compliance gate, commits the docs verify-it
  changed (ADRs, GLOSSARY, changelog, planning removal) in one key-prefixed
  commit, offers to squash the branch, and pushes or opens a PR only on user
  approval. Code is already
  committed per phase by implement-it. Does NOT replace code review. Use after
  verify-it, or when user says commit-it, commit, ship, push.
model: sonnet
---

# commit-it

Doc Cycle epilogue. `/implement-it` commits each phase as it builds it, so
the code is already committed. commit-it does four things:

1. Gates on `/internal-compliance`.
2. Commits the docs `/verify-it` changed, in one commit.
3. Offers to squash the branch into one commit, before anything is pushed.
4. Pushes, or opens a PR, only after explicit user approval.

Does **not** push to main/master directly; creates a feature branch if needed.

## Quick start

```text
commit-it
```

After `/verify-it`:
1. `git status --short`: confirm verify-it left doc changes
2. Offer to run `/internal-compliance`
3. Confirm the docs commit message, commit, optionally squash, and **ask before push**

## Workflow

### 0. Preflight

```bash
git status --short
```

Expect only verify-it's changes: `docs/adr/`, `GLOSSARY.md`, the changelog
(`CHANGELOG.md` or `docs/changelog*`), new `docs/issues/*.md` files it filed
for shortcut markers, and the removed `docs/planning/{ID}/`.
If code files are also uncommitted, stop and tell the user: they belong to a
phase commit from `/implement-it`, not to this one.

If the tree is clean, skip only the docs commit (step 2): the compliance gate
and the squash offer still run, because the phase commits are unreviewed.

### 1. Compliance gate

Always offer to run `/internal-compliance` before staging. If it fails,
stop; do not proceed until compliance issues are resolved.

### 2. Docs commit

Follow [COMMIT-PROCESS.md](COMMIT-PROCESS.md) to stage verify-it's files,
resolve the key, draft the message, and commit.

### 3. Squash (optional)

Offer once to squash the integration branch's phase commits and docs commit
into one commit. See [COMMIT-PROCESS.md § Squash](COMMIT-PROCESS.md#squash-optional)
for when it is safe to offer. Never squash commits already pushed.

### 4. Push

Follow [COMMIT-PROCESS.md § Push and PR](COMMIT-PROCESS.md#push-and-pr).
**Always ask the user before pushing.** Create a pull request only if the
user asks.

## Core Tenets

- **Docs only:** one commit for verify-it's changes; phase code is committed by implement-it.
- **Key-prefixed message:** `CDS-135: <msg>` links the commit to its ticket.
- **Compliance-first:** always gate on `/internal-compliance`.
- **User-confirmed message:** never commit unapproved text.
- **Never push without asking:** push only after explicit user approval, every time.
- **Branch isolation:** never push directly to main/master.
- **No code review replacement:** remind the user to review the diff.
