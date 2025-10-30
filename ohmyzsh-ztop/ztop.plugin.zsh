# ZTop Oh My Zsh Plugin
# Installs and provides easy access to ztop via 'zz' alias

# Installation directory
ZTOP_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/ztop/bin"

# Check and configure sudoers
_ztop_check_sudoers() {
    # Check if sudoers already configured
    if sudo grep -q "NOPASSWD.*htop.*mactop.*nethogs" /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
        return 0
    fi

    echo ""
    echo "⚠️  ZTop requires passwordless sudo for htop, mactop, and nethogs"
    echo ""
    echo "Would you like to configure sudoers now? This will:"
    echo "  - Allow all admin users to run htop, mactop, nethogs without password"
    echo "  - Add one line to /etc/sudoers using 'sudo visudo'"
    echo ""
    read -q "REPLY?Configure sudoers? [y/N] "
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Find actual paths to binaries
        local htop_path=$(which htop 2>/dev/null || echo "/opt/homebrew/bin/htop")
        local mactop_path=$(which mactop 2>/dev/null || echo "/opt/homebrew/bin/mactop")
        local nethogs_path=$(which nethogs 2>/dev/null || echo "/opt/homebrew/bin/nethogs")

        local sudoers_line="%admin ALL=(ALL) NOPASSWD: $htop_path, $mactop_path, $nethogs_path"

        echo ""
        echo "Adding to sudoers:"
        echo "  $sudoers_line"
        echo ""

        # Use a temp file for validation
        local temp_sudoers=$(mktemp)
        sudo cat /etc/sudoers > "$temp_sudoers"
        echo "" >> "$temp_sudoers"
        echo "# ZTop monitoring tools - passwordless sudo" >> "$temp_sudoers"
        echo "$sudoers_line" >> "$temp_sudoers"

        # Validate the sudoers file
        if sudo visudo -c -f "$temp_sudoers" &>/dev/null; then
            # Validation passed, append to actual sudoers
            echo "# ZTop monitoring tools - passwordless sudo" | sudo tee -a /etc/sudoers >/dev/null
            echo "$sudoers_line" | sudo tee -a /etc/sudoers >/dev/null
            echo "✓ Sudoers configured successfully!"
        else
            echo "✗ Sudoers validation failed. Please configure manually:"
            echo "  sudo visudo"
            echo "  Add: $sudoers_line"
        fi
        rm -f "$temp_sudoers"
    else
        echo ""
        echo "⚠️  ZTop will prompt for password on each launch."
        echo "   To configure later, run: sudo visudo"
        echo "   Add this line:"
        echo "   %admin ALL=(ALL) NOPASSWD: /opt/homebrew/bin/htop, /opt/homebrew/bin/mactop, /opt/homebrew/bin/nethogs"
        echo ""
    fi
}

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
            echo ""

            # Check and configure sudoers
            _ztop_check_sudoers

            echo ""
            echo "Use 'zz' to launch ztop"
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
