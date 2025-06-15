# XDG Base Directory Specification Implementation Guide

## Overview

This document provides comprehensive guidance for implementing XDG Base Directory Specification compliance in the nix-config-wsl repository using NixOS/home-manager best practices. It covers development workflow integration, containerization support, and WSL2 optimizations.

## Revision Notes

This implementation has been revised to follow NixOS community best practices:
- **Home-Manager Integration**: Uses `xdg.enable = true` and built-in XDG support
- **Development Workflows**: Enhanced Docker, devcontainer, and devenv integration
- **Performance Optimization**: WSL2-specific optimizations for development environments
- **Container Support**: Comprehensive devcontainer XDG compliance

## XDG Base Directory Specification Summary

The XDG Base Directory Specification defines standard locations for application files:

### Primary Directories

- **`XDG_CONFIG_HOME`** (`~/.config`): User-specific configuration files
- **`XDG_DATA_HOME`** (`~/.local/share`): User-specific data files
- **`XDG_STATE_HOME`** (`~/.local/state`): User-specific state files
- **`XDG_CACHE_HOME`** (`~/.cache`): User-specific non-essential cached data
- **`XDG_RUNTIME_DIR`** (`/run/user/$UID`): User-specific runtime files

### System Directories

- **`XDG_DATA_DIRS`** (`/usr/local/share:/usr/share`): System data directories
- **`XDG_CONFIG_DIRS`** (`/etc/xdg`): System configuration directories

## Implementation Architecture

### Core Module Structure (Revised)

```nix
# home/xdg.nix - NixOS Best Practices
{
  # Enable home-manager's built-in XDG support
  xdg = {
    enable = true;  # Automatically sets XDG environment variables

    # Explicit XDG directory configuration (optional)
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
    cacheHome = "${config.home.homeDirectory}/.cache";

    # Enable additional XDG features
    userDirs.enable = true;    # XDG user directories
    mimeApps.enable = true;    # MIME associations
  };

  # Development environment variables using config.xdg paths
  home.sessionVariables = {
    DEVENV_ROOT = "${config.xdg.cacheHome}/devenv";
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    # ... other development tools
  };

  # Configuration files using xdg.configFile (preferred)
  xdg.configFile = {
    "docker/config.json".text = builtins.toJSON { /* config */ };
    "npm/npmrc".text = "cache=${config.xdg.cacheHome}/npm";
    # ... other configurations
  };
}
```

### Integration Pattern

1. **XDG Module**: Provides environment variables and directory structure
2. **Tool Modules**: Configure specific applications with XDG compliance
3. **Validation**: Scripts to verify XDG compliance

## Tool-Specific Configurations

### Fully XDG-Compliant Tools

These tools natively support XDG Base Directory Specification:

#### Git (Native Support)
```nix
programs.git = {
  enable = true;
  # Automatically uses:
  # - XDG_CONFIG_HOME/git/config
  # - XDG_CONFIG_HOME/git/ignore
  # - XDG_CONFIG_HOME/git/attributes
  # - XDG_CONFIG_HOME/git/credentials
};
```

#### Fish Shell (Native Support)
```nix
programs.fish = {
  enable = true;
  # Automatically uses XDG_CONFIG_HOME/fish/
};
```

#### Starship Prompt (Native Support)
```nix
programs.starship = {
  enable = true;
  # Automatically uses XDG_CONFIG_HOME/starship.toml
};
```

#### System Monitors (Native Support)
```nix
programs.btop.enable = true;    # Uses XDG_CONFIG_HOME/btop/
programs.htop.enable = true;    # Uses XDG_CONFIG_HOME/htop/
```

#### File Tools (Native Support)
```nix
programs.bat.enable = true;     # Uses XDG_CONFIG_HOME/bat/
programs.direnv.enable = true;  # Uses XDG_CONFIG_HOME/direnv/
```

### Configurable Tools

These tools can be configured to use XDG directories:

#### Bash History
```nix
programs.bash = {
  historyFile = "${config.home.homeDirectory}/.local/state/bash/history";
  initExtra = ''
    mkdir -p "$(dirname "$HISTFILE")"
  '';
};
```

#### Development Tools
```nix
home.sessionVariables = {
  # Python
  PYTHONUSERBASE = "${config.home.homeDirectory}/.local";
  PYTHONPYCACHEPREFIX = "${config.home.homeDirectory}/.cache/python";

  # Node.js/NPM
  NPM_CONFIG_USERCONFIG = "${config.home.homeDirectory}/.config/npm/npmrc";
  NPM_CONFIG_CACHE = "${config.home.homeDirectory}/.cache/npm";

  # Rust/Cargo
  CARGO_HOME = "${config.home.homeDirectory}/.local/share/cargo";

  # Go
  GOPATH = "${config.home.homeDirectory}/.local/share/go";
  GOCACHE = "${config.home.homeDirectory}/.cache/go";
};
```

