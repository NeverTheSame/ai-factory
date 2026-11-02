#!/bin/sh
# PreToolUse hook: refuse any Bash command that runs `git push`, including
# `git -C <dir> push`. The factory merges locally and never pushes; the human
# pushes. Exit 2 blocks the tool call and shows stderr to the agent.
#
# This is the soft layer. The hard layer is a permissions.deny rule in the
# project's .claude/settings.json (see templates/settings.json).

input=$(cat)

if printf '%s' "$input" | grep -Eq '(^|[^[:alnum:]_-])git([[:space:]]+-[^[:space:]]+([[:space:]]+[^-[:space:]][^[:space:]]*)?)*[[:space:]]+push([^[:alnum:]_-]|$)'; then
  echo "ai-factory: git push is blocked. The factory never pushes; the human pushes after review." >&2
  exit 2
fi

exit 0
