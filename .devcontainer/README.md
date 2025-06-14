# Development Container Configuration - Fallback Solution

🔄 **This development container serves as a reliable fallback when devenv fails (particularly due to SSH issues).**

## Purpose and Scope

This devcontainer configuration is designed as a **fallback solution** for situations where the preferred devenv approach encounters issues, particularly in corporate environments with complex certificate and SSH forwarding challenges.

**Primary Approach**: Direct WSL development with devenv (see `devenv.nix`)
**Fallback Approach**: This devcontainer configuration for maximum reliability

## When to Use This Devcontainer

### Use Devcontainer When:
- **SSH Agent Forwarding Issues**: VS Code WSL SSH forwarding is problematic
- **Corporate Certificate Challenges**: Complex proxy/certificate environments
- **Environment Isolation Required**: Need complete separation from host system
- **Devenv Setup Failures**: Nix or devenv installation issues on host
- **Team Consistency**: Ensuring identical environments across team members
- **CI/CD Integration**: Container-based development workflows

### Use Devenv When:
- **Standard WSL Environment**: SSH and certificates work reliably
- **Performance Critical**: Need native performance without container overhead
- **Host Integration**: Want to leverage existing NixOS WSL configuration
- **Quick Setup**: Need fast environment activation (5-15 seconds vs 2-5 minutes)

## Key Improvements in This Version

### Enhanced Reliability
- **Multi-stage Dockerfile**: Optimized build process with error handling
- **Certificate Fallback**: Multiple approaches for corporate certificate handling
- **Robust SSH Integration**: Native VS Code SSH forwarding with fallback options
- **Comprehensive Validation**: Nix-based testing scripts for environment verification

### Corporate Environment Support
- **Zscaler Certificate Handling**: Automatic detection and installation
- **Windows-WSL Integration**: Leverages existing windows-wsl-manager patterns
- **Environment Variable Promotion**: Comprehensive SSL certificate configuration
- **Proxy-Friendly**: Designed for corporate proxy environments

## Architecture Overview

### Container Structure
```
Ubuntu 24.04 LTS
├── Multi-stage Dockerfile (optimized build)
├── Nix Package Manager (single-user mode)
├── Fish Shell + Starship Prompt
├── Certificate Management (multi-source)
├── SSH Agent Forwarding (VS Code native)
└── Development Tools (matching devenv.nix)
```

### Script Architecture
```
.devcontainer/scripts/
├── setup-environment.sh     # Main setup with home-manager
├── install-certificates.sh  # Multi-source certificate handling
├── validate-environment.sh  # Comprehensive Nix-based testing
├── check-environment.sh     # Quick startup validation
├── health-check.sh          # Docker health check
└── troubleshoot.sh          # Diagnostic and automated fixes
```

### Integration with Repository Patterns
- **Certificate Handling**: Mirrors `system/certificates.nix` patterns
- **Development Tools**: Matches `devenv.nix` package selection
- **Shell Configuration**: Consistent with repository fish/starship setup
- **Windows Integration**: Leverages `home/windows/` module patterns

## Configuration Files

### Core Configuration
- **`devcontainer.json`** - Comprehensive container configuration with VS Code integration
- **`Dockerfile`** - Multi-stage Ubuntu 24.04 with optimized Nix installation
- **`zscaler-root-ca.crt`** - Corporate certificate for Zscaler environments

### Setup Scripts
- **`scripts/setup-environment.sh`** - Main environment setup with home-manager
- **`scripts/install-certificates.sh`** - Multi-source certificate detection and installation
- **`scripts/validate-environment.sh`** - Comprehensive Nix-based environment testing
- **`scripts/check-environment.sh`** - Quick startup environment validation
- **`scripts/health-check.sh`** - Docker container health monitoring
- **`scripts/troubleshoot.sh`** - Diagnostic tools and automated fixes

## Key Features

### Reliability Enhancements
- ✅ **Multi-stage Dockerfile** with comprehensive error handling
- ✅ **Certificate Fallback System** for corporate environments
- ✅ **Robust SSH Integration** with VS Code native forwarding
- ✅ **Comprehensive Validation** using Nix-based testing
- ✅ **Health Monitoring** with Docker health checks
- ✅ **Automated Troubleshooting** with diagnostic scripts

### Corporate Environment Support
- ✅ **Zscaler Certificate Handling** with automatic detection
- ✅ **Windows-WSL Integration** using repository patterns
- ✅ **Environment Variable Promotion** for SSL certificates
- ✅ **Proxy-Friendly Configuration** for corporate networks
- ✅ **Multiple Certificate Sources** with fallback detection
- ✅ **Certificate Validation** with comprehensive testing

## Setup Requirements

### Host Environment Variables
Set these environment variables for automatic configuration:

```bash
# Git configuration (uses project defaults if not set)
export GIT_USER_NAME="zadorski"  # or your preferred name
export GIT_USER_EMAIL="678169+zadorski@users.noreply.github.com"  # or your email
```

### SSH Agent Setup
Ensure SSH agent is running on your host:

```bash
# Start SSH agent (if not already running)
eval "$(ssh-agent -s)"

# Add your SSH keys
ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/id_ed25519  # or your preferred key

# Verify keys are loaded
ssh-add -l
```

## Security Considerations

### SSH Agent Forwarding vs Key Mounting

