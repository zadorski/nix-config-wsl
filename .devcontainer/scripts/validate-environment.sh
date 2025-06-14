#!/usr/bin/env bash
# Comprehensive environment validation script using Nix-based testing
# Validates functionality of development environment setup

set -euo pipefail

echo "🧪 Validating Development Environment"
echo "====================================="

# test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_WARNINGS=0

# logging functions
log_test() {
    echo "🔍 Testing: $1"
}

log_pass() {
    echo "   ✅ $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

log_fail() {
    echo "   ❌ $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

log_warn() {
    echo "   ⚠️  $1"
    TESTS_WARNINGS=$((TESTS_WARNINGS + 1))
}

# Test 1: Nix Environment
log_test "Nix Package Manager"
if command -v nix >/dev/null 2>&1; then
    NIX_VERSION=$(nix --version)
    log_pass "Nix is available: $NIX_VERSION"
    
    # test nix flakes support
    if nix flake --help >/dev/null 2>&1; then
        log_pass "Nix flakes support enabled"
    else
        log_fail "Nix flakes support not available"
    fi
    
    # test nix store access
    if nix-store --version >/dev/null 2>&1; then
        log_pass "Nix store accessible"
    else
        log_warn "Nix store access issues"
    fi
else
    log_fail "Nix is not available"
fi

# Test 2: Essential Development Tools
log_test "Development Tools"

ESSENTIAL_TOOLS=("git" "curl" "wget" "jq" "tree")
for tool in "${ESSENTIAL_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        log_pass "$tool is available"
    else
        log_fail "$tool is not available"
    fi
done

# Test 3: Nix-specific Development Tools
log_test "Nix Development Tools"

NIX_TOOLS=("nil" "nixfmt" "nix-tree")
for tool in "${NIX_TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        log_pass "$tool is available"
    else
        log_warn "$tool is not available (may be installed via home-manager)"
    fi
done

# Test 4: Shell Configuration
log_test "Shell Configuration"

CURRENT_SHELL=$(echo $SHELL)
USER_SHELL=$(getent passwd vscode | cut -d: -f7)

echo "   Current \$SHELL: $CURRENT_SHELL"
echo "   User shell: $USER_SHELL"

if [[ "$USER_SHELL" == *"fish"* ]]; then
    log_pass "Fish is configured as default shell"
    
    # test fish functionality
    if command -v fish >/dev/null 2>&1; then
        log_pass "Fish is installed and available"
        
        # test fish configuration
        if fish -c 'test -f ~/.config/fish/config.fish'; then
            log_pass "Fish configuration file exists"
        else
            log_warn "Fish configuration file missing (may be managed by home-manager)"
        fi
        
        # test fish abbreviations
        if fish -c 'abbr -l | grep -q "g"' 2>/dev/null; then
            log_pass "Fish abbreviations configured"
        else
            log_warn "Fish abbreviations not found (may be normal)"
        fi
    else
        log_fail "Fish is not installed"
    fi
else
    log_warn "Fish is not configured as default shell"
fi

# Test 5: SSH Configuration and Agent Forwarding
log_test "SSH Configuration"

if [ -n "${SSH_AUTH_SOCK:-}" ]; then
    log_pass "SSH_AUTH_SOCK is set: $SSH_AUTH_SOCK"
    
    if [ -S "$SSH_AUTH_SOCK" ]; then
        log_pass "SSH agent socket exists"
        
        # test SSH agent
        if ssh-add -l >/dev/null 2>&1; then
            KEY_COUNT=$(ssh-add -l | wc -l)
            log_pass "SSH agent has $KEY_COUNT key(s) loaded"
        else
            log_warn "SSH agent has no keys loaded (may be normal)"
        fi
    else
        log_fail "SSH agent socket does not exist"
    fi
else
    log_warn "SSH_AUTH_SOCK not set (SSH agent forwarding not available)"
fi

# test SSH configuration file
if [ -f ~/.ssh/config ]; then
    log_pass "SSH config file exists"
    
    # check for GitHub configuration
    if grep -q "github.com" ~/.ssh/config; then
        log_pass "GitHub SSH configuration found"
    else
        log_warn "GitHub SSH configuration not found"
    fi
else
    log_warn "SSH config file missing"
fi

# Test 6: Git Configuration
log_test "Git Configuration"

if command -v git >/dev/null 2>&1; then
    GIT_VERSION=$(git --version)
    log_pass "Git is available: $GIT_VERSION"
    
    GIT_USER=$(git config --global user.name 2>/dev/null || echo "not set")
    GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "not set")
    
    echo "   Git user.name: $GIT_USER"
    echo "   Git user.email: $GIT_EMAIL"
    
    if [ "$GIT_USER" != "not set" ] && [ "$GIT_EMAIL" != "not set" ]; then
        log_pass "Git user configuration is set"
    else
        log_warn "Git user configuration incomplete"
    fi
    
    # test git safe directory configuration
    if git config --global --get-all safe.directory | grep -q "/workspaces" 2>/dev/null; then
        log_pass "Git safe directory configured for workspaces"
    else
        log_warn "Git safe directory not configured"
    fi
else
    log_fail "Git is not available"
fi

# Test 7: Certificate Configuration
log_test "Certificate Configuration"

# check system certificate store
if [ -f /etc/ssl/certs/ca-certificates.crt ]; then
    log_pass "System certificate store exists"
    
    CERT_COUNT=$(grep -c "BEGIN CERTIFICATE" /etc/ssl/certs/ca-certificates.crt 2>/dev/null || echo "0")
    log_pass "Certificate store contains $CERT_COUNT certificates"
else
    log_fail "System certificate store missing"
fi

# check corporate certificates
CORPORATE_CERTS=$(ls -1 /usr/local/share/ca-certificates/ 2>/dev/null | wc -l)
if [ "$CORPORATE_CERTS" -gt 0 ]; then
    log_pass "Corporate certificates installed: $CORPORATE_CERTS"
else
    log_warn "No corporate certificates found (normal for non-corporate environments)"
fi

# test HTTPS connectivity
if curl -s --max-time 10 https://github.com >/dev/null 2>&1; then
    log_pass "HTTPS connectivity test passed"
else
    log_warn "HTTPS connectivity test failed"
fi

# Test 8: Environment Variables
log_test "Environment Variables"

REQUIRED_ENV_VARS=("EDITOR" "VISUAL" "PAGER")
for var in "${REQUIRED_ENV_VARS[@]}"; do
    if [ -n "${!var:-}" ]; then
        log_pass "$var is set: ${!var}"
    else
        log_warn "$var is not set"
    fi
done

# test certificate environment variables
CERT_ENV_VARS=("SSL_CERT_FILE" "NIX_SSL_CERT_FILE" "CURL_CA_BUNDLE")
for var in "${CERT_ENV_VARS[@]}"; do
    if [ -n "${!var:-}" ]; then
        log_pass "$var is set: ${!var}"
    else
        log_warn "$var is not set"
    fi
done

# Test 9: File Permissions
log_test "File Permissions"

if [ -d ~/.ssh ]; then
    SSH_PERMS=$(stat -c %a ~/.ssh)
    if [ "$SSH_PERMS" = "700" ]; then
        log_pass "SSH directory permissions correct (700)"
    else
        log_warn "SSH directory permissions: $SSH_PERMS (should be 700)"
    fi
fi

# Test 10: Home Manager (if available)
log_test "Home Manager"

if command -v home-manager >/dev/null 2>&1; then
    HM_VERSION=$(home-manager --version 2>/dev/null || echo "unknown")
    log_pass "Home Manager is available: $HM_VERSION"
    
    # check if home-manager configuration exists
    if [ -f ~/.config/home-manager/home.nix ]; then
        log_pass "Home Manager configuration exists"
    else
        log_warn "Home Manager configuration missing"
    fi
else
    log_warn "Home Manager is not available"
fi

# Summary
echo ""
echo "🎯 Validation Summary"
echo "===================="
echo "✅ Tests Passed: $TESTS_PASSED"
echo "❌ Tests Failed: $TESTS_FAILED"
echo "⚠️  Warnings: $TESTS_WARNINGS"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "🎉 Environment validation completed successfully!"
    echo ""
    echo "Next Steps:"
    echo "1. Open a new terminal to use fish shell"
    echo "2. Test SSH access: ssh -T git@github.com"
    echo "3. Test Git operations: git clone <repo>"
    echo "4. Start development work"
else
    echo "⚠️  Environment validation completed with $TESTS_FAILED failures"
    echo ""
    echo "Troubleshooting:"
    echo "1. Check the failed tests above"
    echo "2. Run setup script again: ~/.devcontainer-scripts/setup-environment.sh"
    echo "3. Check logs for detailed error messages"
fi

echo ""
echo "For additional help, see .devcontainer/README.md"

# exit with appropriate code
if [ $TESTS_FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi
