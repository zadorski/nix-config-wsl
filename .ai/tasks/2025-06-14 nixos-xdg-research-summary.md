# NixOS XDG Base Directory Specification Research Summary

**Date**: 2025-06-14  
**Objective**: Research and implement NixOS/home-manager XDG best practices for development environments

## Research Findings

### NixOS/Home-Manager XDG Best Practices

#### Core Principles
1. **Use `xdg.enable = true`**: Enables home-manager's built-in XDG support
2. **Leverage `config.xdg.*` paths**: Use `config.xdg.configHome`, `config.xdg.dataHome`, etc. instead of hardcoded paths
3. **Prefer `xdg.configFile`**: Use home-manager's XDG configuration file management over manual `home.file`
4. **Automatic directory creation**: Home-manager creates XDG directories automatically when `xdg.enable = true`

#### Home-Manager XDG Module Structure
```nix
xdg = {
  enable = true;  # Enables XDG support and sets environment variables
  configHome = "${config.home.homeDirectory}/.config";  # Optional explicit setting
  dataHome = "${config.home.homeDirectory}/.local/share";
  stateHome = "${config.home.homeDirectory}/.local/state";
  cacheHome = "${config.home.homeDirectory}/.cache";
  
  userDirs.enable = true;  # Creates XDG user directories
  mimeApps.enable = true;  # Manages MIME associations
};
```

#### Configuration File Management
```nix
# Preferred approach using xdg.configFile
xdg.configFile."tool/config".text = ''
  # configuration content
'';

# Instead of manual home.file approach
home.file.".config/tool/config".text = ''
  # configuration content
'';
```

### Development Environment XDG Integration

#### Docker XDG Compliance
- **DOCKER_CONFIG**: Set to `${config.xdg.configHome}/docker`
- **Build Cache**: Use XDG cache directories for BuildKit cache
- **Credential Storage**: Configure credential helpers to use XDG paths
- **Container Mounts**: Map XDG directories into development containers

#### DevContainer XDG Support
- **Volume Mounts**: Map host XDG directories to container XDG paths
- **Environment Variables**: Propagate XDG variables into containers
- **Configuration Persistence**: Ensure development tools in containers use XDG paths

#### DevEnv XDG Integration
- **Cache Location**: Use `${config.xdg.cacheHome}/devenv` for devenv state
- **Environment Variables**: Ensure devenv environments respect XDG paths
- **Tool Configuration**: Configure development tools within devenv to use XDG

### WSL2-Specific Considerations

#### Performance Optimizations
- **Cache Placement**: Use WSL2 filesystem for cache directories (better performance)
- **Temporary Files**: Configure `TMPDIR` to use XDG cache for better I/O
- **Build Artifacts**: Place build caches in XDG cache directories

#### Runtime Directory Handling
- **XDG_RUNTIME_DIR**: WSL2 may not have proper systemd setup
- **Fallback Strategy**: Use `${config.xdg.cacheHome}/runtime` as fallback
- **Permissions**: Ensure proper 700 permissions for runtime directories

#### Windows Integration
- **Separate Paths**: Keep Windows-specific configurations separate from XDG
- **Dual Support**: Support both Windows and Linux tool configurations
- **Path Translation**: Handle Windows/Linux path differences appropriately

### Tool-Specific XDG Implementation

#### Native XDG Support (No Configuration Needed)
- **Git**: Automatically uses XDG directories since 2012
- **Fish Shell**: Native XDG support for all configuration
- **Starship**: Uses `XDG_CONFIG_HOME/starship.toml`
- **Btop/Htop**: Native XDG configuration directory support
- **Bat**: Native XDG support for themes and configuration
- **Direnv**: Native XDG support for configuration

#### Configurable XDG Support (Environment Variables)
- **Bash**: `HISTFILE` can be set to XDG state directory
- **Python**: `PYTHONUSERBASE`, `PYTHONPYCACHEPREFIX`
- **Node.js/NPM**: `NPM_CONFIG_*` variables
- **Rust/Cargo**: `CARGO_HOME`
- **Go**: `GOPATH`, `GOCACHE`
- **Docker**: `DOCKER_CONFIG`

#### Limited/No XDG Support (Workarounds Required)
- **SSH**: Doesn't support XDG, but can set custom variables for scripts
- **DevEnv**: Cache location configurable via `devenv.root`
- **Legacy Tools**: May require symlinks or wrapper scripts

## Implementation Decisions and Trade-offs

### NixOS Community Consensus
1. **Prefer home-manager XDG module**: Use built-in support over manual implementation
2. **Use `config.xdg.*` paths**: More maintainable than hardcoded paths
3. **Enable XDG by default**: Modern NixOS configurations should use XDG
4. **Gradual migration**: Don't break existing configurations, migrate incrementally

### Development Workflow Priorities
1. **Performance over purity**: Use cache optimizations even if not strictly XDG
2. **Container compatibility**: Ensure XDG works in development containers
3. **Tool ecosystem support**: Prioritize tools that support XDG natively
4. **Fallback strategies**: Provide fallbacks for environments without full XDG support

### WSL2-Specific Decisions
1. **Filesystem optimization**: Use WSL2 filesystem characteristics for better performance
2. **Runtime directory fallback**: Handle missing systemd gracefully
3. **Windows integration preservation**: Don't break existing Windows tool support
4. **Development container support**: Ensure XDG works with VS Code devcontainers

## Validation Strategy

### Automated Testing
- **Environment Variable Validation**: Check all XDG variables are set correctly
- **Directory Structure Verification**: Ensure XDG directories exist with proper permissions
- **Tool Configuration Testing**: Verify tools use XDG paths correctly
- **Container Integration Testing**: Test XDG compliance in development containers

### Manual Verification
- **Home Directory Cleanliness**: Check for configuration file pollution
- **Tool Functionality**: Verify tools work correctly with XDG paths
- **Performance Testing**: Ensure XDG implementation doesn't impact performance
- **Cross-Platform Testing**: Verify WSL2 and container compatibility

## Recommendations

### Immediate Implementation
1. **Enable home-manager XDG**: Use `xdg.enable = true`
2. **Migrate to `config.xdg.*` paths**: Replace hardcoded paths
3. **Use `xdg.configFile`**: Prefer home-manager configuration file management
4. **Implement development tool XDG support**: Configure Docker, NPM, Cargo, Go

### Future Enhancements
1. **Container optimization**: Enhance devcontainer XDG integration
2. **Tool ecosystem expansion**: Add XDG support for additional development tools
3. **Performance monitoring**: Track XDG implementation performance impact
4. **Community contribution**: Share XDG patterns with NixOS community

### Maintenance Strategy
1. **Regular audits**: Periodically check for new tools and XDG support
2. **Upstream tracking**: Monitor home-manager and tool XDG improvements
3. **Documentation updates**: Keep XDG documentation current with changes
4. **Validation automation**: Maintain automated XDG compliance testing

## Conclusion

The research confirms that NixOS/home-manager provides excellent XDG Base Directory Specification support through built-in modules. The key is leveraging these built-in capabilities rather than implementing manual XDG support. This approach provides better integration, maintainability, and follows community best practices while optimizing for development workflows and WSL2 characteristics.
