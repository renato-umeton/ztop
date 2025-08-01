# ZTop - Terminal System Monitor

## Project Overview
ZTop is a terminal application that creates a 4-pane layout displaying different system monitoring tools in a single terminal window:

- **Top Left**: htop sorted by CPU usage
- **Bottom Left**: htop sorted by memory usage  
- **Top Right**: mactop (macOS activity monitor)
- **Bottom Right**: ctop (container monitoring)

## Implementations

### Python Version (`ztop.py`)
- **Language**: Python 3.13
- **UI Framework**: Rich library for terminal layouts and live updates
- **Process Management**: subprocess with asyncio for handling multiple monitoring tools
- **Layout**: 2x2 grid using Rich's Layout system with color-coded panels

### Bash Version (`ztop.sh`)
- **Language**: Bash
- **UI Framework**: tmux for terminal multiplexing and pane management
- **Process Management**: Direct command execution in tmux panes
- **Layout**: 2x2 grid using tmux's tiled layout
- **Session Management**: Creates/attaches to named tmux session "ztop"

## Key Files
- `ztop.py` - Python implementation with ProcessPane class and ZTop manager
- `ztop.sh` - Bash implementation using tmux for pane management
- `setup.py` - Package installation configuration
- `Pipfile` - Dependencies for Python version
- `tests/` - Comprehensive test suite for Python version
- `README.md` - User documentation and installation instructions

## Dependencies

### Common Dependencies
- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor (brew install mactop)
- `ctop` - Container monitoring tool (brew install ctop)

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

### Bash Version
```bash
chmod +x ztop.sh
./ztop.sh
```

The bash version will:
- Create a new tmux session named "ztop" with 4 panes
- Attach to existing session if already running
- Use tmux's tiled layout for optimal viewing

## Development Notes

### Python Version
- Uses async/await for non-blocking process management
- Real-time updates every 0.5 seconds with Live rendering
- Graceful shutdown handling with signal handlers
- Error handling for missing external commands
- Process cleanup on exit to prevent orphaned processes
- Comprehensive test suite with 31 tests covering unit and integration scenarios

### Bash Version
- Simple tmux-based implementation for lightweight usage
- Session persistence - can detach/reattach without losing state
- Automatic session detection and reuse
- Uses tmux's built-in pane management and layout system
- Direct command execution in each pane for minimal overhead