# Supplemental Content Guidelines: Skill Instructional Architecture

This document dictates the semantic layout, writing pattern constraints, and programmatic structure for all custom skills within this repository. The `internal-compliance` agent evaluates changes against these guidelines during Step 4 (Enforce coding standards).

---

## 1. Structural Architecture Benchmarks (Severity: HIGH)

Custom prompts and skill files must map their functional workflows directly to the architectural styles established by the framework's canonical core.

### A. The Iterative Discovery Loop (`grill-me` Style Invariant)
* **Rule**: When a workflow step mandates developer context gathering or a feature discovery phase, the instructions must force linear step-throttling.
* **Prohibited**: Allowing the model to list or "text-dump" all options, questions, or alternative choices in a single conversational block.
* **Compliant Phrasing Target**: 
  > *"Analyze the workspace configuration. Prompt the user with clarifying trade-off questions exactly one at a time. Do not print out a sequence or list of options. Wait for user input before calculating subsequent states."*

### B. The Rigid Gating Sequence (`tdd` Style Invariant)
* **Rule**: Skills handling code implementation or execution validation loops must split logical verification steps away from feature generation steps. Falling back or progressing requires explicit state-confirmation.
* **Prohibited**: Allowing the agent to assume success, extrapolate passing states, or write speculative production code before establishing a baseline failure pattern.
* **Compliant Phrasing Target**:
  > *"Execute the workspace testing command. Verify and log the terminal failure baseline. Do NOT implement target features until a clean failing state is verified. Implement the absolute minimum code state required to trigger a passing metric."*

### C. The Structural Scaffold Target (`write-a-skill` Style Invariant)
* **Rule**: If a skill outputs markdown text, templates, or records onto the filesystem, it must contain a hard structural layout block.
* **Prohibited**: Allowing the model to format reports or summaries conversationally or fluidly.
* **Compliant Phrasing Target**:
  > *"Generate the findings matrix. The output must strictly fill the following explicit markdown structural code fence block, ensuring no nested code block elements break parsing engines: [Insert Invariant Template Layout Here]"*

---

## 2. Command Vocabulary & Linguistic Precision (Severity: MEDIUM)

LLM execution paths depend heavily on token priority weightings. Custom skills must utilize direct imperative commands while eliminating ambient vocabulary that leads to speculative optimization loops.

### A. Approved Imperatives
Workflow list items must begin exclusively with these deterministic operational verbs:
* **Context Assembly**: `Locate`, `Scan`, `Extract`, `Diff against HEAD`, `Index`
* **Analytical Reasoning**: `Verify`, `Flag`, `Gate`, `Cross-reference`, `Compare`
* **Terminal Actions**: `Report`, `Present`, `Abort`, `Conclude`, `Output`
* **Boundary Restrictions**: `Never`, `Do NOT`, `Forbid`, `Block`

### B. Prohibited Ambiguity Vectors
The use of the following tokens or conceptual soft-verbs will result in an immediate linting error during pre-flight verification:
* **Straying Verbs**: *Should, can, try to, look around, check if possible, optionally consider, see if.*
* **Subjective Metrics**: *Be concise, keep it short, talk clearly, be helpful.* (Replace with deterministic limits, e.g., *"Restrict chat text to 1-4 lines. Enforce Caveman Mode."*)

---

## 3. Phrasing Optimization Matrix (Severity: MEDIUM)

Apply these exact sentence-level structural conversions when drafting custom prompt configurations or refining existing workspace directives:

| Traditional Prompt Style (FAIL) | State Machine Prompt Style (PASS) | Foundational Metric |
| :--- | :--- | :--- |
| Check the repository files and see if there are any settings for security or contributing guidelines located anywhere in the standard directories. | * Locate `SECURITY_POLICY.md` or `CONTRIBUTING.md` at the repo root.<br>* If absent, look for shared files at `docs/agents/compliance/`. | **Context Pruning Guard**: Curbs random file searches. Minimizes context pollution and preserves token allowances on high-volume passes. |
| Try your best to be concise when writing out the analysis summary, and try to tag the relative severity levels. | Present findings in three sections: `### Secrets`, `### Dependencies`, and `### Standards`. For each finding, append an explicit severity block: (`HIGH` / `MEDIUM` / `LOW`). | **Scaffold Determinism**: Displaces subjective evaluation with structural invariants. Formats content for stable parsing by continuous automation tools. |
| If something crashes during the test run, tell the user about it and check if they want to try it again. | * If a HIGH-severity finding exists: Do NOT allow the PR to proceed. Abort execution and output the remediation path.<br>* If only MEDIUM findings exist: Prompt user with sequential options. | **Hard Gating Loops**: Halts failure propagation. Eradicates infinite loop scenarios where the AI runs failing tool sets without updating the code base state. |

---

## 4. Operational Invariants (Severity: HIGH)

* **Atomic Bullet Rule**: Every bullet point in the `SKILL.md` process must specify exactly one action loop. If a directive contains conjunction elements such as *"and then"*, *"or else"*, or *"before finalizing"*, it must be refactored into strict, separate sub-bullets.
* **Embedded Fallback Paths**: Fault handling models must live directly inline with the step they safeguard. Do not collect error recovery mechanics at the bottom of the document.
* **Silent Local Interactivity**: Force the agent to commit operational telemetry maps, code maps, and heavy logs silently directly to disk records rather than filling the live user interactive chat box stream with heavy metadata arrays.