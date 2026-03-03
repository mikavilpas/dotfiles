#!/bin/bash
# git-autosquash-branch.sh
#
# feat(lazygit): add command to autosquash only one branch in a stack
#
# Autosquash only the specified branch in a stack, preserving fixups in
# branches above.
#
# **Issue:**
#
# git's `--autosquash` squashes ALL fixup commits in the rebase range.
# When working with stacked branches, you often want to squash only one
# branch's fixups (e.g., before merging it) while keeping fixups in
# dependent branches intact.
#
# **Solution:**
#
# Use a custom `GIT_SEQUENCE_EDITOR` that modifies the rebase todo list.
# After `--autosquash` arranges fixups, we convert fixups AFTER the target
# branch's update-ref marker back to regular "pick" commands, so they
# won't be squashed.
#
# Example:
#
# For a stack main -> branch1 -> branch2, running this on branch1
# produces:
#
# ```text
#   pick abc123 commit A        |
#   fixup def456 fixup! A       | <- these stay as fixup (will squash)
#   update-ref refs/heads/branch1
#   pick 111aaa commit B        |
#   fixup 222bbb fixup! B       | <- sed changes this to "pick" (preserved)
#   update-ref refs/heads/branch2
# ```
#
# https://stackoverflow.com/questions/29094595/git-interactive-rebase-without-opening-the-editor

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <branch-name>" >&2
  exit 1
fi

BRANCH="$1"

# Find the base commit (where this branch diverges from main/master)
BASE=$(git merge-base "$BRANCH" main 2>/dev/null ||
  git merge-base "$BRANCH" master 2>/dev/null ||
  git merge-base "$BRANCH" HEAD~50)

# The sed command explanation:
#   - Match from "update-ref refs/heads/<branch>" to end of file
#   - In that range, replace "fixup" at line start with "pick"
#   - This preserves fixups in branches above the target branch
#
# Note: Uses -i.bak for cross-platform compatibility (works on both BSD and GNU sed)
# The backup file is cleaned up afterward
export GIT_SEQUENCE_EDITOR='bash -c "sed -i.bak \"/^update-ref refs\\/heads\\/'${BRANCH}'\$/,\$ { s/^fixup/pick/; }\" \"\$1\" && rm -f \"\$1.bak\"" _'

git rebase -i --autosquash --update-refs "$BASE"
