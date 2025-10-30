#!/bin/bash
# ZTop Automated Installation Script
# This script automates the entire installation process for the ztop Oh My Zsh plugin

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_step() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║   ZTop Automated Installation Script    ║"
echo "╔══════════════════════════════════════════╝"
echo ""

# Step 1: Check if Oh My Zsh is installed
print_step "Step 1/5: Checking Oh My Zsh installation..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    print_error "Oh My Zsh is not installed!"
    echo ""
    print_info "Please install Oh My Zsh first:"
    echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
    echo ""
    exit 1
fi
print_success "Oh My Zsh is installed"
echo ""

# Step 2: Clone the repository
print_step "Step 2/5: Installing ztop plugin..."
PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/ztop"

if [[ -d "$PLUGIN_DIR" ]]; then
    print_warning "Plugin directory already exists at $PLUGIN_DIR"
    read -p "Do you want to update it? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Updating existing installation..."
        cd "$PLUGIN_DIR"
        git pull
        print_success "Plugin updated successfully"
    else
        print_info "Skipping clone step"
    fi
else
    print_info "Cloning repository into $PLUGIN_DIR"
    git clone https://github.com/renato-umeton/ztop.git "$PLUGIN_DIR"
    print_success "Plugin cloned successfully"
fi
echo ""

# Step 3: Update .zshrc
print_step "Step 3/5: Configuring ~/.zshrc..."
ZSHRC="$HOME/.zshrc"

if [[ ! -f "$ZSHRC" ]]; then
    print_error "~/.zshrc not found!"
    exit 1
fi

# Check if ztop is already in the plugins array
if grep -q "plugins=.*ztop" "$ZSHRC"; then
    print_success "ztop is already in your plugins list"
else
    # Backup .zshrc
    print_info "Creating backup: ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$ZSHRC" "$ZSHRC.backup.$(date +%Y%m%d_%H%M%S)"

    # Add ztop to plugins array
    print_info "Adding ztop to plugins array..."

    # Check if plugins array exists
    if grep -q "^plugins=(" "$ZSHRC"; then
        # plugins array exists, add ztop to it
        # Handle both single-line and multi-line plugins arrays
        if grep -q "^plugins=([^)]*)" "$ZSHRC"; then
            # Single-line plugins array
            sed -i.tmp 's/^plugins=(\([^)]*\))/plugins=(\1 ztop)/' "$ZSHRC"
            rm -f "$ZSHRC.tmp"
        else
            # Multi-line plugins array - add before the closing parenthesis
            sed -i.tmp '/^plugins=(/,/)/{/)/s/)/  ztop\n)/}' "$ZSHRC"
            rm -f "$ZSHRC.tmp"
        fi
        print_success "Added ztop to existing plugins array"
    else
        # No plugins array found, create one
        echo "" >> "$ZSHRC"
        echo "# ZTop plugin" >> "$ZSHRC"
        echo "plugins=(ztop)" >> "$ZSHRC"
        print_success "Created plugins array with ztop"
    fi
fi
echo ""

# Step 4: Install dependencies
print_step "Step 4/5: Checking dependencies..."
MISSING_DEPS=()

for cmd in tmux htop mactop ctop nethogs; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_DEPS+=($cmd)
    fi
done

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    print_warning "Missing dependencies: ${MISSING_DEPS[*]}"
    echo ""
    print_info "To install all dependencies, run:"
    echo "  brew install tmux htop mactop ctop nethogs"
    echo ""
    read -p "Do you want to install them now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installing dependencies with Homebrew..."
        brew install ${MISSING_DEPS[@]}
        print_success "Dependencies installed"
    else
        print_info "Skipping dependency installation"
        print_warning "Note: ztop requires all dependencies to function properly"
    fi
else
    print_success "All dependencies are installed"
fi
echo ""

# Step 5: Reload shell configuration
print_step "Step 5/5: Finalizing installation..."
print_info "Reloading shell configuration..."
echo ""

print_success "Installation complete!"
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║         Installation Successful!         ║"
echo "╚══════════════════════════════════════════╝"
echo ""
print_info "To activate ztop in this shell, run:"
echo "  source ~/.zshrc"
echo ""
print_info "Or open a new terminal window"
echo ""
print_info "Available commands:"
echo "  • ztop or zz          - Launch ztop"
echo "  • ztop-update         - Update to latest version"
echo "  • ztop-test           - Run test suite"
echo "  • ztop-kill           - Kill the session"
echo ""
print_info "Inside ztop:"
echo "  • Press 'q' to detach (keeps running in background)"
echo "  • Press 'k' to kill session (stops all tools)"
echo ""

# Ask if user wants to reload now
read -p "Would you like to reload your shell now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Reloading shell..."
    exec zsh -l
else
    print_info "Please run 'source ~/.zshrc' or open a new terminal to activate ztop"
fi
echo ""
