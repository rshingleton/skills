# verify-it closing messages

The closing message's first line says what happened and its last line says what to do next.
Before sending, reread those two lines alone: together they must carry the result. Full verify
reports verified and "Green."; incremental close reports "Phase N verified. {N-1} phases
remaining until full close."

## Full verify

> Verify complete: durable core updated for `{ID}`.
>
> Shortcuts: {N} added, {M} no-trigger, {K} filed to docs/issues/. For non-blocking architecture notes, consider `/improve-codebase-architecture`, `/issue-it` or [audit-to-issues](../setup-internal-skills/audit-to-issues.md) for inbox tracking, or a follow-up `/plan-it` slice.
>
> **Next:** Run `/commit-it` to stage and commit locally (push only after your approval). Before opening a PR, run `/internal-compliance`.

## Incremental close

> Phase N verified incrementally.
>
> When all phases are complete, run a Full audit (`/audit-it`) then `/verify-it` (full) to finalize.
>
> **Next:** Continue with `/implement-it` on remaining phases, or run `/audit-it --phase phase-{N+1}` for the next phase.
