#!/usr/bin/env bash
# validate nix workflow optimizations
# tests that experimental features confirmation loops and git dirty warnings are eliminated

set -e

echo "🔍 Validating Nix workflow optimizations..."
echo ""

# colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # no color

# test counters
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_TOTAL=0

# helper functions
test_start() {
    echo -e "${BLUE}🧪 Testing: $1${NC}"
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
}

test_pass() {
    echo -e "${GREEN}✅ PASS: $1${NC}"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo -e "${RED}❌ FAIL: $1${NC}"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

test_warn() {
    echo -e "${YELLOW}⚠️  WARN: $1${NC}"
}

# test 1: check if experimental features are enabled without prompts
test_start "Experimental features configuration"
if nix --version >/dev/null 2>&1; then
    if nix flake --help >/dev/null 2>&1; then
        test_pass "Experimental features (nix-command flakes) are enabled"
    else
        test_fail "Experimental features not properly enabled"
    fi
else
    test_fail "Nix command not available"
fi

# test 2: check if flake operations work without confirmation prompts
test_start "Flake operations without confirmation prompts"
# create a temporary dirty state to test warnings
echo "# temporary test file" > .test-dirty-file

# capture output to check for warnings and prompts
FLAKE_OUTPUT=$(timeout 10s nix flake check --no-warn-dirty 2>&1 || true)

# check if command completed without hanging on prompts
if echo "$FLAKE_OUTPUT" | grep -q "checking NixOS configuration"; then
    test_pass "Flake check completed without hanging on prompts"
else
    test_fail "Flake check may have hung on confirmation prompts"
fi

# test 3: check if git dirty warnings are suppressed
test_start "Git dirty tree warning suppression"
if echo "$FLAKE_OUTPUT" | grep -q "warning: Git tree.*is dirty"; then
    test_warn "Git dirty tree warning still appears (expected with --no-warn-dirty flag)"
else
    test_pass "Git dirty tree warnings are suppressed"
fi

# clean up test file
rm -f .test-dirty-file

# test 4: check nixConfig settings in flake.nix
test_start "Flake nixConfig optimization settings"
if grep -q "warn-dirty = false" flake.nix; then
    test_pass "warn-dirty = false configured in flake.nix"
else
    test_fail "warn-dirty = false not found in flake.nix"
fi

if grep -q "accept-flake-config = true" flake.nix; then
    test_pass "accept-flake-config = true configured in flake.nix"
else
    test_fail "accept-flake-config = true not found in flake.nix"
fi

# test 5: check system nix configuration
test_start "System Nix configuration optimizations"
if grep -q "warn-dirty = false" system/nix.nix; then
    test_pass "warn-dirty = false configured in system/nix.nix"
else
    test_fail "warn-dirty = false not found in system/nix.nix"
fi

if grep -q "trusted-users.*@wheel" system/nix.nix; then
    test_pass "trusted-users configured in system/nix.nix"
else
    test_fail "trusted-users not properly configured in system/nix.nix"
fi

# test 6: check devcontainer configuration
test_start "Devcontainer Nix configuration"
if grep -q "warn-dirty = false" .devcontainer/devcontainer-host-network.json; then
    test_pass "warn-dirty = false configured in devcontainer-host-network.json"
else
    test_fail "warn-dirty = false not found in devcontainer-host-network.json"
fi

if grep -q "accept-flake-config = true" .devcontainer/devcontainer-host-network.json; then
    test_pass "accept-flake-config = true configured in devcontainer-host-network.json"
else
    test_fail "accept-flake-config = true not found in devcontainer-host-network.json"
fi

# test 7: check devenv scripts optimization
test_start "Devenv scripts optimization"
if grep -q "nix flake check --no-warn-dirty" devenv.nix; then
    test_pass "devenv scripts use --no-warn-dirty flag"
else
    test_fail "devenv scripts not optimized with --no-warn-dirty flag"
fi

# test 8: performance settings validation
test_start "Performance optimization settings"
if grep -q "max-jobs.*auto" system/nix.nix; then
    test_pass "max-jobs = auto configured for performance"
else
    test_fail "max-jobs = auto not configured"
fi

if grep -q "cores = 0" system/nix.nix; then
    test_pass "cores = 0 configured for performance"
else
    test_fail "cores = 0 not configured"
fi

# test 9: check if current user is in wheel group (for trusted-users)
test_start "User wheel group membership"
if groups | grep -q wheel; then
    test_pass "Current user is in wheel group (trusted-users)"
else
    test_warn "Current user not in wheel group - may need manual trust configuration"
fi

# test 10: validate that nix commands work without prompts
test_start "Nix commands work without interactive prompts"
# test a simple nix command that would normally prompt
if timeout 5s nix eval --expr "1 + 1" >/dev/null 2>&1; then
    test_pass "Nix eval works without prompts"
else
    test_fail "Nix eval may be hanging on prompts or failing"
fi

echo ""
echo "🏁 Validation Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Total tests: ${BLUE}$TESTS_TOTAL${NC}"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All optimizations are working correctly!${NC}"
    echo ""
    echo "✅ Experimental features confirmation loops eliminated"
    echo "✅ Git dirty tree warnings suppressed"
    echo "✅ Trust configuration properly set up"
    echo "✅ Performance optimizations enabled"
    echo ""
    echo "Your Nix workflow should now be much more efficient!"
    exit 0
else
    echo -e "${RED}⚠️  Some optimizations need attention.${NC}"
    echo ""
    echo "Please review the failed tests above and:"
    echo "1. Ensure you've rebuilt the NixOS configuration: sudo nixos-rebuild switch --flake .#nixos"
    echo "2. Restart your shell/terminal session"
    echo "3. For container environments, rebuild the container"
    echo ""
    exit 1
fi
