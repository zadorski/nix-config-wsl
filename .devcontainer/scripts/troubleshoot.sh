#!/usr/bin/env bash
# Comprehensive troubleshooting script for development environment issues
# Provides diagnostic information and automated fixes

set -euo pipefail

echo "🔧 Development Environment Troubleshooting"
echo "=========================================="

# function to run command and capture output
run_diagnostic() {
    local description="$1"
    local command="$2"
    
    echo ""
    echo "🔍 $description"
    echo "Command: $command"
    echo "Output:"
    
    if eval "$command" 2>&1; then
        echo "✅ Success"
    else
        echo "❌ Failed (exit code: $?)"
    fi
}

# System Information
echo "📊 System Information"
echo "===================="
run_diagnostic "Operating System" "cat /etc/os-release"
run_diagnostic "Kernel Version" "uname -a"
run_diagnostic "Container Environment" "cat /proc/1/cgroup | head -5"
run_diagnostic "Available Memory" "free -h"
run_diagnostic "Disk Usage" "df -h /"

# User and Permissions
echo ""
echo "👤 User and Permissions"
echo "======================"
run_diagnostic "Current User" "whoami"
run_diagnostic "User ID" "id"
run_diagnostic "Home Directory" "ls -la /home/vscode"
run_diagnostic "SSH Directory Permissions" "ls -la ~/.ssh 2>/dev/null || echo 'SSH directory does not exist'"

# Environment Variables
echo ""
echo "🌍 Environment Variables"
echo "======================="
run_diagnostic "PATH" "echo \$PATH"
run_diagnostic "SSH_AUTH_SOCK" "echo \$SSH_AUTH_SOCK"
run_diagnostic "Certificate Variables" "env | grep -E '(SSL_CERT|CURL_CA|REQUESTS_CA)' || echo 'No certificate variables found'"
run_diagnostic "Git Configuration Variables" "env | grep -E '(GIT_|EDITOR|VISUAL)' || echo 'No git variables found'"

# Nix Environment
echo ""
echo "❄️  Nix Environment"
echo "=================="
run_diagnostic "Nix Installation" "ls -la ~/.nix-profile/etc/profile.d/nix.sh 2>/dev/null || echo 'Nix profile script not found'"
run_diagnostic "Nix Version" "nix --version 2>/dev/null || echo 'Nix command not available'"
run_diagnostic "Nix Configuration" "cat ~/.config/nix/nix.conf 2>/dev/null || echo 'Nix config not found'"
run_diagnostic "Nix Store" "nix-store --version 2>/dev/null || echo 'Nix store not available'"
run_diagnostic "Nix Channels" "nix-channel --list 2>/dev/null || echo 'No channels configured'"

# Development Tools
echo ""
echo "🛠️  Development Tools"
echo "===================="
TOOLS=("git" "fish" "starship" "curl" "wget" "jq" "tree" "nil" "nixfmt")
for tool in "${TOOLS[@]}"; do
    run_diagnostic "$tool availability" "command -v $tool && $tool --version 2>/dev/null || $tool -V 2>/dev/null || echo 'Version info not available'"
done

# SSH Configuration
echo ""
echo "🔑 SSH Configuration"
echo "==================="
run_diagnostic "SSH Agent Socket" "ls -la \$SSH_AUTH_SOCK 2>/dev/null || echo 'SSH agent socket not found'"
run_diagnostic "SSH Keys in Agent" "ssh-add -l 2>/dev/null || echo 'No keys in SSH agent or agent not available'"
run_diagnostic "SSH Configuration" "cat ~/.ssh/config 2>/dev/null || echo 'SSH config not found'"
run_diagnostic "SSH Directory Contents" "ls -la ~/.ssh/ 2>/dev/null || echo 'SSH directory not found'"

# Git Configuration
echo ""
echo "📝 Git Configuration"
echo "==================="
run_diagnostic "Git Global Config" "git config --global --list 2>/dev/null || echo 'No global git config'"
run_diagnostic "Git Safe Directories" "git config --global --get-all safe.directory 2>/dev/null || echo 'No safe directories configured'"

# Certificate Configuration
echo ""
echo "🔐 Certificate Configuration"
echo "============================"
run_diagnostic "System Certificate Store" "ls -la /etc/ssl/certs/ca-certificates.crt"
run_diagnostic "Corporate Certificates" "ls -la /usr/local/share/ca-certificates/ 2>/dev/null || echo 'No corporate certificates'"
run_diagnostic "Certificate Count" "grep -c 'BEGIN CERTIFICATE' /etc/ssl/certs/ca-certificates.crt 2>/dev/null || echo 'Cannot count certificates'"

# Network Connectivity
echo ""
echo "🌐 Network Connectivity"
echo "======================="
run_diagnostic "DNS Resolution" "nslookup github.com 2>/dev/null || echo 'DNS resolution failed'"
run_diagnostic "HTTP Connectivity" "curl -s --max-time 10 http://github.com >/dev/null && echo 'HTTP OK' || echo 'HTTP failed'"
run_diagnostic "HTTPS Connectivity" "curl -s --max-time 10 https://github.com >/dev/null && echo 'HTTPS OK' || echo 'HTTPS failed'"
run_diagnostic "HTTPS with Verbose" "curl -v --max-time 10 https://github.com 2>&1 | head -20"

# Home Manager
echo ""
echo "🏠 Home Manager"
echo "==============="
run_diagnostic "Home Manager Availability" "command -v home-manager && home-manager --version 2>/dev/null || echo 'Home Manager not available'"
run_diagnostic "Home Manager Config" "ls -la ~/.config/home-manager/ 2>/dev/null || echo 'Home Manager config not found'"

# Process Information
echo ""
echo "⚙️  Process Information"
echo "======================"
run_diagnostic "Running Processes" "ps aux | head -10"
run_diagnostic "Nix Processes" "ps aux | grep nix || echo 'No nix processes'"

# Automated Fixes
echo ""
echo "🔧 Automated Fixes"
echo "=================="

echo "Attempting to fix common issues..."

# Fix 1: SSH directory permissions
if [ -d ~/.ssh ]; then
    echo "Fixing SSH directory permissions..."
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/* 2>/dev/null || true
    chmod 644 ~/.ssh/*.pub 2>/dev/null || true
    echo "✅ SSH permissions fixed"
else
    echo "Creating SSH directory..."
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo "✅ SSH directory created"
fi

# Fix 2: Git safe directory
echo "Configuring git safe directory..."
git config --global --add safe.directory "/workspaces/*" 2>/dev/null || true
echo "✅ Git safe directory configured"

# Fix 3: Source Nix environment
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    echo "Sourcing Nix environment..."
    source ~/.nix-profile/etc/profile.d/nix.sh
    echo "✅ Nix environment sourced"
fi

echo ""
echo "🎯 Troubleshooting Summary"
echo "========================="
echo "Diagnostic information collected above."
echo ""
echo "Common Solutions:"
echo "1. If Nix is not available, run: curl -L https://nixos.org/nix/install | sh"
echo "2. If SSH agent is not working, check VS Code SSH forwarding settings"
echo "3. If HTTPS fails, check corporate certificate installation"
echo "4. If fish shell is not default, run: sudo chsh -s \$(which fish) vscode"
echo "5. For home-manager issues, run: ~/.devcontainer-scripts/setup-environment.sh"
echo ""
echo "For additional help, see .devcontainer/README.md"
