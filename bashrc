if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

if [ -f ~/.profile ]; then
   . ~/.profile
fi

if [ -f /aeg_sw/etc/profile ]; then
   . /aeg_sw/etc/profile
fi

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

#if [ -f $(which virtualenvwrapper.sh 2>/dev/null) ]; then
#   echo "Yup"
#   export WORKON_HOME=$HOME/.virtualenvs
#   if [ ! -d $WORKON_HOME ]; then
#       mkdir $WORKON_HOME
#   fi
#   #source $(which virtualenvwrapper.sh)
#i

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
  fi
}

# Source AEG module profile if present
AEG_MODULE_PROFILE=/aeg_sw/etc/profile
[ -f ${AEG_MODULE_PROFILE} ] && source ${AEG_MODULE_PROFILE}

