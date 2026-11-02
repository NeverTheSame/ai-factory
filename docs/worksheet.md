# Runtime-shape worksheet

Fill this in once per app, before its first `/factory` job, then copy the result
into `AGENTS.md` → Runtime shape. Status: `have` · `need` · `skip`.

Ask for each row: *what measured problem would this component fix today?* If
you can't name one, mark it `skip`.

| # | Component | Status | Where in code | Problem it fixes (metric) | Rule for changes |
|---|-----------|--------|---------------|---------------------------|------------------|
| 0 | Base: direct model call | | | | |
| 1 | Context construction | | | | |
| 2a | Input guardrails | | | | |
| 2b | Output guardrails + failure policy | | | | |
| 3 | Router / gateway | | | | |
| 4 | Caches (exact / semantic / prompt) | | | | |
| 5 | Agent loop / write actions | | | | |
| 6 | Observability (traces, metrics, evals) | | | | |
| 7 | Orchestration | | | | |
| 8 | User feedback (explicit / implicit) | | | | |

## Escalate-list additions for this app

- [ ] …

## Data that must not leave the app

- [ ] …
