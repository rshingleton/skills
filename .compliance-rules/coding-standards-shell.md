# Coding Standards — Shell (Bash)

Applies to all `.sh` files in the repo. Extends `coding-standards.md` and `implement-it/STANDARDS.md`.

## Shebang

- Every `.sh` file must start with `#!/usr/bin/env bash`
- Use `set -euo pipefail` unless the script has a specific reason not to (document the exception)

## Style

- Functions: `snake_case` names, defined with `name() {` (no `function` keyword)
- Variables: `UPPER_SNAKE` for exported env vars and constants, `lower_snake` for locals
- `local` all function-scoped variables
- Quote all variable expansions: `"$var"`, `"${arr[@]}"`

## Error handling

- Check exit codes of critical commands explicitly
- Use `trap` for cleanup on `EXIT` and `ERR`
- Print errors to stderr: `echo "error: ..." >&2`

## Prohibited

- `cd` without error checking (use `cd ... || exit 1` or `cd ... || return 1`)
- Backtick command substitution — use `$()` instead
- `eval`
- Unquoted variable expansions
