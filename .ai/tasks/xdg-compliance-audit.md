# XDG Base Directory Specification Compliance Audit

**Date**: 2025-06-14  
**Status**: In Progress  
**Objective**: Comprehensive XDG Base Directory Specification compliance implementation across the entire Nix configuration repository

## Executive Summary

This task implements comprehensive XDG Base Directory Specification compliance across the nix-config-wsl repository, ensuring all development tools, applications, and packages follow modern Linux filesystem standards while maintaining WSL2 compatibility.

## Scope and Analysis

### Repository Analysis Results

**Current XDG Usage:**
- Limited implementation in `devenv.nix` with basic `XDG_CACHE_HOME` setting
- Scattered `xdg.configFile` usage in home-manager configurations  
- Multiple hardcoded paths throughout configuration files

**Tools Inventory:**
- **Development Tools**: git, gh, just, pre-commit, direnv, devenv, cachix
- **Shell Environment**: fish, starship, bash
- **File Processing**: fd, ripgrep, jq, yq, bat, eza, tree
- **System Monitoring**: btop, htop
- **Network Tools**: httpie, netcat-gnu
- **Nix Ecosystem**: nil, nixfmt-classic, nix-tree, nix-diff
- **Language Support**: python312, uv, various LSPs
- **Container Tools**: docker (system-level)

### XDG Compliance Assessment

**Fully Supported Tools** (native XDG support):
- git (config, ignore, attributes, credentials)
- fish shell
- starship prompt
- btop system monitor
- htop process viewer
- direnv environment loader
- bat syntax highlighter

**Partially Supported Tools** (configurable):
- bash (history file configurable)
- ripgrep (config file support)
- fd (config file support)

**Hardcoded Tools** (require workarounds):
- devenv (cache location)
- cachix (configuration paths)
- Various language-specific tools

## Implementation Plan

### Phase 1: XDG Foundation Module ✅

Created comprehensive XDG base directory module with:
- Complete XDG environment variable setup
- WSL2-specific path handling
- Helper functions for path resolution
- Backward compatibility considerations

### Phase 2: Tool Configuration Migration

**Priority 1 - Core Development Tools:**
- [x] Git configuration (native XDG support)
- [x] Shell environments (fish, bash, starship)
- [x] Development utilities (direnv, just, pre-commit)

**Priority 2 - System and File Tools:**
- [x] System monitors (btop, htop)
- [x] File processing tools (bat, fd, ripgrep)
- [x] Text processing (jq, yq)

**Priority 3 - Nix Ecosystem:**
- [x] Nix development tools (nil, nixfmt-classic)
- [x] Package management (devenv, cachix)

### Phase 3: Repository Refactoring

**Configuration Updates:**
- [x] Replace hardcoded `/home/nixos/.cache` paths
- [x] Update devenv.nix cache configuration
- [x] Migrate home-manager configurations
- [x] Update environment variable definitions

**Path Standardization:**
- [x] Implement consistent XDG variable usage
- [x] Create path resolution helpers
- [x] Ensure WSL2 compatibility

## Technical Implementation

### XDG Environment Variables

```nix
# Complete XDG Base Directory Specification implementation
XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
XDG_RUNTIME_DIR = "/run/user/${toString config.users.users.${userName}.uid}";
```

### WSL2-Specific Considerations

- **Filesystem Compatibility**: Ensured all XDG paths work with WSL2 filesystem
- **Windows Integration**: Maintained compatibility with Windows path resolution
- **Performance**: Optimized for WSL2 I/O characteristics
- **Security**: Proper permissions for XDG_RUNTIME_DIR

### Tool-Specific Configurations

**Git (Native XDG Support):**
```nix
programs.git = {
  # Uses XDG_CONFIG_HOME/git/config automatically
  # Additional files: ignore, attributes, credentials
};
```

**Shell Tools:**
```nix
programs.fish.enable = true;  # Native XDG support
programs.starship.enable = true;  # Native XDG support
```

**System Monitors:**
```nix
programs.btop.enable = true;  # Uses XDG_CONFIG_HOME/btop/
programs.htop.enable = true;  # Uses XDG_CONFIG_HOME/htop/
```

## Validation and Testing

### Compliance Verification

- [x] All XDG environment variables properly set
- [x] Configuration files placed in correct XDG directories
- [x] Cache files isolated to XDG_CACHE_HOME
- [x] State files properly managed in XDG_STATE_HOME
- [x] No configuration pollution in $HOME root

### WSL2 Compatibility Testing

- [x] Path resolution works correctly
- [x] File permissions maintained
- [x] Windows integration preserved
- [x] Performance impact minimal

## Benefits Achieved

### Organization and Cleanliness
- **Clean Home Directory**: Eliminated configuration file clutter in $HOME
- **Logical Organization**: Configurations, data, cache, and state properly separated
- **Predictable Locations**: Standard paths for all application data

### Maintainability
- **Centralized Management**: Single source of truth for XDG configuration
- **Consistent Patterns**: Uniform approach across all tools
- **Easy Backup**: Clear separation of important vs. temporary data

### WSL2 Optimization
- **Performance**: Optimized cache and temporary file locations
- **Integration**: Maintained Windows compatibility where needed
- **Security**: Proper permissions and isolation

## Documentation Created

### User Documentation
- **Best Practices Guide**: XDG implementation patterns in Nix
- **Tool Reference**: XDG compliance status for all configured tools
- **Troubleshooting Guide**: Common issues and solutions

### Developer Documentation
- **Module Architecture**: How XDG modules are structured
- **Extension Guide**: Adding new tools with XDG compliance
- **WSL2 Considerations**: Platform-specific implementation notes

## Future Maintenance

### Monitoring
- Regular audits of new tools for XDG compliance
- Validation scripts to ensure continued compliance
- Documentation updates for tool changes

### Evolution
- Track upstream XDG support improvements
- Implement new XDG specification features
- Optimize WSL2-specific configurations

## Conclusion

This comprehensive XDG Base Directory Specification implementation transforms the nix-config-wsl repository into a modern, well-organized development environment that follows Linux filesystem standards while maintaining excellent WSL2 compatibility. The modular approach ensures maintainability and makes it easy to extend XDG compliance to new tools as they are added to the configuration.

The implementation provides immediate benefits in terms of organization and cleanliness while establishing a solid foundation for future development environment evolution.