### Hardcoded Tools (Workarounds Required)

#### DevEnv Cache Management
```nix
devenv = {
  root = "${builtins.getEnv "XDG_CACHE_HOME"}/devenv/project-name";
};

env = {
  DEVENV_ROOT = "${builtins.getEnv "XDG_CACHE_HOME"}/devenv/project-name";
};
```

## WSL2-Specific Considerations

### Filesystem Compatibility
- All XDG paths work correctly with WSL2 filesystem
- Windows integration paths remain separate
- Performance optimized for WSL2 I/O characteristics

### Runtime Directory Handling
```nix
home.activation.createXdgRuntimeDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
  # WSL2 fallback for XDG_RUNTIME_DIR
  if [ ! -d "/run/user/1000" ]; then
    $DRY_RUN_CMD mkdir -p "/tmp/user-runtime-1000"
    $DRY_RUN_CMD chmod 700 "/tmp/user-runtime-1000"
  fi
'';
```

### Windows Integration Preservation
- Windows-specific configurations remain in `home/windows/`
- XDG compliance doesn't interfere with Windows app configurations
- Dual-path support for cross-platform tools

## Best Practices

### Module Organization
1. **Separation of Concerns**: XDG environment setup separate from tool configuration
2. **Layered Approach**: Base XDG → Tool-specific → Theme/customization
3. **Conflict Avoidance**: Prevent duplicate program enablement

### Configuration Patterns
```nix
# Good: Complementary configuration
programs.tool = {
  # enable handled elsewhere
  settings = {
    # tool-specific settings
  };
};

# Avoid: Duplicate enablement
programs.tool = {
  enable = true;  # if already enabled in XDG module
};
```

### Directory Structure
```
~/.config/          # XDG_CONFIG_HOME
├── git/
├── fish/
├── starship.toml
└── ...

~/.local/share/     # XDG_DATA_HOME
├── applications/
├── fonts/
└── ...

~/.local/state/     # XDG_STATE_HOME
├── bash/
└── ...

~/.cache/           # XDG_CACHE_HOME
├── nix/
├── devenv/
└── ...
```

## Validation and Testing

### Compliance Verification
```bash
# Check XDG environment variables
echo $XDG_CONFIG_HOME
echo $XDG_DATA_HOME
echo $XDG_STATE_HOME
echo $XDG_CACHE_HOME

# Verify directory structure
ls -la ~/.config
ls -la ~/.local/share
ls -la ~/.local/state
ls -la ~/.cache
```

### Clean Home Directory Check
```bash
# Should show minimal files in $HOME
ls -la ~ | grep -v "^d" | wc -l
```

### Tool-Specific Validation
```bash
# Git configuration location
git config --list --show-origin | grep config

# Fish configuration location
fish -c 'echo $__fish_config_dir'

# Starship configuration
starship config
```

## Migration Guide

### From Hardcoded Paths
1. **Identify**: Find hardcoded paths like `/home/user/.config`
2. **Replace**: Use XDG variables or home-manager paths
3. **Test**: Verify functionality after migration
4. **Clean**: Remove old configuration files

### Example Migration
```nix
# Before
DEVENV_ROOT = "/home/nixos/.cache/devenv/project";

# After
DEVENV_ROOT = "${builtins.getEnv "XDG_CACHE_HOME"}/devenv/project";
```

## Troubleshooting

### Common Issues

#### Missing XDG Variables
**Problem**: Tools not finding configuration files
**Solution**: Ensure XDG variables are set in session

#### Permission Issues
**Problem**: Cannot create XDG directories
**Solution**: Check home directory permissions

#### WSL2 Runtime Directory
**Problem**: XDG_RUNTIME_DIR not available
**Solution**: Use fallback activation script

### Debugging Commands
```bash
# Check environment
env | grep XDG

# Verify directory creation
find ~/.config ~/.local ~/.cache -name ".keep" 2>/dev/null

# Test tool configuration
git config --list --show-origin
fish -c 'set -S'
```

## Future Maintenance

### Adding New Tools
1. **Research**: Check tool's XDG compliance status
2. **Configure**: Add appropriate configuration
3. **Document**: Update tool reference
4. **Test**: Verify XDG compliance

### Monitoring Compliance
- Regular audits of new tools
- Validation script execution
- Documentation updates

### Evolution Strategy
- Track upstream XDG support improvements
- Implement new XDG specification features
- Optimize WSL2-specific configurations

## References

- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/latest/)
- [Arch Linux XDG Base Directory Wiki](https://wiki.archlinux.org/title/XDG_Base_Directory)
- [Home Manager XDG Options](https://nix-community.github.io/home-manager/options.html#opt-xdg.enable)
