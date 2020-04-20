function edit_dotfile
    set -l fname (dotfiles ls-files --full-name ~ \
                 | sd '.*(/.*/)' "$1" \
                 | rg -v README\|tar.gz \
                 | fzf --height 40% --layout reverse)
    if not test -z "$fname"
        # We need a slash cause we have dotfiles and rg regex will treat the dot 
        set -l fpath (dotfiles ls-files --full-name $HOME | rg -F "$fname")
        commandline -f repaint
        commandline "$EDITOR $HOME/$fpath"
        commandline -f execute
    end
end
