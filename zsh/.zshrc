# Prompt

if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# History

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Environment

NVIM_SESSION_DIR=$HOME/.local/share/nvim/sessions

export TERM=xterm-256color
export VISUAL=vi
export EDITOR=$VISUAL

# Path

export PATH=$PATH:$HOME/.config/emacs/bin

# Aliases

if ls --color=auto >/dev/null; then
    alias ls='ls --color=auto -p'
fi

if grep --color=auto 'test' <<<'test' >/dev/null 2>&1; then
    alias grep='grep --color=auto'
fi

if command -v mpv >/dev/null 2>&1; then
    alias mpv='mpv --save-position-on-quit=yes'
fi

# Completions

autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# Utilities

if command -v nvim >/dev/null 2>&1; then
    vi() {
        if [[ -n $1 ]]; then
            nvim "$@"
            return $?
        fi
        session_name=$(basename $PWD)
        if [[ -S $NVIM_SESSION_DIR/$session_name ]]; then
            echo -e "\033[31mSession $session_name already exists\033[0m" >&2
            echo "Run 'vimux a[ttach] $session_name'" >&2
            return 1
        fi
        mkdir -p "$NVIM_SESSION_DIR"
        nvim --listen "$NVIM_SESSION_DIR/$session_name"
    }

    vimux() {
        case "$1" in
        a | attach)
            session_name=$2
            if [[ -z $session_name ]]; then
                session_name=$(ls "$NVIM_SESSION_DIR" | fzf) 
            fi
            server=$NVIM_SESSION_DIR/$session_name
            pkill -f "nvim .*--server $server --remote-ui"
            nvim --server "$server" --remote-ui
            ;;
        ls | list)
            format='%-8s %-20s %-30s %7s\n'
            printf "$format" PID NAME CWD BUFFERS
            for server in "$NVIM_SESSION_DIR"/*; do
                name=$(basename "$server")
                pid=$(nvim --headless --server "$server" --remote-expr 'getpid()')
                cwd=$(nvim --headless --server "$server" --remote-expr 'getcwd()')
                buffers=$(nvim --headless --server "$server" --remote-expr 'len(getbufinfo({"buflisted": 1}))')
                printf "$format" "$pid" "$name" "$cwd" "$buffers"
            done
            ;;
        *)
            echo "Usage: vimux (a|attach)|(ls|list)" >&2
            return 1
        esac
    }
fi
