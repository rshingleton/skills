---
name: internal-compliance
description: Pre-flight compliance check against internal security linting rules before finalizing any pull request. Scans code for secret leakage, dependency policy violations, and organization coding standards. Use when user says compliance check, security scan, secret leak, pre-flight, or before marking a PR ready for review.
---

# Internal Compliance Check

Run this skill as a gating step before any PR is marked ready for review. It verifies the working tree against the internal security and compliance rules defined in this repository and the organization's shared policy documents.

## Process

### 1. Locate policy documents

Look for these files in order — they define the rules the compliance check enforces:

- `SECURITY_POLICY.md` at the repo root or `docs/`
- `CONTRIBUTING.md` at the repo root
- `.compliance-rules/` directory at the repo root (if it exists, read all `*.md` and `*.yaml` files; `coding-standards.md` overrides the baseline in `implement-it/STANDARDS.md`, and `coding-standards-<lang>.md` adds per-language rules)
- `.secrets.baseline` — if present, compare against it for new secrets

If none of these exist, check for a shared policy at `docs/agents/compliance/` (created by `/setup-internal-skills`). If still nothing, flag the absence as a finding and proceed with the built-in rules below.

### 2. Scan for secrets and credentials

Check all staged and unstaged diff against `HEAD`:

- Hardcoded API keys, tokens, or passwords (`-----BEGIN.*PRIVATE KEY-----`, `sk-[a-zA-Z0-9]{20,}`, `AKIA[0-9A-Z]{16}`, etc.)
- `.env` files or `.env.*` files staged for commit
- Connection strings containing plaintext credentials
- Commented-out credential placeholders (`// TODO: insert API key`, etc.)

Report each finding with the file path, line number, and the class of secret detected. Do NOT include the secret value in the report.

### 3. Check dependency policy

If a `package.json`, `requirements.txt`, `Cargo.toml`, `Gemfile`, or `go.mod` exists in the diff:

- Flag any dependency pinned to a `"*"` or open-ended range (`">= "` without upper bound)
- Flag any dependency from an unofficial or shadow registry
- Flag any dependency version with known CVEs (if `.dependency-audit.json` exists, cross-reference it)

### 4. Enforce coding standards

Check the diff for violations of this repo's documented standards:

- **File encoding**: all new files must be UTF-8
- **Line endings**: LF (not CRLF) unless the repo norm is CRLF — check `.gitattributes`
- **Executable permissions**: shell scripts (`.sh`) must be executable; other files must not be
- **Copyright headers**: if any file in the repo has a copyright header block, all new files in the same area must have one too
- **Maximum line length**: 120 characters for code, 72 for Markdown prose (unless the repo's own lint config sets a different max)

### 5. Report

Present findings in three sections:

```markdown
## Compliance Report

### Secrets / Credentials
- [file:line] description (severity: high / medium / low)

### Dependencies
- [file] description (severity: high / medium / low)

### Standards
- [file:line] description (severity: high / medium / low)
```

For each finding, include:
- The exact file path and line number
- A remediation suggestion
- A severity rating

### 6. Gate

- **If any HIGH-severity finding exists**: Do NOT allow the PR to proceed. Explain why and suggest fixes.
- **If only MEDIUM or LOW findings exist**: Summarize them and ask the user whether to proceed or fix first.
- **If no findings**: Report clean and confirm the PR is clear for review.
