#!/bin/bash
# Container SSL Certificate Validation Script
# Run this inside the devcontainer to diagnose SSL certificate issues

set -e

echo "🔍 Container SSL Certificate Environment Analysis"
echo "=============================================="

# Check Container Environment Variables
echo ""
echo "1. Checking SSL Environment Variables in Container..."
ssl_vars=(
    "SSL_CERT_FILE"
    "REQUESTS_CA_BUNDLE" 
    "CURL_CA_BUNDLE"
    "NODE_EXTRA_CA_CERTS"
    "NIX_SSL_CERT_FILE"
    "HTTPS_CA_BUNDLE"
    "CA_BUNDLE"
)

missing_vars=()
for var in "${ssl_vars[@]}"; do
    value="${!var}"
    if [ -n "$value" ]; then
        echo "   ✅ $var = $value"
        if [ -f "$value" ]; then
            echo "      📁 File exists ($(wc -l < "$value") lines)"
            # Check if file contains certificates
            if grep -q "BEGIN CERTIFICATE" "$value" 2>/dev/null; then
                cert_count=$(grep -c "BEGIN CERTIFICATE" "$value")
                echo "      🔐 Contains $cert_count certificate(s)"
            else
                echo "      ⚠️  File exists but may not contain certificates"
            fi
        else
            echo "      ❌ File not found"
        fi
    else
        echo "   ❌ $var = NOT SET"
        missing_vars+=("$var")
    fi
done

# Check Container Certificate Locations
echo ""
echo "2. Checking Container Certificate Locations..."
container_cert_paths=(
    "/etc/ssl/certs/ca-certificates.crt"
    "/etc/ssl/certs/ca-bundle.crt"
    "/usr/local/share/ca-certificates/"
    "/etc/ca-certificates.conf"
    "/usr/local/share/ca-certificates/corporate/"
    "/etc/ssl/certs/zscaler-root-ca.pem"
    "/usr/local/share/ca-certificates/zscaler-root-ca.crt"
)

for path in "${container_cert_paths[@]}"; do
    if [ -e "$path" ]; then
        if [ -d "$path" ]; then
            cert_count=$(find "$path" -name "*.crt" -o -name "*.pem" | wc -l)
            echo "   ✅ Directory exists: $path ($cert_count certificates)"
        else
            echo "   ✅ File exists: $path ($(wc -l < "$path") lines)"
            if grep -q "BEGIN CERTIFICATE" "$path" 2>/dev/null; then
                cert_count=$(grep -c "BEGIN CERTIFICATE" "$path")
                echo "      🔐 Contains $cert_count certificate(s)"
            fi
        fi
    else
        echo "   ❌ Not found: $path"
    fi
done

# Check if certificates are properly installed
echo ""
echo "3. Checking Certificate Installation..."
if command -v update-ca-certificates >/dev/null 2>&1; then
    echo "   ✅ update-ca-certificates command available"
    echo "   📋 Certificate bundle info:"
    if [ -f "/etc/ssl/certs/ca-certificates.crt" ]; then
        cert_count=$(grep -c "BEGIN CERTIFICATE" /etc/ssl/certs/ca-certificates.crt)
        echo "      System bundle contains $cert_count certificates"
    fi
else
    echo "   ❌ update-ca-certificates not available"
fi

# Test SSL connectivity from Container
echo ""
echo "4. Testing SSL Connectivity from Container..."
test_urls=(
    "https://nixos.org"
    "https://github.com"
    "https://cache.nixos.org"
    "https://channels.nixos.org"
)

for url in "${test_urls[@]}"; do
    echo "   Testing $url..."
    
    # Test with curl (verbose for debugging)
    if curl -s --connect-timeout 10 --head "$url" >/dev/null 2>&1; then
        echo "      ✅ curl: SUCCESS"
    else
        echo "      ❌ curl: FAILED"
        # Show detailed error
        echo "      🔍 Detailed curl error:"
        curl -v --connect-timeout 10 --head "$url" 2>&1 | grep -E "(SSL|certificate|verify)" | head -3 | sed 's/^/         /'
    fi
    
    # Test with wget
    if wget --timeout=10 --spider "$url" >/dev/null 2>&1; then
        echo "      ✅ wget: SUCCESS"
    else
        echo "      ❌ wget: FAILED"
    fi
done

# Test APT connectivity
echo ""
echo "5. Testing APT SSL Configuration..."
if timeout 30 apt-get update >/dev/null 2>&1; then
    echo "   ✅ APT can connect to repositories"
else
    echo "   ❌ APT cannot connect to repositories"
fi

# Test Nix installation specifically
echo ""
echo "6. Testing Nix Installation Requirements..."
nix_test_urls=(
    "https://nixos.org/nix/install"
    "https://install.determinate.systems/nix"
)

for url in "${nix_test_urls[@]}"; do
    echo "   Testing Nix installer: $url"
    if curl -s --connect-timeout 10 --head "$url" >/dev/null 2>&1; then
        echo "      ✅ Nix installer accessible"
    else
        echo "      ❌ Nix installer not accessible"
    fi
done

# Generate Container-specific recommendations
echo ""
echo "📋 CONTAINER RECOMMENDATIONS:"
echo "============================"

if [ ${#missing_vars[@]} -gt 0 ]; then
    echo ""
    echo "🔧 Missing Environment Variables in Container:"
    for var in "${missing_vars[@]}"; do
        echo "   - $var"
    done
    echo ""
    echo "💡 These should be set in devcontainer.json containerEnv section"
fi

# Check if we can find any certificate files to use
cert_candidates=(
    "/etc/ssl/certs/ca-certificates.crt"
    "/usr/local/share/ca-certificates/zscaler-root-ca.crt"
    "/etc/ssl/certs/zscaler-root-ca.pem"
)

working_cert=""
for cert in "${cert_candidates[@]}"; do
    if [ -f "$cert" ] && grep -q "BEGIN CERTIFICATE" "$cert" 2>/dev/null; then
        working_cert="$cert"
        break
    fi
done

if [ -n "$working_cert" ]; then
    echo ""
    echo "💡 Found working certificate file: $working_cert"
    echo ""
    echo "🔧 Recommended Container Environment Variables:"
    echo "   SSL_CERT_FILE=$working_cert"
    echo "   REQUESTS_CA_BUNDLE=$working_cert"
    echo "   CURL_CA_BUNDLE=$working_cert"
    echo "   NODE_EXTRA_CA_CERTS=$working_cert"
    echo "   NIX_SSL_CERT_FILE=$working_cert"
else
    echo ""
    echo "⚠️  No working certificate files found in container"
    echo ""
    echo "🔧 Required fixes:"
    echo "   1. Copy certificate file to container during build"
    echo "   2. Install certificate in system certificate store"
    echo "   3. Set environment variables to point to certificate"
    echo "   4. Run update-ca-certificates to rebuild bundle"
fi

echo ""
echo "🚀 Next Steps for Container:"
echo "1. Update devcontainer.json with proper certificate mounting"
echo "2. Update Dockerfile to install certificates properly"
echo "3. Set environment variables in devcontainer.json"
echo "4. Rebuild container and test again"

echo ""
echo "✅ Container SSL Analysis Complete!"
