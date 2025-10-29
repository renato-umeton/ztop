# ZTop - Terminal System Monitor v1.2

## Project Overview
ZTop v1.2 is an optimized terminal application that creates a 5-pane layout displaying system monitoring tools in a single tmux session. It features fast loading and warm start capabilities.

### Layout (5 panes)
- **Left Half**: htop CPU (top) and htop memory with clean interface (bottom)
- **Right Half**: mactop (top), ctop (middle), and nethogs (bottom)

## Implementation

### ZTop v1.2 (`ztop.sh`) - Performance Optimized Release
- **Language**: Bash 3.x+ compatible
- **UI Framework**: tmux for terminal multiplexing and pane management
- **Process Management**: Parallel tool launching with background processes
- **Layout**: Fixed 5-pane layout with optimized 50/50 split
- **Session Management**: Auto-attach with instant warm start capability
- **Performance Optimizations**:
  - **Lazy loading**: Panes created first, then tools launched in parallel
  - **Parallel execution**: All 5 tools start simultaneously
  - **Warm start**: 'q' detaches (tools keep running), reattach instantly
  - **Smart key bindings**: 'q' for detach/hibernate, 'k' for kill
- **Special Features**: Clean htop interface + optimized key shortcuts
- **Design Philosophy**: Performance-focused, production-ready with comprehensive testing
- **Test Coverage**: 22 comprehensive tests covering all functionality including optimizations

## Key Files
- `ztop.sh` - Main bash implementation using tmux for pane management
- `test_ztop.sh` - Comprehensive test suite with layout and optimization verification
- `README.md` - User documentation and installation instructions
- `CLAUDE.md` - Detailed project documentation

## Dependencies

### Required Tools (No Fallbacks)
- `tmux` - Terminal multiplexer
- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor
- `ctop` - Container monitoring tool
- `nethogs` - Network traffic monitor by process (runs continuously with sudo)

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
- Auto-attach to existing session if already running (instant warm start)
- Launch all monitoring tools in parallel for faster startup
- Use clean htop interface with hidden graph meters
- Configure optimized key bindings ('q' to detach, 'k' to kill)
- Require all monitoring tools (no fallbacks)

## Features

### Performance Optimizations (v1.2)
- **Lazy loading with parallel execution** - Panes created first, then all tools launched simultaneously
- **Instant warm start** - Press 'q' to detach (tools keep running), reattach instantly next time
- **Smart session management** - Automatically reuses existing session for zero-delay startup
- **Optimized key bindings** - 'q' for detach/hibernate, 'k' for kill

### Core Features
- **Fixed 5-pane layout** with optimized 50/50 split (2 panes left, 3 panes right)
- **Clean htop interface** with automatic graph meter hiding using `#` keystroke
- **Streamlined dependency checking** - requires all tools, no alternatives
- **Auto session management** - automatically attaches to existing or creates new
- **Bash 3.x+ compatibility** for older and newer systems
- **Production-ready codebase** - fully tested and documented

### Technical Implementation
- **Parallel tool launching** - Background processes for simultaneous tool startup
- **Hardcoded tool arrays** - eliminates complex configuration logic
- **Direct tmux commands** - no abstraction layers or complex functions
- **Automatic session detection** and reuse without user prompts
- **Essential functions only** - removed all unnecessary complexity
- **No fallback tools** - clean, predictable behavior

### Optimizations from Issue #1
Issue #1 requested three optimization strategies, all implemented:
1. **Lazy load** ✓ - Panes created first, then filled in parallel using background processes
2. **Warm start** ✓ - 'q' detaches instead of kills, enabling instant reattach
3. **Smart key mapping** ✓ - 'q' for hibernate/detach, 'k' for kill

## Testing

### Test Suite
- **22 comprehensive tests** covering all functionality including optimizations
- **Layout verification** with automated tmux pane position testing
- **Lazy loading tests** - Verify panes created before tools launched
- **Parallel execution tests** - Verify tools launch simultaneously
- **Key binding tests** - 'q' for detach, 'k' for kill
- **Session reattachment tests** - Verify warm start capability
- **Dependency checking** with tool requirements validation
- **Integration tests** for end-to-end functionality verification
- **htop_mem_clean functionality** testing with # keystroke validation

### Running Tests
```bash
# Run all tests
./test_ztop.sh
```

All tests pass successfully, ensuring reliable operation across different environments.