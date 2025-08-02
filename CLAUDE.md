# ZTop - Terminal System Monitor

## Project Overview
ZTop is a terminal application that creates a 5-pane layout displaying different system monitoring tools in a single terminal window:

### Layout (5 panes)
- **Left Half**: htop CPU (top) and htop memory with clean interface (bottom)
- **Right Half**: mactop (top), ctop (middle), and nethogs (bottom)

## Implementation

### ZTop (`ztop.sh`)
- **Language**: Bash 3.x+ compatible
- **UI Framework**: tmux for terminal multiplexing and pane management
- **Process Management**: Direct command execution in tmux panes
- **Layout**: 5-pane layout with optimized 50/50 split (2 panes left, 3 panes right)
- **Session Management**: Creates/attaches to named tmux session "ztop"
- **Special Features**: Clean htop interface with automatic graph meter hiding

## Key Files
- `ztop.sh` - Main bash implementation using tmux for pane management
- `test_ztop.sh` - Comprehensive test suite with layout verification
- `README.md` - User documentation and installation instructions
- `CLAUDE.md` - Detailed project documentation

## Dependencies

### Required Tools
- `tmux` - Terminal multiplexer
- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor (brew install mactop)
- `ctop` - Container monitoring tool (brew install ctop)
- `nethogs` - Network traffic monitor by process

### Install All Dependencies
```bash
brew install tmux htop mactop ctop nethogs
```

## Usage

```bash
chmod +x ztop.sh
./ztop.sh
```

The script will:
- Create a new tmux session named "ztop" with 5 optimally arranged panes
- Attach to existing session if already running
- Use clean htop interface with hidden graph meters
- Support dependency checking with fallback alternatives

## Features

### Core Features
- **Enhanced 5-pane layout** with optimized 50/50 split (2 panes left, 3 panes right)
- **Clean htop interface** with automatic graph meter hiding using `#` keystroke
- **Comprehensive dependency checking** with fallback alternatives
- **Session persistence** - can detach/reattach without losing state
- **Bash 3.x+ compatibility** for older and newer systems
- **Tool alternatives detection** (btop for mactop, iftop for nethogs, etc.)

### Technical Implementation
- Simple tmux-based implementation for lightweight usage
- Automatic session detection and reuse
- Uses tmux's built-in pane management and layout system
- Direct command execution in each pane for minimal overhead
- Graceful error handling for missing tools

## Testing

### Test Suite
- **12 comprehensive tests** covering all functionality
- **Layout verification** with automated tmux pane position testing
- **Dependency checking** with tool alternatives validation
- **Integration tests** for end-to-end functionality verification
- **htop_mem_clean functionality** testing with # keystroke validation

### Running Tests
```bash
# Run all tests
./test_ztop.sh
```

All tests pass successfully, ensuring reliable operation across different environments.