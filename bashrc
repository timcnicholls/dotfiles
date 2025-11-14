# Source system bashrc if present
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Source user non-bash profile if present
if [ -f ~/.profile ]; then
   . ~/.profile
fi

# Source OS-dependent bashrc if present
case ${OSTYPE} in
    darwin*)
        OS_BASHRC=${HOME}/.bashrc-darwin
        ;;
    linux-gnu*)
        OS_BASHRC=${HOME}/.bashrc-linux
        ;;
    *)
        OS_BASHRC="unknown"
        echo "Unknown OS type"
esac
if [ -f ${OS_BASHRC} ]; then
    . ${OS_BASHRC}
fi

# Source additional bashrc snippets if present
BASHRCD_DIR=${HOME}/.bashrc.d
if [ -d ${BASHRCD_DIR} ]; then
    for file in ${BASHRCD_DIR}/*.bashrc;
    do
        source "$file"
    done
fi
