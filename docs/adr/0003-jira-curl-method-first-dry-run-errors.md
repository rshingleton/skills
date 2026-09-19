# `_jira_curl` method-first interface, dry-run, and error handling

## Status

Accepted

## Context

`_jira_curl` was added in ADR 0002 as a centralized auth wrapper, but its
interface requires callers to remember `-X METHOD` and `-H "Authorization"` is
already handled internally. The calling convention is unintuitive — agents
commonly write `_jira_curl POST "$URL"` which fails because curl receives
`POST` as a hostname.

Additionally:
- No safe preview mode: every POST hits production Jira.
- Non-2xx responses are printed to stdout as raw JSON/XML, with no error
  surfacing or non-zero exit code.

## Decision

Redesign `_jira_curl` with three changes in one pass (they all touch the same
function):

1. **Method-first:** `$1` is the HTTP method. The function prepends `-X $method`
   to the curl invocation. Callers write `_jira_curl POST "$url" -d "..."`.

2. **`--dry-run` flag:** When present as `$2` (or anywhere in the arg list after
   method), the function prints the intended operation without executing.
   Detection is via shift-based arg scanning to avoid false matching against
   payload content.

3. **Error capture:** Wrap curl with `-w "\n%{http_code}"`. Non-2xx responses
   print the status code and parsed error messages to stderr, then return 1.

## Consequences

- Breaking change to `_jira_curl` interface — all ~15 callers inside
  `jira-helpers.sh` plus any external usage must update.
- The new interface is more intuitive (`_jira_curl POST ...` instead of
  `_jira_curl -s -X POST ...`).
- Dry-run gives agents a safe preview before mutating Jira.
- Error capture prevents silent failures from propagating to callers.
- The `--dry-run` arg-scanning approach is a slight complexity increase in
  the function, but avoids coupling the flag to env vars.

## Execution notes

Implemented in phase-1 of plan `jira-curl-overhaul`:

- `_jira_curl` redesigned: method-first (`$1` = GET/POST/PUT/DELETE),
  `--dry-run` arg scanning, error capture via `-w "\n%{http_code}"`.
- Non-2xx prints `Jira API error (NNN):` with parsed error to stderr, returns 1.
- All 14 internal callers migrated; zero old-style `_jira_curl -s -X` calls remain.
- Error path for connection failures produces status "000", handled as non-2xx.
- Dry-run example added to `issue-tracker-jira.md` conventions table.

Verification: `bash -n` clean, all 11 `_jira_*` functions callable,
dry-run and error handling confirmed working.
