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

if [ -d ${AEG_SW_DIR} ]; then
    export AEG_USER_DIR=/aeg_sw/work/users/${USER}
    export AEG_PROJ_DEV_DIR=${AEG_USER_DIR}/develop/projects
    [ -d ${AEG_PROJ_DEV_DIR} ] && PROJ_DEV_DIR=${AEG_PROJ_DEV_DIR}
fi

export AEG_SW_DIR
export PROJ_DEV_DIR

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

# Set up powerline if the appropriate path is present
if [ -d $POWERLINE_NEED_PATH ]; then
    export PATH=$PATH:$POWERLINE_PATH
    export POWERLINE_PACKAGE_PATH
    powerline-daemon -q
    export POWERLINE_ENABLED=1
fi

# Set up brew completions if brew installed
if [ -n "$HAS_BREW" ]; then
    if [ -f $(brew --prefix)/etc/bash_completion ]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi

# Source bashrc for everything else
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

