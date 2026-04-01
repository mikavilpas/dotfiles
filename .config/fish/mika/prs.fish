function prs --description "Show GitHub pull requests"
    gh pr list --author=@me --json number,title,url,headRefName,baseRefName,isDraft | mika prs-summary - --format=branches | glow --width=0
end
