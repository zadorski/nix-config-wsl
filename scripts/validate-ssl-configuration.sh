#!/usr/bin/env bash
# comprehensive SSL certificate validation script for development environment
# validates SSL configuration across all development tools and package managers

set -euo pipefail

# color codes for output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # no color

# print colored status messages
print_status() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# test SSL connectivity to a URL
test_ssl_connectivity() {
    local url="$1"
    local tool="$2"
    local timeout="${3:-10}"
    
    case "$tool" in
        "curl")
            if curl -s --connect-timeout "$timeout" --head "$url" >/dev/null 2>&1; then
                return 0
            fi
            ;;
        "wget")
            if wget --timeout="$timeout" --spider "$url" >/dev/null 2>&1; then
                return 0
            fi
            ;;
        *)
            print_status "$RED" "Unknown tool: $tool"
            return 1
            ;;
    esac
    return 1
}

# validate certificate file exists and is readable
validate_cert_file() {
    local cert_file="$1"
    local var_name="$2"
    
    if [ -n "$cert_file" ]; then
        if [ -f "$cert_file" ]; then
            local cert_count
            cert_count=$(grep -c "BEGIN CERTIFICATE" "$cert_file" 2>/dev/null || echo "0")
            print_status "$GREEN" "  ✅ $var_name: $cert_file ($cert_count certificates)"
            return 0
        else
            print_status "$RED" "  ❌ $var_name: file not found ($cert_file)"
            return 1
        fi
    else
        print_status "$YELLOW" "  ⚠️  $var_name: not set"
        return 1
    fi
}

# test package manager SSL connectivity
test_package_manager() {
    local manager="$1"
    local test_command="$2"
    
    if command -v "$manager" >/dev/null 2>&1; then
        print_status "$BLUE" "  testing $manager SSL connectivity..."
        if timeout 30 bash -c "$test_command" >/dev/null 2>&1; then
            print_status "$GREEN" "    ✅ $manager SSL connectivity working"
            return 0
        else
            print_status "$RED" "    ❌ $manager SSL connectivity failed"
            return 1
        fi
    else
        print_status "$YELLOW" "    ⚠️  $manager not installed"
        return 0
    fi
}

echo ""
print_status "$BLUE" "🔍 SSL Certificate Configuration Validation"
print_status "$BLUE" "============================================"

# check core SSL environment variables
echo ""
print_status "$BLUE" "1. Core SSL Environment Variables"
echo "   checking essential SSL certificate variables..."

core_ssl_vars=(
    "SSL_CERT_FILE"
    "NIX_SSL_CERT_FILE" 
    "CURL_CA_BUNDLE"
)

core_valid=0
for var in "${core_ssl_vars[@]}"; do
    if validate_cert_file "${!var:-}" "$var"; then
        ((core_valid++))
    fi
done

