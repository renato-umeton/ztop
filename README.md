# ZTop - Terminal System Monitor v1.3

All-in-one terminal system monitor with 5 panes: CPU, memory, Mac metrics, containers, and network traffic.

<img width="2106" height="1356" alt="image" src="https://github.com/user-attachments/assets/101fa69d-f266-4f77-9398-60a55bfb5138" />

## Quick Start

### Option 1: Oh My Zsh Plugin (Recommended)

```bash
# Clone into Oh My Zsh plugins
git clone https://github.com/renato-umeton/ztop.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ztop

# Add to ~/.zshrc plugins array
plugins=(... ztop)

# Reload shell
source ~/.zshrc

# Use the 'zz' alias
zz
```

See [ohmyzsh-ztop/README.md](ohmyzsh-ztop/README.md) for details.

### Option 2: Manual Installation

```bash
# Install dependencies
brew install tmux htop mactop ctop nethogs

# Configure passwordless sudo (required)
sudo visudo
# Add this line:
%admin ALL=(ALL) NOPASSWD: /opt/homebrew/bin/htop, /opt/homebrew/bin/mactop, /opt/homebrew/bin/nethogs

# Run
./ztop.sh
```

## Key Features

- **5-pane layout**: htop (CPU), htop (memory), mactop, ctop, nethogs
- **Instant warm start**: Press `q` to detach (keeps running), reattach instantly
- **Parallel loading**: All tools launch simultaneously
- **Full sudo support**: Complete system visibility without password prompts
- **Clean interface**: Auto-hides htop graph meters

## Usage

- `q` - Detach (tools keep running)
- `k` - Kill session (stop all tools)
- `./ztop.sh` - Run or reattach to existing session
- `./ztop.sh --help` - Show all options

## Requirements

- macOS with Homebrew
- Bash 3.x+
- tmux, htop, mactop, ctop, nethogs

Run `./test_ztop.sh` to verify installation (22 tests).
