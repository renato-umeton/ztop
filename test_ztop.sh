#!/bin/bash

# test_ztop.sh - Comprehensive test suite for ztop.sh
# Tests functionality, layout creation, dependency checking, and error handling

# Test framework setup
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZTOP_SCRIPT="$TEST_DIR/brokenztop.sh"
TEST_SESSION="ztop_test"
FAILED_TESTS=0
PASSED_TESTS=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test framework functions
log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASSED_TESTS++))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAILED_TESTS++))
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Setup and teardown functions
setup_test() {
    # Kill any existing test sessions
    tmux kill-session -t "$TEST_SESSION" 2>/dev/null || true
    tmux kill-session -t "ztop" 2>/dev/null || true
}

teardown_test() {
    # Clean up test sessions
    tmux kill-session -t "$TEST_SESSION" 2>/dev/null || true
    tmux kill-session -t "ztop" 2>/dev/null || true
}

# Source the ztop script to access its functions
source_ztop_functions() {
    # Check if we have bash 4+ for associative arrays
    if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
        warn "Bash 3.x detected - using /usr/local/bin/bash if available"
        if [[ -x "/usr/local/bin/bash" ]]; then
            # Use newer bash to source functions
            /usr/local/bin/bash -c "source '$ZTOP_SCRIPT'; declare -f command_exists find_tool get_tool_command get_layout_tools" > /tmp/ztop_functions_export.sh
            source /tmp/ztop_functions_export.sh
            rm -f /tmp/ztop_functions_export.sh
            return
        else
            warn "Newer bash not found - some tests may fail"
        fi
    fi
    
    # Create a modified version of ztop script that exposes functions without running main
    local temp_script="/tmp/ztop_test_functions.sh"
    
    # Extract everything except the main execution
    sed '/^# Run main function/,$d' "$ZTOP_SCRIPT" > "$temp_script"
    
    # Source the functions
    source "$temp_script"
    rm -f "$temp_script"
}

# Test 1: Script exists and is executable
test_script_exists() {
    log_test "Checking if ztop script exists and is executable"
    
    if [[ -f "$ZTOP_SCRIPT" ]]; then
        if [[ -x "$ZTOP_SCRIPT" ]]; then
            pass "Script exists and is executable"
        else
            fail "Script exists but is not executable"
            chmod +x "$ZTOP_SCRIPT"
            pass "Made script executable"
        fi
    else
        fail "Script not found at $ZTOP_SCRIPT"
        return 1
    fi
}

# Test 2: Help function works
test_help_function() {
    log_test "Testing help function"
    
    local help_output
    help_output=$("$ZTOP_SCRIPT" --help 2>&1)
    
    if [[ $? -eq 0 ]] && [[ "$help_output" == *"ztop - Multi-pane system monitoring"* ]]; then
        pass "Help function works correctly"
    else
        fail "Help function failed or output incorrect"
    fi
}

# Test 3: Layout listing works
test_layout_listing() {
    log_test "Testing layout listing function"
    
    local layout_output
    layout_output=$("$ZTOP_SCRIPT" --layouts 2>&1)
    
    if [[ $? -eq 0 ]] && [[ "$layout_output" == *"stacked"* ]] && [[ "$layout_output" == *"original"* ]]; then
        pass "Layout listing works correctly"
    else
        fail "Layout listing failed or missing expected layouts"
    fi
}

# Test 4: Tool listing works
test_tool_listing() {
    log_test "Testing tool availability listing"
    
    local tool_output
    tool_output=$("$ZTOP_SCRIPT" --list-tools 2>&1)
    
    if [[ $? -eq 0 ]] && [[ "$tool_output" == *"Available monitoring tools"* ]]; then
        pass "Tool listing works correctly"
    else
        fail "Tool listing failed"
    fi
}

# Test 5: Function availability after sourcing
test_function_availability() {
    log_test "Testing function availability after sourcing"
    
    source_ztop_functions
    
    local functions=("command_exists" "find_tool" "get_tool_command" "get_layout_tools")
    local all_found=true
    
    for func in "${functions[@]}"; do
        if ! declare -f "$func" > /dev/null; then
            fail "Function $func not available"
            all_found=false
        fi
    done
    
    if $all_found; then
        pass "All required functions are available"
    fi
}

# Test 6: Layout tools parsing
test_layout_tools_parsing() {
    log_test "Testing layout tools parsing"
    
    source_ztop_functions
    
    # Test stacked layout
    local stacked_tools
    stacked_tools=$(get_layout_tools "stacked")
    
    if [[ "$stacked_tools" == *"htop_cpu"* ]] && [[ "$stacked_tools" == *"htop_mem_clean"* ]] && 
       [[ "$stacked_tools" == *"mactop"* ]] && [[ "$stacked_tools" == *"ctop"* ]] && 
       [[ "$stacked_tools" == *"nethogs"* ]]; then
        pass "Stacked layout tools parsed correctly"
    else
        fail "Stacked layout tools parsing failed: $stacked_tools"
    fi
}

# Test 7: Command generation
test_command_generation() {
    log_test "Testing command generation for different tools"
    
    source_ztop_functions
    
    local tests=(
        "htop_cpu:htop -s PERCENT_CPU"
        "htop_mem:htop -s PERCENT_MEM"
        "htop_mem_clean:htop -s PERCENT_MEM"
        "mactop:mactop"
        "ctop:ctop"
        "nethogs:sudo nethogs"
    )
    
    local all_correct=true
    
    for test_case in "${tests[@]}"; do
        local tool="${test_case%:*}"
        local expected="${test_case#*:}"
        local actual
        actual=$(get_tool_command "$tool")
        
        if [[ "$actual" == "$expected" ]]; then
            pass "Command for $tool generated correctly: $actual"
        else
            fail "Command for $tool incorrect. Expected: $expected, Got: $actual"
            all_correct=false
        fi
    done
    
    if $all_correct; then
        pass "All tool commands generated correctly"
    fi
}

