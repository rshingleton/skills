# Jira description style

**Required** for every Jira **create** (delegated to `to-jira` which posts `POST /issue`): `summary`, `description`, and triage **create** body. **Time tracking:** set `timetracking.originalEstimate` + `remainingEstimate` on Task creates when hours are known ([issue-tracker-jira.md § Time estimates](issue-tracker-jira.md#time-estimates-timetracking)).

**Stand-alone descriptions:** Jira descriptions and comments describe the work, not the planning artifact it was sourced from. No references to `ai-prompt.md`, `execution-notes.md`, audit reports, or other planning docs in the issue body.

**Renderer:** Jira Server / Data Center **wiki markup** in the `description` field — **not** GitHub Markdown. Markdown headings and `- [ ]` checkboxes produce broken output (e.g. `1. 1. What`, literal `[ ]` text).

Intake `docs/issues/*.md` may use Markdown locally; **convert** before POST ([format rules](#markdown--wiki-conversion)).

Use [caveman](../../productivity/caveman/SKILL.md) only to cut filler — not as the target voice.

## Wiki template (Task)

Post the body exactly in this shape (blank line after each heading line):

```text
h2. What

* First concrete behavior or change
* Second item

h2. Done when

* Observable outcome one (test or behavior)
* Observable outcome two

h2. Blocked

None
```

**Epics:** add `h2. User stories`, `h2. Decisions`, `h2. Out of scope` as needed — still `*` bullets, no prose walls.

## Formatting rules

| Use | Do not use |
|-----|------------|
| `h2. Section` | `## Section`, `# Section`, `**bold headers**` |
| `*` bullet lines | Markdown `-` lists mixed with headings |
| Plain `*` AC lines under Done when | `- [ ]`, `- [x]`, GFM task lists |
| `*monospace*` via `{{code}}` for identifiers | Triple-backtick fences |
| `None` on its own line under Blocked | Empty section omitted without saying None |

**Numbered lists:** avoid `#` at line start in descriptions — in wiki markup `#` starts a *numbered* list and causes double numbering when combined with exported markdown.

**One blank line** after each `h2.` line before bullets; **no** indent before `*`.

## Markdown → wiki conversion

**Automatic:** All Jira issue bodies are automatically converted from markdown to wiki format by the helper functions (`_jira_create_epic`, `_jira_create_task`, `_jira_update_description`). **Writers can use markdown locally — it will be converted before POST.**

**Conversion rules (applied by `_jira_wiki_body`):**

1. Replace `# ` / `## ` / `### ` → `h1. ` / `h2. ` / `h3. ` (headings)
2. Replace `` `inline code` `` → `{{inline code}}` (monospace)
3. Replace `**bold**` → `*bold*` (Jira wiki emphasis)
4. Replace code blocks `` ```lang...``` `` → `{code:language=lang}...{code}` (with optional language)
5. Replace `[link text](url)` → `link text` (URL dropped, text preserved)
6. Replace `- [ ]` / `- [x]` → `* ` (task lists become plain bullets)
7. Replace leading `-` / `*` → `* ` (bullets normalized)

The helper `_jira_wiki_body <file>` (defined in `jira-helpers.sh`, sourced via `load-jira-env.sh`) automates all conversions. **Callers do not need to pre-convert** — the conversion happens automatically before every Jira POST.

### Example — markdown input (what you write locally)

```markdown
## What

* Fill `ConfigServiceTest.java` with **robust** tests
* Add `@Deprecated` annotation

## Code

```java
@Test
public void testHealth() {}
```

## Done when

- [x] Tests pass
- [x] No regressions
```

### Example — wiki output (what Jira receives)

```text
h2. What

* Fill {{ConfigServiceTest.java}} with *robust* tests
* Add {{@Deprecated}} annotation

h2. Code

{code:language=java}
@Test
public void testHealth() {}
{code}

h2. Done when

* Tests pass
* No regressions
```

## Summary (title field)

- One line, &lt; ~100 chars, verb + object.
- Do not repeat the summary as the first line of the description.
- For Tasks under an Epic: use the phase title as-is by default. Optionally prefix with `<Plan title>: ` (e.g. "Auth v2: Implement login form") when the user opts in — the Epic link already provides parent context.

## What to cut

- "This issue will…", "Please refer to…", paragraph walls, vague AC ("works correctly").
- **References to planning documents** — no mention of `ai-prompt.md`, `execution-notes.md`, phase docs, or audit reports in the Jira description. The description describes the work, not where it was sourced from.

## What to keep

- Concrete behavior, exact API/type/module names, testable outcomes, Blocked keys or `None`.

## Agent checklist (before POST)

**Important:** Conversion to wiki format is automatic. Callers can write markdown; the helpers will convert it.

For explicit pre-conversion (if needed):
1. Use `_jira_wiki_body <file>` (from `jira-helpers.sh`) to preview the conversion
2. Verify output uses `h2.` sections and `*` bullets only
3. No raw `##`, `- [ ]`, or markdown syntax in the POST payload

Most of the time, just write markdown in your local markdown files — the conversion happens automatically.

## Local vs Jira

| Location | Format |
|----------|--------|
| `docs/issues/*.md`, `docs/planning/` | Markdown OK |
| `POST .../issue` `description` | **Wiki only** ([issue-tracker-jira.md](issue-tracker-jira.md)) |
