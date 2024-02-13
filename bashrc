# Source system bashrc if present
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Source user non-bash profile if present
if [ -f ~/.profile ]; then
   . ~/.profile
fi

if command -v pyenv 1>/dev/null 2>&1; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# Set up OS-dependent variables
case ${OSTYPE} in
    darwin*)
        LOCAL_DIR=${HOME}/.local
        PROJ_DEV_DIR=${HOME}/Develop/projects
        GOPATH=$HOME/Develop/tools/go
        HAS_BREW=1
        ;;
    linux-gnu)

        AEG_SW_DIR=/aeg_sw
        LOCAL_DIR=${HOME}/.local
        PROJ_DEV_DIR=${HOME}/develop/projects

        # Override .local setting in LOCAL_DIR for specific distros/versions
        if [ -x /usr/bin/lsb_release ]; then
           dist_name=$(/usr/bin/lsb_release -is)
           dist_release=$(/usr/bin/lsb_release -rs)
           case ${dist_name} in
              CentOS*)
                if [[ $dist_release =~ ^6 ]]; then
                    LOCAL_DIR=${HOME}/.local-el6-2.7
                fi
		WRAP_CODE=1
                ;;
              Ubuntu*)
		if [[ $dist_release =~ ^22 ]]; then
		   LOCAL_DIR=${HOME}/.local-ubuntu-22
		else
		   LOCAL_DIR=${HOME}/.local-ubuntu
		fi
                ;;
           esac
        fi

        export PYTHONUSERBASE=${LOCAL_DIR}
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
    #alias code='module load git && module load cmake && module load python/2 && /usr/bin/code'
    if [ -n "$WRAP_CODE" ]; then
      code()
      {
          module load git
          module load cmake
          module load python/3-9
          /usr/bin/code $*
      }
    fi
fi

if [ ! -d ${PROJ_DEV_DIR} ]; then
    AEGSHR_USER_DIR=/groups/AEGshr/work/users/${USER}
    AEGSHR_PROJ_DEV_DIR=${AEGSHR_USER_DIR}/develop/projects
    [ -d ${AEGSHR_PROJ_DEV_DIR} ] && PROJ_DEV_DIR=${AEGSHR_PROJ_DEV_DIR}
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
alias reset_cursor='echo -en "\e[?25h"'

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

mkcd()
{
    mkdir -p "$1" && cd "$1"
}

# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

# Set up brew completions if brew installed
if [ -n "$HAS_BREW" ]; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi

# Set up powerline if the appropriate path is present
POWERLINE_PATH=${LOCAL_DIR}/bin
if [ -d $POWERLINE_PATH ]; then
    PYTHON_USER_SITE=$(python -m site --user-site)
    POWERLINE_PACKAGE_PATH=${PYTHON_USER_SITE}/powerline
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

# If pyenv is installed, bootstrap virtualenv based on that, otherwise
# use the canonical virtualenvwrapper mechanism. In either case, define
# a workon function that lazily sets up the correct environment before
# getting replaced by virtualenvwrapper
if command -v pyenv 1>/dev/null 2>&1; then
    workon()
    {
        pyenv virtualenvwrapper && workon ${*}
    }
else
    venvwrapper()
    {
        venvwrap_script="virtualenvwrapper.sh"
        if command -v ${venvwrap_script} >/dev/null 2>&1; then
            WORKON_HOME=$HOME/.virtualenvs
            HOST_WORKON_HOME=${WORKON_HOME}-$(hostname -s)
            if [ -d $HOST_WORKON_HOME ]; then
                WORKON_HOME=$HOST_WORKON_HOME
            fi
            export WORKON_HOME
            if [ ! -d $WORKON_HOME ]; then
                mkdir $WORKON_HOME
            fi
            source $(command -v ${venvwrap_script})
        else
            echo "Cannot locate ${venvwrap_script}"
            return 1
        fi
    }

    workon()
    {
        venvwrapper && workon ${*}
    }
fi
