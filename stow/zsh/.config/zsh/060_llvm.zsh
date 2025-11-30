# LLVM Configuration
# LLVM compiler infrastructure

# Portable path detection for Apple Silicon and Intel Macs
if [[ -d "/opt/homebrew/opt/llvm" ]]; then
    # Apple Silicon
    LLVM_PREFIX="/opt/homebrew/opt/llvm"
elif [[ -d "/usr/local/opt/llvm" ]]; then
    # Intel Mac
    LLVM_PREFIX="/usr/local/opt/llvm"
fi

if [[ -n "${LLVM_PREFIX}" ]]; then
    export LDFLAGS="-L${LLVM_PREFIX}/lib"
    export CPPFLAGS="-I${LLVM_PREFIX}/include"
    export CXXFLAGS="-I${LLVM_PREFIX}/include"
    export CFLAGS="-I${LLVM_PREFIX}/include"
    export PATH="${LLVM_PREFIX}/bin:$PATH"
fi
