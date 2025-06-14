#!/usr/bin/env bash
# setup optimized nix configuration for devcontainer environment
# eliminates experimental features confirmation loops and git dirty warnings

set -e

echo "🔧 Setting up optimized Nix configuration for container environment..."

# create nix configuration directory
mkdir -p ~/.config/nix

# create optimized nix.conf for development workflow
cat > ~/.config/nix/nix.conf << 'EOF'
# nix configuration optimized for development workflow
# eliminates redundant warnings and confirmation prompts

# enable modern Nix features
experimental-features = nix-command flakes

# eliminate redundant warnings and prompts for development efficiency
warn-dirty = false
accept-flake-config = true

# performance optimizations
max-jobs = auto
cores = 0

# development-friendly settings
keep-outputs = true
keep-derivations = true

# trust configuration for container environment
trusted-users = root @wheel vscode

# SSL certificate handling
ssl-cert-file = /etc/ssl/certs/ca-certificates.crt
EOF

echo "✅ Nix configuration created at ~/.config/nix/nix.conf"

# verify configuration
if [ -f ~/.config/nix/nix.conf ]; then
    echo "📋 Configuration contents:"
    cat ~/.config/nix/nix.conf
    echo ""
    echo "🎉 Nix workflow optimizations applied successfully!"
    echo ""
    echo "Benefits:"
    echo "  ✅ No more experimental features confirmation prompts"
    echo "  ✅ Git dirty tree warnings suppressed"
    echo "  ✅ Flake configuration accepted automatically"
    echo "  ✅ Performance optimizations enabled"
    echo ""
else
    echo "❌ Failed to create Nix configuration"
    exit 1
fi

# test that nix commands work without prompts
echo "🧪 Testing Nix commands..."
if timeout 10s nix eval --expr "1 + 1" >/dev/null 2>&1; then
    echo "✅ Nix commands work without prompts"
else
    echo "⚠️  Nix commands may still have issues"
fi

echo "🏁 Setup complete!"
