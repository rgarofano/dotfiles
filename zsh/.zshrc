#
# █████████ ▄███████▄ ███   ███ ███████▄  ▄███████▄
#    ▄████▀ ███▄▄▄▄   ███   ███ ███   ███ ███▀  ▀▀▀
#  ▄████▀    ▀██████▄ ███▀▀▀███ ████████  ███      
# █████▄▄▄▄ ▄▄▄▄▄▄███ ███   ███ ███   ███ ████▄▄███
# ▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀  ▀▀▀   ▀▀▀ ▀▀▀   ▀▀▀  ▀▀▀▀▀▀▀ 
#

# ------------------------------------------------------------
# ENVIRONMENT
# ------------------------------------------------------------

export PATH=$PATH:$HOME/.local/bin
export EDITOR=vim
export VISUAL=$EDITOR
export TERM=xterm-256color

NVIM_SERVERS_DIR=$HOME/.local/share/nvim/servers

# ------------------------------------------------------------
# History
# ------------------------------------------------------------

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --zsh)"
fi

# ------------------------------------------------------------
# ALIASES
# ------------------------------------------------------------

if ls --help 2>&1 | grep -q -- --color; then
    alias ls='ls --color=auto -p'
    alias grep='grep --color=auto'
fi

# ------------------------------------------------------------
# COMPLETIONS
# ------------------------------------------------------------

autoload -Uz compinit
compinit
zmodload zsh/complist
zstyle ':completion:*' menu select
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
# case insensitive tab completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ------------------------------------------------------------
# PROMPT
# ------------------------------------------------------------

autoload -Uz vcs_info

precmd() {
    vcs_info
}

setopt PROMPT_SUBST

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' formats ' %F{red} %b%u%c%f'
zstyle ':vcs_info:git:*' actionformats ' %F{red} %b|%a%u%c%f'

PROMPT=$'\n%F{blue}󱄅 %m%f %~${vcs_info_msg_0_}\n%F{green}$%f '

# ------------------------------------------------------------
# BASH BACKWARDS COMPATIBILITY
# ------------------------------------------------------------

bindkey -e

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# ------------------------------------------------------------
# UTILITIES
# ------------------------------------------------------------

if command -v nvim >/dev/null 2>&1; then
    _vi_server_exists() {
        if [[ -z $1 ]]; then
            setopt localoptions null_glob
            local servers=("$NVIM_SERVERS_DIR"/*)
            return $(( ${#servers[@]} == 0 ))
        elif [[ -S $NVIM_SERVERS_DIR/$1 ]]; then
            return 0
        else
            return 1
        fi
    }

    vimux() {
        case "$1" in
        a | attach)
            if [[ -n $2 ]] && ! _vi_server_exists "$2"; then
                echo "\033[31mServer $2 doesn't exist\033[0m" >&2
                echo "'vimux ls' will show the available servers" >&2
                return 1
            fi
            local server_name=$2
            if [[ -z $server_name ]]; then
                server_name=$(ls "$NVIM_SERVERS_DIR" | fzf)
            fi
            local server=$NVIM_SERVERS_DIR/$server_name
            pkill -f "nvim .*--server $server --remote-ui"
            nvim --server "$server" --remote-ui
            ;;
        ls | list)
            if ! _vi_server_exists; then
                echo "No servers are currently running"
                return 0
            fi
            format='%-8s %-20s %-30s\n'
            printf "$format" PID NAME CWD
            for server in "$NVIM_SERVERS_DIR"/*; do
                local name=$(basename "$server")
                local pid=$(nvim --headless --server "$server" --remote-expr 'getpid()')
                local cwd=$(nvim --headless --server "$server" --remote-expr 'getcwd()')
                printf "$format" "$pid" "$name" "$cwd"
            done
            ;;
        *)
            echo "Usage: vimux (a|attach)|(ls|list)" >&2
            return 1
        esac
    }

    vim() {
        if [[ -n $1 ]]; then
            nvim "$@"
            return $?
        fi
        local server_name=$(basename $PWD)
        if _vi_server_exists "$server_name"; then
            echo "Server $server_name is already running"
            echo "Connecting to existing neovim instance"
            vimux attach "$server_name"
            return "$?"
        fi
        mkdir -p "$NVIM_SERVERS_DIR"
        nvim --listen "$NVIM_SERVERS_DIR/$server_name"
    }
fi
