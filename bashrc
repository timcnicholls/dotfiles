echo "In bashrc"

if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

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
        ;;
    linux-gnu)
        AEG_SW_DIR=/aeg_sw
        POWERLINE_NEED_PATH=${AEG_SW_DIR}
        POWERLINE_PATH=${HOME}/.local/bin
        POWERLINE_PACKAGE_PATH=${HOME}/.local/lib/python2.7/site-packages/powerline
        PROJ_DEV_DIR=${HOME}/develop/projects
        ;;
    *)
        echo "Unknown OS type"
esac

if [ ! -z ${AEG_SW_DIR} ] && [ -d ${AEG_SW_DIR} ]; then
    echo AEG_SW_DIR is valid
    export AEG_SW_DIR
    export AEG_USER_DIR=/aeg_sw/work/users/${USER}
    export AEG_PROJ_DEV_DIR=${AEG_USER_DIR}/develop/projects
    [ -d ${AEG_PROJ_DEV_DIR} ] && PROJ_DEV_DIR=${AEG_PROJ_DEV_DIR}
fi

export PROJ_DEV_DIR

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

GOPATH=$HOME/Develop/tools/go
if [ -d $GOPATH ]; then
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
export SHORT_HOST=`/bin/hostname -s`

#Full and Long process lists, default user
psf ()
{
    ps -f -u ${1:-$USER}
}

psl ()
{
    ps -l -u ${1:-$USER}
}

lw()
{
    less `which $*`
}

# Web Proxy config
export ral_http_proxy="http://wwwcache.rl.ac.uk:8080"
export ral_https_proxy="https://wwwcache.rl.ac.uk:8080"
export no_proxy="localhost,rl.ac.uk"

proxy()
{
    cmd=${1:-check}
    quiet=${2:-}
    case ${1:-check} in
    on)
        if [ -z "$quiet" ]; then echo "Enabling HTTP(S) proxy at URL $ral_proxy_url"; fi
        export http_proxy_url=$ral_http_proxy
        export https_proxy_url=$ral_https_proxy
        export http_proxy=$ral_http_proxy
        export https_proxy=$ral_https_proxy
        ;;
    off)
        if [ -z "$quiet" ]; then echo "Disabling HTTP(S) proxy"; fi
        unset http_proxy
        unset https_proxy
        unset http_proxy_url
        unset https_proxy_url
        ;;
    check)
        if [ -n "$http_proxy" ]; then
            echo "HTTP(S) proxy is enabled: $http_proxy"
        else
            echo "HTTP(S) proxy is disabled"
        fi
        ;;
    *)
        echo "Unknown command specified: $1"
        ;;
    esac
}

proxy off quiet

# Docker environment setup
DOCKER_MACHINE_DEFAULT="default"

docker-env()
{
    eval "$(docker-machine env ${1:-$DOCKER_MACHINE_DEFAULT})"
    docker_machine_ip="$(docker-machine ip $DOCKER_MACHINE_NAME)"
    if ! [[ "$no_proxy" =~ (^|,)"${docker_machine_ip}"(,|$) ]]; then
        no_proxy=${no_proxy},${docker_machine_ip}
        export no_proxy
    fi
    echo "Set up docker environment for machine \"$DOCKER_MACHINE_NAME\" with IP address ${docker_machine_ip}"
}


# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

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

workon()
{
    venvwrapper && workon ${*}
}

# Source AEG module profile if present
AEG_MODULE_PROFILE=${AEG_SW_DIR}/etc/profile
[ -f ${AEG_MODULE_PROFILE} ] && source ${AEG_MODULE_PROFILE}

# If AEG directory present, set up various
if [ ! -z ${AEG_SW_DIR} ] && [ -d ${AEG_SW_DIR} ]; then
   alias code='module load git && module load cmake && module load python/2 && /usr/bin/code'
   
   export AEG_USER_DIR=/aeg_sw/work/users/${USER}
fi

_project()
{
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"
    proj_dirs=$(compgen -d ${PROJ_DEV_DIR}/ | awk -F/ '{print $NF}')
    COMPREPLY=($(compgen -W "${proj_dirs}" -- ${cur}))
    return 0
}

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

complete -o nospace -F _project project

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
