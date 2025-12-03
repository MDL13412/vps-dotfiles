# # vim: set ft=zsh fdm=marker ff=unix fileencoding=utf-8:
#
# https://github.com/dreamsofautonomy/zensh
export GPG_TTY=$(tty)

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


#{{{ homebrew
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
export PATH="$HOME/.local/bin:$HOME/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$GOBIN:/usr/local/sbin:/usr/local/bin:$PATH"
export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:${INFOPATH:-}";

fpath=(${HOMEBREW_PREFIX}/share/zsh/site-functions $fpath)
#}}}

export WORDCHARS='';

# 历史命令格式
export HIST_STAMPS="yyyy-mm-dd"
# 历史记录条目数量
export HISTSIZE=10000
# 注销后保存的历史记录条目数量
export SAVEHIST=10000
# 忽略一些命令
export HISTORY_IGNORE="(ls|ll|cd|pwd|exit)*"
export HISTDUP=erase
export HISTFILE="${HOME}/.zsh_history"

#{{{ zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

zinit ice depth=1; zinit light romkatv/powerlevel10k
zinit ice lucid wait"0a" from"gh-r" as"program" atload'eval "$(mcfly init zsh)"'
zinit light cantino/mcfly

# Add in zsh plugins
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light Aloxaf/fzf-tab
zinit light paulirish/git-open
zinit light junegunn/fzf-git.sh

# Add in snippets
zinit snippet OMZP::pip
zinit snippet OMZP::extract

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q
#}}}

# Keybindings
bindkey -e

export PIP_REQUIRE_VIRTUALENV=true

export ZSH_HIGHLIGHT_MAXLENGTH=60
export DISABLE_UPDATE_PROMPT=true

export SHELL=/bin/zsh
export CHEAT_EDITOR=vim
export EDITOR=vim
export LESS='-R'
export PAGER=less
# 禁用终端响铃
unsetopt BEEP

unsetopt flow_control

setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

##############################################################################
# alias
##############################################################################
alias lsa='ls -lah'
alias l='eza -lah'
alias ll='eza -lh'
alias c='clear'
alias lcd='cd '
alias k="lsd -lahF"

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gst='git status'
alias gb='git branch'
alias gcam='git commit --all --message'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcl='git clone --recurse-submodules'
alias gd='git diff'
alias gp='git push'

alias y='yadm'
alias ya='yadm add'
alias yaa='yadm add --all'
alias yst='yadm status'
alias ycam='yadm commit --all --message'
alias ycm='yadm commit --message'
alias yco='yadm checkout'
alias yp='yadm push'

# Shell integrations
# NOTE: 低版本不支持 --zsh 参数 (需要: 0.48.0+)
eval "$(fzf --zsh)"
#source /usr/share/doc/fzf/examples/key-bindings.zsh
#source /usr/share/doc/fzf/examples/completion.zsh
eval "$(direnv hook zsh)"

function take() {
    mkdir -p $@ && cd ${@:$#}
}

if command -v gds | grep alias >/dev/null 2>&1; then
    unalias gds
fi

function repo-sync() {
    pwd
    git add -A
    git commit -am "x"
    git push
}

function cloc-by-dir() {
    ls -d */ | xargs -I {} sh -c 'echo "\033[0;36m{}\033[0m" && cloc --progress-rate=0 --yaml "{}" | yq .SUM.code'
}

function gds() {
    git diff --color "$@" | delta --side-by-side --syntax-theme Dracula
}

function gdf() {
    git diff --color "$@" | delta --syntax-theme Dracula
}

function gdfi () {
    local selected_file_name="$(git status --short | peco | cut -c 4-)"
    gdf --cached -- "${selected_file_name}"
}

function gai () {
    git ls-files --modified --others --exclude-standard | peco --initial-filter=Fuzzy | xargs -r git add --
}

function ydf() {
    yadm diff --color "$@" | delta --syntax-theme Dracula
}

function m () {
    minikube kubectl -- "$@"
}

function gi() {
    curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@ ;
}

alias vimzshrc="vim ~/.zshrc"
alias vimzshrc-custom="vim ~/.zshrc-custom"
alias vimvimrc='vim ~/.vimrc'

##############################################################################
# User configuration
##############################################################################

export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

test -e "${HOME}/.zshrc-local" && source "${HOME}/.zshrc-local"
test -e "${HOME}/.zshrc-custom" && source "${HOME}/.zshrc-custom"

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=159"

function peco-git-branch-checkout () {
    local selected_branch_name="$(git branch -a | peco | tr -d ' ')"

    case "$selected_branch_name" in
        *-\>* )
            selected_branch_name="$(echo ${selected_branch_name} | perl -ne 's/^.*->(.*?)\/(.*)$/\2/;print')";;
        remotes* )
            selected_branch_name="$(echo ${selected_branch_name} | perl -ne 's/^.*?remotes\/(.*?)\/(.*)$/\2/;print')";;
    esac
    if [ -n "$selected_branch_name" ]; then
        BUFFER="git checkout ${selected_branch_name}"
        zle accept-line
    fi
    zle clear-screen
}
zle -N peco-git-branch-checkout
bindkey '^q' peco-git-branch-checkout


