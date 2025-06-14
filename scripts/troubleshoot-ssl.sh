#!/usr/bin/env bash
# SSL troubleshooting script for development environment
# provides step-by-step diagnosis and fixes for SSL certificate issues

set -euo pipefail

# color codes for output formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # no color

# print colored status messages
print_status() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# print section header
print_section() {
    local title="$1"
    echo ""
    print_status "$CYAN" "🔧 $title"
    print_status "$CYAN" "$(printf '=%.0s' $(seq 1 $((${#title} + 3))))"
}

# test SSL connectivity with detailed error reporting
test_ssl_detailed() {
    local url="$1"
    local site_name=$(echo "$url" | sed 's|https://||' | sed 's|/.*||')
    
    print_status "$BLUE" "Testing $site_name..."
    
    # test with curl (verbose for debugging)
    if curl -s --connect-timeout 10 --head "$url" >/dev/null 2>&1; then
        print_status "$GREEN" "  ✅ $site_name: SSL connection successful"
        return 0
    else
        print_status "$RED" "  ❌ $site_name: SSL connection failed"
        
        # show detailed error
        print_status "$YELLOW" "  🔍 Detailed error:"
        curl -v --connect-timeout 10 --head "$url" 2>&1 | grep -E "(SSL|certificate|verify|error)" | head -3 | sed 's/^/     /' || true
        return 1
    fi
}

# check if certificate file is valid
check_cert_file() {
    local cert_file="$1"
    local name="$2"
    
    if [ -f "$cert_file" ]; then
        local cert_count
        cert_count=$(grep -c "BEGIN CERTIFICATE" "$cert_file" 2>/dev/null || echo "0")
        if [ "$cert_count" -gt 0 ]; then
            print_status "$GREEN" "  ✅ $name: $cert_file ($cert_count certificates)"
            return 0
        else
            print_status "$RED" "  ❌ $name: file exists but contains no certificates"
            return 1
        fi
    else
        print_status "$RED" "  ❌ $name: file not found ($cert_file)"
        return 1
    fi
}

echo ""
print_status "$BLUE" "🔍 SSL Certificate Troubleshooting Tool"
print_status "$BLUE" "======================================="

# step 1: check system certificate files
print_section "System Certificate Files"

system_cert_files=(
    "/etc/ssl/certs/ca-certificates.crt:System CA bundle"
    "/etc/ssl/certs/ca-bundle.crt:Alternative CA bundle"
    "/usr/local/share/ca-certificates/:Local certificates directory"
)

system_certs_ok=0
for cert_info in "${system_cert_files[@]}"; do
    cert_file="${cert_info%%:*}"
    cert_name="${cert_info#*:}"
    
    if [[ "$cert_file" == *"/" ]]; then
        # directory check
        if [ -d "$cert_file" ]; then
            cert_count=$(find "$cert_file" -name "*.crt" 2>/dev/null | wc -l)
            print_status "$GREEN" "  ✅ $cert_name: $cert_file ($cert_count files)"
            ((system_certs_ok++))
        else
            print_status "$RED" "  ❌ $cert_name: directory not found"
        fi
    else
        # file check
        if check_cert_file "$cert_file" "$cert_name"; then
            ((system_certs_ok++))
        fi
    fi
done

# step 2: check environment variables
print_section "SSL Environment Variables"

ssl_vars=(
    "SSL_CERT_FILE"
    "NIX_SSL_CERT_FILE"
    "CURL_CA_BUNDLE"
    "REQUESTS_CA_BUNDLE"
    "NODE_EXTRA_CA_CERTS"
    "PIP_CERT"
    "CARGO_HTTP_CAINFO"
    "GIT_SSL_CAINFO"
)

env_vars_ok=0
for var in "${ssl_vars[@]}"; do
    if [ -n "${!var:-}" ]; then
        if [ -f "${!var}" ]; then
            print_status "$GREEN" "  ✅ $var: ${!var}"
            ((env_vars_ok++))
        else
            print_status "$YELLOW" "  ⚠️  $var: set but file not found (${!var})"
        fi
    else
        print_status "$RED" "  ❌ $var: not set"
    fi
done

# step 3: test SSL connectivity
print_section "SSL Connectivity Tests"

test_sites=(
    "https://github.com"
    "https://nixos.org"
    "https://pypi.org"
    "https://registry.npmjs.org"
)

connectivity_ok=0
for site in "${test_sites[@]}"; do
    if test_ssl_detailed "$site"; then
        ((connectivity_ok++))
    fi
done

# step 4: check corporate certificate
print_section "Corporate Certificate Check"

if [ -f "/etc/nixos-certificates-info" ]; then
    print_status "$GREEN" "  ✅ Corporate certificate configuration detected"
    echo ""
    print_status "$BLUE" "  Certificate info:"
    cat /etc/nixos-certificates-info | sed 's/^/     /'
else
    print_status "$YELLOW" "  ⚠️  No corporate certificate configuration found"
    print_status "$BLUE" "  This is normal for non-corporate environments"
fi

# step 5: provide recommendations
print_section "Recommendations"

if [ $system_certs_ok -eq 0 ]; then
    print_status "$RED" "❌ Critical: No system certificate files found"
    echo "   Fix: Install ca-certificates package or check system configuration"
elif [ $env_vars_ok -eq 0 ]; then
    print_status "$YELLOW" "⚠️  Warning: No SSL environment variables set"
    echo "   Fix: Source system environment or configure manually"
elif [ $connectivity_ok -eq 0 ]; then
    print_status "$RED" "❌ Critical: No SSL connectivity working"
    echo "   Fix: Check network connection and certificate configuration"
else
    print_status "$GREEN" "✅ SSL configuration appears to be working"
    echo "   System certificates: $system_certs_ok/3 found"
    echo "   Environment variables: $env_vars_ok/${#ssl_vars[@]} configured"
    echo "   Connectivity tests: $connectivity_ok/${#test_sites[@]} passed"
fi

echo ""
print_status "$BLUE" "🔧 Quick Fixes"
echo ""

if [ $env_vars_ok -lt ${#ssl_vars[@]} ]; then
    print_status "$YELLOW" "To set missing environment variables:"
    echo '   export SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"'
    echo '   export CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"'
    echo '   export REQUESTS_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"'
    echo ""
fi

if [ $connectivity_ok -lt ${#test_sites[@]} ]; then
    print_status "$YELLOW" "To test SSL connectivity manually:"
    echo '   curl -v https://github.com'
    echo '   openssl s_client -connect github.com:443 -servername github.com'
    echo ""
fi

print_status "$BLUE" "For more help, check:"
echo "   • System certificate configuration: system/certificates.nix"
echo "   • Development environment: devenv.nix"
echo "   • SSL validation script: scripts/validate-ssl-configuration.sh"

# exit with appropriate code
if [ $system_certs_ok -gt 0 ] && [ $connectivity_ok -gt 0 ]; then
    exit 0
else
    exit 1
fi
