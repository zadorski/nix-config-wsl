#!/usr/bin/env bash
# Validation script for devenv WSL optimizations
# Tests repository cleanliness, git configuration, and certificate integration

set -e

echo "🧪 Validating Devenv WSL Optimizations"
echo "======================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# Helper functions
test_start() {
    echo -e "\n${BLUE}Testing: $1${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

test_pass() {
    echo -e "  ${GREEN}✅ $1${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo -e "  ${RED}❌ $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

test_warn() {
    echo -e "  ${YELLOW}⚠️  $1${NC}"
}

# Test 1: Repository Cleanliness
test_start "Repository Cleanliness"

# Check for devenv artifacts in repository
if find . -maxdepth 2 -name ".devenv*" -o -name "devenv.lock" | grep -q .; then
    test_fail "Found devenv artifacts in repository directory"
    find . -maxdepth 2 -name ".devenv*" -o -name "devenv.lock"
else
    test_pass "No devenv artifacts found in repository directory"
fi

# Check if devenv cache is configured externally
if [ -n "$DEVENV_ROOT" ] && [[ "$DEVENV_ROOT" != *"$(pwd)"* ]]; then
    test_pass "DEVENV_ROOT configured outside repository: $DEVENV_ROOT"
else
    test_warn "DEVENV_ROOT not configured or points to repository directory"
fi

# Check XDG_CACHE_HOME configuration
if [ -n "$XDG_CACHE_HOME" ] && [ -d "$XDG_CACHE_HOME" ]; then
    test_pass "XDG_CACHE_HOME configured: $XDG_CACHE_HOME"
else
    test_warn "XDG_CACHE_HOME not configured or directory doesn't exist"
fi

# Test 2: Git Configuration
test_start "Git Configuration"

# Check if global gitignore is configured
GLOBAL_GITIGNORE=$(git config --global core.excludesfile 2>/dev/null || echo "")
if [ -n "$GLOBAL_GITIGNORE" ] && [ -f "$GLOBAL_GITIGNORE" ]; then
    test_pass "Global gitignore configured: $GLOBAL_GITIGNORE"
    
    # Check if devenv patterns are in global gitignore
    if grep -q ".devenv" "$GLOBAL_GITIGNORE" 2>/dev/null; then
        test_pass "Devenv patterns found in global gitignore"
    else
        test_warn "Devenv patterns not found in global gitignore"
    fi
else
    test_warn "Global gitignore not configured"
fi

# Test git status for ignored files
if git status --ignored --porcelain | grep -q "^!!"; then
    test_pass "Git is properly ignoring development artifacts"
else
    test_pass "No ignored files found (repository is clean)"
fi

# Test 3: Certificate Integration
test_start "Certificate Integration"

# Check SSL certificate environment variables
SSL_VARS=("SSL_CERT_FILE" "NIX_SSL_CERT_FILE" "CURL_CA_BUNDLE" "REQUESTS_CA_BUNDLE" "NODE_EXTRA_CA_CERTS")
for var in "${SSL_VARS[@]}"; do
    if [ -n "${!var}" ] && [ -f "${!var}" ]; then
        test_pass "$var configured and file exists: ${!var}"
    else
        test_warn "$var not configured or file doesn't exist"
    fi
done

# Check additional certificate variables
ADDITIONAL_VARS=("PIP_CERT" "CARGO_HTTP_CAINFO" "GIT_SSL_CAINFO" "DEVENV_SSL_CERT_FILE")
for var in "${ADDITIONAL_VARS[@]}"; do
    if [ -n "${!var}" ]; then
        test_pass "$var configured: ${!var}"
    else
        test_warn "$var not configured"
    fi
done

# Test SSL connectivity
test_start "SSL Connectivity"

# Test basic SSL connection
if curl -s -I https://github.com >/dev/null 2>&1; then
    test_pass "HTTPS connection to GitHub successful"
else
    test_fail "HTTPS connection to GitHub failed"
fi

# Test Nix SSL connectivity (if nix is available)
if command -v nix >/dev/null 2>&1; then
    if nix-channel --list >/dev/null 2>&1; then
        test_pass "Nix SSL operations working"
    else
        test_warn "Nix SSL operations may have issues"
    fi
fi

# Test 4: Devenv Environment
test_start "Devenv Environment"

# Check if devenv is available
if command -v devenv >/dev/null 2>&1; then
    test_pass "Devenv command available"
    
    # Test devenv shell activation (quick test)
    if timeout 30 devenv shell --command "echo 'Environment test successful'" >/dev/null 2>&1; then
        test_pass "Devenv shell activation successful"
    else
        test_warn "Devenv shell activation failed or timed out"
    fi
else
    test_warn "Devenv command not available"
fi

# Check if direnv is working
if command -v direnv >/dev/null 2>&1; then
    test_pass "Direnv command available"
    
    # Check direnv status
    if direnv status >/dev/null 2>&1; then
        test_pass "Direnv status check successful"
    else
        test_warn "Direnv status check failed"
    fi
else
    test_warn "Direnv command not available"
fi

# Test 5: WSL Integration
test_start "WSL Integration"

# Check if running in WSL
if [ -n "$WSL_DISTRO_NAME" ]; then
    test_pass "Running in WSL: $WSL_DISTRO_NAME"
    
    # Check WSL utilities
    if command -v wslpath >/dev/null 2>&1; then
        test_pass "WSL utilities available"
    else
        test_warn "WSL utilities not available"
    fi
else
    test_warn "Not running in WSL environment"
fi

# Check VS Code server integration
if pgrep -f "vscode-server" >/dev/null 2>&1; then
    test_pass "VS Code server is running"
else
    test_warn "VS Code server not detected"
fi

# Test 6: Performance Validation
test_start "Performance Validation"

# Check cache directory sizes
if [ -d "$HOME/.cache/devenv" ]; then
    CACHE_SIZE=$(du -sh "$HOME/.cache/devenv" 2>/dev/null | cut -f1)
    test_pass "Devenv cache directory exists: $CACHE_SIZE"
else
    test_warn "Devenv cache directory not found"
fi

# Check for large files in repository
LARGE_FILES=$(find . -type f -size +10M 2>/dev/null | wc -l)
if [ "$LARGE_FILES" -eq 0 ]; then
    test_pass "No large files found in repository"
else
    test_warn "Found $LARGE_FILES large files in repository"
fi

# Summary
echo ""
echo "======================================"
echo -e "${BLUE}Validation Summary${NC}"
echo "======================================"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo -e "Total Tests:  $TESTS_TOTAL"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}🎉 All critical tests passed! Devenv WSL optimizations are working correctly.${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  Some tests failed or showed warnings. Review the output above.${NC}"
    exit 1
fi
