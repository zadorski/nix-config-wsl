# NixOS WSL Development System Configuration

This directory contains system-level NixOS configuration modules for the WSL development environment. These configurations provide the foundation for a productive development experience with enhanced startup, session management, and development tools.

## Enhanced Development Features

### Fish Shell Session Management

The Fish shell is configured with intelligent session management that enhances workflow continuity:

**Session Restoration:**
- Automatically restores your last working directory when starting a new shell session
- Falls back to home directory if the previous directory no longer exists
- Session state is preserved in `~/.config/fish/last_dir`

**Usage:**
```bash
# Your shell will automatically restore to the last directory you were working in
# No manual configuration needed - works transparently
```

### SSH Key Management with Keychain

Keychain integration provides seamless SSH authentication without repeated passphrase prompts:

**Automatic Key Loading:**
- Loads SSH keys automatically on shell startup
- Supports multiple key types: `id_maco`, `id_rsa`, `id_ed25519`
- Compatible with GitHub and Azure DevOps SSH requirements
- Eliminates authentication friction in development workflows

**Supported Keys:**
- `~/.ssh/id_maco` - GitHub authentication
- `~/.ssh/id_rsa` - Azure DevOps authentication
- `~/.ssh/id_ed25519` - Modern Ed25519 keys

### Enhanced Directory Listing (Eza)

Eza is configured with development-optimized table views that provide essential information at a glance:

**Available Commands:**
- `ls` - Basic listing with icons and git status
- `ll` - Detailed table view with relative timestamps
- `la` - Comprehensive listing including hidden files with headers
- `lld` - Full development view with permissions and extended attributes
- `tree` - Project structure overview (3 levels deep)
- `treed` - Detailed tree view for deep project analysis (4 levels)

**Information Displayed:**
- File permissions (when relevant for troubleshooting)
- File sizes (for optimization decisions)
- Relative modification times (for recent changes)
- Git status indicators (for version control awareness)
- Clean column layout without heavy borders

### Development Environment Variables

Curated environment variables enhance productivity without bloating the shell:

**Editor Configuration:**
- `EDITOR=nvim` - Default editor for all tools
- `VISUAL=nvim` - Visual editor for complex editing
- `GIT_EDITOR=nvim` - Git commit message editor

**Development Tools:**
- `DOCKER_BUILDKIT=1` - Enable Docker BuildKit for faster builds
- `COMPOSE_DOCKER_CLI_BUILD=1` - Use Docker CLI for compose builds
- `BAT_THEME=Catppuccin-mocha` - Consistent syntax highlighting theme

**WSL Optimizations:**
- `BROWSER=wslview` - Integrate with Windows browser
- Development directories auto-created: `~/dev`, `~/projects`

## Shell Configuration

### Architecture
- **System Default**: Bash (for scripts and system operations)
- **User Default**: Fish (for interactive sessions)
- **Integration**: System-level fish enablement ensures proper PATH and nix integration
- **WSL Compatibility**: `/bin/bash` symlink automatically maintained for WSL terminal

### Shell Behavior
```bash
echo $SHELL          # Shows fish path for interactive users
/bin/bash script.sh  # Scripts can still use bash explicitly
fish                 # Fish available with full nix integration
ls -la /bin/bash     # WSL-compatible bash symlink exists
```

### WSL Terminal Compatibility

The system automatically ensures WSL terminal compatibility by:
- Creating and maintaining `/bin/bash` symlink to the Nix store bash executable
- Using `environment.binsh` to set the system shell path
- Running activation scripts to ensure symlink exists after system updates

This prevents the WSL terminal error: "The terminal process failed to launch: Path to shell executable '/bin/bash' does not exist."

## Troubleshooting

### WSL Terminal Issues

**Problem:** WSL terminal fails to launch with "/bin/bash does not exist" error
```bash
# Check if /bin/bash symlink exists
ls -la /bin/bash

# If missing, rebuild the system configuration
sudo nixos-rebuild switch --flake .

# Verify the symlink was created
ls -la /bin/bash
# Should show: /bin/bash -> /nix/store/.../bash
```

**Problem:** WSL terminal works but shows wrong shell
```bash
# Check current shell
echo $SHELL

# Check available shells
cat /etc/shells

# Switch to fish for interactive use
chsh -s $(which fish)
```

### Session Management Issues

**Problem:** Shell doesn't restore previous directory
```bash
# Check if last_dir file exists and is readable
ls -la ~/.config/fish/last_dir
cat ~/.config/fish/last_dir

# Manually reset session state
rm ~/.config/fish/last_dir
```

**Problem:** Permission denied on directory restoration
```bash
# The shell will automatically fall back to home directory
# Check directory permissions if needed
ls -ld /path/to/previous/directory
```

### SSH Key Management Issues

**Problem:** SSH keys not loading automatically
```bash
# Check if keychain is installed
which keychain

# Verify SSH keys exist
ls -la ~/.ssh/

# Manually test keychain
keychain ~/.ssh/id_maco ~/.ssh/id_rsa
source ~/.keychain/$(hostname)-sh
```

**Problem:** Repeated passphrase prompts
```bash
# Check keychain status
keychain -l

# Clear and reload keychain
keychain --clear
# Restart shell to reload keys
```

### Directory Listing Issues

**Problem:** Eza commands not working
```bash
# Check if eza is installed
which eza

# Test basic functionality
eza --version

# Fall back to basic ls if needed
/bin/ls -la
```

**Problem:** Git status not showing in listings
```bash
# Ensure you're in a git repository
git status

# Check git integration
eza --git --long
```

### Environment Variable Issues

**Problem:** Environment variables not set
```bash
# Check current environment
env | grep -E "(EDITOR|DOCKER|BAT)"

# Reload shell configuration
exec fish
```

## Performance Considerations

### WSL Optimization

The configuration is optimized for WSL performance:
- Minimal startup overhead with conditional loading
- Efficient keychain integration
- Lightweight eza table formatting
- Selective environment variable loading

### Memory Usage

- Session state files are minimal (single directory path)
- Keychain uses efficient SSH agent integration
- Environment variables are curated for necessity

## Accessibility

All configurations maintain WCAG 2.1 AA compliance:
- Catppuccin Mocha color scheme with 4.5:1+ contrast ratios
- Clear table formatting without visual clutter
- Consistent color usage across tools

## Integration

These system configurations integrate seamlessly with:
- **Starship Prompt** - Enhanced with environment awareness
- **Direnv** - Automatic project environment loading
- **Docker/Devcontainers** - Optimized build settings
- **Azure DevOps** - SSH key compatibility

For more detailed configuration information, see the individual module files in this directory.
