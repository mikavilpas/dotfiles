---
name: isolate
description:
  Implement a task in an isolated git worktree using git-wt. Use when asked to isolate work, work in a worktree, or
  implement something separately.
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Task
---

# Isolated Worktree Task

Implement a task in a new git worktree using `git-wt` (<https://github.com/k1LoW/git-wt>).

**IMPORTANT: Execute all steps autonomously without asking for confirmation. The user is offloading this task to you —
proceed through every step (worktree creation, implementation, tests, commits) on your own and report back only when
finished.**

## Instructions

1. Parse a short kebab-case name from the task (e.g., "add gitlab support" → "gitlab-support")

2. Create the worktree using the shared script:

   ```bash
   WORKTREE_PATH=$(~/.config/lazygit/git-create-worktree.sh "feature/<name>")
   ```

   This handles package manager detection, dependency installation, and copying local config files.

3. Create an empty WIP commit describing the task intent:

   ```bash
   git -C <worktree-path> commit --allow-empty -m "$(cat <<'EOF'
   WIP: <short task description, max 70 chars>

   <longer description of the task/intent if needed>
   EOF
   )"
   ```

4. Implement the task:
   - Use absolute paths for all file operations

5. Run tests in the worktree if applicable

6. Commit the changes:

   ```bash
   git -C <worktree-path> add -A
   git -C <worktree-path> commit -m "<descriptive message>"
   ```

7. Before reporting, verify that code quality tools pass in the worktree:
   - Formatters (e.g., `prettier`, `biome format`)
   - Linters (e.g., `eslint`, `biome lint`)
   - Tests (e.g., `vitest`, `jest`, `pytest`)
   - Type checking (e.g., `tsc --noEmit`)

   Run whichever tools are configured for the project. Fix any issues before proceeding.

8. Report back with:
   - Summary of what was implemented
   - Worktree path
   - Branch name: `feature/<name>`
   - How to review: `cd <worktree-path>`
   - How to merge: `git merge feature/<name>`
   - How to cleanup: `mise exec -- git-wt -d feature/<name>`

## Task

$ARGUMENTS
