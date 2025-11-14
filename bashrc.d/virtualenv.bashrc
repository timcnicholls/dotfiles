# Resolve virtualenv location for workon command, overriding if a
# host-specific directory is present
HOST_WORKON_HOME=${WORKON_HOME}-$(hostname -s)
if [ -d $HOST_WORKON_HOME ]; then
    WORKON_HOME=$HOST_WORKON_HOME
fi
export WORKON_HOME

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
