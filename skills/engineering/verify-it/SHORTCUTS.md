# Shortcut markers the plan added

**Full verify only**, before step 3 discards the planning directory. `/implement-it` marks a
deliberate shortcut with a comment `shortcut: <the limit>, <when to upgrade>`
([STANDARDS.md](../implement-it/STANDARDS.md) §2). This step lists the ones the plan added, so a
shortcut with no upgrade trigger reaches the inbox instead of rotting.

## List

Diff the same range as the full audit and keep the added lines that carry a marker:

```bash
base=$(git merge-base main HEAD)
git diff -U0 "$base"..HEAD | grep -E '^(\+\+\+ |@@ |\+.*(#|//|/[*]|--|<!--) ?shortcut:)'
```

The `+++` lines name the file and the `@@` hunk headers give the new line number; drop headers
with no marker under them. Skip hits that are not a deferral (prose that only mentions the
convention, a keyboard shortcut). For each marker record its location, the limit, and the upgrade
trigger. A marker with no upgrade trigger is tagged `no-trigger`.

No markers: say `No shortcut markers added.` and continue.

## Offer `no-trigger` markers to the inbox

Present the `no-trigger` markers as a numbered list and ask once which to capture. For each one the
user picks, call the Skill tool with "issue-it" and capture it per
[audit-to-issues.md](../setup-internal-skills/audit-to-issues.md): `type: defer`,
`status: intake`, `source: verify-it`, the marker's `file:line` and limit under **Notes**. The
user may decline all of them.

Markers that name their trigger are recorded decisions: list them, file nothing.

## Report

Carry the result into the closing message ([CLOSING.md](CLOSING.md)):

```text
Shortcuts: {N} added, {M} no-trigger, {K} filed to docs/issues/.
```

The new `docs/issues/*.md` files are left unstaged like everything else verify-it writes;
`/commit-it` stages them with the docs commit.