if [ $core_valid -eq ${#core_ssl_vars[@]} ]; then
    print_status "$GREEN" "  ✅ all core SSL variables properly configured"
else
    print_status "$YELLOW" "  ⚠️  $core_valid/${#core_ssl_vars[@]} core SSL variables configured"
fi

# check language-specific SSL variables
echo ""
print_status "$BLUE" "2. Language Ecosystem SSL Variables"

# Python ecosystem
echo "   python ecosystem:"
python_vars=(
    "REQUESTS_CA_BUNDLE:Python requests library"
    "PIP_CERT:Python pip package manager"
    "PYTHONHTTPSVERIFY:Python SSL verification"
    "PYTHONCASSLDEFAULTPATH:Python SSL default path"
)

for var_desc in "${python_vars[@]}"; do
    var_name="${var_desc%%:*}"
    var_desc="${var_desc#*:}"
    if [ -n "${!var_name:-}" ]; then
        print_status "$GREEN" "    ✅ $var_name ($var_desc)"
    else
        print_status "$YELLOW" "    ⚠️  $var_name not set ($var_desc)"
    fi
done

# Node.js ecosystem
echo "   node.js ecosystem:"
nodejs_vars=(
    "NODE_EXTRA_CA_CERTS:Node.js runtime"
    "NPM_CONFIG_CAFILE:npm package manager"
    "YARN_CAFILE:Yarn package manager"
)

for var_desc in "${nodejs_vars[@]}"; do
    var_name="${var_desc%%:*}"
    var_desc="${var_desc#*:}"
    if [ -n "${!var_name:-}" ]; then
        print_status "$GREEN" "    ✅ $var_name ($var_desc)"
    else
        print_status "$YELLOW" "    ⚠️  $var_name not set ($var_desc)"
    fi
done

# Rust ecosystem
echo "   rust ecosystem:"
rust_vars=(
    "CARGO_HTTP_CAINFO:Rust cargo package manager"
    "RUSTUP_USE_CURL:rustup uses curl (respects CURL_CA_BUNDLE)"
)

for var_desc in "${rust_vars[@]}"; do
    var_name="${var_desc%%:*}"
    var_desc="${var_desc#*:}"
    if [ -n "${!var_name:-}" ]; then
        print_status "$GREEN" "    ✅ $var_name ($var_desc)"
    else
        print_status "$YELLOW" "    ⚠️  $var_name not set ($var_desc)"
    fi
done

# Go ecosystem
echo "   go ecosystem:"
go_vars=(
    "GOPATH_CERT_FILE:Go modules (legacy)"
    "GOPROXY_CERT_FILE:Go proxy certificate"
    "GOSUMDB_CERT_FILE:Go checksum database"
)

for var_desc in "${go_vars[@]}"; do
    var_name="${var_desc%%:*}"
    var_desc="${var_desc#*:}"
    if [ -n "${!var_name:-}" ]; then
        print_status "$GREEN" "    ✅ $var_name ($var_desc)"
    else
        print_status "$YELLOW" "    ⚠️  $var_name not set ($var_desc)"
    fi
done

# test SSL connectivity
echo ""
print_status "$BLUE" "3. SSL Connectivity Tests"
echo "   testing HTTPS connectivity to common development sites..."

test_urls=(
    "https://github.com"
    "https://nixos.org"
    "https://cache.nixos.org"
    "https://registry.npmjs.org"
    "https://pypi.org"
    "https://crates.io"
    "https://proxy.golang.org"
)

connectivity_passed=0
for url in "${test_urls[@]}"; do
    site_name=$(echo "$url" | sed 's|https://||' | sed 's|/.*||')
    if test_ssl_connectivity "$url" "curl" 10; then
        print_status "$GREEN" "  ✅ $site_name"
        ((connectivity_passed++))
    else
        print_status "$RED" "  ❌ $site_name"
    fi
done

if [ $connectivity_passed -eq ${#test_urls[@]} ]; then
    print_status "$GREEN" "  ✅ all SSL connectivity tests passed"
else
    print_status "$YELLOW" "  ⚠️  $connectivity_passed/${#test_urls[@]} SSL connectivity tests passed"
fi

# test package managers
echo ""
print_status "$BLUE" "4. Package Manager SSL Tests"
echo "   testing package manager SSL connectivity..."

# test npm
test_package_manager "npm" "npm ping"

# test pip
test_package_manager "pip" "pip list --timeout 10"

# test cargo
test_package_manager "cargo" "cargo search --limit 1 serde"

# test go
test_package_manager "go" "go list -m golang.org/x/crypto"

# test git
if command -v git >/dev/null 2>&1; then
    print_status "$BLUE" "  testing git SSL connectivity..."
    if timeout 30 git ls-remote https://github.com/NixOS/nixpkgs.git HEAD >/dev/null 2>&1; then
        print_status "$GREEN" "    ✅ git SSL connectivity working"
    else
        print_status "$RED" "    ❌ git SSL connectivity failed"
    fi
fi

# summary
echo ""
print_status "$BLUE" "📊 SSL Configuration Summary"
print_status "$BLUE" "============================"

if [ $core_valid -eq ${#core_ssl_vars[@]} ] && [ $connectivity_passed -eq ${#test_urls[@]} ]; then
    print_status "$GREEN" "🎉 SSL configuration is working correctly!"
    print_status "$GREEN" "   all core variables configured and connectivity tests passed"
    exit 0
elif [ $core_valid -gt 0 ] || [ $connectivity_passed -gt 0 ]; then
    print_status "$YELLOW" "⚠️  SSL configuration partially working"
    print_status "$YELLOW" "   some variables configured or connectivity tests passed"
    print_status "$YELLOW" "   review the output above for specific issues"
    exit 1
else
    print_status "$RED" "❌ SSL configuration not working"
    print_status "$RED" "   no core variables configured and connectivity tests failed"
    print_status "$RED" "   check certificate installation and environment variables"
    exit 2
fi
