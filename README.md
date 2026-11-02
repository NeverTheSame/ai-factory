# ai-factory

A Claude Code workflow template for AI projects. One command turns a one-line
feature request into a spec, builds it on its own branch, reviews it from four
angles in parallel, then merges it to `main` or hands it to you.

The reviewers know the shape an AI app's request path should have: context,
guardrails, router and gateway, caches, agent write actions, observability,
orchestration and user feedback. They check every change against that shape.

```
/factory add a /health endpoint that returns build version and uptime

feature -> spec-writer -> builder -> [security, code, ux, ui] -> approver -> merge | needs-human
                            ^------ any CHANGES (max 2 resumes) ------'
```

> **Status: v0, not yet piloted.** The files are complete, but no job has run
> from this template yet. Run the three pilots below before you trust it on
> real work.

## What's inside

```
.claude/
  skills/factory/SKILL.md     orchestrator: the loop, job.json, merge rules
  agents/
    spec-writer.md            opus    -> spec.md (with a CH10 line)
    builder.md                opus    -> code in a worktree + build.md
    reviewer-security.md      opus    -> round-N/review-security.md
    reviewer-code.md          sonnet  -> round-N/review-code.md
    reviewer-ux.md            sonnet  -> round-N/review-ux.md   (uses the running app)
    reviewer-ui.md            sonnet  -> round-N/review-ui.md   (uses the running app)
    approver.md               opus    -> decision.md
  settings.json               denies `git push` for every agent
factory/
  backlog.md                  queue for `/factory next`
  jobs/                       runtime state, one folder per job (gitignored)
AGENTS.md                     fill this in: setup, dev server, tests, runtime shape
docs/
  FOUNDATIONS.md              how the build loop and the runtime shape fit together
  worksheet.md                per-app runtime-shape worksheet
```

## Use it

**New project:** click *Use this template* on GitHub, or
`gh repo create my-app --template NeverTheSame/ai-factory --private --clone`.

**Existing repo:** copy `.claude/`, `factory/`, `docs/` and `AGENTS.md` into the
repo root. Add the two `factory/jobs` lines from `.gitignore`. If the repo
already has `.claude/settings.json`, merge the deny rule into it.

Then:

1. **Fill in `docs/worksheet.md`**: have, need or skip for each runtime component.
2. **Fill in `AGENTS.md`**: setup, dev server, test/lint/build commands, and the
   Runtime shape table. This is the most important step, because every agent
   reads its repo knowledge from here. Prove the commands from a cold worktree.
3. **Tailor the checklists.** Each reviewer and the approver has an
   "Add stack-specific rows here" line. A vague checklist produces vague PASSes.
4. Commit on `main`, then run a pilot.

## Commands

```
/factory <feature>               new job through the full loop
/factory next                    first unchecked item in factory/backlog.md
/factory approve <job-id>        merge a needs-human job (main must be clean)
/factory rework <job-id> <note>  send a needs-human job back to the builder
```

To run jobs in parallel, open one Claude Code session per job in the same repo.
Job numbers are claimed with `mkdir`, and each job has its own worktree, branch
and ports, so sessions never write the same file.

A job that ends in `needs-human` keeps its branch and worktree. Read
`decision.md` (or the BLOCKED reason in `build.md`), then approve it or rework it.

## Pilots before you trust it

1. **One small feature end to end.** Expect a spec with testable criteria and a
   `CH10:` line, four verdicts, an approver decision, a clean merge, and the
   worktree and branch removed.
2. **One feature that should escalate** (for example, one that changes a cache
   key or adds a dependency). Expect all reviews to pass and the job to still
   land in `needs-human` with a readable `decision.md`.
3. **Two features in parallel sessions.** Expect no port, branch or state
   collisions.

It is working when all three behave as above, setup runs from a cold worktree
with no manual fixes, and at least one real CHANGES round shows the builder
fixing reviewer findings on resume.

## Requirements

- Claude Code with project skills and subagents
- A git repo whose default branch is `main`
- For apps with a UI: a headless browser CLI the agents can drive, named in
  `AGENTS.md`

## Costs and limits

- Each job takes at least 7 agent runs (spec, build, 4 reviews, approve). Each
  CHANGES round adds a builder resume and 4 reviews, so the most is 17. 4 to 8 of
  those runs use Opus. Start with small features.
- The approver is an LLM gate, not a guarantee. The escalate list and your
  `approve` / `rework` commands are the real safety net.
- The factory merges locally and never pushes. Pushing, PRs and deploys stay
  manual.
- There is no dashboard yet. Job state is in `factory/jobs/<job-id>/job.json`.

## Credits

- The factory loop pattern (spec, build, four parallel reviewers, approver, merge
  or escalate) follows the design shown by
  [zazencodes](https://github.com/zazencodes) in "Build Your Own AI Software
  Factory with Claude Code". This repository is an independent implementation and
  contains none of that project's files.
- The runtime components come from Chip Huyen, *AI Engineering* (O'Reilly,
  2025), chapter 10, "AI Engineering Architecture and User Feedback".

## License

MIT
