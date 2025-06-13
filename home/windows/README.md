# Windows Native Application Configuration

This directory contains configurations for Windows native applications that integrate with the WSL environment. The system provides seamless configuration management across the WSL-Windows boundary while maintaining the repository's modular philosophy.

## Overview

The Windows integration system extends nix-config-wsl to manage Windows native applications alongside the existing WSL environment. It provides:

- **Dynamic Windows path resolution** without hardcoded paths
- **Reliable file linking/copying** between WSL and Windows
- **Conditional loading** with `lib.mkIf` patterns
- **Comprehensive validation** and troubleshooting tools
- **Catppuccin Mocha theme consistency** across environments

## Architecture

### Core Components

- **`default.nix`** - Main Windows integration module with configuration options
- **`lib.nix`** - Helper functions for Windows path resolution and file management
- **Application modules** - Individual configuration files for each Windows application

### Application Modules

- **`fonts.nix`** - Font management and automated installation of CaskaydiaCove Nerd Font
- **`terminal.nix`** - Windows Terminal with Catppuccin Mocha theme and WSL profiles
- **`powershell.nix`** - PowerShell profiles with Starship integration and development tools
- **`vscode.nix`** - VS Code settings synchronized between WSL and Windows
- **`git.nix`** - Git configuration with cross-platform line ending and credential management
- **`ssh.nix`** - SSH key sharing and configuration synchronization

## Dynamic Windows Environment Detection

The Windows integration system now includes advanced dynamic environment detection that automatically discovers Windows paths, usernames, and system configuration without hardcoded values.

### How Dynamic Detection Works

1. **Runtime Environment Detection**: Uses WSL utilities (`wslvar`, `wslpath`) to query Windows environment variables
2. **Automatic Path Resolution**: Dynamically resolves Windows user directories, application data paths, and system directories
3. **Graceful Fallbacks**: Falls back to standard paths when Windows environment is unavailable
4. **Shell Integration**: Automatically loads detected environment variables in bash and fish shells

### Environment Variables Detected

- **`WIN_USERNAME`** - Windows username (from `wslvar USERNAME`)
- **`WIN_USERPROFILE`** - Windows user home directory (from `wslvar USERPROFILE`)
- **`WIN_APPDATA`** - Application data directory (from `wslvar APPDATA`)
- **`WIN_LOCALAPPDATA`** - Local application data directory (from `wslvar LOCALAPPDATA`)
- **`WIN_DRIVE_MOUNT`** - Windows C: drive mount point (auto-detected)
- **`WIN_DOCUMENTS`** - Windows Documents folder
- **`WIN_DESKTOP`** - Windows Desktop folder
- **`WIN_DOWNLOADS`** - Windows Downloads folder

### Dynamic Detection Commands

```bash
# detect Windows environment (runs automatically on home-manager activation)
detect-windows-environment

# validate detected environment
validate-windows-environment

# load environment variables in current shell
load-windows-environment
```

### Environment File Location

Dynamic environment variables are stored in `~/.config/nix-windows-env` and automatically loaded by shell initialization.

## Configuration

### Enabling Windows Integration

Add to your flake configuration:

```nix
# In your home-manager configuration
programs.windows-integration = {
  enable = true;
  windowsUsername = "your-windows-username"; # optional, defaults to WSL username
  
  applications = {
    terminal = true;     # Windows Terminal configuration
    powershell = true;   # PowerShell profile management
    vscode = true;       # VS Code settings synchronization
    git = true;          # Git configuration synchronization
    ssh = true;          # SSH key sharing
  };

  fonts = {
    enable = true;       # Font management and installation
    primaryFont = "CaskaydiaCove Nerd Font";  # Primary font family
    autoInstall = true;  # Automatically install fonts if missing
    sizes = {
      terminal = 11;     # Font size for terminal applications
      editor = 14;       # Font size for editor applications
    };
  };
  
  pathResolution = {
    method = "dynamic";  # "dynamic" (recommended), "wslpath", "environment", or "manual"
  };
  
  fileManagement = {
    strategy = "symlink";      # "symlink", "copy", or "template"
    backupOriginals = true;    # backup existing Windows configs
  };
};
```

### Path Resolution Methods

1. **`dynamic` (recommended)** - Uses runtime Windows environment detection with WSL utilities
2. **`wslpath`** - Uses WSL's `wslpath` command for dynamic path conversion
3. **`environment`** - Uses standard `/mnt/c/Users/username` paths
4. **`manual`** - Allows custom path specification for non-standard setups

### File Management Strategies

1. **`symlink` (default)** - Creates symbolic links from WSL to Windows files
2. **`copy`** - Copies configuration files to Windows locations
3. **`template`** - Generates configuration files from templates

## Validation and Troubleshooting

### Validation Commands

After enabling Windows integration, use these commands to validate the setup:

```bash
# validate overall Windows integration
validate-windows-integration

# validate Windows environment detection
validate-windows-environment

# detect Windows environment manually
detect-windows-environment

# validate font installation
validate-fonts

# install fonts manually
install-fonts

# validate specific applications
validate-git-config
validate-ssh-config

# fix SSH permissions
fix-ssh-permissions

# sync SSH keys manually
sync-ssh-keys
```

### Common Issues and Solutions

#### 1. Path Resolution Failures

**Problem**: Windows paths not resolving correctly
**Solution**: 
- Ensure `wslpath` command is available: `which wslpath`
- Try different path resolution method: `pathResolution.method = "environment"`
- Use manual path overrides for non-standard Windows installations

#### 2. Permission Issues

**Problem**: SSH keys or configuration files have incorrect permissions
**Solution**:
- Run `fix-ssh-permissions` to correct SSH key permissions
- Ensure WSL has access to Windows user directory
- Check Windows file permissions for the target directories

