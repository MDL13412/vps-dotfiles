# vim: set ft=zsh fdm=marker ff=unix fileencoding=utf-8:

" homebrew 安装的 fzf 跟 fzf-tab 不兼容, 需要手工拷贝到 /usr/local/bin/fzf

export GPG_TTY=$(tty)

#zmodload zsh/zprof
# 如果要分析性能的话打开加载这个模块

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export MYZSH_CONF_DIR="${HOME}/.config/myzsh"

#{{{ homebrew
export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
export PATH="$HOME/.local/bin:$HOME/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:$GOBIN:/usr/local/sbin:/usr/local/bin:$PATH"
export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH+:$MANPATH}:";
export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:${INFOPATH:-}";

fpath=(${HOMEBREW_PREFIX}/share/zsh/site-functions $fpath)
#}}}

#{{{ zinit
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

zinit ice depth=1; zinit light romkatv/powerlevel10k

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

#{{{ lib
# nslib_log "info" "This is a info message";
function nslib_log() {
    local level="$1"
    local msg="$2"

    case $level in
        error)          echo -e "\033[41;30;1m[ERROR] ${msg}\033[0m";;
        warn|warning)   echo -e "\033[43;30;1m[WARNING] ${msg}\033[0m";;
        info)           echo -e "\033[47;30;1m[INFO] ${msg}\033[0m";;
        debug)          echo "[DEBUG] ${msg}";;
        *)              echo "[NOTSET] ${msg}";;
    esac
}

function nslib_debug() {
    echo "$(date "+%Y-%m-%d %H:%M:%S") - $@" >> /tmp/nslib_debug.log
}

function source-file() { [[ -s "$1" ]] && source "$1" }
#}}}

#{{{ zsh options
bindkey -e

export PIP_REQUIRE_VIRTUALENV=true

export ZSH_HIGHLIGHT_MAXLENGTH=60
export DISABLE_UPDATE_PROMPT=true

export SHELL=/bin/zsh
export CHEAT_EDITOR=vim
export EDITOR=vim
export LESS='-R'
export PAGER=less

export WORDCHARS='';
HIST_STAMPS="yyyy-mm-dd"    # 历史命令格式
HISTSIZE=10000              # 历史记录条目数量
SAVEHIST=10000              # 注销后保存的历史记录条目数量
HISTDUP=erase
unsetopt BEEP               # 禁用终端响铃
# 忽略一些命令
HISTORY_IGNORE="(ls|l|ll|k|ga|gaa|gst|gb|gcam|gco|gcb|gd|gp|gpl|ya|yaa|yst|ycam|ycm|yco|yp|ypl|gds|gdf|gdfi|gdt|gai|ydf|cd|pwd|exit)*"

export HISTFILE="${HOME}/.zsh_history"

unsetopt flow_control
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' completer _complete _expand _list _match _prefix
zstyle ':completion:*' insert-tab pending   # pasting with tabs doesn't perform completion
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
#}}}

#{{{ port of oh-my-zsh builtin
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

