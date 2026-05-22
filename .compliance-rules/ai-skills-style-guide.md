# Supplemental Rules: AI Skill Architectural & Style Compliance

This matrix defines the required organizational formatting, metadata, and structural constraints for any custom or modified AI skill file (`SKILL.md`) within this repository. Treat deviations as failures during Step 4 (Enforce coding standards).

## 1. Frontmatter Validation (Severity: HIGH)
The agent must verify the YAML frontmatter blocks on any file tracking inside a `skills/` subdirectory:
* **Kebab Namespace**: The `name:` attribute must be written strictly in lowercase kebab-case and match its parent directory name exactly (e.g., directory `write-a-skill` must have `name: write-a-skill`).
* **Trigger Explicitly Anchored**: The `description:` metadata block must contain a functional conditional statement specifying activation phrases using the phrase structure *"Use when..."*.

## 2. Token Budget & Compression Limits (Severity: MEDIUM)
To maximize context window economy for local and cloud models, enforce strict size profiles:
* **Line Ceiling**: The primary `SKILL.md` template must focus purely on core state machine execution sequences and remain under 100 lines of markdown text.
* **Progressive Offloading**: Deep secondary constraints, heavy technical data configurations, and domain code examples must be split out into dedicated sub-files within the same directory, referenced via markdown links rather than inlined.

## 3. Punctuation & Parsing Hygiene (Severity: MEDIUM)
To ensure clean token processing and prevent compilation/rendering breakages within various local AI terminals, flag the use of the following formatting elements:
* **Forbidden Lists**: Do not use sequential numbering (`1.`, `2.`, `3.`) inside workflow execution lists. Workflows must use unordered bullet points (`*` or `-`) to keep steps declarative.
* **Token Noise**: Flag and block the use of em-dashes (`—`) or citation/footnote brackets (`` or `[1]`) within instructions or prose layouts. 
* **Conversational Boundaries**: Prompts requiring human discovery must explicitly instruct the agent to prompt the developer with questions *one at a time* rather than dumping massive choice trees in a single block.

## 4. Operational Persona Decoupling (Severity: HIGH)
* **No Direct Side-Effects**: Skills are forbidden from explicitly containing automated git destructive hooks (e.g., `git push --force`). They must manipulate and prepare local filesystem states only, leaving git commands to manual developer action.
* **Persona Isolation**: Check that planning or architectural analysis scaffolds do not cross boundaries to rewrite or modify working tracking code without an explicit validation step.