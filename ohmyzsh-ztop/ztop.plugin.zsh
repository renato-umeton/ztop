# ZTop Oh My Zsh Plugin
# Installs and provides easy access to ztop via 'zz' alias

# Installation directory
ZTOP_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/ztop/bin"

# Install ztop if not already installed
if [[ ! -d "$ZTOP_DIR" ]]; then
    echo "Installing ztop..."
    mkdir -p "$ZTOP_DIR"

    # Clone the repository
    if command -v git &> /dev/null; then
        git clone https://github.com/renato-umeton/ztop.git "$ZTOP_DIR" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            chmod +x "$ZTOP_DIR/ztop.sh"
            echo "✓ ztop installed successfully!"
            echo "  Use 'zz' to launch ztop"
        else
            echo "✗ Failed to clone ztop repository"
        fi
    else
        echo "✗ git is required to install ztop"
    fi
fi

# Create alias for ztop
if [[ -f "$ZTOP_DIR/ztop.sh" ]]; then
    alias zz="$ZTOP_DIR/ztop.sh"

    # Additional helpful aliases
    alias zz-update="cd $ZTOP_DIR && git pull && cd -"
    alias zz-test="$ZTOP_DIR/test_ztop.sh"
    alias zz-kill="$ZTOP_DIR/ztop.sh --kill"
    alias zz-help="$ZTOP_DIR/ztop.sh --help"
fi
