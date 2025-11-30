# ImageMagick Configuration
# Image manipulation tools

if command -v brew &> /dev/null; then
    export DYLD_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_LIBRARY_PATH"
fi
