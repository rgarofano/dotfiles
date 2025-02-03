
# ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗███████╗    ███████╗███████╗██╗  ██╗██████╗  ██████╗    
# ██╔══██╗╚██╗ ██╔╝██╔══██╗████╗  ██║██╔════╝    ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝    
# ██████╔╝ ╚████╔╝ ███████║██╔██╗ ██║███████╗      ███╔╝ ███████╗███████║██████╔╝██║         
# ██╔══██╗  ╚██╔╝  ██╔══██║██║╚██╗██║╚════██║     ███╔╝  ╚════██║██╔══██║██╔══██╗██║         
# ██║  ██║   ██║   ██║  ██║██║ ╚████║███████║    ███████╗███████║██║  ██║██║  ██║╚██████╗    
# ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝    ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝    

# prompt
eval "$(starship init zsh)"

# setup history file
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.cache/zsh/history"

# autocompletion
autoload -U compinit
zstyle ":completion:*" menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)
source <(fzf --zsh)

# cycle through tab completion options with vim keybindings
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# command shortcuts
alias ll="ls -la"
alias vi="nvim"

# dotfile management
alias config='git --git-dir=/home/rgarofano/dotfiles --work-tree=/home/rgarofano/.config'
config config --local status.showUntrackedFiles no

# code - search codebase from current directory and open selected files in neovim
# bat is used instead of cat for syntax highlighting
alias code='vi $(fzf --preview="bat --color=always {}")'
# ipkg - install software on Arch linux by selecting package(s) in the fuzzy finder
alias ipkg='pacman -Slq | fzf --multi --preview "pacman -Si {}" | xargs -ro sudo pacman -S'
# rmpkg - remove software on Arch linux by selecting package(s) in the fussy finder
alias rmpkg='pacman -Qq | fzf --multi --preview "pacman -Qi {}" | xargs -ro sudo pacman -Rns'
# update Arch linux with a more intuitive command
alias update='sudo pacman -Syu'

# shortcut for zshrc path
export ZSHRC="$HOME/.config/zsh/.zshrc"

# set the default editor
export VISUAL=nvim
export EDITOR="$VISUAL"

# Directory for personal projects
export PROJECTS_BASE_DIR="$HOME/Projects"

function edit-command-line-inplace() {
  if [[ $CONTEXT != start ]]; then
    if (( ! ${+widgets[edit-command-line]} )); then
      autoload -Uz edit-command-line
      zle -N edit-command-line
    fi
    zle edit-command-line
    return
  fi
  () {
    emulate -L zsh -o nomultibyte
    local editor=("${(@Q)${(z)${VISUAL:-${EDITOR:-vi}}}}") 
    case $editor in
      (*vim*)
        "${(@)editor}" -c "normal! $(($#LBUFFER + 1))go" -- $1
      ;;
      (*emacs*)
        local lines=("${(@f)LBUFFER}") 
        "${(@)editor}" +${#lines}:$((${#lines[-1]} + 1)) $1
      ;;
      (*)
        "${(@)editor}" $1
      ;;
    esac
    BUFFER=$(<$1)
    CURSOR=$#BUFFER
  } =(<<<"$BUFFER") </dev/tty
}

zle -N edit-command-line-inplace
bindkey "^e" edit-command-line-inplace

function project() {
    if [[ -z $1 ]]; then
        tmux attach-session
        return 0
    fi

    if [[ ! -z $2 ]]; then
        if tmux has-session -t "$1 ($2)"; then
            tmux attach-session -t "$1 ($2)"
            return 0
        fi
    else
        if tmux has-session -t "$1 (frontend)"; then
            tmux attach-session -t "$1 (frontend)"
            return 0
        elif tmux has-session -t "$1 (backend)"; then
            tmux attach-session -t "$1 (backend)"
            return 0
        fi
    fi

    frontend_dir="$PROJECTS_BASE_DIR/$1/${1}-client"
    backend_dir="$PROJECTS_BASE_DIR/$1/${1}-server"
    mkdir -p $frontend_dir
    mkdir -p $backend_dir

    tmux new-session -c $frontend_dir -s "$1 (frontend)" \
        \; rename-window Neovim \; send-keys vi C-m \; new-window \; detach
    tmux new-session -c $backend_dir -s "$1 (backend)" \
        \; rename-window Neovim \; send-keys vi C-m \; new-window \; detach

    if [[ ! -z $2 ]]; then
        tmux attach-session -t "$1 ($2)"
        return 0
    fi

    tmux attach-session -t "$1 (frontend)"
}

function create_react_app() {
    if [[ -z $1 ]]; then
        echo "Error: Expected an argument for the name of the app"
        return 0
    fi

    npm create vite@latest $1 -- --template react-ts
    cd $1
    npm install tailwindcss @tailwindcss/vite
    sed -i "/import { defineConfig } from 'vite'/a\import tailwindcss from '@tailwindcss/vite'" vite.config.ts
    sed -i 's/plugins: \[react()\],/plugins: \[tailwindcss(), react()],/' vite.config.ts
    sed -i '1i @import "tailwindcss";\n' src/index.css
    sed -i 's/React/React + Tailwindcss/' src/App.tsx
}

# enable syntax highlighting (should be last)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
