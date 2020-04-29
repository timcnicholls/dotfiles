# Source system bashrc if present
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Source user non-bash profile if present
if [ -f ~/.profile ]; then
   . ~/.profile
fi

# Set up OS-dependent variables
case ${OSTYPE} in
    darwin*)
        POWERLINE_NEED_PATH=/usr/local/opt
        POWERLINE_PATH=${HOME}/Library/Python/2.7/bin
        POWERLINE_PACKAGE_PATH=${HOME}/Library/Python/2.7/lib/python/site-packages/powerline
        HAS_BREW=1
        PROJ_DEV_DIR=${HOME}/Develop/projects
        GOPATH=$HOME/Develop/tools/go
        ;;
    linux-gnu)
        LOCAL_DIR=.local
        if [ -x /usr/bin/lsb_release ]; then
           dist_release=$(/usr/bin/lsb_release -rs)
           if [[ $dist_release =~ ^6 ]]; then
             LOCAL_DIR=.local-el6-2.7
           fi
        fi
        AEG_SW_DIR=/aeg_sw
        POWERLINE_NEED_PATH=${AEG_SW_DIR}
        POWERLINE_PATH=${HOME}/${LOCAL_DIR}/bin
        POWERLINE_PACKAGE_PATH=${HOME}/${LOCAL_DIR}/lib/python2.7/site-packages/powerline
        PROJ_DEV_DIR=${HOME}/develop/projects
        ;;
    *)
        echo "Unknown OS type"
esac

# On AEG dev hosts mounting /aeg_sw, set up environment accordingly and override PROJ_DEV_DIR
if [ ! -z ${AEG_SW_DIR} ] && [ -d ${AEG_SW_DIR} ]; then
    export AEG_SW_DIR
    export AEG_USER_DIR=${AEG_SW_DIR}/work/users/${USER}
    export AEG_PROJ_DEV_DIR=${AEG_USER_DIR}/develop/projects
    [ -d ${AEG_PROJ_DEV_DIR} ] && PROJ_DEV_DIR=${AEG_PROJ_DEV_DIR}

    # Source AEG module profile if present
    AEG_MODULE_PROFILE=${AEG_SW_DIR}/etc/profile
    [ -f ${AEG_MODULE_PROFILE} ] && source ${AEG_MODULE_PROFILE}

    # Alias VSCode command line to preload recent git, cmake & python
    alias code='module load git && module load cmake && module load python/2 && /usr/bin/code'

fi
export PROJ_DEV_DIR

# Internal function to support project name completions
_project()
{
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"
    proj_dirs=$(compgen -d ${PROJ_DEV_DIR}/ | awk -F/ '{print $NF}')
    COMPREPLY=($(compgen -W "${proj_dirs}" -- ${cur}))
    return 0
}

# Function to switch to project development directory
project()
{
    PROJ_DIR=${PROJ_DEV_DIR}/$1
    if [ -d "${PROJ_DIR}" ]; then
        echo "Changing to project directory ${PROJ_DIR}"
        cd $PROJ_DIR
    else
        echo "No such project directory: $PROJ_DIR"
    fi
}

# Add completion control to project function 
complete -o nospace -F _project project

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

# Manage paths - only add if not already present
pathadd $HOME/bin
pathadd /usr/local/bin

# Set up GOPATH if present on system
if [ -z ${GOPATH} ] && [ -d ${GOPATH} ]; then
    export GOPATH
    pathadd $GOPATH after
fi

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

# Options
set -o noclobber
set bell-style off

export VISUAL="emacs -nw"

#Full and Long process lists, default user
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

# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

# Function to ease setting up virtualenvrwapper environments
venvwrapper()
{
  venvwrap_script="virtualenvwrapper.sh"
  if command -v ${venvwrap_script} >/dev/null 2>&1; then
    export WORKON_HOME=$HOME/.virtualenvs
    if [ ! -d $WORKON_HOME ]; then
       mkdir $WORKON_HOME
    fi
    source $(command -v ${venvwrap_script})
  else
    echo "Cannot locate ${venvwrap_script}"
    return 1
  fi
}

# Lazy loading of virtualenv wrapper for the workon function
workon()
{
    venvwrapper && workon ${*}
}

# Set up brew completions if brew installed
if [ -n "$HAS_BREW" ]; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi

# Set up powerline if the appropriate path is present
if [ -d $POWERLINE_NEED_PATH ]; then
    export PATH=$PATH:$POWERLINE_PATH
    export POWERLINE_PACKAGE_PATH
    powerline-daemon -q
    export POWERLINE_ENABLED=1
fi
if [ ${POWERLINE_ENABLED:-0} -eq 1 ]; then
    export POWERLINE_BASH_CONTINUATION=1
    export POWERLINE_BASH_SELECT=1
    source ${POWERLINE_PACKAGE_PATH}/bindings/bash/powerline.sh
fi
