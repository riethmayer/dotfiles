# Go Configuration
# Go programming language

if command -v go &> /dev/null; then
    export GOPATH="$(go env GOPATH)"
    # Unset GOBIN so go install uses $GOPATH/bin consistently
    unset GOBIN
    export PATH="${PATH}:${GOPATH}/bin"
fi
