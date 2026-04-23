function new-issue --description "Create a GitHub issue, rename branch to chore/<num>-<slug>, amend HEAD with Fixes footer"
    if test -z "$GH_HOST"
        echo "new-issue: GH_HOST is not set. GH_HOST must be set explicitly for safety." >&2
        return 1
    end

    set --local current_branch (git branch --show-current)
    if contains $current_branch main master development
        echo "new-issue: refusing to run on protected branch '$current_branch'." >&2
        return 1
    end

    set --local subject (git log -n1 --format=%s)
    set --local original_message (git log -n1 --format=%B | string collect)
    echo "new-issue: using commit subject as title: $subject"

    echo "new-issue: creating issue on $GH_HOST (assignee=@me)..."
    set --local issue_url (gh issue create \
        --assignee=@me \
        --title="$subject" \
        --body=(mika branch-summary))
    or return 1
    echo "new-issue: created $issue_url"

    set --local issue_number (basename $issue_url)

    set --local slug (string replace --regex '^[^:]*:\s*' '' -- $subject \
        | string lower \
        | string replace --all --regex '[^a-z0-9]+' '-' \
        | string trim --chars '-')

    set --local new_branch "chore/$issue_number-$slug"
    echo "new-issue: renaming branch '$current_branch' -> '$new_branch'"
    git branch --move $new_branch

    echo "new-issue: amending HEAD with 'Fixes: $issue_url' footer"
    git commit --amend --message "$original_message" --message "Fixes: $issue_url"

    # gh issue view itself logs that the issue is opened in the browser, don't double log
    gh issue view $issue_number --web
end
