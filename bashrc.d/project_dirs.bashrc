# Override project development directory for AEGshr share if not already set
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
