# ai-factory

A Claude Code plugin for AI projects. One command turns a one-line feature
request into a spec, builds it on its own branch, reviews it from four angles in
parallel, then merges it to `main` or hands it to you.

The reviewers know the shape an AI app's request path should have: context,
guardrails, router and gateway, caches, agent write actions, observability,
orchestration and user feedback. They check every change against that shape.

```
/ai-factory:factory add a /health endpoint that returns build version and uptime

feature -> spec-writer -> builder -> [security, code, ux, ui] -> approver -> merge | needs-human
                            ^------ any CHANGES (max 2 resumes) ------'
```

> **Status: v0.1, not yet piloted.** The files are complete, but no job has run
> from this plugin yet. Run the three pilots below before you trust it on real work.

## Install

```bash
claude plugin marketplace add NeverTheSame/ai-factory
claude plugin install ai-factory@ai-factory
```

Or run the same commands inside a session as `/plugin marketplace add …` and
`/plugin install …`. To share it with a team, add `--scope project` to both, then
commit `.claude/settings.json`. Teammates get the marketplace once they trust
the folder.

**Updates:** `claude plugin marketplace update ai-factory`, then
`claude plugin update ai-factory@ai-factory`. A new version is published only
when `version` in `plugin.json` changes.

## Set up a project

In the repo you want to run the factory in:

```
/ai-factory:init
```

It creates the following, and never overwrites a file that already exists:

| File | What it's for |
|---|---|
| `AGENTS.md` | setup, dev server, test commands, runtime shape, review checklist additions |
| `factory/backlog.md`, `factory/jobs/` | the queue and the per-job runtime state (gitignored) |
| `docs/ai-factory/FOUNDATIONS.md` | how the build loop and the runtime shape fit together |
| `docs/ai-factory/worksheet.md` | the per-app runtime-shape worksheet |
| `.claude/settings.json` | a `permissions.deny` rule for `git push`, merged into your existing file |

Then:

1. **Fill in the worksheet:** have, need or skip for each runtime component.
2. **Fill in `AGENTS.md`:** every `TODO`. This is the most important step,
   because every agent reads its repo knowledge from here. Prove the setup and
   test commands from a cold worktree.
3. **Fill in `AGENTS.md` → Review checklist additions:** the rows specific to
   this project for each reviewer and the approver. The agent files are shared
   across all your projects, so project rules go here, not in the plugin.
4. Commit on `main`, then run a pilot.

## Commands

```
/ai-factory:factory <feature>               new job through the full loop
/ai-factory:factory next                    first unchecked item in factory/backlog.md
/ai-factory:factory approve <job-id>        merge a needs-human job (main must be clean)
/ai-factory:factory rework <job-id> <note>  send a needs-human job back to the builder
/ai-factory:init                            set up the current repo
```

To run jobs in parallel, open one Claude Code session per job in the same repo.
Job numbers are claimed with `mkdir`, and each job has its own worktree, branch
and ports.

A job that ends in `needs-human` keeps its branch and worktree. Read
`factory/jobs/<job-id>/decision.md` (or the BLOCKED reason in `build.md`), then
approve it or rework it.

## Pilots before you trust it

1. **One small feature end to end.** Expect a spec with testable criteria and a
   `CH10:` line, four verdicts, an approver decision, a clean merge, and the
   worktree and branch removed.
2. **One feature that should escalate** (for example, one that changes a cache
   key or adds a dependency). Expect all reviews to pass and the job to still
   land in `needs-human`.
3. **Two features in parallel sessions.** Expect no port, branch or state
   collisions.

## What's inside

```
.claude-plugin/marketplace.json          this repo is its own marketplace
plugins/ai-factory/
  .claude-plugin/plugin.json             name, version
  skills/factory/SKILL.md                orchestrator: the loop, job.json, merge rules
  skills/init/SKILL.md                   project scaffolding
  agents/
    spec-writer.md        opus           -> spec.md (with a CH10 line)
    builder.md            opus           -> code in a worktree + build.md
    reviewer-security.md  opus           -> round-N/review-security.md
    reviewer-code.md      sonnet         -> round-N/review-code.md
    reviewer-ux.md        sonnet         -> round-N/review-ux.md (uses the running app)
    reviewer-ui.md        sonnet         -> round-N/review-ui.md (uses the running app)
    approver.md           opus           -> decision.md
  hooks/hooks.json, scripts/block-push.sh   refuses `git push` and tells the agent why
  templates/                             what /ai-factory:init copies
```

## Never pushes

Two layers, because a plugin can't ship permission rules:

- **Hard:** `permissions.deny` for `git push` in the project's
  `.claude/settings.json`. `/ai-factory:init` adds it.
- **Soft:** the plugin's `PreToolUse` hook, which also catches `git -C <dir> push`
  and explains the refusal to the agent.

This blocks Claude from pushing in that project, including in your own sessions.
Push yourself with `! git push` after you have reviewed what was merged.

## Without the plugin

Copy `plugins/ai-factory/agents/` to `.claude/agents/` and
`plugins/ai-factory/skills/factory/` to `.claude/skills/factory/`, then copy the
files from `templates/` by hand (see the table above). The command is then
`/factory`, and the agents have no `ai-factory:` prefix. The orchestrator handles
both. You lose the push hook and updates.

## Costs and limits

- Each job takes at least 7 agent runs (spec, build, 4 reviews, approve). Each
  CHANGES round adds a builder resume and 4 reviews, so the most is 17. 4 to 8 of
  those runs use Opus. Start with small features.
- The approver is an LLM gate, not a guarantee. The escalate list and your
  `approve` / `rework` commands are the real safety net.
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
