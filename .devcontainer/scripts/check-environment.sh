#!/usr/bin/env bash
# Quick environment check script for container startup
# Performs basic validation and reports status

set -euo pipefail

echo "🔄 Checking development environment status..."

# check Nix availability
if command -v nix >/dev/null 2>&1; then
    echo "✅ Nix: $(nix --version)"
else
    echo "❌ Nix: Not available"
fi

# check essential tools
TOOLS=("git" "fish" "curl")
for tool in "${TOOLS[@]}"; do
    if command -v "$tool" >/dev/null 2>&1; then
        echo "✅ $tool: Available"
    else
        echo "❌ $tool: Not available"
    fi
done

# check SSH agent
if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
    if ssh-add -l >/dev/null 2>&1; then
        KEY_COUNT=$(ssh-add -l | wc -l)
        echo "✅ SSH Agent: $KEY_COUNT key(s) loaded"
    else
        echo "⚠️  SSH Agent: No keys loaded"
    fi
else
    echo "❌ SSH Agent: Not available"
fi

# check certificates
if curl -s --max-time 5 https://github.com >/dev/null 2>&1; then
    echo "✅ HTTPS: Connectivity OK"
else
    echo "❌ HTTPS: Connectivity failed"
fi

echo "🔄 Environment check completed"