#### 3. Symlink Creation Failures

**Problem**: Cannot create symlinks between WSL and Windows
**Solution**:
- Enable Developer Mode in Windows Settings
- Use `copy` strategy instead of `symlink`
- Ensure target directories exist and are writable

#### 4. Application Not Found

**Problem**: Windows application directories not found
**Solution**:
- Verify application is installed on Windows
- Check if application uses non-standard installation paths
- Use manual path overrides in configuration

### WSL Configuration Requirements

Ensure your `/etc/wsl.conf` includes:

```ini
[automount]
enabled = true
root = /mnt/
options = "metadata,umask=22,fmask=11"

[interop]
enabled = true
appendWindowsPath = true
```

## Font Management

The Windows integration system includes comprehensive font management capabilities that ensure consistent typography across all Windows applications.

### Font Installation

The system automatically downloads and installs **CaskaydiaCove Nerd Font** from the official Nerd Fonts GitHub repository. This font provides:

- **Complete Nerd Font icon support** for enhanced terminal and editor experience
- **Cascadia Code base** with Microsoft's excellent programming font design
- **Ligature support** for better code readability
- **Multiple variants** including Regular, Bold, Italic, and Bold Italic

### Font Configuration

All Windows applications are configured with a consistent font fallback chain:

1. **CaskaydiaCove Nerd Font** (primary with icon support)
2. **Cascadia Code** (fallback without icons)
3. **Cascadia Mono** (monospace variant)
4. **Consolas** (Windows system font)
5. **Courier New** (universal fallback)

### Font Sizes

Standardized font sizes across applications:
- **Terminal applications**: 11pt (Windows Terminal, PowerShell console)
- **Editor applications**: 14pt (VS Code editor, text editors)

### Font Validation

Use the font validation tools to ensure proper installation:

```bash
# comprehensive font validation
validate-fonts

# manual font installation (if automatic fails)
install-fonts

# force reinstall fonts
install-fonts --force
```

### Font Troubleshooting

#### Font Not Appearing in Applications

1. **Check installation**: Run `validate-fonts` to verify font files are present
2. **Restart applications**: Close and reopen Windows Terminal, VS Code, etc.
3. **Clear font cache**: Restart Windows to refresh the font cache
4. **Manual installation**: Use `install-fonts` to reinstall fonts

#### Permission Issues

1. **User-level installation**: Fonts are installed to user directory (no admin required)
2. **WSL access**: Ensure WSL can access Windows user directories
3. **PowerShell execution**: Verify PowerShell execution policy allows scripts

#### Download Failures

1. **Internet connectivity**: Ensure access to GitHub releases
2. **Proxy settings**: Configure proxy if behind corporate firewall
3. **Manual download**: Download CascadiaCode.zip manually and extract to user fonts directory

## Application-Specific Documentation

### Windows Terminal

- **Theme**: Catppuccin Mocha with WCAG 2.1 AA compliance
- **Profiles**: Optimized WSL, PowerShell, and Command Prompt profiles
- **Keybindings**: Development-focused shortcuts
- **Location**: `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`

### PowerShell

- **Profile**: Enhanced with Starship prompt and development aliases
- **Modules**: PSReadLine with Catppuccin colors
- **Integration**: WSL command shortcuts and environment synchronization
- **Location**: `%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

### VS Code

- **Settings**: Catppuccin Mocha theme with WSL integration
- **Extensions**: Workspace-specific extension recommendations
- **Terminal**: Configured for PowerShell and WSL profiles
- **Location**: `%APPDATA%\Code\User\settings.json`

### Git

- **Configuration**: Synchronized between WSL and Windows
- **Credentials**: Windows Credential Manager integration
- **Line Endings**: Proper handling for cross-platform development
- **Location**: `%USERPROFILE%\.gitconfig`

### SSH

- **Key Sharing**: Symlinks SSH keys from WSL to Windows
- **Configuration**: Unified SSH config for both environments
- **Permissions**: Automatic permission fixing for cross-platform access
- **Location**: `%USERPROFILE%\.ssh\`

## Security Considerations

- **SSH Keys**: Shared keys maintain proper permissions across environments
- **Credentials**: Uses Windows Credential Manager for secure storage
- **File Permissions**: Respects both WSL and Windows permission models
- **Backups**: Original configurations are backed up before modification

## Performance Optimizations

- **Conditional Loading**: Only enabled applications are configured
- **Path Caching**: Windows paths are resolved once and cached
- **File Watching**: Optimized file watching excludes unnecessary directories
- **WSL Integration**: Leverages WSL's native Windows integration features

## Troubleshooting Checklist

1. **WSL Environment**: Verify running in WSL with `validate-windows-integration`
2. **Windows Applications**: Confirm target applications are installed
3. **Permissions**: Check file and directory permissions with validation scripts
4. **Path Resolution**: Test path resolution with different methods
5. **File Strategy**: Try different file management strategies if issues persist
6. **WSL Configuration**: Verify `/etc/wsl.conf` settings
7. **Windows Features**: Ensure Developer Mode is enabled for symlinks

## Contributing

When adding new Windows application configurations:

1. Create a new module file in `home/windows/`
2. Follow the existing pattern with `lib.mkIf` conditional loading
3. Add validation and troubleshooting scripts
4. Update this README with application-specific documentation
5. Test with different path resolution methods and file strategies

## References

- [WSL Documentation](https://docs.microsoft.com/en-us/windows/wsl/)
- [Windows Terminal Documentation](https://docs.microsoft.com/en-us/windows/terminal/)
- [Catppuccin Theme](https://github.com/catppuccin/catppuccin)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
