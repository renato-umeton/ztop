# ZTop - Terminal System Monitor
 
Requirements: `brew install tmux htop mactop ctop nethogs`

**Quick Start:**
- Python version: `pipenv run python ztop.py`
- Bash version: `./ztop.sh` (requires Bash 4+)
- Compatibility version: `./ztop_compat.sh` (Bash 3.x compatible)

<img width="2106" height="1356" alt="image" src="https://github.com/user-attachments/assets/101fa69d-f266-4f77-9398-60a55bfb5138" />

---

A terminal application that displays system monitoring tools in multiple layouts:

## Python Version (4-pane layout)
- **Top Left**: htop sorted by CPU usage
- **Bottom Left**: htop sorted by memory usage  
- **Top Right**: mactop (macOS activity monitor)
- **Bottom Right**: ctop (container monitoring)

## Bash Compatibility Version (5-pane layout)
- **Left Half**: htop CPU (top) and htop memory with clean interface (bottom)
- **Right Half**: mactop (top), ctop (middle), and nethogs (bottom)

## Prerequisites

### All Versions
- `tmux` - Terminal multiplexer
- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor (install with `brew install mactop`)
- `ctop` - Container monitoring tool (install with `brew install ctop`)

### Compatibility Version Additional
- `nethogs` - Network traffic monitor by process (install with `brew install nethogs`)

### Install All Dependencies
```bash
brew install tmux htop mactop ctop nethogs
```

## Installation & Usage

### Python Version
1. Install Python dependencies:
   ```bash
   pipenv install
   ```

2. Run the application:
   ```bash
   pipenv run python ztop.py
   ```

   Or install as a package:
   ```bash
   pip install -e .
   ztop
   ```

### Bash Versions
1. Make scripts executable:
   ```bash
   chmod +x ztop.sh ztop_compat.sh
   ```

2. Run your preferred version:
   ```bash
   # Original bash version (requires Bash 4+)
   ./ztop.sh
   
   # Compatibility version (Bash 3.x compatible)
   ./ztop_compat.sh
   ```

## Features

### Python Version
- Real-time monitoring in 4 split panes
- Color-coded panels for easy identification
- Graceful shutdown handling
- Automatic process cleanup on exit
- Rich terminal UI library

### Bash Compatibility Version
- Enhanced 5-pane layout with optimized 50/50 split
- Clean htop interface with automatic graph meter hiding
- Comprehensive dependency checking with fallback alternatives
- Session persistence with tmux (detach/reattach support)
- Bash 3.x compatibility for older macOS systems

## Testing

Run the comprehensive test suites:

```bash
# Python tests (31 tests)
pipenv run pytest

# Bash compatibility tests (12 tests including layout verification)
./test_ztop_compat.sh

# Original bash tests (requires Bash 4+)
./test_ztop.sh
```

## Requirements

### Python Version
- Python 3.8+
- rich library for terminal UI
- Required monitoring tools

### Bash Versions
- tmux terminal multiplexer
- Bash 3.x+ (compatibility version) or Bash 4+ (original version)
- Required monitoring tools
