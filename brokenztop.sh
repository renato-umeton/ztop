#!/bin/bash

# ztop.sh - Enhanced multi-pane system monitoring with tmux
# Creates 4 panes with complementary monitoring tools

# Check for bash 4+ (required for associative arrays)
if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
    echo "Error: This script requires Bash 4.0 or higher for associative arrays."
    echo "Current version: $BASH_VERSION"
    echo "On macOS, install newer bash with: brew install bash"
    echo "Then run with: /bin/bash $0 $@ (if available)"
    exit 1
fi

SESSION_NAME="ztop"
DEFAULT_WIDTH=120
DEFAULT_HEIGHT=40

# Layout configurations
declare -A LAYOUTS=(
    ["stacked"]="htop_cpu,htop_mem_clean,mactop,ctop,nethogs"   # Your custom stacked layout
    ["original"]="htop_cpu,mactop,htop_mem,ctop"              # Original 4-pane grid
    ["processes"]="htop_cpu,htop_mem,iftop,ctop"              # Dual htop + network/containers
    ["mixed"]="htop_cpu,htop_mem,mactop,iftop"                # Dual htop + system + network
    ["docker"]="htop_cpu,mactop,iftop,ctop"                   # Original but with better network
    ["network"]="htop_cpu,htop_mem,iftop,nethogs"             # Focus on network monitoring
)

# Current layout selection
CURRENT_LAYOUT="stacked"  # Default to your custom stacked layout

# Tool definitions
declare -A TOOL_CONFIGS=(
    ["htop_cpu"]="htop -s PERCENT_CPU"
    ["htop_mem"]="htop -s PERCENT_MEM" 
    ["htop_mem_clean"]="htop -s PERCENT_MEM"  # Will be configured to hide CPU/mem bars
    ["mactop"]="mactop"
    ["iftop"]="sudo iftop -i en0 -P"
    ["ctop"]="ctop"
    ["nethogs"]="sudo nethogs"
)

# Alternative tools for different systems/preferences
declare -A ALT_TOOLS=(
    ["mactop"]="btop"
    ["iftop"]="nethogs"
    ["ctop"]="docker stats"
    ["nethogs"]="iftop"
)

# Get tools for current layout
get_layout_tools() {
    local layout="${1:-$CURRENT_LAYOUT}"
    echo "${LAYOUTS[$layout]}" | tr ',' ' '
}

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[ztop]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[ztop]${NC} $1"
}

error() {
    echo -e "${RED}[ztop]${NC} $1"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Find available tool or alternative
find_tool() {
    local tool_name="$1"
    
    # Extract base tool name (remove suffixes like _cpu, _mem, _clean)
    local base_tool=$(echo "$tool_name" | sed 's/_cpu$//' | sed 's/_mem$//' | sed 's/_clean$//' | sed 's/_mem_clean$//')
    
    if command_exists "$base_tool"; then
        echo "$base_tool"
        return 0
    fi
    
    # Check for alternative
    local alt="${ALT_TOOLS[$base_tool]}"
    if [[ -n "$alt" ]] && command_exists "$alt"; then
        warn "Using $alt instead of $base_tool"
        echo "$alt"
        return 0
    fi
    
    # Special cases for compound commands
    case "$base_tool" in
        "docker")
            if command_exists "docker"; then
                echo "docker"
                return 0
            fi
            ;;
    esac
    
    return 1
}

# Get command for tool
get_tool_command() {
    local tool_name="$1"
    
    # Check if we have a predefined command
    if [[ -n "${TOOL_CONFIGS[$tool_name]}" ]]; then
        echo "${TOOL_CONFIGS[$tool_name]}"
        return 0
    fi
    
    # Generate command based on tool name
    case "$tool_name" in
        "htop_cpu") echo "htop -s PERCENT_CPU" ;;
        "htop_mem") echo "htop -s PERCENT_MEM" ;;
        "htop_mem_clean") echo "htop -s PERCENT_MEM" ;;  # Will be configured via keystrokes
        "nethogs") echo "sudo nethogs" ;;
        "docker") echo "docker stats" ;;
        *) echo "$tool_name" ;;
    esac
}

