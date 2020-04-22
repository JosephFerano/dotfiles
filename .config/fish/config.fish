set -g fish_user_paths $fish_user_paths ~/bin ~/.cargo/bin ~/.local/bin

set -g MANPAGER "sh -c 'col -bx | bat -l man -p'"
set EDITOR vim
set -U FZF_COMPLETE 0
set -U FZF_LEGACY_KEYBINDINGS 0
set -U FZF_DEFAULT_OPTS "--height 40% --reverse --border"

source ~/.config/fish/dircolors.fish
source ~/.config/fish/marks.fish

bind \cx 'if jobs > /dev/null ; fg; fish_prompt; end'
bind \ep 'edit_dotfile'

abbr -a -g c "clip.exe"
abbr -a -g o wsl-open
abbr -a -g dot dotfiles
abbr -a -g fcon "source ~/.config/fish/config.fish"

alias ll "exa -la"
alias xdg-open wsl-open

alias dotfiles "git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

alias bms save_bookmark
alias g fuzzy_bookmarks
alias bmp print_bookmark
alias bmd delete_bookmark
alias bml list_bookmarks

alias restart-tmux "not pgrep tmux && tmux new -d -s delete-me \
                    && tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh \
                    && tmux kill-session -t delete-me \
                    && tmux attach || tmux attach "
