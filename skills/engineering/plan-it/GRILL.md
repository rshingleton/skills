# The Grill

**Always runs**, ad-hoc or from issues, with or without prior intake evaluation, and
however small the work looks. A one-phase plan still gets at least one round.

Call the Skill tool twice, for "grilling" and "domain-modeling". `grilling` owns the interview
method; `domain-modeling` owns `GLOSSARY.md` and ADR upkeep. Give both the intake and
`sources/` as context, not as a substitute for grilling.

Add this plan agenda to the design tree:

- **Overlapping intake:** merge or split intake items that cover the same ground.
- **One plan or several:** decide whether the work is one plan or should be split.
- **Vertical slices:** the phases, each verifiable on its own, and how each is verified
  ([SCAFFOLD.md](SCAFFOLD.md#slicing-rules)).
- **Seams:** for each phase, the public interfaces tests will sit at, what a test there
  catches, and what it misses. A phase with no code seam (prose-only work) names its
  observable check instead.
- **Deferred decisions and risk.**

Scaffold only after the user confirms shared understanding. Do not answer your own questions
and continue in the same turn.
