# docs/reference/ layout

Phase 1 of `/doc-it` creates or refreshes this tree. Keep pages navigable; prefer maps and tables over prose dumps.

## Required files

| File | Contents |
|------|----------|
| `README.md` | Index: what each file covers, last doc-it run date, repo scope noted |
| `overview.md` | System purpose, major boundaries, deployment shape (if inferable) |
| `module-map.md` | Modules/packages, primary responsibilities, key dependencies (diagram or table) |
| `entry-points.md` | HTTP routes, CLIs, workers, public APIs, main `main()` paths |
| `domains.md` | Domain areas → code locations; link `CONTEXT.md` terms; **Glossary gaps** list |
| `test-landscape.md` | Test types, where they live, factual coverage (gaps and **TR-*** recommendations go in `docs/reference-audit/testing.md`) |

## Optional (create when useful)

| File | When |
|------|------|
| `data-flow.md` | Non-trivial persistence, queues, or cross-service flows |
| `external-systems.md` | Third-party integrations and config touchpoints |
| `build-and-deploy.md` | Non-obvious build pipelines or env matrices |

## Style

- Present tense, factual ("The Order module validates…").
- Every section that names a module should include at least one path (e.g. `src/orders/`).
- Mark uncertainty: `*(unverified)*` when not confirmed in source.
- Do not paste secrets, credentials, or full `.env` keys.
