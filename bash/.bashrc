# Don't do anything unless we are in a tty

if ! [[ -t 1 ]]; then
    return
fi

# History

shopt -s histappend
export HISTCONTROL=ignoreboth:erasedups

# Path
export PATH=$PATH:$HOME/.local/bin

# Aliases

if command -v nvim >/dev/null 2>&1; then
    alias vi=nvim
fi

if ls --color=auto >/dev/null; then
    alias ls='ls --color=auto -p'
fi

if grep --color=auto 'test' <<<'test' >/dev/null 2>&1; then
    alias grep='grep --color=auto'
fi

if command -v mpv >/dev/null 2>&1; then
    alias mpv='mpv --save-position-on-quit=yes'
fi

# Prompt

if [[ -f /usr/share/git/git-prompt.sh ]]; then
    . /usr/share/git/git-prompt.sh
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWUNTRACKEDFILES=1
fi

update_prompt() {
    if declare -F __git_ps1 >/dev/null; then
        PS1="\[\e[34m\]\h \[\e[33m\]\w \[\e[31m\]$(__git_ps1 '(%s) ')\[\e[32m\]\$ \[\e[0m\]"
    else
        PS1="\[\e[34m\]\h \[\e[33m\]\w \[\e[32m\]\$ \[\e[0m\]"
    fi
}

if ! [[ $PROMPT_COMMAND =~ update_prompt$ ]]; then
    PROMPT_COMMAND="${PROMPT_COMMAND:-:}; update_prompt"
fi

fastfetch
