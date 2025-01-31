
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
export PROJECTS_BASE_DIR=$HOME/Projects

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
    if tmux has-session; then
        if [[ -z $1 ]]; then
            tmux attach-session $1
        else
            # default to the last used session
            tmux attach-session
        fi
    elif [[ -z $1 ]]; then
        echo "Please provide a project name when attaching to a session that doesn't exist" 
    else
        mkdir -p $PROJECTS_BASE_DIR/$1
        cd $PROJECTS_BASE_DIR/$1

        tmux new-session -s $1 \
            \; rename-window frontend \; split-window -h \; send-keys vi C-m \; select-pane -L \; resize-pane -L 45 \
            \; new-window -n backend \; split-window -h \; send-keys vi C-m \; select-pane -L \; resize-pane -L 45 \
            \; select-window -p
    fi
}

# enable syntax highlighting (should be last)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
