# Devenv Template

A comprehensive devenv template for creating consistent, reproducible development environments using Nix.

## Quick Start

1. **Copy this template to your project:**
   ```bash
   cp -r /path/to/nix-config-wsl/templates/devenv-template/* /path/to/your/project/
   ```

2. **Customize the configuration:**
   - Edit `devenv.nix` to add your project-specific packages and scripts
   - Modify environment variables in the `env` section
   - Add language-specific configurations in the `languages` section

3. **Enter the development environment:**
   ```bash
   devenv shell
   ```

4. **Or use automatic loading with direnv:**
   ```bash
   direnv allow
   # Environment will automatically load when you enter the directory
   ```

## Features

### 🛠️ Development Tools
- **Git** with GitHub CLI integration
- **Fish shell** with Starship prompt
- **Just** for task automation
- **Pre-commit hooks** for code quality
- **File processing tools** (fd, ripgrep, jq, yq, tree)
- **Network tools** (curl, wget, httpie)

### 🎨 VS Code Integration
- Optimized settings for WSL development
- Fish shell as default terminal
- File watcher exclusions for better performance
- Pre-configured tasks for common operations

### 🔧 Customization Points

#### Adding Languages
Uncomment and customize the `languages` section in `devenv.nix`:

```nix
languages = {
  javascript = {
    enable = true;
    package = pkgs.nodejs_20;
  };
  
  python = {
    enable = true;
    package = pkgs.python311;
  };
  
  go = {
    enable = true;
  };
  
  rust = {
    enable = true;
  };
};
```

#### Adding Packages
Add packages to the `packages` list in `devenv.nix`:

```nix
packages = with pkgs; [
  # existing packages...
  
  # Add your packages here:
  nodejs_20
  python311
  go
  rustc
  docker-compose
  terraform
];
```

#### Custom Scripts
Modify the `scripts` section to add project-specific commands:

```nix
scripts = {
  dev.exec = ''
    echo "Starting development server..."
    npm start
  '';
  
  test.exec = ''
    echo "Running tests..."
    npm test
  '';
  
  deploy.exec = ''
    echo "Deploying application..."
    ./deploy.sh
  '';
};
```

#### Development Processes
For long-running services, use the `processes` section:

```nix
processes = {
  web.exec = "npm start";
  api.exec = "python manage.py runserver";
  database.exec = "docker run --rm -p 5432:5432 postgres";
};
```

### 🔐 Corporate Environment Support
The template includes certificate handling for corporate environments:
- SSL certificates are automatically configured
- Works with corporate proxies and firewalls
- Zscaler and similar corporate tools are supported

### 📋 Available Commands
Once in the development environment, use these commands:

- `dev` - Show available commands and help
- `test` - Run project tests
- `build` - Build the project
- `format` - Format code
- `lint` - Lint code

Customize these commands in the `scripts` section of `devenv.nix`.

## VS Code Tasks

The template includes pre-configured VS Code tasks accessible via `Ctrl+Shift+P`:

- **Enter Development Environment** - Start devenv shell
- **Run Development Server** - Execute the `dev` command
- **Run Tests** - Execute the `test` command
- **Build Project** - Execute the `build` command
- **Format Code** - Execute the `format` command
- **Lint Code** - Execute the `lint` command

## Pre-commit Hooks

The template includes basic pre-commit hooks:
- YAML/JSON/TOML validation
- Large file prevention
- Trailing whitespace removal
- End-of-file newline enforcement

Add language-specific hooks by uncommenting them in the `pre-commit.hooks` section.

## Troubleshooting

### Environment Not Loading
```bash
# Check direnv status
direnv status

# Reload environment
direnv reload

# Or manually enter
devenv shell
```

### Missing Packages
```bash
# Update devenv
devenv update

# Rebuild environment
devenv shell --rebuild
```

### VS Code Integration Issues
1. Ensure you're using VS Code with WSL extension
2. Open the project from within WSL
3. Check that the terminal profile is set to fish
4. Restart VS Code if needed

## Migration from Other Tools

### From Docker/Docker Compose
Replace your `Dockerfile` and `docker-compose.yml` with `devenv.nix`:
- Add packages instead of `apt install`
- Use `processes` instead of `services`
- Use `scripts` instead of `Makefile` targets

### From package.json scripts
Move npm scripts to the `scripts` section in `devenv.nix`:
```nix
scripts = {
  start.exec = "npm start";
  test.exec = "npm test";
  build.exec = "npm run build";
};
```

### From Python virtual environments
Replace `requirements.txt` with packages in `devenv.nix`:
```nix
packages = with pkgs; [
  python311
  python311Packages.pip
  python311Packages.virtualenv
];

languages.python = {
  enable = true;
  package = pkgs.python311;
};
```

## Best Practices

1. **Keep it minimal** - Only add packages you actually need
2. **Use scripts** - Define common tasks as scripts for consistency
3. **Document changes** - Update this README when you customize the template
4. **Version control** - Commit `devenv.nix` and `.envrc` to your repository
5. **Test regularly** - Ensure the environment works on different machines

## Support

For issues with this template:
1. Check the [devenv documentation](https://devenv.sh/)
2. Review the parent nix-config-wsl repository
3. Ensure your Nix installation supports flakes
