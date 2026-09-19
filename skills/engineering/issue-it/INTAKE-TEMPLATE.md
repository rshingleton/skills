## Context

Where this came from (review comment, grill decision, user report, link to code).

For **email** or **ServiceNow**, paste the original request here (verbatim). Set `source: email` or `source: servicenow` and optional `external_id:` (ticket number) in frontmatter.

For **codebase context**, note the relevant modules, domain terms, or reference docs discovered during context gathering (e.g. "Auth module uses token-based throttling in `AuthFilter.java`").

## Problem / request

What is wrong or what we want. Be specific — include error messages, user stories, or concrete scenarios extracted during probing.

Good: "The `/api/orders` endpoint returns 504 when more than 100 items are in the cart."
Bad: "Performance issue."

## Acceptance (for planning)

What "done" looks like when this becomes a plan phase. Use concrete, testable statements from the probing session.

Good:
- Requests over 100 items respond within 2s
- Rate limit returns 429 with Retry-After header
- AuthFilter logs exceeded limits per IP

## Notes

Links, logs, related ADRs, and any decisions from the probing session. Reference the code areas explored (module names, file paths, reference doc sections).
