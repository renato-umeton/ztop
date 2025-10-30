# ZTop Oh My Zsh Plugin
# Provides easy access to ztop via 'ztop' and 'zz' aliases

# Plugin directory (where this file is located)
ZTOP_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/ztop"

# Check and configure sudoers automatically
_ztop_check_sudoers() {
    # Check if sudoers already configured
    if sudo grep -q "NOPASSWD.*htop.*mactop.*nethogs" /etc/sudoers /etc/sudoers.d/* 2>/dev/null; then
        echo "✓ Sudoers already configured for ztop"
        return 0
    fi

    echo ""
    echo "🔧 Configuring passwordless sudo for htop, mactop, and nethogs..."

    # Find actual paths to binaries
    local htop_path=$(which htop 2>/dev/null || echo "/opt/homebrew/bin/htop")
    local mactop_path=$(which mactop 2>/dev/null || echo "/opt/homebrew/bin/mactop")
    local nethogs_path=$(which nethogs 2>/dev/null || echo "/opt/homebrew/bin/nethogs")

    local sudoers_line="%admin ALL=(ALL) NOPASSWD: $htop_path, $mactop_path, $nethogs_path"

    echo "   Adding to /etc/sudoers: $sudoers_line"

    # Use a temp file for validation
    local temp_sudoers=$(mktemp)
    sudo cat /etc/sudoers > "$temp_sudoers" 2>/dev/null
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
    echo ""
}

# Check if ztop.sh exists and offer to configure sudoers on first run
if [[ -f "$ZTOP_DIR/ztop.sh" && ! -f "$ZTOP_DIR/.ztop_configured" ]]; then
    chmod +x "$ZTOP_DIR/ztop.sh"

    # Check and configure sudoers
    _ztop_check_sudoers

    # Mark as configured
    touch "$ZTOP_DIR/.ztop_configured"

    echo ""
    echo "✓ ZTop plugin loaded! Use 'ztop' or 'zz' to launch"
    echo ""
fi

# Create aliases for ztop
if [[ -f "$ZTOP_DIR/ztop.sh" ]]; then
    # Main aliases - both ztop and zz work
    alias ztop="$ZTOP_DIR/ztop.sh"
    alias zz="$ZTOP_DIR/ztop.sh"

    # Additional helpful aliases (both ztop-* and zz-* variants)
    alias ztop-update="cd $ZTOP_DIR && git pull && cd -"
    alias ztop-test="$ZTOP_DIR/test_ztop.sh"
    alias ztop-kill="$ZTOP_DIR/ztop.sh --kill"
    alias ztop-help="$ZTOP_DIR/ztop.sh --help"

    # Short zz-* aliases
    alias zz-update="cd $ZTOP_DIR && git pull && cd -"
    alias zz-test="$ZTOP_DIR/test_ztop.sh"
    alias zz-kill="$ZTOP_DIR/ztop.sh --kill"
    alias zz-help="$ZTOP_DIR/ztop.sh --help"
fi