**Chosen Approach: SSH Agent Forwarding** ✅
- **Security**: SSH keys never leave the host system
- **Principle of Least Privilege**: Container only gets access to SSH operations, not raw keys
- **Audit Trail**: All SSH operations logged on host
- **Key Rotation**: Automatic when host keys are updated

**Alternative: Direct Key Mounting** ❌
- **Security Risk**: SSH keys copied into container filesystem
- **Persistence**: Keys remain in container even after use
- **Permission Issues**: Difficult to maintain proper key permissions
- **Key Exposure**: Risk of keys being included in container images

### Implementation Details

1. **SSH Socket Mounting**: Host SSH agent socket mounted at `/ssh-agent`
2. **Environment Variable**: `SSH_AUTH_SOCK` points to mounted socket
3. **No Key Storage**: No SSH keys stored in container filesystem
4. **Automatic Cleanup**: SSH access removed when container stops

## Usage

### Automatic Setup Process
The container automatically configures itself through a multi-phase setup:

1. **Container Creation**: Multi-stage Dockerfile builds optimized environment
2. **Certificate Installation**: Detects and installs corporate certificates
3. **Nix Environment Setup**: Installs Nix with flakes support
4. **Home Manager Configuration**: Applies declarative user configuration
5. **Development Tools**: Installs tools matching `devenv.nix` patterns
6. **Shell Configuration**: Sets up Fish shell with Starship prompt
7. **SSH Integration**: Configures SSH agent forwarding
8. **Validation**: Runs comprehensive environment testing

### Manual Operations
If you need to run setup manually or troubleshoot issues:

```bash
# Run full environment setup
~/.devcontainer-scripts/setup-environment.sh

# Validate environment
~/.devcontainer-scripts/validate-environment.sh

# Quick environment check
~/.devcontainer-scripts/check-environment.sh

# Comprehensive troubleshooting
~/.devcontainer-scripts/troubleshoot.sh

# Start fish shell
exec fish
```

### Verifying Setup

```bash
# Check Nix installation
nix --version

# Check home-manager
home-manager --version

# Check default shell (should be fish)
echo $SHELL

# Test SSH agent forwarding
ssh-add -l  # Should list your SSH keys

# Test Git configuration
git config --list

# Test Git SSH access
ssh -T git@github.com
```

### Fish Shell Features

```bash
# Git shortcuts
g status     # git status
ga .         # git add .
gc -m "msg"  # git commit -m "msg"
gp           # git push
gl           # git pull

# Development shortcuts
ll           # ls -la
nfc          # nix flake check
nfs          # nix flake show

# Directory navigation
..           # cd ..
...          # cd ../..
```

## Troubleshooting

### SSH Agent Issues
```bash
# Check if SSH agent is forwarded
echo $SSH_AUTH_SOCK  # Should show /ssh-agent

# List available keys
ssh-add -l

# Test SSH connection
ssh -T git@github.com
```

### Shell Issues
```bash
# Check current shell
echo $SHELL

# Manually switch to fish
fish

# Check fish configuration
fish -c 'echo $PATH'
```

### Git Issues
```bash
# Check Git configuration
git config --list --global

# Test Git SSH
GIT_SSH_COMMAND="ssh -v" git ls-remote git@github.com:user/repo.git
```

## Security Best Practices

1. **Regular Key Rotation**: Rotate SSH keys regularly on host system
2. **Key Passphrase**: Use passphrase-protected SSH keys
3. **Agent Timeout**: Configure SSH agent timeout on host
4. **Audit Access**: Monitor SSH key usage through host logs
5. **Container Isolation**: Don't mount additional sensitive directories

## Migration from Legacy Setup

### What Changed
- **Removed**: Complex manual package installations and shell configurations
- **Replaced**: Custom scripts with Nix home-manager configurations
- **Simplified**: Certificate management using existing Nix patterns
- **Maintained**: All essential functionality (Git, SSH, Fish shell, certificates)

### Configuration Files

| File | Status | Purpose |
|------|--------|---------|
| `devcontainer.json` | **Simplified** | Removed redundant features, focused on essentials |
| `Dockerfile` | **Streamlined** | Ubuntu base + Nix + certificates only |
| `nix-setup.sh` | **New** | Nix-based setup using home-manager |
| `startup.sh` | **Legacy** | Minimal compatibility script |

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GIT_USER_NAME` | `zadorski` | Git user name |
| `GIT_USER_EMAIL` | `678169+zadorski@users.noreply.github.com` | Git user email |
| `SSH_AUTH_SOCK` | `/ssh-agent` | SSH agent socket path |

## Customization

### Adding Development Tools
Edit the `home.packages` list in `nix-setup.sh`:

```nix
home.packages = with pkgs; [
  fish
  starship
  git
  curl
  wget
  # Add your tools here
  nodejs
  python3
  docker
];
```

### Modifying Shell Configuration
Update the Fish configuration in `nix-setup.sh`:

```nix
programs.fish = {
  enable = true;
  shellInit = ''
    # Add your custom fish configuration here
    set -gx EDITOR nvim
    abbr -a myalias 'my command'
  '';
};
```

## Future Improvements

Consider these enhancements:
- **Dedicated Nix Flake**: Create a flake specifically for container configuration
- **Host Config Sync**: Automatic synchronization with host Nix configuration
- **Devenv Integration**: Project-specific development environments
- **Overlay Support**: Custom package overlays for specialized tools
