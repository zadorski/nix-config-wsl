#!/usr/bin/env bash
# XDG Base Directory Specification compliance validation script
# validates that all tools and configurations follow XDG standards

set -euo pipefail

# colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # no color

# test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNED=0

# helper functions
test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((TESTS_PASSED++))
}

test_fail() {
    echo -e "${RED}✗${NC} $1"
    ((TESTS_FAILED++))
}

test_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((TESTS_WARNED++))
}

test_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# check if directory exists
dir_exists() {
    [ -d "$1" ]
}

# check if file exists
file_exists() {
    [ -f "$1" ]
}

# check if environment variable is set
env_var_set() {
    [ -n "${!1:-}" ]
}

echo "🔍 XDG Base Directory Specification Compliance Validation"
echo "========================================================"
echo ""

# check XDG environment variables
echo "📋 XDG Environment Variables"
echo "----------------------------"

if env_var_set XDG_CONFIG_HOME; then
    test_pass "XDG_CONFIG_HOME is set: $XDG_CONFIG_HOME"
    if dir_exists "$XDG_CONFIG_HOME"; then
        test_pass "XDG_CONFIG_HOME directory exists"
    else
        test_fail "XDG_CONFIG_HOME directory does not exist"
    fi
else
    test_fail "XDG_CONFIG_HOME is not set"
    XDG_CONFIG_HOME="$HOME/.config"
    test_info "Using default: $XDG_CONFIG_HOME"
fi

if env_var_set XDG_DATA_HOME; then
    test_pass "XDG_DATA_HOME is set: $XDG_DATA_HOME"
    if dir_exists "$XDG_DATA_HOME"; then
        test_pass "XDG_DATA_HOME directory exists"
    else
        test_fail "XDG_DATA_HOME directory does not exist"
    fi
else
    test_fail "XDG_DATA_HOME is not set"
    XDG_DATA_HOME="$HOME/.local/share"
    test_info "Using default: $XDG_DATA_HOME"
fi

if env_var_set XDG_STATE_HOME; then
    test_pass "XDG_STATE_HOME is set: $XDG_STATE_HOME"
    if dir_exists "$XDG_STATE_HOME"; then
        test_pass "XDG_STATE_HOME directory exists"
    else
        test_fail "XDG_STATE_HOME directory does not exist"
    fi
else
    test_fail "XDG_STATE_HOME is not set"
    XDG_STATE_HOME="$HOME/.local/state"
    test_info "Using default: $XDG_STATE_HOME"
fi

if env_var_set XDG_CACHE_HOME; then
    test_pass "XDG_CACHE_HOME is set: $XDG_CACHE_HOME"
    if dir_exists "$XDG_CACHE_HOME"; then
        test_pass "XDG_CACHE_HOME directory exists"
    else
        test_fail "XDG_CACHE_HOME directory does not exist"
    fi
else
    test_fail "XDG_CACHE_HOME is not set"
    XDG_CACHE_HOME="$HOME/.cache"
    test_info "Using default: $XDG_CACHE_HOME"
fi

if env_var_set XDG_RUNTIME_DIR; then
    test_pass "XDG_RUNTIME_DIR is set: $XDG_RUNTIME_DIR"
    if dir_exists "$XDG_RUNTIME_DIR"; then
        test_pass "XDG_RUNTIME_DIR directory exists"
        # check permissions (should be 700)
        PERMS=$(stat -c "%a" "$XDG_RUNTIME_DIR" 2>/dev/null || echo "unknown")
        if [ "$PERMS" = "700" ]; then
            test_pass "XDG_RUNTIME_DIR has correct permissions (700)"
        else
            test_warn "XDG_RUNTIME_DIR permissions: $PERMS (should be 700)"
        fi
    else
        test_warn "XDG_RUNTIME_DIR directory does not exist"
    fi
else
    test_warn "XDG_RUNTIME_DIR is not set (may be handled by systemd)"
fi

echo ""

# check XDG directory structure
echo "📁 XDG Directory Structure"
echo "--------------------------"

# essential XDG directories
xdg_dirs=(
    "$XDG_CONFIG_HOME"
    "$XDG_DATA_HOME"
    "$XDG_STATE_HOME"
    "$XDG_CACHE_HOME"
    "$XDG_DATA_HOME/applications"
    "$XDG_DATA_HOME/fonts"
    "$HOME/.local/bin"
)

for dir in "${xdg_dirs[@]}"; do
    if dir_exists "$dir"; then
        test_pass "Directory exists: $dir"
    else
        test_fail "Directory missing: $dir"
    fi
done

echo ""

# check tool-specific XDG compliance
echo "🔧 Tool-Specific XDG Compliance"
echo "-------------------------------"

# git - native XDG support
if command_exists git; then
    if file_exists "$XDG_CONFIG_HOME/git/config" || git config --global --list >/dev/null 2>&1; then
        test_pass "Git: Using XDG configuration"
        
        # check for legacy files
        if file_exists "$HOME/.gitconfig"; then
            test_warn "Git: Legacy ~/.gitconfig exists (consider migrating)"
        fi
    else
        test_fail "Git: No XDG configuration found"
    fi
else
    test_info "Git: Not installed"
fi

# fish shell - native XDG support
if command_exists fish; then
    if dir_exists "$XDG_CONFIG_HOME/fish"; then
        test_pass "Fish: Using XDG configuration directory"
    else
        test_fail "Fish: XDG configuration directory not found"
    fi
