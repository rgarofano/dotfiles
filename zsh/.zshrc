# ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗███████╗    ███████╗███████╗██╗  ██╗██████╗  ██████╗    
# ██╔══██╗╚██╗ ██╔╝██╔══██╗████╗  ██║██╔════╝    ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝    
# ██████╔╝ ╚████╔╝ ███████║██╔██╗ ██║███████╗      ███╔╝ ███████╗███████║██████╔╝██║         
# ██╔══██╗  ╚██╔╝  ██╔══██║██║╚██╗██║╚════██║     ███╔╝  ╚════██║██╔══██║██╔══██╗██║         ██║  ██║   ██║   ██║  ██║██║ ╚████║███████║    ███████╗███████║██║  ██║██║  ██║╚██████╗    
# ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝    ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝    

# prompt
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
tux=$(echo "\Uebc6")
git=$(echo "\Ue702")
zstyle ':vcs_info:git:*' formats " $git %b"
setopt prompt_subst
PROMPT='[%F{yellow}${tux} %F{cyan}%n%f %f%F{blue}%~%f%F{red}${vcs_info_msg_0_}%f]$ '

# autocompletion
autoload -U compinit
zstyle ":completion:*" menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)

# cycle through tab completion options with vim keybindings
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# setup history file
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.cache/zsh/history"

# aliases
alias ll="ls -laF"
alias vi="nvim"
alias webcam="mpv --profile=low-latency --untimed --demuxer-lavf-o-set=input_format=mjpeg /dev/video0"
alias xclip="xclip -selection c"
alias gcan="git commit --amend --no-edit"

# Escape question mark character in pasted links
set zle_bracketed_paste
autoload -Uz bracketed-paste-magic url-quote-magic
zle -N bracketed-paste bracketed-paste-magic
zle -N self-insert url-quote-magic

# dotfile management
alias config="git --git-dir=$HOME/dotfiles --work-tree=$HOME/.config"
config config --local status.showUntrackedFiles no

# code - search codebase from current directory and open selected files in neovim
# bat is used instead of cat for syntax highlighting
alias code='vi $(fzf --preview="bat --color=always {}")'
# ipkg - install software on Arch linux by selecting package(s) in the fuzzy finder
alias ipkg='yay -Slq | fzf --multi --preview "yay -Si {}" | xargs -ro yay -S'
# rmpkg - remove software on Arch linux by selecting package(s) in the fussy finder
alias rmpkg='yay -Qq | fzf --multi --preview "yay -Qi {}" | xargs -ro yay -Rns'
# update Arch linux with a more intuitive command
alias update='yay -Syu'

# set the default editor
export VISUAL=nvim
export EDITOR="$VISUAL"

# have proper terminal experience over ssh
export TERM=xterm-256color

# Directory for personal projects
export PROJECTS_BASE_DIR="$HOME/Projects"

function project() {
    [[ -z $1 ]] && tmux attach-session && return 0

    if [[ -z $2 ]]; then
        tmux has-session -t "$1 (frontend)" && tmux attach-session -t "$1 (frontend)" && return 0
        tmux has-session -t "$1 (backend)" && tmux attach-session -t "$1 (backend)" && return 0
    else
        tmux has-session -t "$1 ($2)" && tmux attach-session -t "$1 ($2)" && return 0
    fi

    frontend_dir="$PROJECTS_BASE_DIR/$1/client"
    backend_dir="$PROJECTS_BASE_DIR/$1/server"
    mkdir -p $frontend_dir
    mkdir -p $backend_dir

    tmux new-session -c $frontend_dir -s "$1 (frontend)" \
        \; rename-window Neovim \; send-keys vi C-m \; new-window \; detach
    tmux new-session -c $backend_dir -s "$1 (backend)" \
        \; rename-window Neovim \; send-keys vi C-m \; new-window \; detach

    [[ -z $2 ]] || tmux attach-session -t "$1 ($2)" && return 0

    tmux attach-session -t "$1 (frontend)"
}

function create_react_app() {
    [[ -z $1 ]] && echo "Error: Expected an argument for the name of the app" && return 0

    npm create vite@latest $1 -- --template react-ts
    cd $1
    npm install tailwindcss @tailwindcss/vite
    sed -i "/import { defineConfig } from 'vite'/a\import tailwindcss from '@tailwindcss/vite'" vite.config.ts
    sed -i 's/plugins: \[react()\],/plugins: \[tailwindcss(), react()],/' vite.config.ts
    sed -i '1i @import "tailwindcss";\n' src/index.css
    sed -i 's/React/React + Tailwindcss/' src/App.tsx
}

function play() {
    [[ -z $1 ]] && echo "Please provide a video file or youtube link" && return 0
    tmux has-session -t play > /dev/null 2>&1 || tmux new-session -s play \; detach-client > /dev/null
    tmux attach-session -t play \; new-window \; send-keys "mpv --save-watch-history $1" C-m \; detach-client > /dev/null
}

function ytrss() {
    [[ -z $1 ]] && echo "Usage: ytrss YOUTUBE_CHANNEL_URL" && return 0
    curl -s ${1} | grep -oE "https://www\.youtube\.com/feeds/videos\.xml\?channel_id=\S{24}" | head -n 1 >> $HOME/.config/newsboat/urls
}

function news() {
    tmux has-session -t news && tmux attach -t news && return 0
    tmux new-session -d -s news 
    tmux send-keys -t news "newsboat" Enter
    tmux attach -t news
}

function contentcheck() {
    FAILED=0
    for file in $(git diff --name-only --diff-filter ACMRT HEAD~1 HEAD -- '*.go'); do
        if [[ $(gopls check ${file}) != "" ]]; then
            FAILED=1
            gopls check ${file}
        fi
    done
    return ${FAILED}
}

function formatdiff() {
    FAILED=0
    for file in $(git diff --name-only --diff-filter ACMRT HEAD~1 HEAD -- '*.go'); do
        if [[ $(gofmt -l ${file}) == ${file} ]]; then
            FAILED=1 
            gofmt -d ${file}
        fi
    done
    return ${FAILED}
}

function gerrit() {
    if [[ "$1" == "add" ]]; then
        [[ -z $2 ]] && echo "Usage: gerrit add PROJECT" && return 1
        git remote add gerrit ssh://${USER}@gerrit.gmicloud.online:29418/${2}
    elif [[ "$1" == "push" ]]; then
        echo "Checking format diff before push.."
        if ! formatdiff; then
            echo "Format diff failed" && return 1
        fi
        echo "Format diff passed!"
        echo "Running content check before push.."
        if ! contentcheck; then
            echo "Content check failed" && return 1
        fi
        echo "Content check passed!"
        git push gerrit 'HEAD:refs/for/master'
    elif [[ "$1" == "pull" ]]; then
        [[ -z $2 ]] && git pull gerrit master && return 0
        git pull gerrit $2
    elif [[ "$1" == "submodule" ]] && [[ "$2" == "hook" ]]; then
        [[ -z $3 ]] || [[ -z $4 ]] && echo "Usage: gerrit submodule hook PARENT_DIR SUBMODULE" && return 1
        hooks_dir=${3}/.git/modules/${4}/hooks
        curl -Lo ${hooks_dir}/commit-msg http://gerrit.gmicloud.online/tools/hooks/commit-msg
        chmod +x ${hooks_dir}/commit-msg
    else
        echo "Usage: gerrit (add|push|pull|submodule hook) [ARGS...]"
        return 1
    fi
}

# enable syntax highlighting (should be near bottom)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# enhance vi mode (should be after zsh-syntax-highlighting)
source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh
