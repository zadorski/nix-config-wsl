#!/usr/bin/env bash
# Certificate installation script with multiple fallback approaches
# Designed for corporate environments with Zscaler and other proxy certificates

set -euo pipefail

echo "🔐 Installing certificates for corporate environment..."

# certificate sources in order of preference
CERT_SOURCES=(
    "/usr/local/share/ca-certificates/corporate/zscaler-root-ca.crt"
    "/workspaces/nix-config-wsl/certs/zscaler.pem"
    "/mnt/c/Users/*/AppData/Local/Zscaler/ZscalerRootCertificate-*.crt"
    "/mnt/c/ProgramData/Zscaler/cert/ZscalerRootCertificate-*.crt"
)

# function to validate certificate
validate_certificate() {
    local cert_file="$1"
    
    if [ ! -f "$cert_file" ]; then
        return 1
    fi
    
    # check if file contains certificate markers
    if grep -q "BEGIN CERTIFICATE\|BEGIN TRUSTED CERTIFICATE" "$cert_file" 2>/dev/null; then
        # check if it's not a placeholder
        if ! grep -qi "placeholder\|example\|template" "$cert_file" 2>/dev/null; then
            return 0
        fi
    fi
    
    return 1
}

# function to install certificate
install_certificate() {
    local source_cert="$1"
    local target_name="$2"
    
    echo "  Installing certificate: $source_cert -> $target_name"
    
    # copy to system certificate directory
    sudo cp "$source_cert" "/usr/local/share/ca-certificates/$target_name"
    sudo chmod 644 "/usr/local/share/ca-certificates/$target_name"
    
    return 0
}

# main certificate installation logic
certificates_installed=0

echo "Searching for corporate certificates..."

# search for Zscaler certificates
for pattern in "${CERT_SOURCES[@]}"; do
    # expand glob patterns
    for cert_file in $pattern; do
        if validate_certificate "$cert_file"; then
            echo "✓ Found valid certificate: $cert_file"
            
            # determine target name based on source
            if [[ "$cert_file" == *"zscaler"* ]]; then
                target_name="zscaler-corporate.crt"
            else
                target_name="corporate-$(basename "$cert_file" | tr '[:upper:]' '[:lower:]').crt"
            fi
            
            if install_certificate "$cert_file" "$target_name"; then
                certificates_installed=$((certificates_installed + 1))
                echo "✅ Successfully installed: $target_name"
            else
                echo "❌ Failed to install: $cert_file"
            fi
        fi
    done
done

# additional certificate detection from Windows certificate store
if command -v wslpath >/dev/null 2>&1; then
    echo "Checking Windows certificate store..."
    
    # try to find certificates in Windows user profile
    if [ -n "${WIN_USERNAME:-}" ]; then
        win_cert_dirs=(
            "/mnt/c/Users/$WIN_USERNAME/AppData/Local/Zscaler"
            "/mnt/c/Users/$WIN_USERNAME/AppData/Roaming/Zscaler"
        )
        
        for cert_dir in "${win_cert_dirs[@]}"; do
            if [ -d "$cert_dir" ]; then
                echo "  Searching in: $cert_dir"
                find "$cert_dir" -name "*.crt" -o -name "*.pem" 2>/dev/null | while read -r cert_file; do
                    if validate_certificate "$cert_file"; then
                        target_name="windows-$(basename "$cert_file" | tr '[:upper:]' '[:lower:]')"
                        if install_certificate "$cert_file" "$target_name"; then
                            certificates_installed=$((certificates_installed + 1))
                            echo "✅ Installed Windows certificate: $target_name"
                        fi
                    fi
                done
            fi
        done
    fi
fi

# update system certificate store
echo "Updating system certificate store..."
if sudo update-ca-certificates; then
    echo "✅ Certificate store updated successfully"
else
    echo "⚠️  Certificate store update had warnings, but continuing..."
fi

# verify certificate installation
echo "Verifying certificate installation..."
cert_count=$(ls -1 /usr/local/share/ca-certificates/ 2>/dev/null | wc -l)
echo "📊 Total certificates in store: $cert_count"

if [ $certificates_installed -gt 0 ]; then
    echo "🎉 Successfully installed $certificates_installed corporate certificate(s)"
    
    # test HTTPS connectivity
    echo "Testing HTTPS connectivity..."
    if curl -s --max-time 10 https://github.com >/dev/null 2>&1; then
        echo "✅ HTTPS connectivity test passed"
    else
        echo "⚠️  HTTPS connectivity test failed - may need additional configuration"
    fi
else
    echo "ℹ️  No corporate certificates found - using system defaults"
    echo "   This is normal for non-corporate environments"
fi

echo "🔐 Certificate installation completed"
