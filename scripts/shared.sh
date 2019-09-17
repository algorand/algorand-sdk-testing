# Shared functions

# ensure correct nodejs version (>=10) if running on travis
function ensure_nodejs_version {
    NODE_REQUIRED_VERSION="10"  # min version supporting for await expr
    NODE_CURRENT_VERSION=$(node --version | cut -c 2-)
    if [ ! "$(printf '%s\n' "$NODE_CURRENT_VERSION" "$NODE_REQUIRED_VERSION" | sort -V | head -n1)" = "$NODE_REQUIRED_VERSION" ]
    then
        if [ -n "$TRAVIS_BUILD_DIR" ] && [ -s "$NVM_DIR/nvm.sh" ]
        then
            . "$NVM_DIR/nvm.sh"
            nvm use stable
        else
            echo "Switching nodejs from $NODE_CURRENT_VERSION required but not performed"
        fi
    fi
}
