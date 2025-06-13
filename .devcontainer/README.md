# Development Container Configuration - Refactored

This directory contains a **simplified, Nix-centric** development container configuration that has been refactored to reduce complexity and improve maintainability.

## Refactoring Overview

The configuration has been **significantly simplified** by:
- **Eliminating redundant package installations** across multiple files
- **Leveraging Nix home-manager** for declarative user configuration
- **Consolidating scattered settings** into a cohesive Nix-based approach
- **Removing complex manual setup scripts** in favor of Nix configuration
- **Reusing existing host Nix patterns** for consistency

## Architecture

### New Simplified Structure
- **Minimal Dockerfile**: Ubuntu base + Nix + essential certificates only
- **Nix Home-Manager**: Handles all user configuration, tools, and shell setup
- **Single Setup Script**: `nix-setup.sh` replaces complex `startup.sh`
- **Configuration Reuse**: Leverages existing host NixOS configuration patterns

### Key Features
- **Nix Package Management**: All development tools managed declaratively through Nix
- **Home-Manager Integration**: User configuration managed with the same patterns as host
- **Certificate Management**: Automatic Zscaler certificate integration
- **SSH Agent Forwarding**: Secure Git operations using host SSH keys
- **Fish Shell + Starship**: Modern shell with prompt, configured via Nix
- **Git Integration**: Automatic configuration from environment variables

## Files

- **`devcontainer.json`** - Simplified container configuration focusing on essentials
- **`Dockerfile`** - Streamlined Ubuntu base with Nix and certificate setup
- **`nix-setup.sh`** - **New**: Nix-based setup using home-manager (replaces complex startup.sh)
- **`startup.sh`** - **Legacy**: Kept for compatibility, now minimal
- **`zscaler-root-ca.crt`** - Corporate certificate for Zscaler environments

## Benefits of Refactoring

### Before (Complex Setup)
- ❌ **Fragmented configuration** across multiple files
- ❌ **Redundant package installations** in Dockerfile and startup.sh
- ❌ **Manual shell configuration** with complex scripts
- ❌ **Inconsistent certificate handling**
- ❌ **Difficult to maintain** due to scattered settings

### After (Nix-Centric Approach)
- ✅ **Consolidated configuration** using Nix home-manager
- ✅ **Single source of truth** for development tools
- ✅ **Declarative setup** with reproducible results
- ✅ **Consistent with host** NixOS configuration patterns
- ✅ **Easy to maintain** and extend

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

### Automatic Setup
The container automatically configures itself when opened in VS Code:

1. **Nix Installation**: Nix package manager with flakes support
2. **Home-Manager Setup**: Declarative user configuration
3. **Development Tools**: Fish shell, Starship prompt, Git, essential tools
4. **SSH Integration**: Agent forwarding for secure Git operations
5. **Certificate Setup**: Zscaler certificate integration

### Manual Setup (if needed)
If automatic setup fails, run manually:

```bash
# Run the Nix-based setup
./.devcontainer/nix-setup.sh

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
