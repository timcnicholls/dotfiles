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
