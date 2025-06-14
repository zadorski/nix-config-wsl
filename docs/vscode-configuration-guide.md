# VSCode Configuration Guide for nix-config-wsl

This guide documents the comprehensive VSCode configuration implemented for optimal Nix-based WSL development.

## Overview

The VSCode configuration uses a **dual-layer approach** combining declarative system settings with workspace-specific customizations to provide an optimal development experience.

## Architecture

### Layer 1: Declarative System Configuration

**File**: `home/windows/vscode.nix`  
**Purpose**: System-wide VSCode settings managed by Nix  
**Benefits**: Reproducible, version-controlled, consistent across projects

#### Key Features
- **400+ comprehensive settings** covering all aspects of the editor
- **Multi-language LSP integration** for Nix, Python, TypeScript, Rust, Go, Shell
- **Catppuccin Mocha theming** with accessibility compliance
- **WSL2 performance optimizations** with intelligent file exclusions
- **Corporate environment support** with SSL certificate integration

### Layer 2: Workspace-Specific Settings

**File**: `.vscode/settings.json`  
**Purpose**: Project-specific overrides and enhancements  
**Benefits**: Flexible, portable, optimized for specific project needs

#### Key Features
- **Nix-specific configurations** for language server and file associations
- **Project-optimized exclusions** for better performance
- **Extension recommendations** tailored to Nix development
- **Devcontainer integration** for fallback development scenarios

## Configuration Highlights

### 🎨 Editor Experience
```nix
# Enhanced editor appearance and behavior
"workbench.colorTheme" = "Catppuccin Mocha";
"editor.bracketPairColorization.enabled" = true;
"editor.minimap.enabled" = true;
"editor.wordWrap" = "bounded";
"editor.rulers" = [ 80 120 ];
```

### 🗂️ File Tree Optimization
```nix
# Intelligent file organization
"explorer.fileNesting.enabled" = true;
"explorer.fileNesting.patterns" = {
  "flake.nix" = "flake.lock";
  "devenv.nix" = "devenv.lock, .devenv.flake.nix";
  "package.json" = "package-lock.json, yarn.lock, pnpm-lock.yaml";
};
```

### 🔧 Language Server Configuration
```nix
# Comprehensive LSP setup
"nix.enableLanguageServer" = true;
"nix.serverPath" = "nil";
"python.analysis.typeCheckingMode" = "basic";
"rust-analyzer.check.command" = "clippy";
"go.useLanguageServer" = true;
```

### ⚡ Performance Optimization
```nix
# WSL2-specific performance tuning
"files.watcherExclude" = {
  "**/nix/store/**" = true;
  "**/.devenv/**" = true;
  "**/.direnv/**" = true;
  # ... 70+ additional exclusions
};
```

## Language Support

### Nix Development (Primary Focus)
- **Language Server**: nil with formatting and diagnostics
- **Formatter**: nixfmt with automatic formatting on save
- **File Associations**: Proper syntax highlighting for .nix files
- **Project Integration**: Flake and devenv file recognition

### Multi-Language Support
- **Python**: Black formatter, type checking, auto-imports
- **TypeScript/JavaScript**: Prettier formatting, ESLint integration
- **Rust**: rust-analyzer with Clippy, inlay hints, cargo integration
- **Go**: Language server with goimports, linting, testing support
- **Shell**: Fish and Bash syntax support with formatting

## Performance Features

### WSL2 Optimizations
- **File Watcher Exclusions**: 70+ patterns to reduce system load
- **Search Optimization**: Smart indexing with result limits
- **Memory Management**: Optimized settings for WSL2 constraints
- **Network Handling**: Corporate proxy and SSL certificate support

### Development Workflow
- **Auto-save**: Intelligent auto-save with 1-second delay
- **Format on Save**: Automatic code formatting across all languages
- **Code Actions**: Organize imports, fix issues automatically
- **Git Integration**: Enhanced git workflow with timeline and decorations

## Integration Points

### System Integration
- **Certificate Management**: Leverages `system/certificates.nix`
- **Development Environment**: Seamless `devenv.nix` integration
- **Shell Configuration**: Consistent with Fish and Starship setup
- **Theming**: Unified Catppuccin Mocha across all tools

### Container Support
- **Devcontainer Configuration**: Enhanced settings for container development
- **Extension Management**: Automatic extension installation in containers
- **Performance Tuning**: Container-specific optimizations
- **SSL Handling**: Corporate certificate propagation to containers

## Usage Instructions

### For Developers

1. **Automatic Setup**: Settings are applied when NixOS rebuilds
2. **Language Servers**: Work immediately upon opening projects
3. **Formatting**: Automatic formatting on save for all supported languages
4. **File Navigation**: Enhanced explorer with nesting and smart exclusions

### For System Administrators

1. **Configuration**: Modify `home/windows/vscode.nix`
2. **Deployment**: `sudo nixos-rebuild switch --flake .#nixos`
3. **Verification**: Check settings are applied across user environments
4. **Monitoring**: Track performance and user experience

### For Project Maintainers

1. **Workspace Settings**: Customize `.vscode/settings.json` per project
2. **Extensions**: Add project-specific recommendations
3. **Language Configuration**: Fine-tune LSP settings
4. **Performance**: Add project-specific exclusions

## Troubleshooting

### Common Issues

#### Language Server Not Working
```bash
# Verify nil is available
which nil
# Check VSCode output panel for errors
# Restart language server: Ctrl+Shift+P -> "Restart Language Server"
```

#### Performance Issues
```bash
# Check file watcher exclusions
# Monitor system resources
# Add additional exclusions if needed
```

#### Settings Not Applied
```bash
# Rebuild NixOS configuration
sudo nixos-rebuild switch --flake .#nixos
# Restart VSCode
# Check Windows integration is enabled
```

### Getting Help

1. **System Logs**: `journalctl -u home-manager-*`
2. **VSCode Logs**: Check VSCode output panel
3. **Configuration Validation**: `nix flake check`
4. **Documentation**: See `docs/` directory for detailed guides

## Future Enhancements

### Planned Improvements
- **Extension Management**: Declarative extension installation
- **Debugging Configuration**: Language-specific debug setups
- **Task Automation**: Integrated build and test tasks
- **Workspace Templates**: Project-specific configurations

### Monitoring Points
- **Performance Metrics**: Track editor responsiveness
- **LSP Reliability**: Monitor language server stability
- **User Experience**: Gather developer feedback
- **Configuration Drift**: Ensure settings remain consistent

## Conclusion

This VSCode configuration provides a comprehensive, performance-optimized development environment that seamlessly integrates with the broader Nix-based WSL setup. The dual-layer approach ensures both system-wide consistency and project-specific flexibility, while the extensive optimizations provide excellent performance in WSL2 environments.

The configuration serves as a solid foundation for Nix development while supporting multi-language workflows with enterprise-grade features for corporate environments.
