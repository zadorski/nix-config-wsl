{ pkgs, lib, config, ... }:

{
  # nix-config-wsl repository development environment
  # optimized for editing NixOS configurations with full toolchain support

  # repository cleanliness: move devenv cache outside project directory
  cachix.enable = false;  # disable cachix integration to reduce cache files

  # configure devenv to use system-wide cache locations
  devenv = {
    # move devenv state outside the repository
    root = "/home/nixos/.cache/devenv/nix-config-wsl";

    # ensure clean repository by using external paths
    warnOnNewGeneration = false;  # reduce noise in repository
  };

  # essential packages for nix configuration development
  packages = with pkgs; [
    # nix development tools
    nil                   # nix language server for VS Code
    nixfmt-classic        # nix code formatter
    nix-tree             # visualize nix dependencies
    nix-diff             # compare nix derivations
    
    # development utilities
    git                  # version control
    gh                   # github CLI for repository management
    just                 # modern make alternative
    pre-commit           # git hooks for code quality
    
    # shell and prompt
    fish                 # modern shell with good defaults
    starship             # cross-shell prompt
    
    # file and text processing
    fd                   # fast find alternative
    ripgrep              # fast grep alternative
    jq                   # JSON processor
    yq                   # YAML processor
    tree                 # directory visualization
    
    # network and debugging tools
    curl                 # HTTP client
    wget                 # file downloader
    
    # WSL-specific utilities
    wslu                 # WSL utilities for Windows integration
  ];

  # environment variables for nix development
  env = {
    # project identification
    PROJECT_ROOT = builtins.toString ./.;
    PROJECT_TYPE = "nix-config";

    # nix-specific environment
    NIXPKGS_ALLOW_UNFREE = "1";

    # development tools configuration
    EDITOR = "code";
    VISUAL = "code";
    PAGER = "less";

    # git configuration
    GIT_EDITOR = "code --wait";

    # repository cleanliness: configure cache and temporary directories
    DEVENV_ROOT = "/home/nixos/.cache/devenv/nix-config-wsl";
    XDG_CACHE_HOME = "/home/nixos/.cache";

    # ensure devenv uses external directories for state
    DIRENV_LOG_FORMAT = "";  # reduce direnv logging noise

    # certificate handling: inherit from system configuration
    # these will be automatically set by the system/certificates.nix module
    # using the system certificate bundle that includes corporate certificates
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    CURL_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    REQUESTS_CA_BUNDLE = "/etc/ssl/certs/ca-certificates.crt";
    NODE_EXTRA_CA_CERTS = "/etc/ssl/certs/ca-certificates.crt";

    # additional certificate variables for comprehensive coverage
    PIP_CERT = "/etc/ssl/certs/ca-certificates.crt";
    CARGO_HTTP_CAINFO = "/etc/ssl/certs/ca-certificates.crt";
    GIT_SSL_CAINFO = "/etc/ssl/certs/ca-certificates.crt";

    # ensure devenv respects system certificates
    DEVENV_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  };

  # development scripts for common tasks
  scripts = {
    # nix configuration management
    rebuild.exec = ''
      echo "🔄 Rebuilding NixOS configuration..."
      sudo nixos-rebuild switch --flake .#nixos
    '';
    
    check.exec = ''
      echo "🔍 Checking flake configuration..."
      nix flake check
    '';
    
    update.exec = ''
      echo "⬆️  Updating flake inputs..."
      nix flake update
    '';
    
    format.exec = ''
      echo "🎨 Formatting Nix files..."
      find . -name "*.nix" -not -path "./templates/*" -exec nixfmt {} \;
    '';
    
    # development workflow
    dev.exec = ''
      echo "🚀 Starting nix-config development environment..."
      echo ""
      echo "Available commands:"
      echo "  • rebuild - Rebuild and switch NixOS configuration"
      echo "  • check   - Validate flake configuration"
      echo "  • update  - Update flake inputs"
      echo "  • format  - Format Nix files"
      echo "  • test    - Run configuration tests"
      echo ""
      echo "VS Code integration:"
      echo "  • Nix language server (nil) is available"
      echo "  • Use Ctrl+Shift+P -> 'Nix: Format File' to format"
      echo ""
    '';
    
    test.exec = ''
      echo "🧪 Running configuration tests..."
      echo "Checking flake..."
      nix flake check
      echo "Building configuration (dry-run)..."
      nixos-rebuild dry-build --flake .#nixos
    '';
  };

  # git hooks for code quality
  pre-commit = {
    enable = true;
    hooks = {
      # nix formatting
      nixfmt = {
        enable = true;
        package = pkgs.nixfmt-classic;
      };
      
      # general file checks
      check-yaml = {
        enable = true;
      };
      
      check-json = {
        enable = true;
      };
      
      check-toml = {
        enable = true;
      };
      
      # prevent large files
      check-added-large-files = {
        enable = true;
      };
      
      # trailing whitespace
      trailing-whitespace = {
        enable = true;
      };
      
      # end of file newline
      end-of-file-fixer = {
        enable = true;
      };
    };
  };

  # shell initialization
  enterShell = ''
    echo ""
    echo "🎉 Welcome to nix-config-wsl development environment!"
    echo ""
    echo "📁 Project: NixOS WSL Configuration"
    echo "🏠 Location: $PROJECT_ROOT"
    echo ""
    echo "🛠️  Available tools:"
    echo "  • nil (Nix language server) - for VS Code integration"
    echo "  • nixfmt - for code formatting"
    echo "  • nix flake commands - for configuration management"
    echo "  • pre-commit hooks - for code quality"
    echo ""
    echo "🚀 Quick start:"
    echo "  • Run 'dev' to see all available commands"
    echo "  • Run 'check' to validate configuration"
    echo "  • Run 'rebuild' to apply changes"
    echo ""
    echo "💡 VS Code users: The Nix language server is configured and ready!"
    echo ""
    
    # ensure git is configured for safe directory
    git config --global --add safe.directory "$PROJECT_ROOT" 2>/dev/null || true
    
    # display current git status if in a git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
      echo "📊 Git status:"
      git status --short --branch
      echo ""
    fi
  '';

  # language support (primarily Nix)
  languages = {
    nix = {
      enable = true;
    };
  };
}
