# ZTop - Terminal System Monitor v1.5

All-in-one terminal system monitor with 5 panes: CPU, memory, Mac metrics, containers, and network traffic.

<img width="2106" height="1356" alt="image" src="https://github.com/user-attachments/assets/101fa69d-f266-4f77-9398-60a55bfb5138" />

## Installation

### Option 1: Homebrew (Recommended)

```bash
brew tap renato-umeton/ztop
brew install ztop
```

Then configure passwordless sudo:
```bash
sudo visudo
# Add this line:
%admin ALL=(ALL) NOPASSWD: /opt/homebrew/bin/htop, /opt/homebrew/bin/mactop, /opt/homebrew/bin/nethogs
```

Launch with `ztop` or `zz`!

### Option 2: Oh My Zsh Plugin (Fully Automatic!)

```bash
# 1. Clone into Oh My Zsh plugins
git clone https://github.com/renato-umeton/ztop.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ztop

# 2. Add to ~/.zshrc plugins array
plugins=(... ztop)

# 3. Reload shell - automatic sudoers configuration happens here!
source ~/.zshrc
```

**That's it!** The plugin automatically:
- Configures passwordless sudo (no prompts!)
- Sets up all aliases: `ztop`, `zz`, and helpers
- Detects binary paths
- Validates configuration before applying

Just type `ztop` or `zz` to launch!

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
