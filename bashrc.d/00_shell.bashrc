# Shell prompts, including changing terminal window titles
case ${TERM} in
  xterm*)
    export PS_PREFIX="\[\033]0;\u@\h: \w\007\]"
    ;;
  *)
    export PS_PREFIX=""
    ;;
esac
export PS1_LONG="${PS_PREFIX}[\[\e[1m\]\h\[\e[0m\]] \w \$ "
export PS1_SHORT="${PS_PREFIX}[\[\e[1m\]\h\[\e[0m\]] \W \$ "
export PS1=$PS1_LONG
export PS2='+> '
alias ps1='export PS1=$PS1_LONG'
alias ps1s='export PS1=$PS1_SHORT'
export SHORT_HOST=$(hostname -s)
export PROMPT_COMMAND='echo -ne "\033]0;${USER}@${SHORT_HOST}: $(dirs +0)\007"'

# Aliases
alias m='less -M'
alias more='less -M'
alias less='less -M'
alias la='ls -a'
alias ll='ls -al'
alias ldir='ls -dF *(/)'
alias lldir='ls -dlF *(/)'
alias vi='vim'
alias pph='export PYTHONPATH=`pwd`:${PYTHONPATH}'
alias reset_cursor='echo -en "\e[?25h"'

# Options
set -o noclobber
set bell-style off

# Command functions

# Function to add paths
pathadd()
{
    path=${1:-/usr/bin}
    posn=${2:-before}
    if [ -d $path ]; then
        if  [[ ":$PATH:" != *":$path:"* ]]; then
            if [ $posn == 'after' ]; then
                export PATH=$PATH:$path
            else
                export PATH=$path:$PATH
            fi
        fi
    fi
}

# Full and Long process lists, default user
psf ()
{
    ps -f -u ${1:-$USER}
}

psl ()
{
    ps -l -u ${1:-$USER}
}

# Shorthand to less on something on the path
lw()
{
    less $(which $*)
}

# Make directory and change into it
mkcd()
{
    mkdir -p "$1" && cd "$1"
}

# Miscellaneous settings for shell
pathadd $HOME/bin
pathadd /usr/local/bin

export VISUAL="emacs -nw"
