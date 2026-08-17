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

NVIM_SERVERS_DIR=$HOME/.local/share/nvim/servers

export TERM=xterm-256color
export VISUAL=vi
export EDITOR=$VISUAL
bindkey -e # use default emacs bindings for shell

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

# Utilities

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

    vi() {
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
