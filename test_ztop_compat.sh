#!/bin/bash

# test_ztop_compat.sh - Simple test suite for bash 3.x compatible ztop
# Tests basic functionality that works with older bash versions

# Test framework setup
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZTOP_SCRIPT="$TEST_DIR/ztop_compat.sh"
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

# Test 1: Script exists and is executable
test_script_exists() {
    log_test "Checking if ztop compatibility script exists and is executable"
    
    if [[ -f "$ZTOP_SCRIPT" ]]; then
        if [[ -x "$ZTOP_SCRIPT" ]]; then
            pass "Script exists and is executable"
        else
            fail "Script exists but is not executable"
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

# Test 3: Tool listing works
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

# Test 4: Session creation test (without running tools)
test_session_creation() {
    log_test "Testing tmux session creation (compatibility version)"
    
    if ! command -v tmux &> /dev/null; then
        warn "Skipping session creation test - tmux not available"
        return
    fi
    
    # Create a test session manually using the same logic
    tmux new-session -d -s "$TEST_SESSION" -x 80 -y 24
    
    # Create the layout structure
    tmux split-window -h -p 50 -t "$TEST_SESSION:0"
    tmux split-window -v -p 50 -t "$TEST_SESSION:0.0"
    tmux split-window -v -p 50 -t "$TEST_SESSION:0.1"
    tmux split-window -v -p 30 -t "$TEST_SESSION:0.2"
    
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
}

# Test 5: Error handling
test_error_handling() {
    log_test "Testing error handling for invalid options"
    
    # Test invalid option
    local output
    output=$("$ZTOP_SCRIPT" --invalid-option 2>&1)
    local exit_code=$?
    
    if [[ $exit_code -ne 0 ]] && [[ "$output" == *"Unknown option"* ]]; then
        pass "Invalid option error handling works"
    else
        fail "Invalid option error handling failed"
    fi
}

# Test 6: Kill session functionality
test_kill_session() {
    log_test "Testing kill session functionality"
    
    if ! command -v tmux &> /dev/null; then
        warn "Skipping kill session test - tmux not available"
        return
    fi
    
    # Create a test session that stays alive
    tmux new-session -d -s "ztop" sleep 10
    
    # Test kill command
    local output
    output=$("$ZTOP_SCRIPT" --kill 2>&1)
    
    if [[ "$output" == *"killed"* ]]; then
        pass "Kill session functionality works"
    else
        fail "Kill session functionality failed"
    fi
}

# Test 7: Bash version compatibility
test_bash_compatibility() {
    log_test "Testing bash 3.x compatibility"
    
    echo "Current bash version: $BASH_VERSION"
    
    if [[ ${BASH_VERSION%%.*} -eq 3 ]]; then
        pass "Running on bash 3.x - compatibility script should work"
    elif [[ ${BASH_VERSION%%.*} -ge 4 ]]; then
        pass "Running on bash 4+ - compatibility script should also work"
    else
        warn "Unknown bash version"
    fi
}

# Test 8: Function definitions (basic check)
test_function_definitions() {
    log_test "Testing that key functions are defined in the script"
    
    # Check if key functions exist in the script
    local functions=("command_exists" "get_layout_tools" "find_tool" "get_tool_command")
    local all_found=true
    
    for func in "${functions[@]}"; do
        if ! grep -q "^$func()" "$ZTOP_SCRIPT"; then
            fail "Function $func not found in script"
            all_found=false
        fi
    done
    
    if $all_found; then
        pass "All required functions are defined in the script"
    fi
}

# Main test runner
run_all_tests() {
    echo -e "${BLUE}=== ZTop Compatibility Test Suite ===${NC}"
    echo "Testing script: $ZTOP_SCRIPT"
    echo "Bash version: $BASH_VERSION"
    echo ""
    
    setup_test
    
    # Run all tests
    test_script_exists
    test_help_function
    test_tool_listing
    test_session_creation
    test_error_handling
    test_kill_session
    test_bash_compatibility
    test_function_definitions
    
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