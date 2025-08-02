# ZTop - Terminal System Monitor v1.0

## Project Overview
ZTop v1.0 is a streamlined terminal application that creates a 5-pane layout displaying system monitoring tools in a single tmux session:

### Layout (5 panes)
- **Left Half**: htop CPU (top) and htop memory with clean interface (bottom)
- **Right Half**: mactop (top), ctop (middle), and nethogs (bottom)

## Implementation

### ZTop v1.0 (`ztop.sh`) - Production Release
- **Language**: Bash 3.x+ compatible
- **Size**: 183 lines (production-ready, fully tested)
- **UI Framework**: tmux for terminal multiplexing and pane management
- **Process Management**: Direct command execution with hardcoded tool arrays
- **Layout**: Fixed 5-pane layout with optimized 50/50 split
- **Session Management**: Auto-attach to existing session or create new
- **Special Features**: Clean htop interface + global `q` quit shortcut
- **Design Philosophy**: Minimal, focused, production-ready with comprehensive testing
- **Test Coverage**: 13 comprehensive tests covering all functionality

## Key Files
- `ztop.sh` - Main bash implementation using tmux for pane management
- `test_ztop.sh` - Comprehensive test suite with layout verification
- `README.md` - User documentation and installation instructions
- `CLAUDE.md` - Detailed project documentation

## Dependencies

### Required Tools (No Fallbacks)
- `tmux` - Terminal multiplexer
- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor
- `ctop` - Container monitoring tool
- `nethogs` - Network traffic monitor by process

### Install All Dependencies
```bash
brew install tmux htop mactop ctop nethogs
```

**Note**: All tools are required. The simplified version provides no fallback alternatives for missing tools.

## Usage

```bash
chmod +x ztop.sh
./ztop.sh
```

The script will:
- Create a new tmux session named "ztop" with 5 optimally arranged panes
- Auto-attach to existing session if already running
- Use clean htop interface with hidden graph meters
- Require all monitoring tools (no fallbacks)

## Features

### Core Features
- **Fixed 5-pane layout** with optimized 50/50 split (2 panes left, 3 panes right)
- **Clean htop interface** with automatic graph meter hiding using `#` keystroke
- **Global quit shortcut** - press `q` from any pane to kill entire session
- **Streamlined dependency checking** - requires all tools, no alternatives
- **Auto session management** - automatically attaches to existing or creates new
- **Bash 3.x+ compatibility** for older and newer systems
- **Production-ready codebase** - 183 lines, fully tested and documented

### Technical Implementation
- **Hardcoded tool arrays** - eliminates complex configuration logic
- **Direct tmux commands** - no abstraction layers or complex functions
- **Automatic session detection** and reuse without user prompts
- **Essential functions only** - removed all unnecessary complexity
- **No fallback tools** - clean, predictable behavior

### Simplifications Made
- Removed unused layout system (6 layouts → 1 fixed layout)
- Eliminated complex dependency checking with duplicate detection
- Removed all tool alternatives and fallback logic
- Hardcoded session configuration instead of variables
- Simplified session management (no interactive prompts)
- Streamlined help and command-line options
- Removed cleanup traps and complex error handling

## Testing

### Test Suite
- **13 comprehensive tests** covering all functionality
- **Layout verification** with automated tmux pane position testing
- **Global 'q' key binding** functionality testing
- **Dependency checking** with tool requirements validation
- **Integration tests** for end-to-end functionality verification
- **htop_mem_clean functionality** testing with # keystroke validation

### Running Tests
```bash
# Run all tests
./test_ztop.sh
```

All tests pass successfully, ensuring reliable operation across different environments.