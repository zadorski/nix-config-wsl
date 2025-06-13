# Devcontainer Configuration

This devcontainer provides a Nix-based development environment with fish shell and secure SSH/Git integration.

## Features

### Shell Configuration
- **Fish Shell**: Modern shell with intelligent autocompletion and syntax highlighting
- **Default Shell**: Fish is configured as the default login shell for the `vscode` user
- **Nix Integration**: Full Nix environment with flake support
- **Development Aliases**: Pre-configured git and development shortcuts

### SSH/Git Integration
- **SSH Agent Forwarding**: Secure SSH key access without mounting keys directly
- **Git Configuration**: Automatic setup with environment variables
- **Security**: No SSH keys stored in container - uses host SSH agent

## Setup Requirements

### Host Environment Variables
Set these environment variables on your host system for automatic configuration:

```bash
# Git configuration (optional - defaults provided)
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your.email@example.com"
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

### Starting the Container
The devcontainer will automatically:
1. Install fish shell via Nix
2. Configure fish as default shell
3. Set up SSH agent forwarding
4. Configure Git with environment variables
5. Create development aliases and shortcuts

### Verifying Setup

```bash
# Check default shell
echo $SHELL  # Should show fish path

# Test SSH agent forwarding
ssh-add -l  # Should list your SSH keys

# Test Git configuration
git config --global user.name
git config --global user.email

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

## Files Modified

- `.devcontainer/devcontainer.json`: Container configuration with SSH forwarding
- `.devcontainer/startup.sh`: Setup script for fish and SSH/Git configuration
- `.devcontainer/Dockerfile`: Base container image (unchanged)

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GIT_USER_NAME` | `vscode` | Git user name |
| `GIT_USER_EMAIL` | `vscode@localhost` | Git user email |
| `SSH_AUTH_SOCK` | `/ssh-agent` | SSH agent socket path |

## Next Steps

After container setup:
1. Verify fish shell is working: `echo $SHELL`
2. Test SSH access: `ssh -T git@github.com`
3. Test Git operations: `git clone`, `git push`
4. Customize fish configuration in `~/.config/fish/config.fish`
