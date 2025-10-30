# ZTop - Terminal System Monitor v1.6

All-in-one terminal system monitor with 5 panes: CPU, memory, Mac metrics, containers, and network traffic.

<img width="2106" height="1356" alt="image" src="https://github.com/user-attachments/assets/101fa69d-f266-4f77-9398-60a55bfb5138" />

## Installation

### Automated Installation (Recommended!)

Run this single command to install ztop automatically:

```bash
curl -fsSL https://raw.githubusercontent.com/renato-umeton/ztop/main/install.sh | bash
```

Or clone and run locally:

```bash
git clone https://github.com/renato-umeton/ztop.git /tmp/ztop && bash /tmp/ztop/install.sh
```

**The installer automatically:**
- ✓ Checks for Oh My Zsh installation
- ✓ Clones the plugin to the correct directory
- ✓ Updates your `~/.zshrc` with the ztop plugin
- ✓ Checks and offers to install missing dependencies
- ✓ Provides helpful status messages throughout
- ✓ Creates a backup of your `.zshrc` before modifications

After installation, the plugin automatically:
- Configures passwordless sudo (no prompts!)
- Sets up all aliases: `ztop`, `zz`, and helpers
- Detects binary paths and validates configuration

Just type `ztop` or `zz` to launch!

### Manual Installation

If you prefer to install manually:

```bash
# 1. Clone into Oh My Zsh plugins
git clone https://github.com/renato-umeton/ztop.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ztop

# 2. Add to ~/.zshrc plugins array
plugins=(... ztop)

# 3. Reload shell - automatic sudoers configuration happens here!
source ~/.zshrc
```

## Key Features

- **5-pane layout**: htop (CPU), htop (memory), mactop, ctop, nethogs
- **Instant warm start**: Press `q` to detach (keeps running), reattach instantly
- **Parallel loading**: All tools launch simultaneously
- **Full sudo support**: Complete system visibility without password prompts
- **Clean interface**: Auto-hides htop graph meters

## Usage

- `ztop` / `zz` - Launch ztop
- `ztop-update` / `zz-update` - Update to latest version
- `ztop-test` / `zz-test` - Run test suite
- `ztop-kill` / `zz-kill` - Kill the session
- `q` - Detach (tools keep running)
- `k` - Kill session (stop all tools)

## Requirements

- **macOS** with Homebrew
- **Oh My Zsh** installed
- **Dependencies**: `brew install tmux htop mactop ctop nethogs`

All configuration is automatic - the plugin handles everything!
