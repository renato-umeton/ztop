# ZTop - Terminal System Monitor
 
Requirements: `brew install tmux htop mactop ctop nethogs`

**Quick Start:** `./ztop.sh`

<img width="2106" height="1356" alt="image" src="https://github.com/user-attachments/assets/101fa69d-f266-4f77-9398-60a55bfb5138" />

---

A terminal application that displays system monitoring tools in an optimized 5-pane layout:

## Layout (5 panes)
- **Left Half**: htop CPU (top) and htop memory with clean interface (bottom)
- **Right Half**: mactop (top), ctop (middle), and nethogs (bottom)

## Prerequisites

### Required Tools
- `tmux` - Terminal multiplexer
- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor
- `ctop` - Container monitoring tool
- `nethogs` - Network traffic monitor by process

### Install All Dependencies
```bash
brew install tmux htop mactop ctop nethogs
```

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
- Attach to existing session if already running
- Apply clean htop interface with hidden graph meters
- Check dependencies and suggest alternatives if tools are missing

## Features

- **Enhanced 5-pane layout** with optimized 50/50 split (2 panes left, 3 panes right)
- **Clean htop interface** with automatic graph meter hiding using `#` keystroke
- **Comprehensive dependency checking** with fallback alternatives (btop for mactop, etc.)
- **Session persistence** with tmux (detach/reattach support)
- **Bash 3.x+ compatibility** for older and newer macOS systems
- **Graceful error handling** for missing tools with helpful suggestions

## Testing

Run the comprehensive test suite:

```bash
./test_ztop.sh
```

**12 comprehensive tests** including:
- Layout verification with automated tmux pane position testing
- Dependency checking with tool alternatives validation
- htop_mem_clean functionality with # keystroke validation
- Integration tests for end-to-end functionality verification

All tests pass successfully, ensuring reliable operation across different environments.

## Requirements

- **Bash 3.x+** (compatible with older and newer systems)
- **tmux** terminal multiplexer
- **Required monitoring tools** (htop, mactop, ctop, nethogs)
