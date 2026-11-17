#!/bin/bash
# Update the MR/PR description of a branch with a summary of its commits and the
# surrounding stack. Usage: update-pr-description.sh <branch>
set -euo pipefail

BRANCH="${1:?Usage: update-pr-description.sh <branch>}"
SUMMARY="$(mika branch-summary --branch "$BRANCH")"

# Resolve the forge from the branch's upstream remote rather than always
# using "origin". Some projects work with multiple git forges, so the
# branch may track a remote other than origin.
REMOTE_NAME="$(git config "branch.$BRANCH.remote" || true)"
if [[ -z "$REMOTE_NAME" ]]; then
  REMOTE_NAME="origin"
fi
REMOTE_URL="$(git remote get-url "$REMOTE_NAME")"

if [[ "$REMOTE_URL" == *"github"* || "$REMOTE_URL" == *"ghe.com"* ]]; then
  echo "Updating PR description for $BRANCH on GitHub"

  SUMMARY="$(echo "$SUMMARY" | oxfmt --config ~/.config/lazygit/oxfmt-markdown.json --stdin-filepath summary.md)"
  gh pr edit "$BRANCH" --body="$SUMMARY" --add-assignee="@me"
else
  echo "Updating MR description for $BRANCH on GitLab"

  # build a summary of the current mr stack
  # Same paging caveat as the GitHub branch above; 100 is glab's maximum.
  STACK_SUMMARY=$(glab mr list --per-page=100 --output=json | mika mr-stack-summary - --branch "$BRANCH")
  SUMMARY="$(printf '%s\n\n---\n\n# Merge request stack\n\n%s' "$SUMMARY" "$STACK_SUMMARY")"

  echo "$SUMMARY"

  glab mr update "$BRANCH" --description="$SUMMARY" --assignee="@me" --ready

  # GitLab may auto-draft if it sees fixup! commits, so mark ready a few more times
  for i in {1..5}; do
    sleep 2
    glab mr update "$BRANCH" --ready
  done
fi
