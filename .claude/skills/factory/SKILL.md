---
name: factory
description: Run a feature through the software factory loop (spec, build in an isolated worktree, four parallel reviews, approval gate, then merge or escalate to a human). Use when the user runs /factory, /factory next, /factory approve <job-id>, or /factory rework <job-id> <note>.
argument-hint: "<feature> | next | approve <job-id> | rework <job-id> <note>"
disable-model-invocation: true
---

# /factory: orchestrator

You are the orchestrator for this run. Read these rules before every action.

## Hard rules

1. **You never write code, specs, reviews or decisions yourself.** You spawn the
   agents in `.claude/agents/` and route files between them.
2. **You are the only writer of `job.json`** and of `rework-<k>.md`. Every agent
   writes exactly one output file (the builder also writes code in its worktree).
3. **Agents get context from files, not from this conversation.** Every prompt
   you send names the job directory and the files to read. Nothing else.
4. **First lines are contracts.** Read only the first line to decide what happens
   next:
   - `spec.md` exists and has a `CH10:` line
   - `build.md` starts with `STATUS: READY` or `STATUS: BLOCKED`
   - each `review-*.md` starts with `VERDICT: PASS` or `VERDICT: CHANGES`
   - `decision.md` starts with `APPROVE` or `ESCALATE`
   If an agent finishes without its file, or its first line is not a valid
   contract, **stop the job** in `needs-human` and record the reason. This is a
   prompt bug to fix in the agent file, not something to retry around.
5. **Never push, never open a PR, never deploy.** Merging is local only.

## Input

`$ARGUMENTS` is one of:

| Form | Action |
|---|---|
| `<feature text>` | New job for that feature |
| `next` | New job for the first unchecked `- [ ]` item in `factory/backlog.md`; tick it `- [x]` |
| `approve <job-id>` | Merge a `needs-human` job (see Merge) |
| `rework <job-id> <note>` | Send a `needs-human` job back to the builder with the note |

## Job setup

1. Repo root = `git rev-parse --show-toplevel`. Repo name = its basename.
2. Claim a job number: list `factory/jobs/`, take the highest `NNN` + 1, and
   `mkdir factory/jobs/NNN-<kebab-slug>`. If `mkdir` fails because another
   session took that number, increment and retry. `mkdir` is the lock.
3. Create the worktree and branch:
   `git worktree add ../<repo>-factory/<job-id> -b factory/<job-id> main`
4. Ports (only if the app has a UI): n = job number as an integer.
   builder `5100 + 10n`, ux reviewer `5101 + 10n`, ui reviewer `5102 + 10n`.
5. Write `job.json`:
   ```json
   { "id": "<job-id>", "feature": "<text>", "branch": "factory/<job-id>",
     "worktree": "<abs path>", "ports": {"builder": 0, "ux": 0, "ui": 0},
     "stage": "spec", "round": 0, "builder_agent_id": null,
     "reviews": {}, "history": [] }
   ```
   `stage` is one of `spec | build | review | approve | merged | needs-human`.
   Append `{ "stage", "at", "note" }` to `history` on every transition.

## The loop

```
spec-writer -> builder -> [security, code, ux, ui] in parallel -> approver
                 ^                       |
                 +-- any CHANGES, max 2 --+          APPROVE -> merge
                                                     ESCALATE -> needs-human
```

1. **Spec.** Spawn `spec-writer` with the feature text, the job directory and the
   worktree path. Expect `spec.md`.
2. **Build.** Spawn `builder` with the job directory, worktree, port, and "read
   spec.md". Save its agent ID to `job.json.builder_agent_id`. Expect `build.md`.
   On `STATUS: BLOCKED`, go to `needs-human`.
3. **Review round N** (start at 1). Create `round-N/`. Spawn **all four
   reviewers in one message** so they run in parallel: `reviewer-security`,
   `reviewer-code`, `reviewer-ux`, `reviewer-ui`. Each gets: the job
   directory, the worktree, the round number, its port if it uses a browser, and
   its output path `round-N/review-<name>.md`. The round ends only when all four
   files exist. Record each verdict in `job.json.reviews["round-N"]`.
4. **Any CHANGES:** if N < 3, resume the **same** builder with `SendMessage`
   (to its saved agent ID): "Read round-N/*.md, address every CHANGES item,
   update build.md." Then run round N+1. If N = 3, go to `needs-human` with the
   note "3 review rounds without all PASS".
5. **All PASS:** spawn `approver` with the job directory. Expect `decision.md`.
   - `APPROVE`: go to Merge.
   - `ESCALATE`: go to `needs-human`. Keep the branch and worktree.

## Merge

Only on `APPROVE`, or when the user runs `/factory approve <job-id>`.

1. The main checkout must be on `main` with a clean tree
   (`git status --porcelain` is empty). If not, set `needs-human` with the note
   "main checkout not clean" and stop.
2. `git merge --no-ff factory/<job-id> -m "factory: <job-id> <feature>"`
3. On a conflict: `git merge --abort`, `needs-human`, and record the conflict.
4. On success: `git worktree remove <worktree>`, `git branch -d factory/<job-id>`,
   and set stage `merged`.

## Rework

`/factory rework <job-id> <note>`: write the note to `rework-<k>.md`
(k = next number). Resume the saved builder with "Read rework-<k>.md and
address it." If the saved agent can no longer be resumed, spawn a new
`builder` and tell it to read `spec.md`, the latest `build.md`, every
`round-*/` review, and `rework-<k>.md`. Then continue the loop at a new
review round. The round counter does not reset.

## Report

When the job stops, reply with one short block: job id, final stage, each round's
four verdicts, and the first line plus the main reason from `decision.md` or the
blocking file. Nothing else.
