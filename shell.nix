# ref:: https://github.com/Misterio77/nix-config/blob/main/shell.nix
#{ pkgs ? import <nixpkgs> {}, ... }: 

# ref:: https://github.com/jiaqiwang969/nix-config/blob/dev/shell.nix
{ 
  pkgs ? # if pkgs is not defined, instantiate nixpkgs from locked commit
  let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
  import nixpkgs { overlays = [ ]; }, 
  ... 
}:

{
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";
    nativeBuildInputs = with pkgs; [
      # core nix tools
      nix
      home-manager
      git

      # nix development tools
      nil                   # nix language server for VS Code
      nixfmt-classic        # nix code formatter
      nix-tree             # visualize nix dependencies
      nix-diff             # compare nix derivations

      # development utilities
      just                 # modern make alternative
      pre-commit           # git hooks for code quality
      gh                   # github CLI for repository management

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

      # secrets management
      sops
      ssh-to-age
      age
      gnupg

      # WSL-specific utilities
      wslu                 # WSL utilities for Windows integration
    ];

    # environment variables for nix development
    PROJECT_ROOT = builtins.toString ./.;
    PROJECT_TYPE = "nix-config";
    NIXPKGS_ALLOW_UNFREE = "1";
    EDITOR = "code";
    VISUAL = "code";
    PAGER = "less";
    GIT_EDITOR = "code --wait";

    shellHook = ''
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
      echo "  • git, gh - version control and GitHub integration"
      echo ""
      echo "🚀 Quick commands:"
      echo "  • nix flake check - validate configuration"
      echo "  • sudo nixos-rebuild switch --flake .#nixos - apply changes"
      echo "  • nixfmt **/*.nix - format Nix files"
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
  };
}