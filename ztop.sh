#!/bin/bash

# ztop.sh - Multi-pane system monitoring with tmux
# Creates 5 panes: Left[htop_cpu+htop_mem_clean] | Right[mactop+ctop+nethogs]

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[ztop]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[ztop]${NC} $1"
}

error() {
    echo -e "${RED}[ztop]${NC} $1"
}

command_exists() {
    command -v "$1" &> /dev/null
}

# Check required tools
check_dependencies() {
    if ! command_exists tmux; then
        error "tmux is required but not installed"
        echo "  Install with: brew install tmux"
        exit 1
    fi
    
    local missing_tools=()
    for tool in htop mactop ctop nethogs; do
        if ! command_exists "$tool"; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        warn "Missing tools: ${missing_tools[*]}"
        echo "  Install with: brew install ${missing_tools[*]}"
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Simple session management
manage_session() {
    if tmux has-session -t "ztop" 2>/dev/null; then
        log "Attaching to existing session..."
        tmux attach-session -t "ztop"
        exit 0
    fi
}

# Create tmux session with 5-pane layout
create_session() {
    log "Creating new tmux session..."
    
    tmux new-session -d -s "ztop" -x 120 -y 40
    
    # Create 5-pane layout: 2 left, 3 right
    tmux split-window -h -p 50 -t "ztop:0.0"
    tmux split-window -v -p 50 -t "ztop:0.0"
    tmux split-window -v -p 67 -t "ztop:0.2"
    tmux split-window -v -p 50 -t "ztop:0.3"
    
    tmux set -g pane-border-status top
    tmux set -g pane-border-format "#{pane_index}: #{pane_title}"
}

# Launch monitoring tools in panes
launch_tools() {
    local tools=("htop_cpu" "htop_mem_clean" "mactop" "ctop" "nethogs")
    local commands=("htop -s PERCENT_CPU" "htop -s PERCENT_MEM" "mactop" "ctop" "sudo nethogs")
    local titles=("htop (CPU)" "htop (MEM-clean)" "mactop" "ctop" "nethogs")
    
    for i in {0..4}; do
        local tool=${tools[$i]}
        local command=${commands[$i]}
        local title=${titles[$i]}
        
        tmux select-pane -t "ztop:0.$i" -T "$title"
        
        if [[ "$command" == sudo* ]] && ! sudo -n true 2>/dev/null; then
            warn "May need password for $tool"
        fi
        
        tmux send-keys -t "ztop:0.$i" "$command" Enter
        
        # Hide graph meter for clean htop
        if [[ "$tool" == "htop_mem_clean" ]]; then
            sleep 2
            tmux send-keys -t "ztop:0.$i" '#'
        fi
    done
}

# Configure tmux
configure_tmux() {
    tmux set -g mouse on
    tmux set -g status-right "ztop | %H:%M %d-%b-%y"
}

# Help function
show_help() {
    cat << EOF
ztop - Multi-pane system monitoring with tmux

Usage: $0 [OPTIONS]

Options:
    -h, --help          Show this help message
    -k, --kill          Kill existing ztop session
    -l, --list-tools    List available monitoring tools

Layout: Left[htop CPU + htop MEM] | Right[mactop + ctop + nethogs]

EOF
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -k|--kill)
            if tmux has-session -t "ztop" 2>/dev/null; then
                tmux kill-session -t "ztop"
                log "Session killed"
            else
                warn "No session found"
            fi
            exit 0
            ;;
        -l|--list-tools)
            echo "Required tools:"
            for tool in tmux htop mactop ctop nethogs; do
                if command_exists "$tool"; then
                    echo "  ✓ $tool"
                else
                    echo "  ✗ $tool"
                fi
            done
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    log "Starting ztop..."
    
    check_dependencies
    manage_session
    create_session
    configure_tmux
    launch_tools
    
    log "Session ready! Use Ctrl+B then d to detach"
    tmux attach-session -t "ztop"
}

main "$@"