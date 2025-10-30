# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
ZTop v1.3 is a bash-based terminal application that creates a 5-pane tmux layout displaying system monitoring tools. It features performance optimizations including lazy loading, parallel tool execution, warm start capabilities, and full sudo support for comprehensive system monitoring.

## Commands

### Testing
```bash
./test_ztop.sh          # Run full test suite (22 tests)
```

### Running
```bash
./ztop.sh               # Run ztop (creates or attaches to session)
./ztop.sh --help        # Show help and available options
./ztop.sh --list-tools  # Check which tools are installed
./ztop.sh --kill        # Kill existing ztop session
```

### Dependencies Installation
```bash
brew install tmux htop mactop ctop nethogs
```

## Architecture

### Core Design Pattern
The application follows a **lazy loading with parallel execution** pattern:
1. **Session management** (`manage_session`) - Auto-attach to existing session if available
2. **Pane creation** (`create_session`) - Create empty 5-pane layout first
3. **Parallel tool launch** (`launch_tools`) - All 5 tools start simultaneously using background processes (`&`)
4. **Configuration** (`configure_tmux`) - Apply tmux settings and key bindings

### Key Technical Details

**Layout Structure** (ztop.sh:72-84):
- 5 panes total: 2 left (panes 0,1), 3 right (panes 2,3,4)
- Created using tmux split-window commands with specific targeting
- Panes are sized for 50/50 horizontal split

**Warm Start Implementation** (ztop.sh:128-129):
- 'q' key bound to `detach-client` (not kill) - tools keep running
- 'k' key bound to `kill-session` - stops all tools
- `manage_session` auto-attaches to existing session for instant restart

**Parallel Tool Launch** (ztop.sh:96-121):
- Each tool launched in background subshell using `( ... ) &`
- `wait` command ensures all tools start before attach
- Special handling for htop_mem_clean: sends '#' keystroke after 2s to hide graph meters

**Tool Configuration** (ztop.sh:92-94):
- Tools, commands, and titles stored in hardcoded arrays
- No fallback alternatives - all tools required
- htop, mactop, and nethogs run with sudo for full system access
- nethogs wrapped in `while true` loop with sudo for continuous operation
- ctop does not require sudo

### Testing Architecture

**Test Suite Structure** (test_ztop.sh):
- 16 core functionality tests + 6 optimization-specific tests = 22 total
- Tests verify: script existence, help/options, session creation, layout structure, key bindings
- Optimization tests check: lazy loading pattern, parallel execution, 'q' detach, 'k' kill, reattachment

**Key Test Patterns**:
- Layout verification (test_ztop.sh:234-295): Creates test session and validates pane positions using `tmux list-panes`
- Key binding tests use `tmux list-keys` to verify bindings exist
- Optimization tests verify code structure (function order) rather than runtime behavior

## Important Implementation Notes

### Bash Compatibility
- Written for Bash 3.x+ compatibility (macOS ships with Bash 3.2)
- Avoids Bash 4+ features (associative arrays, etc.)
- Uses simple arrays with parallel indexing pattern

### Tmux Session Management
- Session name is hardcoded as "ztop"
- Always check for existing session with `tmux has-session -t "ztop"`
- Use `tmux attach-session -t "ztop"` at the end of main()

### htop_mem_clean Feature
- Uses same command as regular htop: `htop -s PERCENT_MEM`
- Automatically sends '#' keystroke after 2-second delay to hide graph meters
- Implemented in launch_tools using conditional check for "htop_mem_clean" tool name

### Dependency Checking
- All 5 tools are required: tmux, htop, mactop, ctop, nethogs
- No fallback alternatives provided (simplified from earlier versions)
- User can choose to continue if tools missing (prompted via read)

### Sudo Requirements
- htop, mactop, and nethogs require sudo for full system access
- Users should configure passwordless sudo in /etc/sudoers using `visudo`
- Example sudoers entries (use absolute paths):
  ```
  yourusername ALL=(ALL) NOPASSWD: /opt/homebrew/bin/htop
  yourusername ALL=(ALL) NOPASSWD: /opt/homebrew/bin/mactop
  yourusername ALL=(ALL) NOPASSWD: /opt/homebrew/bin/nethogs
  ```
- Without passwordless sudo, user will be prompted for password on each tool launch

## Testing Requirements

### When Making Changes
1. All 22 tests must pass before committing
2. Test both with and without existing tmux sessions
3. Verify layout structure hasn't changed (panes 0,1 left, panes 2,3,4 right)
4. If modifying optimizations, update corresponding tests

### Adding New Tests
- Follow existing test pattern: `test_function_name()`
- Use `log_test`, `pass`, `fail`, `warn` functions for output
- Clean up test sessions in teardown
- Skip tests gracefully if dependencies unavailable (using `warn`)
