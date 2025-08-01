# ZTop - Terminal System Monitor

A terminal application that displays system monitoring tools in a 4-pane layout:

- **Top Left**: htop sorted by CPU usage
- **Bottom Left**: htop sorted by memory usage  
- **Top Right**: mactop (macOS activity monitor)
- **Bottom Right**: ctop (container monitoring)

## Prerequisites

Make sure you have the following tools installed:

- `htop` - Interactive process viewer
- `mactop` - macOS activity monitor (install with `brew install mactop`)
- `ctop` - Container monitoring tool (install with `brew install ctop`)

## Installation

1. Install dependencies:
   ```bash
   pipenv install
   ```

2. Run the application:
   ```bash
   pipenv run python ztop.py
   ```

Or install it as a package:
```bash
pip install -e .
ztop
```

## Usage

Simply run `ztop` or `python ztop.py` to start the monitoring dashboard.

Press `Ctrl+C` to exit.

## Features

- Real-time monitoring in 4 split panes
- Color-coded panels for easy identification
- Graceful shutdown handling
- Automatic process cleanup on exit

## Requirements

- Python 3.8+
- rich library for terminal UI
- htop, mactop, and ctop binaries