function take() { mkdir -p $@ && cd ${@:$#} }
function compress() { tar vzcf $1.tar.gz $1 }
function copyfile { clipcopy $1 }
function clipcopy() { cat "${1:-/dev/stdin}" | pbcopy; }
function clippaste() { pbpaste; }

function copypath {
  local file="${1:-.}"
  [[ $file = /* ]] || file="$PWD/$file"
  print -n "${file:a}" | clipcopy || return 1
  echo ${(%):-"%B${file:a}%b copied to clipboard."}
}

function zsh_stats() {
    fc -l 1 \
        | awk '{ CMD[$2]++; count++; } END { for (a in CMD) print CMD[a] " " CMD[a]*100/count "% " a }' \
        | grep -v "./" | sort -nr | head -n 20 | column -c3 -s " " -t | nl
}
#}}}

#{{{ misc
# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"

alias lsa='ls -lah'

function k {
    { __print-path-argument $@; eza -lah --time-style=long-iso --color=always $@ } \
        | add-index --input-type eza_list --print-indexables | set-index-variables
}
compdef _ls k

function la {
    { __print-path-argument $@; eza -lah --time-style=long-iso --color=always $@ } \
        | add-index --input-type ls_list --print-indexables | set-index-variables
}
compdef _ls la

function l {
    { __print-path-argument $@; eza -lah --time-style=long-iso --color=always $@ } \
        | add-index --input-type eza_list --print-indexables | set-index-variables
}
compdef _ls l

function ll {
    { __print-path-argument $@; eza -lh --time-style=long-iso --color=always $@ } \
        | add-index --input-type eza_list --print-indexables | set-index-variables
}
compdef _ls ll

alias c='clear'
alias lcd='cd '

alias timezsh='for i in $(seq 1 10); do time zsh -i -c exit; done'

function repo-sync() {
    nslib_log info "repo-sync: $(pwd)"
    git add -A && git commit -am "x" && git push
}

alias vimzshrc="vim ~/.zshrc"
alias vimzshrc-custom="vim ~/.zshrc-custom"
alias vimvimrc='vim ~/.vimrc'
#}}}

#{{{ User configuration
export GOPATH=$HOME/go
export GOBIN=$GOPATH/bin
export PATH="$GOBIN:$PATH"

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

export EZA_CONFIG_DIR=${HOME}/.config/eza
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line --info=inline-right --ansi \
  --layout=reverse --border=none --color=bg+:#283457 \
  --color=bg:#16161e --color=border:#27a1b9 --color=fg:#c0caf5 \
  --color=gutter:#16161e --color=header:#ff9e64 --color=hl+:#2ac3de \
  --color=hl:#2ac3de --color=info:#545c7e --color=marker:#ff007c \
  --color=pointer:#ff007c --color=prompt:#2ac3de \
  --color=query:#c0caf5:regular --color=scrollbar:#27a1b9 \
  --color=separator:#ff9e64 --color=spinner:#ff007c \
"
#}}}
#{{{ widgets
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
#}}}

#{{{ other
function pretty_print_text() { python -c 'import sys, json; print(json.loads(input()))' }
function cloc-by-dir() {
    ls -d */ | xargs -I {} sh -c 'echo "\033[0;36m{}\033[0m" && cloc --progress-rate=0 --yaml "{}" | yq .SUM.code'
}
function show-term-colors() {
    for i in {0..255}; do
        print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'};
    done
}

source-file "${HOME}/.zshrc-local";
source-file "${HOME}/.zshrc-custom";

export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=159"

zmodload zsh/terminfo

bindkey "$terminfo[cuu1]" history-substring-search-up
bindkey "$terminfo[cud1]" history-substring-search-down

bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

source-file "${HOMEBREW_PREFIX}/opt/asdf/libexec/asdf.sh";

eval "$(mcfly init zsh)"
#}}}

#{{{ SCM Breeze 替代
fzf-or-complete() {
  if (( $+widgets[fzf-completion] )); then
    nslib_debug "fzf-completion"
    zle fzf-completion
  else
    nslib_debug "expand-or-complete"
    zle expand-or-complete
  fi
}
zle -N fzf-or-complete

# See: https://sblask.github.io/blog/tech/2017/04/10/migrating-away-from-scm-breeze.html
function __flatten-index-arguments {
    for argument in $( echo $@ )
    do
        if [[ "${argument}" =~ ^[0-9]+-[0-9]+$ ]]
        then
            for index in $( eval echo {${argument/-/..}} )
            do
                echo ${index}
            done
        else
            echo ${argument}
        fi
    done
}

function __expand-indexes {
    for index in $( __flatten-index-arguments $@ ); do
        local index_variable="e${index}"
        local resolved_index=$( eval echo "\"\${${index_variable}}\"" )
        if [ "${resolved_index}" != "" ]; then
            # printf "${resolved_index}" | gnu-sed --regexp-extended "s|([ '\"])|\\\\\1|g"
            printf "${resolved_index}" | sed -E 's/([ '\''"])/\\\1/g'
            printf " "
        else
            printf ""
        fi
    done
}

function expand-indexes-or-expand-or-complete {
    # local MATCH=$( echo ${LBUFFER} | grep --perl-regexp --only-matching "(?<=^| )([0-9]+([ -][0-9]+)*)$" 2>/dev/null )
    local MATCH=$( echo ${LBUFFER} | grep -Eo "(^| )[0-9]+([ -][0-9]+)*$" | sed 's/^ //' 2>/dev/null )
    if [ "${MATCH}" != "" ]; then
        local REPLACEMENT=$( __expand-indexes ${MATCH} )
        if [ "${REPLACEMENT}" != "" ]; then
            LBUFFER="${LBUFFER/%${MATCH}/${REPLACEMENT}}"
        else
            fzf-or-complete
            # zle expand-or-complete
            # NOTE: 这里触发 fzf 的补全行为
            # zle fzf-completion
        fi
    else
        # zle expand-or-complete
        # NOTE: 这里触发 fzf 的补全行为
        fzf-or-complete
        #zle fzf-completion
    fi
}

function set-index-variables() {
    local input="$(cat -)"

    local old_ifs=$IFS
    IFS=$'\n'

    local index=1
    #echo $input | sed --expression '0,/@@indexables@@/d' | while read -r file
    echo $input | sed -e '1,/@@indexables@@/d' | while read -r file
    do
        export e$index="$file"
        let index++
    done

    #echo $input | sed --expression '/@@indexables@@/,$d' | while read -r line
    echo $input | sed -e '/@@indexables@@/,$d' | while read -r line
    do
        echo $line
    done

    IFS=$old_ifs
}

function __print-path-argument {
    local path_arguments=()
    for argument in $@; do
        if [ -d "${argument}" ]
        then
            path_arguments+=("${argument}")
        fi
    done
    # ls prints paths if several are given, but not if it's only one
    if [[ "${#path_arguments[@]}" -eq "1" ]]; then
        echo "${path_arguments[1]}:"
    fi
}

zle -N expand-indexes-or-expand-or-complete
bindkey -M viins '^I' expand-indexes-or-expand-or-complete
bindkey '^I' expand-indexes-or-expand-or-complete

function findi {
    local lines=$(find $@)
    local restricted=false
    if [ $(echo $lines | wc -l) -gt 99 ]; then
        lines="$(echo $lines | head -n 99)"
        restricted=true
    fi

    echo $lines | add-index --input-type list --print-indexables | set-index-variables
    if $restricted; then
        echo "\n\n..."
    fi
}
compdef _find find

function findu {
    find $@ | add-index --input-type list --print-indexables | set-index-variables
}
compdef _find findu

alias g='git'
alias ga='git add'
alias gaa='git add --all'
function gst() {
    git status $@ | add-index --input-type git_status --print-indexables | set-index-variables
}
alias gb='git branch'
alias gcam='git commit --all --message'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcl='git clone --recurse-submodules'
alias gd='git diff'
alias gp='git push'
alias gpl='git pull --rebase'

alias y='yadm'
alias ya='yadm add'
alias yaa='yadm add --all'
function yst() {
    yadm status $@ | add-index --input-type git_status --print-indexables | set-index-variables
}
alias ycam='yadm commit --all --message'
alias ycm='yadm commit --message'
alias yco='yadm checkout'
alias yp='yadm push'
alias ypl='yadm pull --rebase'

if command -v gds | grep alias >/dev/null 2>&1; then
    unalias gds
fi

function gds() { git diff --color "$@" | delta --side-by-side --syntax-theme Dracula }
function gdv() { git diff --color "$@" | delta --side-by-side --syntax-theme Dracula }
function gdf() { git diff --color "$@" | delta --syntax-theme Dracula }

function gdfi () {
    local selected_file_name="$(git status --short | peco | cut -c 4-)"
    gdf --cached -- "${selected_file_name}"
}

function gdt() {
    params="$@"
    if brew ls --versions scmpuff > /dev/null; then
        params=`scmpuff expand "$@" 2>/dev/null`
    fi

    if [ $# -eq 0 ]; then
        git difftool --no-prompt --extcmd "icdiff --line-numbers --no-bold" | less
    elif [ ${#params} -eq 0 ]; then
        git difftool --no-prompt --extcmd "icdiff --line-numbers --no-bold" "$@" | less
    else
        git difftool --no-prompt --extcmd "icdiff --line-numbers --no-bold" "$params" | less
    fi
}

function gai () {
    git ls-files --modified --others --exclude-standard | peco --initial-filter=Fuzzy | xargs -r git add --
}

function ydf() { yadm diff --color "$@" | delta --syntax-theme Dracula }
function yds() { yadm diff --color "$@" | delta --side-by-side --syntax-theme Dracula }
function ydv() { yadm diff --color "$@" | delta --side-by-side --syntax-theme Dracula }

function girm() {
    git status --porcelain=v1 | peco | awk '{$1=""; sub("^ ", ""); print}' | xargs -I {} rm {}
}

function enable-git-debug() {
    export GIT_TRACE_PACKET=1; export GIT_TRACE=1; export GIT_CURL_VERBOSE=1; export GIT_SSH_COMMAND="ssh -vvv";
}
#}}}

source-file ~/.p10k.zsh
