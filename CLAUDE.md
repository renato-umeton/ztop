# ZTop - Terminal System Monitor

## Project Overview
ZTop is a terminal application that creates a multi-pane layout displaying different system monitoring tools in a single terminal window:

### Python Version Layout (4 panes)
- **Top Left**: htop sorted by CPU usage
- **Bottom Left**: htop sorted by memory usage  
- **Top Right**: mactop (macOS activity monitor)
- **Bottom Right**: ctop (container monitoring)

### Bash Compatibility Version Layout (5 panes)
- **Left Half**: htop CPU (top) and htop memory with clean interface (bottom)
- **Right Half**: mactop (top), ctop (middle), and nethogs (bottom)

## Implementations

### Python Version (`ztop.py`)
- **Language**: Python 3.13
- **UI Framework**: Rich library for terminal layouts and live updates
- **Process Management**: subprocess with asyncio for handling multiple monitoring tools
- **Layout**: 2x2 grid using Rich's Layout system with color-coded panels

### Bash Version (`ztop.sh`)
- **Language**: Bash 4+
- **UI Framework**: tmux for terminal multiplexing and pane management
- **Process Management**: Direct command execution in tmux panes
- **Layout**: 2x2 grid using tmux's tiled layout
- **Session Management**: Creates/attaches to named tmux session "ztop"

### Bash Compatibility Version (`ztop_compat.sh`)
- **Language**: Bash 3.x compatible
- **UI Framework**: tmux for terminal multiplexing and pane management
- **Process Management**: Direct command execution in tmux panes
- **Layout**: 5-pane layout with 50/50 split (2 panes left, 3 panes right)
- **Session Management**: Creates/attaches to named tmux session "ztop"
- **Special Features**: Clean htop interface with hidden graph meters

## Key Files
- `ztop.py` - Python implementation with ProcessPane class and ZTop manager
- `ztop.sh` - Bash 4+ implementation using tmux for pane management
- `ztop_compat.sh` - Bash 3.x compatible implementation with enhanced layout
- `setup.py` - Package installation configuration
- `Pipfile` - Dependencies for Python version
- `tests/` - Comprehensive test suite for Python version
- `test_ztop.sh` - Bash test suite for ztop.sh
- `test_ztop_compat.sh` - Bash test suite for ztop_compat.sh with layout verification
- `README.md` - User documentation and installation instructions

## Dependencies

### Common Dependencies
- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor (brew install mactop)
- `ctop` - Container monitoring tool (brew install ctop)
- `nethogs` - Network traffic monitor by process (compatibility version only)

### Python Version Dependencies
- `rich` - Python terminal UI library
- `pytest` - Testing framework (dev dependency)

### Bash Version Dependencies
- `tmux` - Terminal multiplexer

## Usage

### Python Version
```bash
pipenv install
pipenv run python ztop.py
```

Or install as package:
```bash
pip install -e .
ztop
```

### Bash Version (Bash 4+)
```bash
chmod +x ztop.sh
./ztop.sh
```

### Bash Compatibility Version (Bash 3.x)
```bash
chmod +x ztop_compat.sh
./ztop_compat.sh
```

The bash versions will:
- Create a new tmux session named "ztop" 
- Attach to existing session if already running
- Use optimized layout for system monitoring
- Support clean interface options (compatibility version)

## Development Notes

### Python Version
- Uses async/await for non-blocking process management
- Real-time updates every 0.5 seconds with Live rendering
- Graceful shutdown handling with signal handlers
- Error handling for missing external commands
- Process cleanup on exit to prevent orphaned processes
- Comprehensive test suite with 31 tests covering unit and integration scenarios

### Bash Versions
- Simple tmux-based implementation for lightweight usage
- Session persistence - can detach/reattach without losing state
- Automatic session detection and reuse
- Uses tmux's built-in pane management and layout system
- Direct command execution in each pane for minimal overhead

### Bash Compatibility Version (`ztop_compat.sh`)
- Enhanced 5-pane layout with proper 50/50 split
- Clean htop interface with automatic graph meter hiding
- Comprehensive dependency checking with fallback options
- Layout verification testing for quality assurance
- Bash 3.x compatibility for older macOS systems
- Tool alternatives detection (btop for mactop, etc.)

## Testing

### Test Suites
- **Python tests**: 31 comprehensive tests using pytest
- **Bash tests**: Shell-based test suites for both bash versions
- **Layout verification**: Automated tmux pane position testing
- **Integration tests**: End-to-end functionality verification

### Running Tests
```bash
# Python tests
pipenv run pytest

# Bash compatibility tests
./test_ztop_compat.sh

# Original bash tests (requires Bash 4+)
./test_ztop.sh
```