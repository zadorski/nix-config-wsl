# Development Environment Guide

This repository uses [devenv](https://devenv.sh/) for development environment management, providing a superior alternative to devcontainers with better performance and simpler maintenance.

## Quick Start

### Automatic Environment (Recommended)

1. **Allow direnv (one-time setup):**
   ```bash
   direnv allow
   ```

2. **Environment automatically activates when entering directory:**
   ```bash
   cd nix-config-wsl
   # Environment loads automatically
   ```

### Manual Environment

```bash
# Enter development environment manually
devenv shell

# Exit environment
exit
```

## Available Commands

Once in the development environment, use these commands:

### Nix Configuration Management
- `rebuild` - Rebuild and switch NixOS configuration
- `check` - Validate flake configuration
- `update` - Update flake inputs
- `format` - Format Nix files
- `test` - Run configuration tests

### Development Workflow
- `dev` - Show all available commands and help
- `build` - Build project (dry-run)
- `lint` - Lint and validate code

### Examples
```bash
# Quick validation
check

# Apply configuration changes
rebuild

# Update dependencies
update

# Format all Nix files
format
```

## VS Code Integration

### Automatic Setup
The development environment provides:
- **Nix language server (nil)** - Syntax highlighting, completion, error checking
- **Fish shell** - Modern shell with good defaults
- **Integrated terminal** - Automatically uses development environment
- **File watching** - Optimized for Nix store and development files

### Manual VS Code Setup (if needed)
1. Install the **Nix IDE** extension
2. Ensure terminal profile is set to fish
3. Open project from WSL (not Windows)

### VS Code Tasks
Access via `Ctrl+Shift+P` → "Tasks: Run Task":
- **Enter Development Environment**
- **Run Development Server** 
- **Run Tests**
- **Build Project**
- **Format Code**

## Features

### 🛠️ Development Tools
- **Nix toolchain** - nil language server, nixfmt formatter, nix-tree, nix-diff
- **Git integration** - GitHub CLI, pre-commit hooks
- **Modern CLI tools** - fish shell, starship prompt, fd, ripgrep, jq, yq
- **Build automation** - just task runner
- **Quality assurance** - pre-commit hooks for code formatting and validation

### 🔐 Security & Corporate Support
- **SSH agent forwarding** - Automatic via WSL integration
- **Certificate handling** - Corporate certificates (Zscaler) automatically configured
- **Secure Git operations** - SSH keys and GPG signing work seamlessly

### ⚡ Performance
- **Fast startup** - 5-15 seconds vs 2-5 minutes for containers
- **Low resource usage** - ~50MB vs ~500MB for containers
- **Native performance** - No container overhead
- **Shared Nix store** - Efficient package sharing across projects

## Project Structure

```
nix-config-wsl/
├── devenv.nix              # Development environment configuration
├── .envrc                  # Automatic environment activation
├── flake.nix              # Nix flake configuration
├── home/                  # Home-manager configuration
├── system/                # NixOS system configuration
├── templates/             # Reusable templates
│   └── devenv-template/   # Template for external projects
└── docs/                  # Documentation
    └── devenv-vs-devcontainer.md  # Comparison guide
```

## Customization

### Adding Packages
Edit `devenv.nix` to add new packages:

```nix
packages = with pkgs; [
  # existing packages...
  
  # Add your packages here
  nodejs_20
  python311
  docker-compose
];
```

### Custom Scripts
Add project-specific commands:

```nix
scripts = {
  my-command.exec = ''
    echo "Running my custom command..."
    # Your command here
  '';
};
```

### Environment Variables
Configure project-specific variables:

```nix
env = {
  MY_VAR = "value";
  PROJECT_CONFIG = "/path/to/config";
};
```

## Troubleshooting

### Environment Not Loading
```bash
# Check direnv status
direnv status

# Reload environment
direnv reload

# Manual activation
devenv shell
```

### Missing Packages
```bash
# Update environment
devenv update

# Rebuild environment
devenv shell --rebuild
```

### VS Code Issues
1. Ensure you're opening the project from WSL
2. Check that fish is set as the default terminal
3. Restart VS Code if language server isn't working
4. Install the Nix IDE extension if syntax highlighting is missing

### Performance Issues
```bash
# Clean up old generations
nix-collect-garbage -d

# Optimize Nix store
nix-store --optimise
```

## Migration from Devcontainer

If you're migrating from the old devcontainer setup:

1. **Remove old configuration:**
   ```bash
   rm -rf .devcontainer/
   ```

2. **The new setup is already configured** - just use `direnv allow`

3. **Benefits you'll notice:**
   - 10x faster startup time
   - 10x less memory usage
   - Better VS Code integration
   - Simpler maintenance

See [docs/devenv-vs-devcontainer.md](docs/devenv-vs-devcontainer.md) for detailed comparison.

## External Projects

### Using the Template
For other projects, copy the devenv template:

```bash
cp -r templates/devenv-template/* /path/to/your/project/
cd /path/to/your/project
direnv allow
```

### Template Features
- Generic development environment
- Language-agnostic base configuration
- VS Code integration
- Customizable for any project type
- Pre-commit hooks and quality tools

See [templates/devenv-template/README.md](templates/devenv-template/README.md) for detailed usage.

## Best Practices

1. **Use direnv** - Enable automatic environment loading
2. **Commit configuration** - Include `devenv.nix` and `.envrc` in version control
3. **Keep it minimal** - Only add packages you actually need
4. **Use scripts** - Define common tasks as scripts for consistency
5. **Test regularly** - Run `check` before committing changes

## Support

- **Devenv documentation**: https://devenv.sh/
- **NixOS manual**: https://nixos.org/manual/nixos/stable/
- **This repository**: Check existing configurations and templates