# Check tool availability and suggest alternatives
check_dependencies() {
    local missing_tools=()
    local suggestions=()
    
    # Check tmux first
    if ! command_exists tmux; then
        error "tmux is required but not installed"
        echo "  Install with: brew install tmux  # macOS"
        echo "              apt install tmux   # Ubuntu"
        echo "              yum install tmux   # CentOS"
        exit 1
    fi
    
    # Check monitoring tools for current layout
    local tools=($(get_layout_tools))
    local checked_tools=()
    
    for tool_name in "${tools[@]}"; do
        # Extract base tool name and avoid duplicates
        local base_tool=$(echo "$tool_name" | sed 's/_cpu$//' | sed 's/_mem$//')
        
        # Skip if we already checked this base tool
        if [[ " ${checked_tools[@]} " =~ " ${base_tool} " ]]; then
            continue
        fi
        checked_tools+=("$base_tool")
        
        if ! find_tool "$tool_name" &>/dev/null; then
            missing_tools+=("$base_tool")
            case "$base_tool" in
                "mactop") suggestions+=("brew install mactop  # or: pip install btop") ;;
                "iftop") suggestions+=("brew install iftop  # or: apt install iftop") ;;
                "ctop") suggestions+=("brew install ctop   # or: apt install ctop") ;;
                "htop") suggestions+=("brew install htop   # or: apt install htop") ;;
                "nethogs") suggestions+=("brew install nethogs # or: apt install nethogs") ;;
                "docker") suggestions+=("Install Docker Desktop # or: apt install docker.io") ;;
            esac
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        warn "Some monitoring tools are missing for '$CURRENT_LAYOUT' layout:"
        printf '  %s\n' "${missing_tools[@]}"
        echo
        echo "Install suggestions:"
        printf '  %s\n' "${suggestions[@]}"
        echo
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Enhanced session management
manage_session() {
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "Session '$SESSION_NAME' already exists."
        echo "1) Attach to existing session"
        echo "2) Kill and recreate session"
        echo "3) Cancel"
        read -p "Choose option [1-3]: " -n 1 -r
        echo
        
        case $REPLY in
            1) 
                log "Attaching to existing session..."
                tmux attach-session -t "$SESSION_NAME"
                exit 0
                ;;
            2)
                log "Killing existing session..."
                tmux kill-session -t "$SESSION_NAME"
                ;;
            3)
                log "Cancelled"
                exit 0
                ;;
            *)
                error "Invalid option"
                exit 1
                ;;
        esac
    fi
}

# Setup tmux session with improved layout
create_session() {
    log "Creating new tmux session: $SESSION_NAME"
    
    # Create session with custom size
    tmux new-session -d -s "$SESSION_NAME" -x "$DEFAULT_WIDTH" -y "$DEFAULT_HEIGHT"
    
    # Check if using the stacked layout
    if [[ "$CURRENT_LAYOUT" == "stacked" ]]; then
        # Create custom 5-pane stacked layout: 2 panes on left, 3 on right
        
        # Split horizontally to create left and right columns (50%/50%)
        tmux split-window -h -p 50 -t "$SESSION_NAME:0"
        
        # Split LEFT column: htop CPU (50%) and htop MEM (50%)
        tmux split-window -v -p 50 -t "$SESSION_NAME:0.0"
        
        # Split RIGHT column: mactop (50%) and bottom section (50%)
        tmux split-window -v -p 50 -t "$SESSION_NAME:0.1" 
        
        # Split the bottom-right section: ctop (30% of bottom = 15% total) and nethogs (70% of bottom = 35% total)
        tmux split-window -v -p 30 -t "$SESSION_NAME:0.2"
        
        # Final pane arrangement:
        # 0: left-top (htop CPU) - 50% of left column
        # 1: left-bottom (htop MEM clean) - 50% of left column  
        # 2: right-top (mactop) - 50% of right column
        # 3: right-middle (ctop) - 15% of total vertical space
        # 4: right-bottom (nethogs) - 35% of total vertical space
        
        log "Created 5-pane stacked layout: Left[CPU+MEM] | Right[mactop(50%)+ctop(15%)+nethogs(35%)]"
        
    else
        # Create standard 4-pane layout for other layouts
        tmux split-window -h -t "$SESSION_NAME:0"        # Split horizontally
        tmux split-window -v -t "$SESSION_NAME:0.0"      # Split left vertically
        tmux split-window -v -t "$SESSION_NAME:0.1"      # Split right vertically
        tmux select-layout -t "$SESSION_NAME:0" tiled    # Balance the panes
        
        log "Created standard 4-pane grid layout"
    fi
    
    # Set pane titles
    tmux set -g pane-border-status top
    tmux set -g pane-border-format "#{pane_index}: #{pane_title}"
}

