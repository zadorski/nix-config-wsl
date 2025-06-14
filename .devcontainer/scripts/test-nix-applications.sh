#!/usr/bin/env bash
# Nix-based application testing script
# Tests functionality of applications that may not be installed yet

set -euo pipefail

echo "🧪 Testing Nix Applications and Functionality"
echo "============================================="

# source Nix environment
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    source ~/.nix-profile/etc/profile.d/nix.sh
else
    echo "❌ Nix environment not available"
    exit 1
fi

# test results tracking
TESTS_PASSED=0
TESTS_FAILED=0

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

# function to test Nix package availability and functionality
test_nix_package() {
    local package_name="$1"
    local test_command="$2"
    local description="$3"
    
    log_test "$description"
    
    # try to run the application via nix-shell
    if nix-shell -p "$package_name" --run "$test_command" >/dev/null 2>&1; then
        log_pass "$package_name works via nix-shell"
    else
        # try to install temporarily and test
        if nix-env -iA "nixpkgs.$package_name" >/dev/null 2>&1; then
            if eval "$test_command" >/dev/null 2>&1; then
                log_pass "$package_name installed and working"
                # clean up temporary installation
                nix-env -e "$package_name" >/dev/null 2>&1 || true
            else
                log_fail "$package_name installed but not working"
            fi
        else
            log_fail "$package_name not available or installation failed"
        fi
    fi
}

# Test 1: Essential Development Tools
echo "🛠️  Essential Development Tools"
echo "=============================="

test_nix_package "git" "git --version" "Git Version Control"
test_nix_package "curl" "curl --version" "Curl HTTP Client"
test_nix_package "wget" "wget --version" "Wget Downloader"
test_nix_package "jq" "jq --version" "JQ JSON Processor"
test_nix_package "tree" "tree --version" "Tree Directory Viewer"

# Test 2: Nix Development Tools
echo ""
echo "❄️  Nix Development Tools"
echo "========================"

test_nix_package "nil" "nil --version" "Nix Language Server"
test_nix_package "nixfmt-classic" "nixfmt --version" "Nix Formatter"
test_nix_package "nix-tree" "nix-tree --version" "Nix Tree Visualizer"

# Test 3: Shell and Prompt Tools
echo ""
echo "🐚 Shell and Prompt Tools"
echo "========================"

test_nix_package "fish" "fish --version" "Fish Shell"
test_nix_package "starship" "starship --version" "Starship Prompt"

# Test 4: File and Text Processing
echo ""
echo "📄 File and Text Processing"
echo "=========================="

test_nix_package "fd" "fd --version" "FD Find Alternative"
test_nix_package "ripgrep" "rg --version" "Ripgrep Search Tool"
test_nix_package "yq" "yq --version" "YQ YAML Processor"

# Test 5: Development Utilities
echo ""
echo "⚙️  Development Utilities"
echo "========================"

test_nix_package "gh" "gh --version" "GitHub CLI"
test_nix_package "just" "just --version" "Just Command Runner"
test_nix_package "pre-commit" "pre-commit --version" "Pre-commit Hooks"

# Test 6: System Monitoring Tools
echo ""
echo "📊 System Monitoring Tools"
echo "=========================="

test_nix_package "htop" "htop --version" "Htop Process Monitor"
test_nix_package "ncdu" "ncdu --version" "NCDU Disk Usage Analyzer"

# Test 7: Network Tools
echo ""
echo "🌐 Network Tools"
echo "==============="

# test network connectivity through Nix packages
log_test "Network Connectivity via Nix"
if nix-shell -p curl --run "curl -s --max-time 10 https://cache.nixos.org" >/dev/null 2>&1; then
    log_pass "Nix cache connectivity works"
else
    log_fail "Nix cache connectivity failed"
fi

if nix-shell -p wget --run "wget -q --timeout=10 -O /dev/null https://github.com" >/dev/null 2>&1; then
    log_pass "GitHub connectivity via wget works"
else
    log_fail "GitHub connectivity via wget failed"
fi

# Test 8: Nix Flake Operations
echo ""
echo "❄️  Nix Flake Operations"
echo "======================="

log_test "Nix Flake Commands"
if nix flake --help >/dev/null 2>&1; then
    log_pass "Nix flake command available"
else
    log_fail "Nix flake command not available"
fi

# test flake evaluation (if in a flake directory)
if [ -f "/workspaces/nix-config-wsl/flake.nix" ]; then
    log_test "Flake Evaluation"
    if cd /workspaces/nix-config-wsl && nix flake show >/dev/null 2>&1; then
        log_pass "Flake evaluation successful"
    else
        log_fail "Flake evaluation failed"
    fi
fi

# Test 9: Home Manager Integration
echo ""
echo "🏠 Home Manager Integration"
echo "=========================="

log_test "Home Manager Package Installation"
if nix-shell '<home-manager>' -A install --run "echo 'Home Manager available'" >/dev/null 2>&1; then
    log_pass "Home Manager installation works"
else
    log_fail "Home Manager installation failed"
fi

# Test 10: Certificate-dependent Operations
echo ""
echo "🔐 Certificate-dependent Operations"
echo "=================================="

log_test "HTTPS Operations with Certificates"
# test various HTTPS operations that depend on certificates
HTTPS_SITES=("https://github.com" "https://cache.nixos.org" "https://channels.nixos.org")

for site in "${HTTPS_SITES[@]}"; do
    if nix-shell -p curl --run "curl -s --max-time 10 '$site'" >/dev/null 2>&1; then
        log_pass "HTTPS access to $site works"
    else
        log_fail "HTTPS access to $site failed"
    fi
done

# Summary
echo ""
echo "🎯 Nix Application Testing Summary"
echo "=================================="
echo "✅ Tests Passed: $TESTS_PASSED"
echo "❌ Tests Failed: $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo "🎉 All Nix application tests passed!"
    echo "The development environment is fully functional."
else
    echo "⚠️  Some Nix application tests failed."
    echo "This may indicate package availability or network issues."
fi

echo ""
echo "💡 Note: This script tests applications via nix-shell even if not permanently installed."
echo "This validates that the Nix environment can provide all required development tools."

exit $TESTS_FAILED
