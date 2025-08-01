# ZTop - Terminal System Monitor

## Project Overview
ZTop is a terminal application that creates a 4-pane layout displaying different system monitoring tools in a single terminal window:

- **Top Left**: htop sorted by CPU usage
- **Bottom Left**: htop sorted by memory usage  
- **Top Right**: mactop (macOS activity monitor)
- **Bottom Right**: ctop (container monitoring)

## Architecture
- **Language**: Python 3.13
- **UI Framework**: Rich library for terminal layouts and live updates
- **Process Management**: subprocess with asyncio for handling multiple monitoring tools
- **Layout**: 2x2 grid using Rich's Layout system with color-coded panels

## Key Files
- `ztop.py` - Main application with ProcessPane class and ZTop manager
- `setup.py` - Package installation configuration
- `Pipfile` - Dependencies (rich, asyncio-subprocess)
- `README.md` - User documentation and installation instructions

## Dependencies
- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor (brew install mactop)
- `ctop` - Container monitoring tool (brew install ctop)
- `rich` - Python terminal UI library

## Usage
```bash
pipenv install
pipenv run python ztop.py
```

Or install as package:
```bash
pip install -e .
ztop
```

## Development Notes
- Uses async/await for non-blocking process management
- Real-time updates every 0.5 seconds with Live rendering
- Graceful shutdown handling with signal handlers
- Error handling for missing external commands
- Process cleanup on exit to prevent orphaned processes