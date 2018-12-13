# Set up OS-dependent variables
case ${OSTYPE} in
    darwin*)
        POWERLINE_NEED_PATH=/usr/local/opt
        POWERLINE_PATH=${HOME}/Library/Python/2.7/bin
        POWERLINE_PACKAGE_PATH=${HOME}/Library/Python/2.7/lib/python/site-packages/powerline
        HAS_BREW=1
        ;;
    linux-gnu)
        POWERLINE_NEED_PATH=/aeg_sw
        POWERLINE_PATH=${HOME}/.local/bin
        POWERLINE_PACKAGE_PATH=${HOME}/.local/lib/python2.7/site-packages/powerline
        ;;
    *)
        echo "Unknown OS type"
esac

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

