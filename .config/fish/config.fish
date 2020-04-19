set -g fish_user_paths $fish_user_paths ~/bin ~/.cargo/bin ~/.local/bin

set -g MANPAGER "sh -c 'col -bx | bat -l man -p'"
set EDITOR vim
set -U FZF_COMPLETE 0
set -U FZF_LEGACY_KEYBINDINGS 0

source ~/.config/fish/dircolors.fish

bind \cx 'if jobs > /dev/null ; fg; fish_prompt; end'

abbr -a -g c "clip.exe"
abbr -a -g o wsl-open
abbr -a -g dot dotfiles

alias ll "exa -la"
alias xdg-open wsl-ope

alias dotfiles "git --git-dir=$HOME/.dotfiles --work-tree=$HOME"


