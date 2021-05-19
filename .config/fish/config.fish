set -g fish_user_paths $fish_user_paths ~/bin ~/.cargo/bin ~/.local/bin

set -g MANPAGER "sh -c 'col -bx | bat -l man -p'"
set EDITOR vim
set -U FZF_COMPLETE 0
set -U FZF_LEGACY_KEYBINDINGS 0
set -U FZF_DEFAULT_OPTS "--height 40% --reverse --border"
set -g DISPLAY (cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0

source ~/.config/fish/dircolors.fish
source ~/.config/fish/marks.fish

bind \cx 'if jobs > /dev/null ; fg; fish_prompt; end'

abbr -a -g c "clip.exe"
abbr -a -g o wsl-open
abbr -a -g dot dotfiles
abbr -a -g fcon "source ~/.config/fish/config.fish"

alias ls "exa --group-directories-first"
alias ll "exa -la --group-directories-first"
alias lc "exa -1 --group-directories-first"
alias lt "exa -l --sort=modified"
alias vi "vim -u ~/.vimrc.basic"

# git

abbr -a -g gs     "git status --untracked-files"
abbr -a -g gl     "git lop -10"
abbr -a -g gll    "git lol -15"
abbr -a -g glp    "git lfs pull"
abbr -a -g glm    "gss git merge ; glp"
abbr -a -g ga     "git add"
abbr -a -g gch    "git checkout"
abbr -a -g gchm   "git checkout master"
abbr -a -g gchb   "git checkout -b"
abbr -a -g gd     "git diff"
abbr -a -g gdh    "git diff HEAD"
abbr -a -g gm     "git merge"
abbr -a -g gms    "git merge --squash"
abbr -a -g gb     "git branch"
abbr -a -g gba    "git branch -a"
abbr -a -g gf     "git fetch"
abbr -a -g gr     "git rebase"
abbr -a -g gc     "git commit"
abbr -a -g gcm    "git commit -m"
abbr -a -g gcau   "git commit --author"
abbr -a -g gcam   "git commit -am"
abbr -a -g ga     "git add"
abbr -a -g gaa    "git add -A"
abbr -a -g gpl    "git pull"
abbr -a -g gp     "git push"
abbr -a -g gpd    "git push -d origin"
abbr -a -g gpu    "git push -u origin"
abbr -a -g gpr    "git remote prune origin"
abbr -a -g grh    "git reset --hard"
abbr -a -g gcl    "git clean -fd"
abbr -a -g gst    "git stash"
abbr -a -g gsl    "git stash list"
abbr -a -g gsp    "git stash pop"
abbr -a -g gsu    "git submodule update"
abbr -a -g glom   "git lop -10 origin/master"
abbr -a -g gmom   "git merge origin/master"
abbr -a -g gmm    "git merge master"
abbr -a -g gss    "env GIT_LFS_SKIP_SMUDGE=1"


alias xdg-open wsl-open

alias dotfiles "git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

alias g "bookmark go"

alias restart-tmux "not pgrep tmux && tmux new -d -s delete-me \
                    && tmux run-shell ~/.tmux/plugins/tmux-resurrect/scripts/restore.sh \
                    && tmux kill-session -t delete-me \
                    && tmux attach || tmux attach "

# source /home/joe/.opam/opam-init/init.fish > /dev/null 2> /dev/null; or true
