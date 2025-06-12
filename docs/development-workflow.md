# Development Workflow Guide

This guide covers the optimized development workflow with the enhanced NixOS WSL configuration.

## Quick Start

### 1. System Rebuild
After pulling the latest configuration:
```bash
sudo nixos-rebuild switch --flake .#nixos
```

### 2. Shell Restart
Restart your shell to load new configurations:
```bash
exec fish  # or just open a new terminal
```

## Development Environment Features

### devenv + direnv Integration

**Automatic Project Environments**: Navigate to any project directory with a `.envrc` file to automatically load project-specific tools and dependencies.

```bash
# In any project directory
echo 'use devenv' > .envrc
direnv allow
# Environment automatically loads with project-specific tools
```

### Enhanced CLI Tools

**Modern File Operations**:
- `ls` → `eza --icons --git` (better ls with git status)
- `ll` → `eza -l --icons --git` (detailed list view)
- `cat` → `bat` (syntax highlighting)
- `tree` → `eza --tree --icons` (directory tree with icons)

**Git Workflow**:
- Enhanced diff viewing with `delta`
- Terminal UI with `lazygit`
- Useful aliases: `gst`, `gco`, `gcb`, `gp`, `gl`

### Docker Development

**Rootless Docker**: Improved security and devcontainer compatibility
```bash
# Docker commands work without sudo
docker run hello-world
docker-compose up -d

# Devcontainer shortcuts
dc up    # docker-compose up
dcd      # docker-compose down
dcb      # docker-compose build
```

### SSH Configuration

**Pre-configured for**:
- GitHub: `ssh -T git@github.com`
- Azure DevOps: `ssh -T git@ssh.dev.azure.com`

## Project Setup Patterns

### 1. Basic Project with devenv
```bash
mkdir my-project && cd my-project
echo 'use devenv' > .envrc
direnv allow

# Create devenv.nix for project-specific tools
cat > devenv.nix << 'EOF'
{ pkgs, ... }: {
  packages = with pkgs; [
    nodejs
    python3
    # add project-specific tools
  ];
  
  scripts.dev.exec = "npm run dev";
  scripts.test.exec = "npm test";
}
EOF
```

### 2. Multi-language Project
```bash
# devenv.nix example for full-stack project
{ pkgs, ... }: {
  packages = with pkgs; [
    nodejs_20
    python311
    postgresql
    redis
  ];
  
  services.postgres.enable = true;
  services.redis.enable = true;
  
  scripts = {
    setup.exec = ''
      npm install
      pip install -r requirements.txt
    '';
    dev.exec = ''
      npm run dev &
      python manage.py runserver
    '';
  };
}
```

### 3. Container Development
```bash
# Use with VS Code devcontainers
# .devcontainer/devcontainer.json will work seamlessly
# with the optimized Docker configuration
```

## Starship Prompt Features

The streamlined prompt shows:
- **Directory**: Current path with git repo awareness
- **Git**: Branch, status, and ahead/behind indicators
- **Languages**: Node.js, Python, Rust, Go, Java (when detected)
- **Docker**: Context when docker files present
- **Nix**: Shell indicator for nix environments
- **devenv**: Environment profile when active
- **Performance**: Command duration for long-running commands

## Troubleshooting

### devenv Not Loading
```bash
# Check direnv status
direnv status

# Reload environment
direnv reload
```

### Docker Permission Issues
```bash
# Verify rootless Docker is running
systemctl --user status docker

# Restart if needed
systemctl --user restart docker
```

### SSH Key Issues
```bash
# Add your SSH key
ssh-add ~/.ssh/id_ed25519

# Test connections
ssh -T git@github.com
ssh -T git@ssh.dev.azure.com
```

## Advanced Usage

### Custom devenv Templates
Create reusable templates in `~/.config/devenv/templates/`:

```bash
mkdir -p ~/.config/devenv/templates/nodejs
cat > ~/.config/devenv/templates/nodejs/devenv.nix << 'EOF'
{ pkgs, ... }: {
  packages = with pkgs; [ nodejs_20 npm-check-updates ];
  scripts.dev.exec = "npm run dev";
  scripts.build.exec = "npm run build";
}
EOF
```

### Project-specific Shell Aliases
Add to your project's `.envrc`:
```bash
# .envrc
use devenv

# Project-specific aliases
alias start="npm run dev"
alias deploy="npm run build && npm run deploy"
```

This optimized configuration provides a modern, efficient development environment tailored for WSL with excellent devcontainer support and seamless project environment management.
