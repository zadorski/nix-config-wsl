#!/bin/bash
# WSL SSL Certificate Validation Script
# Run this in WSL to diagnose SSL certificate propagation from Windows

set -e

echo "🔍 WSL SSL Certificate Environment Analysis"
echo "=========================================="

# Check WSL Environment Variables
echo ""
echo "1. Checking SSL Environment Variables in WSL..."
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
        else
            echo "      ❌ File not found"
        fi
    else
        echo "   ❌ $var = NOT SET"
        missing_vars+=("$var")
    fi
done

# Check Windows certificate propagation paths
echo ""
echo "2. Checking Windows Certificate Propagation..."
windows_cert_paths=(
    "/mnt/c/zscaler-root-ca.crt"
    "/mnt/c/Program Files/Zscaler/ZSClient/cert.pem"
    "/mnt/c/Program Files (x86)/Zscaler/ZSClient/cert.pem"
    "/mnt/c/Users/$USER/AppData/Roaming/zscaler/cert.pem"
    "/mnt/c/Users/$USER/AppData/Local/zscaler/cert.pem"
)

found_windows_certs=()
for path in "${windows_cert_paths[@]}"; do
    if [ -f "$path" ]; then
        echo "   ✅ Found Windows cert: $path"
        found_windows_certs+=("$path")
    else
        echo "   ❌ Not found: $path"
    fi
done

# Check WSL certificate locations
echo ""
echo "3. Checking WSL Certificate Locations..."
wsl_cert_paths=(
    "/etc/ssl/certs/ca-certificates.crt"
    "/etc/ssl/certs/ca-bundle.crt"
    "/usr/local/share/ca-certificates/"
    "/etc/ca-certificates.conf"
)

for path in "${wsl_cert_paths[@]}"; do
    if [ -e "$path" ]; then
        if [ -d "$path" ]; then
            cert_count=$(find "$path" -name "*.crt" | wc -l)
            echo "   ✅ Directory exists: $path ($cert_count certificates)"
        else
            echo "   ✅ File exists: $path ($(wc -l < "$path") lines)"
        fi
    else
        echo "   ❌ Not found: $path"
    fi
done

# Test SSL connectivity from WSL
echo ""
echo "4. Testing SSL Connectivity from WSL..."
test_urls=(
    "https://nixos.org"
    "https://github.com"
    "https://cache.nixos.org"
)

for url in "${test_urls[@]}"; do
    echo "   Testing $url..."
    
    # Test with curl
    if curl -s --connect-timeout 10 --head "$url" >/dev/null 2>&1; then
        echo "      ✅ curl: SUCCESS"
    else
        echo "      ❌ curl: FAILED"
    fi
    
    # Test with wget
    if wget --timeout=10 --spider "$url" >/dev/null 2>&1; then
        echo "      ✅ wget: SUCCESS"
    else
        echo "      ❌ wget: FAILED"
    fi
done

# Check apt SSL configuration
echo ""
echo "5. Testing APT SSL Configuration..."
if apt-get update >/dev/null 2>&1; then
    echo "   ✅ APT can connect to repositories"
else
    echo "   ❌ APT cannot connect to repositories"
fi

# Generate WSL-specific recommendations
echo ""
echo "📋 WSL RECOMMENDATIONS:"
echo "======================"

if [ ${#missing_vars[@]} -gt 0 ]; then
    echo ""
    echo "🔧 Missing Environment Variables in WSL:"
    for var in "${missing_vars[@]}"; do
        echo "   - $var"
    done
fi

if [ ${#found_windows_certs[@]} -gt 0 ]; then
    echo ""
    echo "💡 Found Windows Certificate Files:"
    for cert in "${found_windows_certs[@]}"; do
        echo "   - $cert"
    done
    
    echo ""
    echo "🔧 Recommended WSL Environment Variables:"
    cert_file="${found_windows_certs[0]}"
    echo "   export SSL_CERT_FILE=\"$cert_file\""
    echo "   export REQUESTS_CA_BUNDLE=\"$cert_file\""
    echo "   export CURL_CA_BUNDLE=\"$cert_file\""
    echo "   export NODE_EXTRA_CA_CERTS=\"$cert_file\""
    echo "   export NIX_SSL_CERT_FILE=\"$cert_file\""
    
    echo ""
    echo "🔧 Add to ~/.bashrc or ~/.profile:"
    echo "   echo 'export SSL_CERT_FILE=\"$cert_file\"' >> ~/.bashrc"
    echo "   echo 'export REQUESTS_CA_BUNDLE=\"$cert_file\"' >> ~/.bashrc"
    echo "   echo 'export CURL_CA_BUNDLE=\"$cert_file\"' >> ~/.bashrc"
    echo "   echo 'export NODE_EXTRA_CA_CERTS=\"$cert_file\"' >> ~/.bashrc"
    echo "   echo 'export NIX_SSL_CERT_FILE=\"$cert_file\"' >> ~/.bashrc"
else
    echo ""
    echo "⚠️  No Windows certificate files accessible from WSL"
    echo "   1. Ensure certificate file exists on Windows"
    echo "   2. Check Windows drive mounting in WSL"
    echo "   3. Copy certificate to WSL filesystem"
fi

echo ""
echo "🚀 Next Steps for WSL:"
echo "1. Set environment variables in WSL"
echo "2. Source the updated profile: source ~/.bashrc"
echo "3. Test SSL connectivity again"
echo "4. Proceed to container validation"

echo ""
echo "✅ WSL SSL Analysis Complete!"
