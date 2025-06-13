#!/usr/bin/env bash
# Migration script from devcontainer to direct WSL development
# Based on analysis in .ai/tasks/done/development-environment-analysis.md

set -e

echo "🚀 Migrating from devcontainer to direct WSL development..."
echo ""

# Phase 1: Backup and remove devcontainer infrastructure
echo "📦 Phase 1: Removing devcontainer infrastructure..."

if [ -d ".devcontainer" ]; then
    echo "  • Creating backup of current devcontainer configuration..."
    mkdir -p .backup/devcontainer-$(date +%Y%m%d-%H%M%S)
    cp -r .devcontainer/* .backup/devcontainer-$(date +%Y%m%d-%H%M%S)/
    
    echo "  • Removing .devcontainer directory..."
    rm -rf .devcontainer
    
    echo "  ✅ Devcontainer infrastructure removed"
else
    echo "  ℹ️  No .devcontainer directory found"
fi

# Phase 2: Create project devenv configuration
echo ""
echo "🔧 Phase 2: Creating project development environment..."

if [ ! -f "devenv.nix" ]; then
    echo "  • Creating devenv.nix configuration..."
    cat > devenv.nix << 'EOF'
{ pkgs, ... }: {
  # Essential development packages
  packages = with pkgs; [
    # Core tools
    git
    curl
    wget
    
    # Shell and prompt
    fish
    starship
    
    # Development utilities
    just              # modern make alternative
    direnv            # automatic environment loading
    
    # Add project-specific tools here
    # nodejs_20       # for Node.js projects
    # python311       # for Python projects
    # go              # for Go projects
  ];

  # Environment variables
  env = {
    # Project-specific environment variables
    PROJECT_ROOT = builtins.toString ./.;
    EDITOR = "nvim";
  };

  # Development scripts
  scripts = {
    # Add common development tasks
    dev.exec = ''
      echo "🚀 Starting development environment..."
      echo "Add your development server command here"
    '';
    
    test.exec = ''
      echo "🧪 Running tests..."
      echo "Add your test command here"
    '';
    
    build.exec = ''
      echo "🔨 Building project..."
      echo "Add your build command here"
    '';
  };

  # Development processes (optional)
  # processes = {
  #   web.exec = "npm start";
  #   api.exec = "python manage.py runserver";
  # };

  # Shell initialization
  enterShell = ''
    echo ""
    echo "🎉 Welcome to the development environment!"
    echo ""
    echo "Available commands:"
    echo "  • dev   - Start development server"
    echo "  • test  - Run tests"
    echo "  • build - Build project"
    echo ""
    echo "To start development: run 'dev'"
    echo ""
  '';
}
EOF
    echo "  ✅ Created devenv.nix"
else
    echo "  ℹ️  devenv.nix already exists, skipping creation"
fi

# Phase 3: Create .envrc for automatic environment loading
if [ ! -f ".envrc" ]; then
    echo "  • Creating .envrc for automatic environment activation..."
    cat > .envrc << 'EOF'
# Automatically load devenv when entering directory
use devenv
EOF
    echo "  ✅ Created .envrc"
    
    # Allow direnv if it's available
    if command -v direnv >/dev/null 2>&1; then
        echo "  • Allowing direnv for this directory..."
        direnv allow
        echo "  ✅ Direnv configured"
    else
        echo "  ⚠️  direnv not found - environment won't auto-load"
        echo "     Install direnv or manually run 'devenv shell' to enter environment"
    fi
else
    echo "  ℹ️  .envrc already exists, skipping creation"
fi

# Phase 4: Create VS Code configuration
echo ""
echo "🎨 Phase 3: Setting up VS Code configuration..."

mkdir -p .vscode

if [ ! -f ".vscode/settings.json" ]; then
    echo "  • Creating VS Code settings..."
    cat > .vscode/settings.json << 'EOF'
{
    "terminal.integrated.defaultProfile.linux": "fish",
    "terminal.integrated.profiles.linux": {
        "fish": {
            "path": "/home/nixos/.nix-profile/bin/fish"
        }
    },
    "files.watcherExclude": {
        "**/node_modules/**": true,
        "**/.git/objects/**": true,
        "**/.git/subtree-cache/**": true,
        "**/nix/store/**": true,
        "**/.devenv/**": true
    },
    "remote.WSL.useShellEnvironment": true,
    "remote.WSL.fileWatcher.polling": false
}
EOF
    echo "  ✅ Created VS Code settings"
else
    echo "  ℹ️  VS Code settings already exist, skipping creation"
fi

if [ ! -f ".vscode/tasks.json" ]; then
    echo "  • Creating VS Code tasks..."
    cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Enter Development Environment",
            "type": "shell",
            "command": "devenv shell",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Run Development Server",
            "type": "shell",
            "command": "dev",
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        },
        {
            "label": "Run Tests",
            "type": "shell",
            "command": "test",
            "group": "test",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": false,
                "panel": "shared"
            }
        }
    ]
}
EOF
    echo "  ✅ Created VS Code tasks"
else
    echo "  ℹ️  VS Code tasks already exist, skipping creation"
fi

# Phase 5: Create documentation
echo ""
echo "📚 Phase 4: Creating documentation..."

if [ ! -f "DEVELOPMENT.md" ]; then
    echo "  • Creating development documentation..."
    cat > DEVELOPMENT.md << 'EOF'
# Development Environment

This project uses [devenv](https://devenv.sh/) for development environment management with Nix.

## Quick Start

1. **Enter the development environment:**
   ```bash
   devenv shell
   ```

2. **Start development server:**
   ```bash
   dev
   ```

3. **Run tests:**
   ```bash
   test
   ```

## Automatic Environment Loading

If you have `direnv` installed, the development environment will automatically activate when you enter the project directory.

## VS Code Integration

- Open the project in VS Code
- The terminal will automatically use the fish shell
- Use Ctrl+Shift+P and search for tasks to run development commands
- Available tasks:
  - "Enter Development Environment"
  - "Run Development Server"
  - "Run Tests"

## Customizing the Environment

Edit `devenv.nix` to:
- Add new packages to the `packages` list
- Define environment variables in the `env` section
- Create custom scripts in the `scripts` section
- Set up development processes in the `processes` section

## Troubleshooting

- If environment doesn't load automatically, run `direnv allow`
- If devenv is not found, ensure Nix and devenv are installed
- For FHS-incompatible tools, use `nix-shell -p <package>` as a workaround
EOF
    echo "  ✅ Created development documentation"
else
    echo "  ℹ️  Development documentation already exists, skipping creation"
fi

# Final steps
echo ""
echo "🎯 Migration complete!"
echo ""
echo "Next steps:"
echo "1. Customize devenv.nix for your project's specific needs"
echo "2. Add project-specific packages and scripts"
echo "3. Test the environment by running 'devenv shell'"
echo "4. Open the project in VS Code to verify WSL integration"
echo ""
echo "📖 See DEVELOPMENT.md for detailed usage instructions"
echo ""
echo "🔄 To revert this migration, restore from .backup/ directory"
