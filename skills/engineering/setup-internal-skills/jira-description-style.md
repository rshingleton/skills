# Jira description style

**Required** for every Jira **create** (`POST /issue`): `summary`, `description`, and triage **create** body. **Time tracking:** set `timetracking.originalEstimate` + `remainingEstimate` on Task creates when hours are known ([issue-tracker-jira.md § Time estimates](issue-tracker-jira.md#time-estimates-timetracking)).

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

When source is phase scope, intake markdown, or other planning artifacts:

1. Replace `## Title` / `### Title` → `h2. Title` / `h3. Title` (strip `#` characters only).
2. Replace leading `- ` / `* ` list markers with `* ` (single asterisk + space).
3. Strip `- [ ]` / `- [x]` → bullet text only: `* ConfigServiceTest covers GET /api/health returns 200 UP`
4. Remove duplicate summary paragraph at top.
5. Do **not** paste markdown through unchanged.

The helper `_jira_wiki_body <file>` automates steps 1-3 (defined in `jira-helpers.sh`, sourced via `load-jira-env.sh`).

### Example — broken (what the UI shows wrong)

```markdown
## What
* Fill ConfigServiceTest.java…

## Done when
- [ ] ConfigServiceTest covers GET /api/health
```

→ Renders as `1. 1. What`, literal `[ ]`.

### Example — correct (same content)

```text
h2. What

* Fill {{ConfigServiceTest.java}} with mock-based tests for admin HTTP API
* Add {{@Deprecated}} on {{cds.backend.type}} fallback in {{CdsConfig.java}}
* Move {{GreptimeCodecBackendE2eTest}} to {{@Category(RemoteBackendIntegrationTest.class)}}

h2. Done when

* {{ConfigServiceTest}} covers {{GET /api/health}} — returns 200 UP
* Config CRUD PUT/GET/DELETE with correct statuses
* Auth guard returns 401 without API key
* 404 for missing keys, 400 for invalid format
* Admin UI returns 200 HTML
* Mock repository only — no live backend in unit tests
* Runs in default {{./gradlew}} suite
* {{@Deprecated}} on fallback as specified
* {{GreptimeCodecBackendE2eTest}} categorized without {{Assume.assumeTrue()}}
* All tests green, no regressions

h2. Blocked

None
```

## Summary (title field)

- One line, &lt; ~100 chars, verb + object.
- Do not repeat the summary as the first line of the description.

## What to cut

- "This issue will…", "Please refer to…", paragraph walls, vague AC ("works correctly").
- **References to planning documents** — no mention of `ai-prompt.md`, `execution-notes.md`, phase docs, or audit reports in the Jira description. The description describes the work, not where it was sourced from.

## What to keep

- Concrete behavior, exact API/type/module names, testable outcomes, Blocked keys or `None`.

## Agent checklist (before POST)

1. Body uses **`h2.`** sections and **`*`** bullets only.
2. No `##`, no `- [ ]`, no lines starting with `#` (except `h2.` / `h3.`).
3. Every AC is one `*` line under `h2. Done when`.
4. `jq --arg body` or heredoc contains wiki text, not markdown.

Use `_jira_wiki_body <file>` (from `jira-helpers.sh`) to automate conversion.

## Local vs Jira

| Location | Format |
|----------|--------|
| `docs/issues/*.md`, `docs/planning/` | Markdown OK |
| `POST .../issue` `description` | **Wiki only** ([issue-tracker-jira.md](issue-tracker-jira.md)) |
