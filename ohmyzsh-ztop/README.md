# ZTop Oh My Zsh Plugin

An Oh My Zsh plugin that installs [ztop](https://github.com/renato-umeton/ztop) and provides convenient aliases.

## Installation

### Using Oh My Zsh

1. Clone this repository into your Oh My Zsh custom plugins directory:

```bash
git clone https://github.com/renato-umeton/ztop.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ztop
```

2. Add `ztop` to your plugins array in `~/.zshrc`:

```bash
plugins=(... ztop)
```

3. Reload your shell:

```bash
source ~/.zshrc
```

The plugin will automatically clone the ztop repository and set up aliases on first load.

## Prerequisites

Make sure you have the required dependencies installed:

```bash
brew install tmux htop mactop ctop nethogs
```

**Configure passwordless sudo** (required for full functionality):

```bash
sudo visudo
# Add this line:
%admin ALL=(ALL) NOPASSWD: /opt/homebrew/bin/htop, /opt/homebrew/bin/mactop, /opt/homebrew/bin/nethogs
```

## Aliases

- `zz` - Launch ztop (or reattach to existing session)
- `zz-update` - Update ztop to the latest version
- `zz-test` - Run ztop test suite
- `zz-kill` - Kill the ztop session
- `zz-help` - Show ztop help

## Usage

Simply type `zz` in your terminal to launch ztop:

```bash
zz
```

Press `q` to detach (keeps running in background), or `k` to kill the session.

## What is ZTop?

ZTop is an all-in-one terminal system monitor that displays CPU, memory, Mac metrics, containers, and network traffic in a 5-pane tmux layout with instant warm start capabilities.

For more information, visit: https://github.com/renato-umeton/ztop
