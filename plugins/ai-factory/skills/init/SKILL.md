---
name: init
description: Set up the current git repo for the ai-factory loop. Copies AGENTS.md, the backlog, the foundations doc and worksheet, adds the factory/jobs gitignore lines and the git-push deny rule. Never overwrites existing files. Use when the user runs /ai-factory:init.
argument-hint: "(no arguments)"
disable-model-invocation: true
---

# /ai-factory:init

Prepare the current repo so `/ai-factory:factory` can run in it.

## Locate the templates

The templates ship with this plugin in `templates/`, two directories above this
skill's own directory (`<plugin root>/templates/`). Use the base directory shown
when this skill loaded, or `${CLAUDE_PLUGIN_ROOT}/templates` if your environment
sets it. Confirm the folder exists before you copy anything.

## Steps

Work at the repo root (`git rev-parse --show-toplevel`). Stop and say why if the
current directory is not a git repo.

For each row: **if the target already exists, do not overwrite it.** Report it
as "kept" and, for `AGENTS.md`, tell the user which sections from the template
are missing from theirs.

| Template | Target |
|---|---|
| `templates/AGENTS.md` | `AGENTS.md` |
| `templates/backlog.md` | `factory/backlog.md` |
| (empty file) | `factory/jobs/.gitkeep` |
| `templates/docs/FOUNDATIONS.md` | `docs/ai-factory/FOUNDATIONS.md` |
| `templates/docs/worksheet.md` | `docs/ai-factory/worksheet.md` |

Then:

1. **`.gitignore`:** append these two lines only if they are not already present:
   ```
   factory/jobs/*
   !factory/jobs/.gitkeep
   ```
2. **`.claude/settings.json`:** make sure `permissions.deny` contains every rule
   in `templates/settings.json`. If the file exists, merge the rules into its
   existing `deny` array and keep every other key unchanged. If it doesn't exist,
   copy the template. This is the hard block on `git push`. The plugin's hook
   only adds a message for the agent.
3. **Do not commit.** Show `git status --short` and stop.

## Report

One short block:
- created: <paths>
- kept (already existed): <paths>
- next: "Fill in docs/ai-factory/worksheet.md, then every TODO in AGENTS.md,
  then prove the setup and test commands from a cold worktree. Commit, then run
  /ai-factory:factory <small feature>."
