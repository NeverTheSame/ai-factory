# AGENTS.md

Every factory agent reads this file before it does anything. Replace every
`TODO`. A vague answer here produces vague reviews.

Read `docs/FOUNDATIONS.md` for how the factory and the runtime shape fit together.

## Project

- What it is: TODO (one sentence)
- Has a user interface: TODO yes / no
- Default branch: `main`

## Setup (fresh checkout)

Commands that take a brand-new `git worktree` to a runnable state. Test them
from a cold worktree before you trust the factory:
`git worktree add /tmp/factory-smoke main`, run them, then
`git worktree remove /tmp/factory-smoke`.

```bash
TODO   # e.g. uv sync / npm ci / cp .env.example .env
```

## Dev server

```bash
TODO --port <PORT>   # agents substitute their assigned port
```

- Ready when: TODO (URL or log line)
- Browser tool for agents: TODO (for example a headless browser CLI), or "none"

## Validation

The builder must pass all of these before it writes `STATUS: READY`. Reviewers
re-run them.

```bash
TODO   # test
TODO   # lint / typecheck
TODO   # build
```

## Conventions

- TODO: language and style rules, error handling, test layout

## Runtime shape

The AI request path of this app (see `docs/FOUNDATIONS.md`). Status is `have`,
`need` or `skip`. `skip` is fine: add a component only when a measured problem
calls for it.

| # | Component | Status | Where in code | Rule for changes |
|---|-----------|--------|---------------|------------------|
| 1 | Context construction | TODO | TODO | built in one place, typed |
| 2 | Guardrails (input / output) | TODO | TODO | new input passes the input guard; output scored before shown |
| 3 | Router / gateway | TODO | TODO | no direct provider calls |
| 4 | Caches | TODO | TODO | key includes every output-changing input; per-user keys |
| 5 | Agent loop / write actions | TODO | TODO | idempotency key + audit record |
| 6 | Observability | TODO | TODO | one trace per request, cost per span |
| 7 | Orchestration | TODO | TODO | plain typed pipeline, no new framework |
| 8 | User feedback | TODO | TODO | explicit + implicit signals recorded |

## Data the agents must not send to external APIs

- TODO (for example: raw personal data, uploaded files, credentials)
