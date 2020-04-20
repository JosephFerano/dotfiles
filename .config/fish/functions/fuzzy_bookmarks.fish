function fuzzy_bookmarks
    if test -z "$argv"
        set -l result (bml | fzf --height 40% --ansi --preview "tree -L 2 (echo {2})" | awk '{print $1}')
        if not test -z "$result"
            go_to_bookmark $result
        end
    else
        go_to_bookmark $argv[1]
    end
end 