# use alt-x to execute this ZLE widget
function dk-exec() {
    local selected_container_info="$(docker ps | tail -n +2 | peco)"
    local selected_container_uuid=$(/bin/echo "${selected_container_info}" | awk '{print $1}')
    local brief_info=$(docker ps --filter "id=${selected_container_uuid}" --format "Name: {{.Names}}\tImage: {{.Image}}")

    BUFFER="# ${brief_info}
    docker exec -it ${selected_container_uuid} /bin/bash"
    zle down-line
    zle vi-end-of-line
    zle vi-backward-blank-word
    zle clear-screen
}
zle -N dk-exec

function dk-kill-and-rm() {
    local selected_container_info="$(docker ps | tail -n +2 | peco)"
    local selected_container_uuid=$(/bin/echo "${selected_container_info}" | awk '{print $1}')
    local brief_info=$(docker ps --filter "id=${selected_container_uuid}" --format "Name: {{.Names}}\tImage: {{.Image}}")

    BUFFER="# ${brief_info}
    docker kill ${selected_container_uuid};
    docker rm ${selected_container_uuid}"
    zle down-line
    zle down-line
    zle vi-end-of-line
    zle clear-screen
}
zle -N dk-kill-and-rm

function dk-ip() {
    local selected_container_info="$(docker ps | tail -n +2 | peco)"
    local selected_container_uuid=$(/bin/echo "${selected_container_info}" | awk '{print $1}')
    local brief_info=$(docker ps --filter "id=${selected_container_uuid}" --format "Name: {{.Names}}\tImage: {{.Image}}")

    BUFFER="# ${brief_info}
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' ${selected_container_uuid}"
    zle clear-screen
}
zle -N dk-ip

function dk-log-f() {
    local selected_container_info="$(docker ps | tail -n +2 | peco)"
    local selected_container_uuid=$(/bin/echo "${selected_container_info}" | awk '{print $1}')
    local brief_info=$(docker ps --filter "id=${selected_container_uuid}" --format "Name: {{.Names}}\tImage: {{.Image}}")

    BUFFER="# ${brief_info}
    docker logs -f ${selected_container_uuid}"
    zle clear-screen
    zle down-line
    zle vi-end-of-line
}
zle -N dk-log-f

# 例如在 vim 中, 按 ctrl-z 停止当前任务, 可以在终端进行操作, 再次 ctrl-z 回到 vim
# see: https://gist.github.com/jeebak/2fb31f964669892f6ef457508916bdb3
function fancy-ctrl-z() {
  local suspended_jobs="$(jobs -s)"
  if [[ -n "$suspended_jobs" ]] && [[ $#BUFFER -eq 0 ]]; then
    builtin fg
    zle accept-line
  else
    zle push-input
    zle clear-screen
    zle get-line
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

zmodload zsh/terminfo

bindkey "$terminfo[cuu1]" history-substring-search-up
bindkey "$terminfo[cud1]" history-substring-search-down

bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

function compress() {
    tar vzcf $1.tar.gz $1
}

function girm() {
    git status --porcelain=v1 | peco | awk '{$1=""; sub("^ ", ""); print}' | xargs -I {} rm {}
}

function pretty_print_text() {
    python -c 'import sys, json; print(json.loads(input()))'
}

function copyfile {
  clipcopy $1
}

function clipcopy() {
    cat "${1:-/dev/stdin}" | pbcopy;
}

function clippaste() {
    pbpaste;
}

# Copies the path of given directory or file to the system or X Windows clipboard.
# Copy current directory if no parameter.
function copypath {
  # If no argument passed, use current directory
  local file="${1:-.}"

  # If argument is not an absolute path, prepend $PWD
  [[ $file = /* ]] || file="$PWD/$file"

  # Copy the absolute path without resolving symlinks
  # If clipcopy fails, exit the function with an error
  print -n "${file:a}" | clipcopy || return 1

  echo ${(%):-"%B${file:a}%b copied to clipboard."}
}

function zsh_stats() {
    fc -l 1 \
        | awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' \
        | grep -v "./" | sort -nr | head -n 20 | column -c3 -s " " -t | nl
}


#eval "$(mcfly init zsh)"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

