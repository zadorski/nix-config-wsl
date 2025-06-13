{ pkgs, lib, config, ... }:

{
  # Generic devenv template for external projects
  # Provides a solid foundation for various development environments
  # Customize this file based on your project's specific needs

  # essential development packages
  packages = with pkgs; [
    # version control
    git
    gh                   # GitHub CLI
    
    # shell and prompt
    fish                 # modern shell with good defaults
    starship             # cross-shell prompt
    
    # development utilities
    just                 # modern make alternative
    direnv               # automatic environment loading
    pre-commit           # git hooks for code quality
    
    # file and text processing
    fd                   # fast find alternative
    ripgrep              # fast grep alternative
    jq                   # JSON processor
    yq                   # YAML processor
    tree                 # directory visualization
    
    # network and debugging tools
    curl                 # HTTP client
    wget                 # file downloader
    httpie               # user-friendly HTTP client
    
    # Add language-specific tools here:
    # nodejs_20          # for Node.js projects
    # python311          # for Python projects
    # go                 # for Go projects
    # rustc              # for Rust projects
    # openjdk            # for Java projects
    # dotnet-sdk         # for .NET projects
  ];

  # environment variables
  env = {
    # project identification
    PROJECT_ROOT = builtins.toString ./.;
    
    # development tools configuration
    EDITOR = "code";
    VISUAL = "code";
    PAGER = "less";
    
    # git configuration
    GIT_EDITOR = "code --wait";
    
    # certificate handling for corporate environments
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    CURL_CA_BUNDLE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    
    # Add project-specific environment variables here:
    # NODE_ENV = "development";
    # PYTHONPATH = "./src";
    # GOPATH = "./go";
  };

  # development scripts for common tasks
  scripts = {
    # development workflow
    dev.exec = ''
      echo "🚀 Starting development environment..."
      echo ""
      echo "Available commands:"
      echo "  • dev     - Show this help"
      echo "  • test    - Run tests"
      echo "  • build   - Build project"
      echo "  • format  - Format code"
      echo "  • lint    - Lint code"
      echo ""
      echo "Customize these scripts in devenv.nix for your project!"
      echo ""
    '';
    
    test.exec = ''
      echo "🧪 Running tests..."
      echo "Add your test command here"
      # Example commands:
      # npm test
      # python -m pytest
      # go test ./...
      # cargo test
    '';
    
    build.exec = ''
      echo "🔨 Building project..."
      echo "Add your build command here"
      # Example commands:
      # npm run build
      # python setup.py build
      # go build
      # cargo build
    '';
    
    format.exec = ''
      echo "🎨 Formatting code..."
      echo "Add your formatting command here"
      # Example commands:
      # npm run format
      # black .
      # gofmt -w .
      # cargo fmt
    '';
    
    lint.exec = ''
      echo "🔍 Linting code..."
      echo "Add your linting command here"
      # Example commands:
      # npm run lint
      # flake8 .
      # golangci-lint run
      # cargo clippy
    '';
  };

  # git hooks for code quality (customize as needed)
  pre-commit = {
    enable = true;
    hooks = {
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
      
      # Add language-specific hooks here:
      # prettier = {
      #   enable = true;
      # };
      # black = {
      #   enable = true;
      # };
      # gofmt = {
      #   enable = true;
      # };
    };
  };

  # development processes (optional - for long-running services)
  # processes = {
  #   web.exec = "npm start";
  #   api.exec = "python manage.py runserver";
  #   database.exec = "docker run --rm -p 5432:5432 postgres";
  # };

  # shell initialization
  enterShell = ''
    echo ""
    echo "🎉 Welcome to your development environment!"
    echo ""
    echo "📁 Project: $(basename $PROJECT_ROOT)"
    echo "🏠 Location: $PROJECT_ROOT"
    echo ""
    echo "🛠️  Development tools are ready!"
    echo ""
    echo "🚀 Quick start:"
    echo "  • Run 'dev' to see available commands"
    echo "  • Customize devenv.nix for your project needs"
    echo "  • Add language-specific packages and scripts"
    echo ""
    echo "💡 VS Code users: Install relevant language extensions for best experience"
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

  # language support (enable as needed for your project)
  # languages = {
  #   javascript = {
  #     enable = true;
  #     package = pkgs.nodejs_20;
  #   };
  #   
  #   python = {
  #     enable = true;
  #     package = pkgs.python311;
  #   };
  #   
  #   go = {
  #     enable = true;
  #   };
  #   
  #   rust = {
  #     enable = true;
  #   };
  # };
}