# Launch monitoring tools in panes
launch_tools() {
    local tools=($(get_layout_tools))
    local pane=0
    
    for tool_name in "${tools[@]}"; do
        local actual_tool
        local display_name="$tool_name"
        
        if actual_tool=$(find_tool "$tool_name"); then
            log "Starting $tool_name in pane $pane"
            
            # Set pane title with descriptive name
            case "$tool_name" in
                "htop_cpu") display_name="htop (CPU)" ;;
                "htop_mem") display_name="htop (MEM)" ;;
                "htop_mem_clean") display_name="htop (MEM-clean)" ;;
                *) display_name="$actual_tool" ;;
            esac
            
            tmux select-pane -t "$SESSION_NAME:0.$pane" -T "$display_name"
            
            # Get the command to run
            local command=$(get_tool_command "$tool_name")
            
            # Handle sudo commands with a check
            if [[ "$command" == sudo* ]]; then
                # Test if sudo is available and user can use it
                if ! command_exists sudo; then
                    warn "sudo not available, trying without sudo"
                    command=${command#sudo }
                elif ! sudo -n true 2>/dev/null; then
                    warn "May need to enter password for $tool_name"
                fi
            fi
            
            # Launch the tool
            tmux send-keys -t "$SESSION_NAME:0.$pane" "$command" Enter
            
            # Special configuration for htop_mem_clean - hide CPU/memory bars
            if [[ "$tool_name" == "htop_mem_clean" ]]; then
                log "Configuring htop to hide CPU/memory meters..."
                # Wait a moment for htop to start
                sleep 2
                
                # Send keystrokes to configure htop:
                # F2 = Setup, navigate to Meters configuration
                tmux send-keys -t "$SESSION_NAME:0.$pane" 'F2'     # Enter setup
                sleep 0.8
                
                # Navigate to the left column (Active Meters) and remove CPU/Memory meters
                # Press Left arrow to ensure we're in the left column
                tmux send-keys -t "$SESSION_NAME:0.$pane" 'Left'
                sleep 0.3
                
                # Remove all meters from left column by pressing Delete repeatedly
                # This will remove CPU, Memory, and other default meters
                for i in {1..15}; do
                    tmux send-keys -t "$SESSION_NAME:0.$pane" 'Delete'
                    sleep 0.1
                done
                
                # Save and exit setup
                tmux send-keys -t "$SESSION_NAME:0.$pane" 'F10'    # Save and exit
                sleep 0.5
            fi
            
        else
            warn "Tool $tool_name not available, showing placeholder"
            tmux select-pane -t "$SESSION_NAME:0.$pane" -T "unavailable"
            tmux send-keys -t "$SESSION_NAME:0.$pane" "echo 'Tool $tool_name not available'; echo 'Press Ctrl+C then enter a command manually'; bash" Enter
        fi
        
        ((pane++))
    done
}

