#!/bin/bash
# git-create-worktree.sh
#
# Create a git worktree with git-wt, install dependencies, and copy local
# config files. Prints the worktree path to stdout.
#
# Usage: git-create-worktree.sh <branch-name>
#
# The branch name should include the full path (e.g., "feature/my-task").
#
# Steps:
#   1. Detect package manager (pnpm, npm, or none)
#   2. Create worktree via git-wt with appropriate --hook flag
#   3. Copy local config files (.mise.local.toml, .env*) preserving paths
#   4. Print the worktree path

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <branch-name>" >&2
  exit 1
fi

BRANCH="$1"

# Detect package manager
HOOK_ARGS=()
if [[ -f "pnpm-lock.yaml" ]]; then
  HOOK_ARGS=(--hook "mise exec -- pnpm i")
elif [[ -f "package-lock.json" ]]; then
  HOOK_ARGS=(--hook "mise exec -- npm i")
fi

# Create worktree (--nocd prints the path instead of changing directory)
WORKTREE_PATH=$(mise exec -- git-wt --nocd "${HOOK_ARGS[@]}" "$BRANCH")

# Copy local config files preserving relative paths
# - .mise.local.toml: local mise tool configuration
# - .env files: .env, .env.local, .env.*.local
mise exec -- fd --hidden --no-ignore --type f \
  "^\.mise\.local\.toml$|^\.env(\.local|\..*\.local)?$" . \
  --exec sh -c 'cp "$1" "'"$WORKTREE_PATH"'/$1"' _ {}

echo "git worktree created to path: $WORKTREE_PATH"
cd "$WORKTREE_PATH"
