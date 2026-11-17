function battail
    set file $argv[1]
    set needle $argv[2]
    # https://github.com/sharkdp/bat?tab=readme-ov-file#tail--f
    if [ -z "$needle" ]
        tail -F $file | bat --style="plain" --color=always --paging=never --language log
    else
        tail -F $file | rg --line-buffered "$needle" | bat --style="plain" --paging=never --language log
    end
end
