# ZTop - Terminal System Monitor v1.2
 
**Requirements:** `brew install tmux htop mactop ctop nethogs`

**Quick Start:** `./ztop.sh`

<img width="2106" height="1356" alt="image" src="https://github.com/user-attachments/assets/101fa69d-f266-4f77-9398-60a55bfb5138" />

---

A streamlined terminal application that displays system monitoring tools in a fixed 5-pane layout.

**Production Release v1.2**: Optimized for fast loading with parallel tool execution and warm start capabilities.

## Layout (5 panes)
- **Left Half**: htop CPU (top) and htop memory with clean interface (bottom)
- **Right Half**: mactop (top), ctop (middle), and nethogs (bottom)

## Prerequisites

### Required Tools (No Alternatives)
- `tmux` - Terminal multiplexer
- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor
- `ctop` - Container monitoring tool
- `nethogs` - Network traffic monitor by process (runs continuously with sudo)

### Install All Dependencies
```bash
brew install tmux htop mactop ctop nethogs
```

**Important**: All tools are required. The simplified version does not provide fallback alternatives.

### Configure Passwordless sudo for Monitoring Tools (Required)

htop, mactop, and nethogs require root privileges to access all system information. To run ztop smoothly without password prompts, you must configure sudoers to allow these commands to run with sudo WITHOUT requiring a password.

**Option 1: Allow your user to run monitoring tools without password (Recommended)**

```bash
sudo visudo
```

Add these lines at the end of the file (replace `yourusername` with your actual username):
```
# ZTop monitoring tools - allow passwordless sudo
yourusername ALL=(ALL) NOPASSWD: /opt/homebrew/bin/htop
yourusername ALL=(ALL) NOPASSWD: /opt/homebrew/bin/mactop
yourusername ALL=(ALL) NOPASSWD: /opt/homebrew/bin/nethogs
```

The `NOPASSWD:` keyword means these commands will run with sudo WITHOUT asking for your password.

**Option 2: Allow all admin users to run monitoring tools without password**

```bash
sudo visudo
```

Add these lines at the end of the file:
```
# ZTop monitoring tools - allow passwordless sudo for all admin users
%admin ALL=(ALL) NOPASSWD: /opt/homebrew/bin/htop
%admin ALL=(ALL) NOPASSWD: /opt/homebrew/bin/mactop
%admin ALL=(ALL) NOPASSWD: /opt/homebrew/bin/nethogs
```

The `NOPASSWD:` keyword means these commands will run with sudo WITHOUT asking for a password.

**Important Notes**:
- Always use `visudo` to edit sudoers file (it validates syntax before saving)
- The paths must be absolute (use `which htop`, `which mactop`, `which nethogs` to find correct paths)
- Common paths: `/opt/homebrew/bin/` (Apple Silicon) or `/usr/local/bin/` (Intel Mac)
- ctop does not require sudo and is not included
- Save and exit (`:wq` in vi/vim)

## Installation & Usage

1. Make the script executable:
   ```bash
   chmod +x ztop.sh
   ```

2. Run ZTop:
   ```bash
   ./ztop.sh
   ```

The script will automatically:
- Create a new tmux session named "ztop" with 5 optimized panes
- Auto-attach to existing session if already running (instant warm start)
- Launch all monitoring tools in parallel for faster startup
- Apply clean htop interface with hidden graph meters
- Setup optimized key shortcuts ('q' to detach, 'k' to kill)
- Check for required tools and exit if any are missing

## Features

### Performance Optimizations (v1.2)
- **Lazy loading with parallel execution** - All tools launch simultaneously for faster startup
- **Instant warm start** - Press `q` to detach (tools keep running), reattach instantly on next run
- **Smart session management** - Automatically reuses existing session when available

### Core Features
- **Fixed 5-pane layout** with optimized 50/50 split (2 panes left, 3 panes right)
- **Clean htop interface** with automatic graph meter hiding using `#` keystroke
- **Optimized key shortcuts**:
  - Press `q` from any pane to detach (tools keep running in background)
  - Press `k` from any pane to kill entire session (stop all tools)
- **Production-ready design** - Fully tested, documented code
- **Auto session management** - no interactive prompts, automatic attach/create
- **Bash 3.x+ compatibility** for older and newer macOS systems
- **No fallback tools** - clean, predictable behavior requiring exact tools
- **Hardcoded tool arrays** - eliminates complex configuration logic

## Testing

Run the comprehensive test suite:

```bash
./test_ztop.sh
```

**22 comprehensive tests** including:
- Layout verification with automated tmux pane position testing
- Lazy loading and parallel execution testing
- Key binding functionality testing (q for detach, k for kill)
- Session reattachment and warm start testing
- Simplified dependency checking validation
- htop_mem_clean functionality with # keystroke validation
- Integration tests for streamlined functionality verification

All tests pass successfully, ensuring reliable operation with optimizations.

## Requirements

- **Bash 3.x+** (compatible with older and newer systems)
- **tmux** terminal multiplexer
- **All monitoring tools required** (htop, mactop, ctop, nethogs) - no alternatives

## Design Philosophy

This v1.2 release prioritizes **performance and usability**:
- **Parallel tool loading** - All monitoring tools launch simultaneously
- **Instant warm start** - Detach and reattach without reloading tools
- **Smart key bindings** - 'q' for detach (hibernate), 'k' for kill
- **No fallback tools** - ensures consistent behavior across environments
- **Hardcoded configuration** - eliminates complex logic and edge cases
- **Production-ready codebase** - thoroughly tested and documented
- **Direct execution** - streamlined flow without abstraction layers
- **Comprehensive testing** - 22 tests ensuring reliable operation with optimizations