# Setup key bindings and tmux options
configure_tmux() {
    # Don't balance layout for stacked - we want custom proportions
    if [[ "$CURRENT_LAYOUT" != "stacked" ]]; then
        tmux select-layout -t "$SESSION_NAME:0" tiled
    fi
    
    # Set up custom key bindings for ztop session
    tmux bind-key -T prefix r respawn-pane -k  # Restart current pane
    tmux bind-key -T prefix R source-file ~/.tmux.conf \; display-message "Config reloaded"
    tmux bind-key -T prefix q kill-session -t "$SESSION_NAME"  # Quit entire session with prefix+q
    
    # Enable mouse support
    tmux set -g mouse on
    
    # Status line configuration
    tmux set -g status-left "[#S] "
    tmux set -g status-right "ztop | %H:%M %d-%b-%y | Press Prefix+q to quit"
    tmux set -g status-bg colour235
    tmux set -g status-fg colour250
}

# Cleanup function
cleanup() {
    log "Cleaning up..."
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux kill-session -t "$SESSION_NAME"
    fi
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
    -L, --layouts       List available layouts
    -p, --layout NAME   Use specific layout (default: $CURRENT_LAYOUT)
    -s, --size WxH      Set tmux window size (default: ${DEFAULT_WIDTH}x${DEFAULT_HEIGHT})

Available Layouts:
    stacked      Left: htop(CPU+MEM 50%each) | Right: mactop(50%)+ctop(15%)+iftop(35%)  [Default]
    original     htop(CPU) | mactop    | htop(MEM) | containers    [4-pane grid]
    processes    htop(CPU) | htop(MEM) | network   | containers    
    mixed        htop(CPU) | htop(MEM) | mactop    | network
    docker       htop(CPU) | mactop    | network   | containers  
    network      htop(CPU) | htop(MEM) | iftop     | nethogs

Within tmux session:
    Prefix + r          Restart current pane
    Prefix + R          Reload tmux config
    Mouse               Click to select panes, scroll in panes

Examples:
    $0                       # Use stacked layout (htop CPU+MEM | mactop+ctop+iftop)
    $0 -p original          # Use original 4-pane grid layout  
    $0 -p docker -s 150x50  # Docker layout with custom size

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
            if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
                tmux kill-session -t "$SESSION_NAME"
                log "Session '$SESSION_NAME' killed"
            else
                warn "No session '$SESSION_NAME' found"
            fi
            exit 0
            ;;
        -l|--list-tools)
            echo "Available monitoring tools:"
            for tool in htop mactop btop iftop nethogs ctop docker; do
                if command_exists "$tool"; then
                    echo "  ✓ $tool"
                else
                    echo "  ✗ $tool"
                fi
            done
            exit 0
            ;;
        -L|--layouts)
            echo "Available layouts:"
            for layout in "${!LAYOUTS[@]}"; do
                local tools="${LAYOUTS[$layout]}"
                echo "  $layout: $tools"
            done
            exit 0
            ;;
        -p|--layout)
            if [[ -n "${LAYOUTS[$2]}" ]]; then
                CURRENT_LAYOUT="$2"
                log "Using layout: $CURRENT_LAYOUT"
                shift 2
            else
                error "Unknown layout: $2"
                echo "Available layouts: ${!LAYOUTS[*]}"
                exit 1
            fi
            ;;
        -s|--size)
            if [[ $2 =~ ^[0-9]+x[0-9]+$ ]]; then
                DEFAULT_WIDTH=$(echo "$2" | cut -d'x' -f1)
                DEFAULT_HEIGHT=$(echo "$2" | cut -d'x' -f2)
                shift 2
            else
                error "Invalid size format. Use WIDTHxHEIGHT (e.g., 120x40)"
                exit 1
            fi
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
    log "Starting ztop with '$CURRENT_LAYOUT' layout..."
    
    # Set up trap for cleanup
    trap cleanup EXIT INT TERM
    
    check_dependencies
    manage_session
    create_session
    configure_tmux
    launch_tools
    
    log "Session ready! Use Ctrl+B then d to detach"
    tmux attach-session -t "$SESSION_NAME"
}

# Run main function
main "$@"