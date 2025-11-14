# On AEG dev hosts mounting /aeg_sw, set up environment accordingly and override PROJ_DEV_DIR
if [ ! -z ${AEG_SW_DIR} ] && [ -d ${AEG_SW_DIR} ]; then
    export AEG_SW_DIR
    export AEG_USER_DIR=${AEG_SW_DIR}/work/users/${USER}
    export AEG_PROJ_DEV_DIR=${AEG_USER_DIR}/develop/projects
    [ -d ${AEG_PROJ_DEV_DIR} ] && PROJ_DEV_DIR=${AEG_PROJ_DEV_DIR}

    # Source AEG module profile if present
    AEG_MODULE_PROFILE=${AEG_SW_DIR}/etc/profile
    [ -f ${AEG_MODULE_PROFILE} ] && source ${AEG_MODULE_PROFILE}

    # Set XDG_CACHE_DIR to AEG user directory if present
    AEG_USER_CACHE_DIR=${AEG_USER_DIR}/.cache
    if [ -d ${AEG_USER_CACHE_DIR} ]; then
    	export XDG_CACHE_HOME=${AEG_USER_CACHE_DIR}
    fi

    # Set virtualenv WORKON_HOME to AEG user directory if present
    AEG_USER_WORKON_HOME=${AEG_USER_DIR}/virtualenvs
    if [ -d ${AEG_USER_WORKON_HOME} ]; then
	    WORKON_HOME=${AEG_USER_WORKON_HOME}
    fi

    # Set vscode user data and extensions dir to AEG user directory if present
    AEG_USER_VSCODE_DIR=${AEG_USER_DIR}/vscode_data
    if [ -d ${AEG_USER_VSCODE_DIR} ]; then
       export VSCODE_USER_DATA_DIR=${AEG_USER_VSCODE_DIR}/Code
       export VSCODE_EXTENSIONS_DIR=${AEG_USER_VSCODE_DIR}/extensions
    else
       export VSCODE_USER_DATA_DIR=${HOME}/.config/Code
       export VSCODE_EXTENSIONS_DIR=${HOME}/.vscode/extensions
    fi
       # Alias VSCode command line to preload recent git, cmake & python
    #alias code='module load git && module load cmake && module load python/2 && /usr/bin/code'
    if [ -n "$WRAP_CODE" ]; then
      code()
      {
          module load git
          module load cmake
          module load python/3-9
          /usr/bin/code --user-data-dir=${VSCODE_USER_DATA_DIR} --extensions-dir=${VSCODE_EXTENSIONS_DIR} $*
      }
    else
      code()
      {
          /usr/bin/code --user-data-dir=${VSCODE_USER_DATA_DIR} --extensions-dir=${VSCODE_EXTENSIONS_DIR} $*
      }
    fi

    # Set PlatformIO code directory to AEG user directory if present
    AEG_USER_PLATFORMIO_CORE_DIR=${AEG_USER_DIR}/platformio
    if [ -d ${AEG_USER_PLATFORMIO_CORE_DIR} ]; then
	    export PLATFORMIO_CORE_DIR=${AEG_USER_PLATFORMIO_CORE_DIR}
    fi
fi

