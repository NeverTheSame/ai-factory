# Foundations

This template rests on two ideas. Each answers a different question.

| | Answers | Lives in |
|---|---|---|
| **Build loop** (software factory) | *How* a feature becomes merged code | `.claude/skills/factory/`, `.claude/agents/` |
| **Runtime shape** (AI Engineering, ch. 10) | *What shape* the app's AI request path has | `AGENTS.md` → Runtime shape, reviewer checklists |

They are not alternatives. **The build loop is the process. The runtime shape is
what the loop's reviewers check against.** Without the runtime shape, the
factory only reviews generic code quality. Without the loop, the runtime shape
is a diagram that nobody enforces.

## The build loop

```
feature -> spec-writer -> builder -> [security, code, ux, ui] -> approver -> merge | needs-human
                            ^------ any CHANGES (max 2 resumes) ------'
```

- The session that runs `/factory` is the orchestrator. It spawns agents and
  only writes `job.json`.
- Agents get context from files, never from the conversation. Each one writes
  one file.
- First lines are contracts: `STATUS: READY|BLOCKED`, `VERDICT: PASS|CHANGES`,
  `APPROVE|ESCALATE`.
- Each job gets its own git worktree, branch (`factory/<job-id>`) and ports
  (`5100+10n`), so several sessions can run jobs in parallel.
- Merging is local (`--no-ff`). The factory never pushes.

## The runtime shape

Start with **query → model → response**. Add a component only to fix a problem
you have measured. A component can be skipped if the system works well without it.

| # | Component | Adds | Pitfall |
|---|---|---|---|
| 1 | Context construction | retrieval, tools, query rewriting, cleaning | bad context in, bad output out |
| 2 | Guardrails | input: leaks, injection, out-of-scope. Output: score each result; retry, fallback, human | latency; streaming makes output checks leaky |
| 3 | Router + gateway | router picks the model; gateway is one API to many models (access, cost, fallback, logging) | the gateway is a single point of failure |
| 4 | Caches | exact, then semantic (only at a high hit rate), then provider prompt cache | never share user-specific entries |
| 5 | Agent patterns | loops and branches; read actions gather, write actions change the world | write actions + prompt injection |
| 6 | Observability | metrics, logs, one trace per request with cost per span; drift evals | monitoring says *that*, observability says *where* |
| 7 | Orchestration | chain the components; run independent steps in parallel | frameworks hide calls and latency |
| 8 | User feedback | explicit (ratings) and implicit (regenerate, edit, share, delete) | over-fitting to a vocal minority |

Source: Chip Huyen, *AI Engineering* (O'Reilly, 2025), chapter 10.

## Where they join

Four places, all files the agents already read:

1. **`AGENTS.md` → Runtime shape.** The builder learns the architecture it must
   extend: what exists, where it is, and the rule for changing it.
2. **`spec.md` → `CH10:` line.** The spec-writer names the components a feature
   touches, e.g. `CH10: 4 Caches, 6 Observability`. Reviewers use it to pick
   checklist sections, and the approver uses it to match the escalate list.
3. **Reviewer checklists: one owner per component.** No fifth reviewer is
   needed, so the cost per job stays the same.

   | Reviewer | Owns |
   |---|---|
   | security (opus) | 2 Guardrails, 5 Write actions, plus cross-user cache leaks |
   | code (sonnet) | 1 Context, 3 Router/gateway, 4 Caches, 6 Observability, 7 Orchestration |
   | ux (sonnet) | 8 User feedback |
   | ui (sonnet) | visible guardrail and write-action outcomes |

   Watch `code`: it owns five components. If its PASSes get vague, move the
   context and router rules into the spec's acceptance criteria. Those are
   written by Opus, and the builder must meet them.
4. **Approver → always-escalate list.** Model or routing changes, cache keys,
   write actions, guardrail thresholds or judge prompts, removed traces, and
   feedback storage all go to a human, even when every review passes.

## The loop follows its own rules

| Runtime idea | In the factory | When it fails, fix… |
|---|---|---|
| 7 Orchestration, no framework | `/factory` is a plain loop in a skill | the skill |
| 2 Output guardrails, retry policy | 4 reviewers, up to 2 resumes, then a human | a bad PASS means a checklist gap |
| 5 Gate write actions | merge is the only write; needs a clean `main` | the escalate list |
| 6 Observability | `job.json`, `round-N/` files | a missing verdict line means a prompt bug |
| 3 Cheap model where enough | opus: spec, build, security, approve. sonnet: code, ux, ui | move a reviewer to opus only if it keeps missing |
| 8 Feedback without loops | `/factory rework` notes, monthly checklist pass | over-fitting to one noisy job |

## Order of operations for a new app

1. **Shape:** fill in `docs/worksheet.md`: have, need or skip for each component.
2. **Teach:** copy it into `AGENTS.md` → Runtime shape, and prove the setup and
   test commands from a cold worktree.
3. **Arm:** add stack-specific rows to each reviewer's checklist and to the
   approver's escalate list.
4. **Pilot:** run one small job, one job you expect to escalate, and two jobs in
   parallel. At least one real CHANGES round should get fixed on resume.
5. **Grow:** add a runtime component only when observability shows the problem
   it fixes. File it as a `/factory` job.
6. **Learn:** once a month, fold recurring review findings back into the
   checklists. They are the factory's memory.
