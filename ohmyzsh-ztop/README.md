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

The plugin will automatically:
- Clone the ztop repository
- Set up aliases
- Offer to configure passwordless sudo for you

## Prerequisites

Make sure you have the required dependencies installed:

```bash
brew install tmux htop mactop ctop nethogs
```

## Automatic Sudoers Configuration

On first load, the plugin will ask if you want to configure passwordless sudo. If you accept:
- It will automatically detect the paths to htop, mactop, and nethogs
- Validate the sudoers configuration before applying
- Add one line to /etc/sudoers safely

If you prefer to configure manually:

```bash
sudo visudo
# Add this line:
%admin ALL=(ALL) NOPASSWD: /opt/homebrew/bin/htop, /opt/homebrew/bin/mactop, /opt/homebrew/bin/nethogs
```

## Aliases

### Main Aliases (both work!)

- `ztop` - Launch ztop (or reattach to existing session)
- `zz` - Same as ztop (shorter alias)

### Helper Aliases (both variants available)

- `ztop-update` / `zz-update` - Update ztop to the latest version
- `ztop-test` / `zz-test` - Run ztop test suite
- `ztop-kill` / `zz-kill` - Kill the ztop session
- `ztop-help` / `zz-help` - Show ztop help

Use whichever naming style you prefer!

## Usage

Simply type `ztop` or `zz` in your terminal to launch ztop:

```bash
ztop  # or
zz    # shorter version
```

Press `q` to detach (keeps running in background), or `k` to kill the session.

## What is ZTop?

ZTop is an all-in-one terminal system monitor that displays CPU, memory, Mac metrics, containers, and network traffic in a 5-pane tmux layout with instant warm start capabilities.

For more information, visit: https://github.com/renato-umeton/ztop
