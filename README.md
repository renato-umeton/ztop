# ZTop - Terminal System Monitor
 
**Requirements:** `brew install tmux htop mactop ctop nethogs`

**Quick Start:** `./ztop.sh`

<img width="2106" height="1356" alt="image" src="https://github.com/user-attachments/assets/101fa69d-f266-4f77-9398-60a55bfb5138" />

---

A streamlined terminal application that displays system monitoring tools in a fixed 5-pane layout.

**Simplified Design**: 177 lines of code (56% reduction) with no fallback tools or complex configuration.

## Layout (5 panes)
- **Left Half**: htop CPU (top) and htop memory with clean interface (bottom)
- **Right Half**: mactop (top), ctop (middle), and nethogs (bottom)

## Prerequisites

### Required Tools (No Alternatives)
- `tmux` - Terminal multiplexer
- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor
- `ctop` - Container monitoring tool
- `nethogs` - Network traffic monitor by process

### Install All Dependencies
```bash
brew install tmux htop mactop ctop nethogs
```

**Important**: All tools are required. The simplified version does not provide fallback alternatives.

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
- Auto-attach to existing session if already running (no prompts)
- Apply clean htop interface with hidden graph meters
- Check for required tools and exit if any are missing

## Features

- **Fixed 5-pane layout** with optimized 50/50 split (2 panes left, 3 panes right)
- **Clean htop interface** with automatic graph meter hiding using `#` keystroke
- **Streamlined design** - 177 lines (56% reduction from original)
- **Auto session management** - no interactive prompts, automatic attach/create
- **Bash 3.x+ compatibility** for older and newer macOS systems
- **No fallback tools** - clean, predictable behavior requiring exact tools
- **Hardcoded tool arrays** - eliminates complex configuration logic

## Testing

Run the comprehensive test suite:

```bash
./test_ztop.sh
```

**12 comprehensive tests** including:
- Layout verification with automated tmux pane position testing
- Simplified dependency checking validation
- htop_mem_clean functionality with # keystroke validation
- Integration tests for streamlined functionality verification

All tests pass successfully, ensuring reliable operation with the simplified design.

## Requirements

- **Bash 3.x+** (compatible with older and newer systems)
- **tmux** terminal multiplexer
- **All monitoring tools required** (htop, mactop, ctop, nethogs) - no alternatives

## Design Philosophy

This version prioritizes **simplicity and predictability** over flexibility:
- **No fallback tools** - ensures consistent behavior across environments
- **Hardcoded configuration** - eliminates complex logic and edge cases
- **Minimal codebase** - easier to understand, maintain, and debug
- **Direct execution** - streamlined flow without abstraction layers
