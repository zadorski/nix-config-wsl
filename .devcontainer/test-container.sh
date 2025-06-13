#!/usr/bin/env bash
# Test script to validate container configuration

echo "=== Container Configuration Test ==="

# Test 1: JSON validation
echo "1. Testing devcontainer.json syntax..."
if command -v python3 >/dev/null 2>&1; then
    python3 -c "import json; json.load(open('.devcontainer/devcontainer.json')); print('✓ JSON is valid')" || {
        echo "✗ JSON syntax error"
        exit 1
    }
else
    echo "⚠ Python3 not available, skipping JSON validation"
fi

# Test 2: Dockerfile syntax
echo "2. Testing Dockerfile syntax..."
if command -v docker >/dev/null 2>&1; then
    docker build --dry-run -f .devcontainer/Dockerfile .devcontainer/ >/dev/null 2>&1 && {
        echo "✓ Dockerfile syntax is valid"
    } || {
        echo "✗ Dockerfile has syntax errors"
        exit 1
    }
else
    echo "⚠ Docker not available, skipping Dockerfile validation"
fi

# Test 3: Script syntax
echo "3. Testing nix-setup.sh syntax..."
bash -n .devcontainer/nix-setup.sh && {
    echo "✓ nix-setup.sh syntax is valid"
} || {
    echo "✗ nix-setup.sh has syntax errors"
    exit 1
}

# Test 4: Required files
echo "4. Checking required files..."
required_files=(
    ".devcontainer/devcontainer.json"
    ".devcontainer/Dockerfile"
    ".devcontainer/nix-setup.sh"
    ".devcontainer/zscaler-root-ca.crt"
)

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

# Test 5: Script permissions
echo "5. Checking script permissions..."
if [ -x ".devcontainer/nix-setup.sh" ]; then
    echo "✓ nix-setup.sh is executable"
else
    echo "✗ nix-setup.sh is not executable"
    chmod +x .devcontainer/nix-setup.sh
    echo "✓ Fixed nix-setup.sh permissions"
fi

echo ""
echo "=== All tests passed! ==="
echo "The container configuration should work correctly."
echo ""
echo "To test the container:"
echo "1. Open this folder in VS Code"
echo "2. Press Ctrl+Shift+P"
echo "3. Run 'Dev Containers: Reopen in Container'"
echo ""
