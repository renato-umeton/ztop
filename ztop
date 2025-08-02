#!/bin/bash

# ztop.sh - Multi-pane system monitoring with tmux
# Creates 4 panes: htop (cpu), htop (mem), mactop, ctop

SESSION_NAME="ztop"

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed"
    exit 1
fi

# Check if session already exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session '$SESSION_NAME' already exists. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# Create new tmux session
echo "Creating new tmux session: $SESSION_NAME"

# Start new session with first pane (top-left: htop cpu)
tmux new-session -d -s "$SESSION_NAME" -x 120 -y 40

# Split horizontally to create top and bottom sections
tmux split-window -h -t "$SESSION_NAME:0"

# Split the left pane vertically (top-left and bottom-left)
tmux split-window -v -t "$SESSION_NAME:0.0"

# Split the right pane vertically (top-right and bottom-right) 
tmux split-window -v -t "$SESSION_NAME:0.1"

# Now we have 4 panes arranged as:
# 0: top-left, 1: top-right, 2: bottom-left, 3: bottom-right

# Start htop with CPU sorting in top-left pane (pane 0)
tmux send-keys -t "$SESSION_NAME:0.0" 'htop -s PERCENT_CPU' Enter

# Start mactop in top-right pane (pane 1) 
tmux send-keys -t "$SESSION_NAME:0.1" 'mactop' Enter

# Start htop with memory sorting in bottom-left pane (pane 2)
tmux send-keys -t "$SESSION_NAME:0.2" 'htop -s PERCENT_MEM' Enter

# Start ctop in bottom-right pane (pane 3)
tmux send-keys -t "$SESSION_NAME:0.3" 'ctop' Enter

# Balance the panes for better layout
tmux select-layout -t "$SESSION_NAME:0" tiled

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
