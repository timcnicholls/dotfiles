# Set up GOPATH if present on system
if [ -z ${GOPATH} ] && [ -d ${GOPATH} ]; then
    export GOPATH
    pathadd $GOPATH after
fi
