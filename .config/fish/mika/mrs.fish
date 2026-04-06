function mrs --description "Show GitLab merge requests"
    glab mr list --author=@me --output=json | mika mrs-summary - --format=branches
end