else
    test_info "Fish: Not installed"
fi

# starship - native XDG support
if command_exists starship; then
    if file_exists "$XDG_CONFIG_HOME/starship.toml"; then
        test_pass "Starship: Using XDG configuration file"
    else
        test_warn "Starship: XDG configuration file not found"
    fi
else
    test_info "Starship: Not installed"
fi

# bash history
if command_exists bash; then
    if env_var_set HISTFILE; then
        if [[ "$HISTFILE" == *"$XDG_STATE_HOME"* ]] || [[ "$HISTFILE" == *".local/state"* ]]; then
            test_pass "Bash: Using XDG-compliant history location"
        else
            test_warn "Bash: History file not in XDG location: $HISTFILE"
        fi
    else
        test_warn "Bash: HISTFILE not set"
    fi
fi

# btop - native XDG support
if command_exists btop; then
    if dir_exists "$XDG_CONFIG_HOME/btop"; then
        test_pass "Btop: Using XDG configuration directory"
    else
        test_warn "Btop: XDG configuration directory not found"
    fi
else
    test_info "Btop: Not installed"
fi

# htop - native XDG support  
if command_exists htop; then
    if file_exists "$XDG_CONFIG_HOME/htop/htoprc"; then
        test_pass "Htop: Using XDG configuration file"
    else
        test_warn "Htop: XDG configuration file not found"
    fi
else
    test_info "Htop: Not installed"
fi

# bat - native XDG support
if command_exists bat; then
    if dir_exists "$XDG_CONFIG_HOME/bat"; then
        test_pass "Bat: Using XDG configuration directory"
    else
        test_warn "Bat: XDG configuration directory not found"
    fi
else
    test_info "Bat: Not installed"
fi

# direnv - native XDG support
if command_exists direnv; then
    if dir_exists "$XDG_CONFIG_HOME/direnv"; then
        test_pass "Direnv: Using XDG configuration directory"
    else
        test_warn "Direnv: XDG configuration directory not found"
    fi
else
    test_info "Direnv: Not installed"
fi

echo ""

# check for common XDG violations in home directory
echo "🏠 Home Directory Cleanliness Check"
echo "----------------------------------"

# common dotfiles that should be moved to XDG directories
legacy_files=(
    ".gitconfig"
    ".bashrc"
    ".bash_history"
    ".vimrc"
    ".tmux.conf"
    ".zshrc"
    ".profile"
)

violations_found=false
for file in "${legacy_files[@]}"; do
    if file_exists "$HOME/$file"; then
        test_warn "Legacy file found: ~/$file (consider XDG migration)"
        violations_found=true
    fi
done

if ! $violations_found; then
    test_pass "No common XDG violations found in home directory"
fi

# check for unexpected directories in home
unexpected_dirs=(
    ".config"  # should exist
    ".local"   # should exist  
    ".cache"   # should exist
    ".npm"
    ".cargo"
    ".rustup"
    ".go"
    ".python"
)

for dir in "${unexpected_dirs[@]}"; do
    if [[ "$dir" == ".config" ]] || [[ "$dir" == ".local" ]] || [[ "$dir" == ".cache" ]]; then
        continue  # these should exist
    fi
    
    if dir_exists "$HOME/$dir"; then
        test_warn "Non-XDG directory found: ~/$dir (consider migration)"
    fi
done

echo ""

# development environment specific checks
echo "🛠️  Development Environment XDG Compliance"
echo "-------------------------------------------"

# devenv cache location
if env_var_set DEVENV_ROOT; then
    if [[ "$DEVENV_ROOT" == *"$XDG_CACHE_HOME"* ]] || [[ "$DEVENV_ROOT" == *".cache"* ]]; then
        test_pass "DevEnv: Using XDG cache location"
    else
        test_warn "DevEnv: Not using XDG cache location: $DEVENV_ROOT"
    fi
else
    test_info "DevEnv: DEVENV_ROOT not set"
fi

# python user base
if env_var_set PYTHONUSERBASE; then
    if [[ "$PYTHONUSERBASE" == *".local"* ]]; then
        test_pass "Python: Using XDG-compliant user base"
    else
        test_warn "Python: User base not XDG-compliant: $PYTHONUSERBASE"
    fi
else
    test_info "Python: PYTHONUSERBASE not set"
fi

# npm configuration
if env_var_set NPM_CONFIG_USERCONFIG; then
    if [[ "$NPM_CONFIG_USERCONFIG" == *"$XDG_CONFIG_HOME"* ]] || [[ "$NPM_CONFIG_USERCONFIG" == *".config"* ]]; then
        test_pass "NPM: Using XDG configuration location"
    else
        test_warn "NPM: Configuration not in XDG location: $NPM_CONFIG_USERCONFIG"
    fi
else
    test_info "NPM: NPM_CONFIG_USERCONFIG not set"
fi

echo ""

# summary
echo "📊 Validation Summary"
echo "--------------------"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"
echo -e "Warnings: ${YELLOW}$TESTS_WARNED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    if [ $TESTS_WARNED -eq 0 ]; then
        echo -e "${GREEN}🎉 Perfect XDG compliance!${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠️  XDG compliance with warnings${NC}"
        exit 0
    fi
else
    echo -e "${RED}❌ XDG compliance issues found${NC}"
    exit 1
fi
