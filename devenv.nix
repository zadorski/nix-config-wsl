{ pkgs, lib, config, ... }:

{
  # nix-config-wsl repository development environment
  # production-ready, SSL-compliant development environment with streamlined tooling

  # repository cleanliness: move devenv cache outside project directory
  cachix.enable = false;  # disable cachix integration to reduce cache files

  # configure devenv to use XDG-compliant cache locations
  # leverages home-manager XDG configuration for consistency
  devenv = {
    # move devenv state to XDG cache directory
    # uses fallback for environments where XDG_CACHE_HOME might not be set
    root =
      let cacheHome = builtins.getEnv "XDG_CACHE_HOME";
      in if cacheHome != ""
         then "${cacheHome}/devenv/nix-config-wsl"
         else "/home/nixos/.cache/devenv/nix-config-wsl";

    # ensure clean repository by using external paths
    warnOnNewGeneration = false;  # reduce noise in repository
  };

  # essential packages for nix configuration development
  # focus on tools that provide daily value and work reliably with SSL
  packages = with pkgs; [
    # core nix development tools (essential for daily work)
    nil                   # nix language server for VS Code
    nixfmt-classic        # nix code formatter (RFC-compliant)
    nix-tree             # visualize nix dependencies (debugging)

    # version control and collaboration (essential)
    git                  # version control
    gh                   # github CLI for repository management

    # modern shell environment (essential for user experience)
    fish                 # modern shell with good defaults
    starship             # cross-shell prompt (optimized configuration)

    # file and text processing (essential for development)
    fd                   # fast find alternative (better than find)
    ripgrep              # fast grep alternative (better than grep)
    jq                   # JSON processor (essential for modern development)
    yq                   # YAML processor (essential for configuration files)
    tree                 # directory visualization (debugging and exploration)

    # network tools (essential, SSL-compliant)
    curl                 # HTTP client (respects SSL_CERT_FILE)
    wget                 # file downloader (respects SSL certificates)

    # development automation (essential for workflow)
    just                 # modern make alternative (simple task runner)
    pre-commit           # git hooks for code quality

    # WSL-specific utilities (essential for WSL environment)
    wslu                 # WSL utilities for Windows integration

    # SSL validation and troubleshooting
    openssl              # SSL certificate inspection and validation
    ca-certificates      # system certificate bundle
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

    # repository cleanliness: use XDG-compliant directories
    # consistent with devenv.root configuration above
    DEVENV_ROOT =
      let cacheHome = builtins.getEnv "XDG_CACHE_HOME";
      in if cacheHome != ""
         then "${cacheHome}/devenv/nix-config-wsl"
         else "/home/nixos/.cache/devenv/nix-config-wsl";

    # ensure devenv uses external directories for state
    DIRENV_LOG_FORMAT = "";  # reduce direnv logging noise

    # development environment XDG compliance
    # these variables ensure tools respect XDG directories in devenv
    DOCKER_CONFIG = "${builtins.getEnv "XDG_CONFIG_HOME"}/docker";
    NPM_CONFIG_CACHE = "${builtins.getEnv "XDG_CACHE_HOME"}/npm";
    CARGO_HOME = "${builtins.getEnv "XDG_DATA_HOME"}/cargo";
    GOPATH = "${builtins.getEnv "XDG_DATA_HOME"}/go";
    GOCACHE = "${builtins.getEnv "XDG_CACHE_HOME"}/go";

    # SSL certificate handling: inherit from system configuration
    # these variables are automatically set by system/certificates.nix
    # and will use the system certificate bundle that includes corporate certificates
    # note: using environment variable references to inherit from system
    SSL_CERT_FILE = "\${SSL_CERT_FILE:-/etc/ssl/certs/ca-certificates.crt}";
    NIX_SSL_CERT_FILE = "\${NIX_SSL_CERT_FILE:-/etc/ssl/certs/ca-certificates.crt}";
    CURL_CA_BUNDLE = "\${CURL_CA_BUNDLE:-/etc/ssl/certs/ca-certificates.crt}";

    # language ecosystem SSL variables (inherit from system)
    REQUESTS_CA_BUNDLE = "\${REQUESTS_CA_BUNDLE:-/etc/ssl/certs/ca-certificates.crt}";
    PIP_CERT = "\${PIP_CERT:-/etc/ssl/certs/ca-certificates.crt}";
    NODE_EXTRA_CA_CERTS = "\${NODE_EXTRA_CA_CERTS:-/etc/ssl/certs/ca-certificates.crt}";
    NPM_CONFIG_CAFILE = "\${NPM_CONFIG_CAFILE:-/etc/ssl/certs/ca-certificates.crt}";
    CARGO_HTTP_CAINFO = "\${CARGO_HTTP_CAINFO:-/etc/ssl/certs/ca-certificates.crt}";
    GIT_SSL_CAINFO = "\${GIT_SSL_CAINFO:-/etc/ssl/certs/ca-certificates.crt}";

    # ensure devenv respects system certificates
    DEVENV_SSL_CERT_FILE = "\${DEVENV_SSL_CERT_FILE:-/etc/ssl/certs/ca-certificates.crt}";

    # development environment optimization
    # reduce startup time and improve performance
    STARSHIP_CONFIG = builtins.toString ./home/starship.toml;
    STARSHIP_CACHE = "/home/nixos/.cache/starship";
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
      nix flake check --no-warn-dirty
    '';

    update.exec = ''
      echo "⬆️  Updating flake inputs..."
      nix flake update --no-warn-dirty
    '';

    format.exec = ''
      echo "🎨 Formatting Nix files..."
      find . -name "*.nix" -not -path "./templates/*" -exec nixfmt {} \;
    '';

    # SSL validation and troubleshooting
    validate-ssl.exec = ''
      echo "🔐 Validating SSL configuration..."
      chmod +x scripts/validate-ssl-configuration.sh
      ./scripts/validate-ssl-configuration.sh
    '';

    # XDG Base Directory Specification compliance validation
    validate-xdg.exec = ''
      echo "📋 Validating XDG Base Directory Specification compliance..."
      chmod +x scripts/validate-xdg-compliance.sh
      ./scripts/validate-xdg-compliance.sh
    '';

    # comprehensive testing
    test.exec = ''
      echo "🧪 Running comprehensive tests..."
      echo ""
      echo "1. Checking flake configuration..."
      nix flake check --no-warn-dirty
      echo ""
      echo "2. Validating SSL configuration..."
      chmod +x scripts/validate-ssl-configuration.sh
      ./scripts/validate-ssl-configuration.sh
      echo ""
      echo "3. Testing build (dry-run)..."
      nixos-rebuild dry-build --flake .#nixos
    '';

    # development workflow help
    dev.exec = ''
      echo "🚀 nix-config-wsl Development Environment"
      echo "========================================"
      echo ""
      echo "Essential commands:"
      echo "  • check        - Validate flake configuration"
      echo "  • rebuild      - Rebuild and switch NixOS configuration"
      echo "  • format       - Format Nix files with nixfmt"
      echo "  • validate-ssl - Test SSL certificate configuration"
      echo "  • test         - Run comprehensive tests"
      echo "  • update       - Update flake inputs"
      echo ""
      echo "Development tools available:"
      echo "  • nil          - Nix language server (VS Code integration)"
      echo "  • nixfmt       - Nix code formatter"
      echo "  • git + gh     - Version control and GitHub CLI"
      echo "  • fish         - Modern shell with starship prompt"
      echo ""
      echo "SSL certificate status:"
      if [ -f "/etc/nixos-certificates-info" ]; then
        echo "  ✅ Corporate certificates configured"
      else
        echo "  ⚠️  No corporate certificates detected"
      fi
      echo ""
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
    echo "🎉 nix-config-wsl development environment ready!"
    echo ""
    echo "📁 Project: NixOS WSL Configuration"
    echo "🏠 Location: $PROJECT_ROOT"

    # SSL certificate status check
    if [ -f "/etc/nixos-certificates-info" ]; then
      echo "🔐 SSL: Corporate certificates configured"
    else
      echo "🔐 SSL: Using system defaults"
    fi

    # quick environment validation
    if command -v nil >/dev/null 2>&1; then
      echo "🛠️  Tools: Nix language server ready"
    fi

    if [ -n "${STARSHIP_CONFIG:-}" ] && [ -f "${STARSHIP_CONFIG}" ]; then
      echo "✨ Prompt: Starship configured"
    fi

    echo ""
    echo "🚀 Quick commands:"
    echo "  • dev          - Show all available commands"
    echo "  • check        - Validate configuration"
    echo "  • validate-ssl - Test SSL setup"
    echo "  • rebuild      - Apply changes"
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