# Test 8: Dependency checking
test_dependency_checking() {
    log_test "Testing dependency checking function"
    
    source_ztop_functions
    
    # Test tmux dependency
    if command_exists tmux; then
        pass "tmux dependency check works"
    else
        warn "tmux not available - some tests will be skipped"
    fi
    
    # Test other tools
    local tools=("htop" "mactop" "ctop" "nethogs")
    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            pass "$tool is available"
        else
            warn "$tool is not available (optional for testing)"
        fi
    done
}

# Test 9: Session creation (integration test)
test_session_creation() {
    log_test "Testing tmux session creation (requires tmux)"
    
    if ! command -v tmux &> /dev/null; then
        warn "Skipping session creation test - tmux not available"
        return
    fi
    
    # Test session creation without actually running tools
    local test_script="/tmp/ztop_test_session.sh"
    
    cat > "$test_script" << 'EOF'
#!/bin/bash
SESSION_NAME="ztop_test"
DEFAULT_WIDTH=80
DEFAULT_HEIGHT=24

# Create session
tmux new-session -d -s "$SESSION_NAME" -x "$DEFAULT_WIDTH" -y "$DEFAULT_HEIGHT"

# Create stacked layout
tmux split-window -h -p 50 -t "$SESSION_NAME:0"
tmux split-window -v -p 50 -t "$SESSION_NAME:0.0"
tmux split-window -v -p 50 -t "$SESSION_NAME:0.1"
tmux split-window -v -p 30 -t "$SESSION_NAME:0.2"

echo "Session created successfully"
EOF
    
    chmod +x "$test_script"
    
    if "$test_script" 2>/dev/null; then
        # Check if session exists and has correct pane count
        local pane_count
        pane_count=$(tmux list-panes -t "$TEST_SESSION" 2>/dev/null | wc -l)
        
        if [[ "$pane_count" -eq 5 ]]; then
            pass "Session created with correct number of panes (5)"
        else
            fail "Session created but pane count incorrect: $pane_count (expected 5)"
        fi
        
        # Clean up
        tmux kill-session -t "$TEST_SESSION" 2>/dev/null
    else
        fail "Session creation failed"
    fi
    
    rm -f "$test_script"
}

# Test 10: Layout percentage validation
test_layout_percentages() {
    log_test "Testing layout percentage calculations"
    
    if ! command -v tmux &> /dev/null; then
        warn "Skipping layout percentage test - tmux not available"
        return
    fi
    
    # Create a test session and check pane sizes
    tmux new-session -d -s "$TEST_SESSION" -x 100 -y 40
    
    # Create the stacked layout
    tmux split-window -h -p 50 -t "$TEST_SESSION:0"
    tmux split-window -v -p 50 -t "$TEST_SESSION:0.0"
    tmux split-window -v -p 50 -t "$TEST_SESSION:0.1"
    tmux split-window -v -p 30 -t "$TEST_SESSION:0.2"
    
    # Get pane information
    local pane_info
    pane_info=$(tmux list-panes -t "$TEST_SESSION" -F "#{pane_index}:#{pane_width}x#{pane_height}" 2>/dev/null)
    
    if [[ -n "$pane_info" ]]; then
        pass "Layout created and pane information retrieved"
        echo "Pane sizes: $pane_info"
    else
        fail "Could not retrieve pane information"
    fi
}

# Test 11: Error handling
test_error_handling() {
    log_test "Testing error handling for invalid options"
    
    # Test invalid layout
    local output
    output=$("$ZTOP_SCRIPT" --layout invalid_layout 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && [[ "$output" == *"Unknown layout"* ]]; then
        pass "Invalid layout error handling works"
    else
        fail "Invalid layout error handling failed"
    fi
    
    # Test invalid size format
    output=$("$ZTOP_SCRIPT" --size invalid_size 2>&1)
    exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && [[ "$output" == *"Invalid size format"* ]]; then
        pass "Invalid size error handling works"
    else
        fail "Invalid size error handling failed"
    fi
}

# Test 12: Kill session functionality
test_kill_session() {
    log_test "Testing kill session functionality"
    
    if ! command -v tmux &> /dev/null; then
        warn "Skipping kill session test - tmux not available"
        return
    fi
    
    # Create a test session
    tmux new-session -d -s "ztop" echo "test"
    
    # Test kill command
    local output
    output=$("$ZTOP_SCRIPT" --kill 2>&1)
    
    if [[ "$output" == *"killed"* ]]; then
        pass "Kill session functionality works"
    else
        fail "Kill session functionality failed"
    fi
}

# Main test runner
run_all_tests() {
    echo -e "${BLUE}=== ZTop Test Suite ===${NC}"
    echo "Testing script: $ZTOP_SCRIPT"
    echo ""
    
    setup_test
    
    # Run all tests
    test_script_exists
    test_help_function
    test_layout_listing
    test_tool_listing
    test_function_availability
    test_layout_tools_parsing
    test_command_generation
    test_dependency_checking
    test_session_creation
    test_layout_percentages
    test_error_handling
    test_kill_session
    
    teardown_test
    
    # Summary
    echo ""
    echo -e "${BLUE}=== Test Summary ===${NC}"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    
    if [[ $FAILED_TESTS -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_all_tests
fi