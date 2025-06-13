# Templates Directory

This directory contains reusable templates for various development scenarios.

## Available Templates

### 1. Devenv Template (`devenv-template/`)

A comprehensive devenv template for creating consistent, reproducible development environments using Nix.

**Purpose**: Provides a superior alternative to devcontainers with better performance and simpler maintenance.

**Features**:
- 🛠️ **Development Tools** - Git, GitHub CLI, modern shell, task automation
- 🎨 **VS Code Integration** - Optimized settings, tasks, and terminal configuration
- 🔧 **Customizable** - Easy to adapt for any language or framework
- 🔐 **Corporate Support** - Certificate handling and proxy compatibility
- ⚡ **Performance** - 10x faster startup than containers, native performance

**Usage**:
```bash
# Copy template to your project
cp -r templates/devenv-template/* /path/to/your/project/

# Customize devenv.nix for your needs
# Activate environment
cd /path/to/your/project
direnv allow
```

See [devenv-template/README.md](devenv-template/README.md) for detailed usage instructions.

### 2. NixOS Config Templates

Additional templates for different NixOS configuration patterns:

- **`nixos-config-balanced/`** - Balanced approach between simplicity and modularity
- **`nixos-config-per-host/`** - Host-specific configuration management
- **`nixos-config-per-system/`** - System-type based organization
- **`nixos-config-transcluded/`** - Transcluded configuration approach

## Template Selection Guide

### For Development Environments
**Use `devenv-template/`** when you need:
- Project-specific development environment
- Language-agnostic base configuration
- VS Code integration
- Corporate environment compatibility
- Superior performance to devcontainers

### For NixOS Configurations
Choose based on your organizational needs:
- **Balanced**: Good starting point for most users
- **Per-host**: Multiple machines with different configurations
- **Per-system**: Different system types (desktop, server, etc.)
- **Transcluded**: Advanced modular configuration

## Best Practices

### Using Templates
1. **Copy, don't symlink** - Templates are starting points, not shared configurations
2. **Customize immediately** - Adapt the template to your specific needs
3. **Version control** - Include the customized template files in your repository
4. **Document changes** - Update README files when you modify templates

### Template Development
1. **Keep minimal** - Include only essential, commonly-needed features
2. **Document thoroughly** - Provide clear usage instructions and examples
3. **Test regularly** - Ensure templates work across different environments
4. **Version appropriately** - Use semantic versioning for template updates

## Contributing

When adding new templates:

1. **Create descriptive directory name** - Use kebab-case naming
2. **Include comprehensive README** - Document purpose, usage, and customization
3. **Provide working examples** - Include sample configurations
4. **Test thoroughly** - Verify template works in clean environment
5. **Update this README** - Add entry to the template list

## Support

For template-related issues:
- Check the specific template's README file
- Review the parent nix-config-wsl repository documentation
- Ensure your Nix installation supports the required features
