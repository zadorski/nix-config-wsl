# VSCode Configuration for nix-config-wsl

This directory contains workspace-specific VSCode settings optimized for Nix-based WSL development.

## Configuration Architecture

### Dual Configuration Approach

This project uses a **dual configuration approach** for VSCode settings:

1. **Declarative System Settings** (`home/windows/vscode.nix`)
   - System-wide VSCode configuration managed by Nix
   - Consistent across all projects and environments
   - Includes theme, fonts, editor behavior, and LSP configurations
   - Automatically applied when the NixOS configuration is rebuilt

2. **Workspace-Specific Settings** (`.vscode/settings.json`)
   - Project-specific overrides and enhancements
   - Nix-specific language server configuration
   - Development workflow optimizations
   - File associations and exclusions specific to this project

### Why This Approach?

- **Reproducibility**: System settings are version-controlled and declarative
- **Flexibility**: Project-specific needs can be addressed without affecting other projects
- **Maintainability**: Clear separation between system and project concerns
- **Performance**: WSL2-specific optimizations applied where needed

## Key Features

### 🎨 **Enhanced Editor Experience**
- Catppuccin Mocha theme with consistent dark mode
- Optimized font configuration with ligature support
- Bracket pair colorization and guides
- Minimap with proportional sizing
- Smart word wrapping and rulers at 80/120 characters

### 🗂️ **File Tree Optimization**
- Comprehensive file exclusions (70+ patterns)
- File nesting for related files (TypeScript, package files, Nix files)
- Smart explorer sorting and organization
- Performance-optimized file watching

### 🔧 **Multi-Language Development**
- **Nix**: Language server (nil) with formatting and diagnostics
- **Python**: Black formatter, type checking, auto-imports
- **TypeScript/JavaScript**: Prettier formatting, ESLint integration
- **Rust**: rust-analyzer with Clippy, inlay hints
- **Go**: Language server with goimports and linting
- **Shell**: Fish and Bash syntax support

### ⚡ **WSL2 Performance Optimization**
- Comprehensive file watcher exclusions
- Optimized search and indexing settings
- Reduced polling for better performance
- Smart caching strategies

### 🔒 **Corporate Environment Support**
- SSL certificate integration via system configuration
- Corporate proxy compatibility
- Security settings for workspace trust

## File Structure

```
.vscode/
├── settings.json          # Workspace-specific settings
└── README.md             # This documentation
```

## Usage Instructions

### For Developers

1. **Open the workspace** in VSCode (preferably via WSL)
2. **Install recommended extensions** when prompted
3. **Verify Nix language server** is working (syntax highlighting, formatting)
4. **Test auto-formatting** with `Ctrl+Shift+I` or save a file

### For System Administrators

1. **Modify system settings** in `home/windows/vscode.nix`
2. **Rebuild NixOS configuration**: `sudo nixos-rebuild switch --flake .#nixos`
3. **Restart VSCode** to apply system-level changes

### For Project Maintainers

1. **Update workspace settings** in `.vscode/settings.json`
2. **Add language-specific configurations** as needed
3. **Update recommended extensions** list
4. **Test changes** across different development scenarios

## Recommended Extensions

The following extensions are automatically recommended when opening this workspace:

### Core Development
- `jnoortheen.nix-ide` - Nix language support
- `ms-vscode.vscode-json` - JSON language support
- `redhat.vscode-yaml` - YAML language support

### Container Development
- `ms-azuretools.vscode-docker` - Docker support
- `ms-vscode-remote.remote-containers` - Dev container support

### Git and Version Control
- `eamodio.gitlens` - Enhanced Git integration

### Remote Development
- `ms-vscode.remote-wsl` - WSL integration

### Theming
- `catppuccin.catppuccin-vsc` - Catppuccin theme
- `catppuccin.catppuccin-vsc-icons` - Catppuccin icons

## Troubleshooting

### Common Issues

#### Nix Language Server Not Working
1. Ensure `nil` is installed: `nix-shell -p nil`
2. Check language server path in settings
3. Restart VSCode and reload window

#### Performance Issues in WSL2
1. Verify file watcher exclusions are applied
2. Check if large directories are being watched
3. Consider adding more exclusions to `files.watcherExclude`

#### Certificate Issues
1. Verify system certificate configuration in `system/certificates.nix`
2. Check environment variables are set correctly
3. Restart development environment

### Getting Help

1. **Check system logs**: `journalctl -u vscode-server`
2. **Verify Nix configuration**: `nix flake check`
3. **Test in clean environment**: Use devcontainer fallback
4. **Consult documentation**: See `docs/` directory for detailed guides

## Customization

### Adding New Languages

1. **Add language-specific settings** to `.vscode/settings.json`:
   ```json
   "[newlanguage]": {
     "editor.defaultFormatter": "extension.formatter",
     "editor.tabSize": 4
   }
   ```

2. **Add recommended extensions** for the language
3. **Update file associations** if needed
4. **Test formatting and language server integration**

### Performance Tuning

1. **Add file exclusions** for large directories:
   ```json
   "files.watcherExclude": {
     "**/large-directory/**": true
   }
   ```

2. **Adjust search limits** if needed:
   ```json
   "search.maxResults": 50000
   ```

3. **Monitor performance** with VSCode's built-in tools

## Integration with Development Environment

This VSCode configuration is designed to work seamlessly with:

- **devenv.nix**: Development environment with Nix language server
- **system/certificates.nix**: Corporate SSL certificate handling
- **home/development.nix**: Enhanced development tools (git, bat, fzf)
- **.devcontainer/**: Fallback container development environment

The configuration automatically adapts to the available tools and maintains consistency across different development scenarios.
