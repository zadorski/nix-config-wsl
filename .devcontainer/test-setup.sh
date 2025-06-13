#!/usr/bin/env bash
# Test script for devcontainer configuration
# Run this after container setup to verify everything is working

set -e

echo "🧪 Testing Devcontainer Configuration"
echo "======================================"

# Test 1: Shell Configuration
echo "1. Testing Shell Configuration..."
CURRENT_SHELL=$(echo $SHELL)
USER_SHELL=$(getent passwd vscode | cut -d: -f7)

echo "   Current \$SHELL: $CURRENT_SHELL"
echo "   User shell: $USER_SHELL"

if [[ "$USER_SHELL" == *"fish"* ]]; then
    echo "   ✅ Fish is configured as default shell"
else
    echo "   ❌ Fish is NOT configured as default shell"
    exit 1
fi

# Test 2: Fish Functionality
echo "2. Testing Fish Functionality..."
if command -v fish >/dev/null 2>&1; then
    echo "   ✅ Fish is installed and available"
    
    # Test fish configuration
    if fish -c 'test -f ~/.config/fish/config.fish'; then
        echo "   ✅ Fish configuration file exists"
    else
        echo "   ❌ Fish configuration file missing"
    fi
    
    # Test fish aliases
    if fish -c 'abbr -l | grep -q "g"'; then
        echo "   ✅ Fish abbreviations configured"
    else
        echo "   ⚠️  Fish abbreviations not found (may be normal)"
    fi
else
    echo "   ❌ Fish is not installed"
    exit 1
fi

# Test 3: Nix Environment
echo "3. Testing Nix Environment..."
if command -v nix >/dev/null 2>&1; then
    echo "   ✅ Nix is available"
    
    # Test nix profile
    if nix profile list | grep -q fish; then
        echo "   ✅ Fish installed via Nix profile"
    else
        echo "   ❌ Fish not found in Nix profile"
    fi
else
    echo "   ❌ Nix is not available"
    exit 1
fi

# Test 4: SSH Configuration
echo "4. Testing SSH Configuration..."
if [ -n "$SSH_AUTH_SOCK" ]; then
    echo "   ✅ SSH_AUTH_SOCK is set: $SSH_AUTH_SOCK"
    
    if [ -S "$SSH_AUTH_SOCK" ]; then
        echo "   ✅ SSH agent socket exists"
        
        # Test SSH agent
        if ssh-add -l >/dev/null 2>&1; then
            KEY_COUNT=$(ssh-add -l | wc -l)
            echo "   ✅ SSH agent has $KEY_COUNT key(s) loaded"
        else
            echo "   ⚠️  SSH agent has no keys loaded (may be normal)"
        fi
    else
        echo "   ❌ SSH agent socket does not exist"
    fi
else
    echo "   ⚠️  SSH_AUTH_SOCK not set (SSH agent forwarding not available)"
fi

# Test SSH config
if [ -f ~/.ssh/config ]; then
    echo "   ✅ SSH config file exists"
else
    echo "   ❌ SSH config file missing"
fi

# Test 5: Git Configuration
echo "5. Testing Git Configuration..."
if command -v git >/dev/null 2>&1; then
    echo "   ✅ Git is available"
    
    GIT_USER=$(git config --global user.name 2>/dev/null || echo "not set")
    GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "not set")
    
    echo "   Git user.name: $GIT_USER"
    echo "   Git user.email: $GIT_EMAIL"
    
    if [ "$GIT_USER" != "not set" ] && [ "$GIT_EMAIL" != "not set" ]; then
        echo "   ✅ Git is configured"
    else
        echo "   ❌ Git configuration incomplete"
    fi
else
    echo "   ❌ Git is not available"
    exit 1
fi

# Test 6: Development Environment
echo "6. Testing Development Environment..."

# Test environment variables
ENV_VARS=("EDITOR" "VISUAL" "PAGER")
for var in "${ENV_VARS[@]}"; do
    if [ -n "${!var}" ]; then
        echo "   ✅ $var is set: ${!var}"
    else
        echo "   ⚠️  $var is not set"
    fi
done

# Test 7: File Permissions
echo "7. Testing File Permissions..."
if [ -d ~/.ssh ]; then
    SSH_PERMS=$(stat -c %a ~/.ssh)
    if [ "$SSH_PERMS" = "700" ]; then
        echo "   ✅ SSH directory permissions correct (700)"
    else
        echo "   ⚠️  SSH directory permissions: $SSH_PERMS (should be 700)"
    fi
fi

if [ -f ~/.ssh/config ]; then
    CONFIG_PERMS=$(stat -c %a ~/.ssh/config)
    if [ "$CONFIG_PERMS" = "600" ]; then
        echo "   ✅ SSH config permissions correct (600)"
    else
        echo "   ⚠️  SSH config permissions: $CONFIG_PERMS (should be 600)"
    fi
fi

echo ""
echo "🎉 Configuration Test Complete!"
echo ""
echo "Next Steps:"
echo "1. Open a new terminal to use fish shell"
echo "2. Test SSH access: ssh -T git@github.com"
echo "3. Test Git operations: git clone <repo>"
echo "4. Customize fish config in ~/.config/fish/config.fish"
echo ""
echo "For troubleshooting, see .devcontainer/README.md"
