#!/usr/bin/env bash
set -e

echo "Setting up Nix-based development container..."

# source Nix environment
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    source ~/.nix-profile/etc/profile.d/nix.sh
    echo "Nix environment loaded"
else
    echo "Error: Nix environment not found"
    exit 1
fi

# create minimal container-specific Nix configuration
echo "Creating container Nix configuration..."
mkdir -p ~/.config/home-manager

# create a simplified home-manager configuration that leverages the host config
cat > ~/.config/home-manager/home.nix << 'EOF'
{ pkgs, ... }:

{
  # basic home-manager configuration for container
  home = {
    username = "vscode";
    homeDirectory = "/home/vscode";
    stateVersion = "24.05";
  };

  # enable home-manager to manage itself
  programs.home-manager.enable = true;

  # essential development tools
  home.packages = with pkgs; [
    fish
    starship
    git
    curl
    wget
  ];

  # git configuration from environment variables
  programs.git = {
    enable = true;
    userName = builtins.getEnv "GIT_USER_NAME";
    userEmail = builtins.getEnv "GIT_USER_EMAIL";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      core.autocrlf = "input";
      safe.directory = "/workspaces/*";
    };
  };

  # SSH configuration for agent forwarding
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    matchBlocks = {
      "github.com" = {
        host = "github.com";
        user = "git";
        forwardAgent = true;
        identitiesOnly = true;
      };
      "ssh.dev.azure.com" = {
        host = "ssh.dev.azure.com";
        user = "git";
        forwardAgent = true;
        identitiesOnly = true;
      };
    };
  };

  # fish shell configuration
  programs.fish = {
    enable = true;
    shellInit = ''
      # disable fish greeting
      set -g fish_greeting

      # development environment variables
      set -gx EDITOR vim
      set -gx PAGER less

      # git aliases
      abbr -a g git
      abbr -a ga 'git add'
      abbr -a gc 'git commit'
      abbr -a gco 'git checkout'
      abbr -a gp 'git push'
      abbr -a gl 'git pull'
      abbr -a gs 'git status'
      abbr -a gd 'git diff'

      # nix aliases
      abbr -a nf 'nix flake'
      abbr -a nfc 'nix flake check'
      abbr -a nfs 'nix flake show'

      # common aliases
      abbr -a ll 'ls -la'
      abbr -a .. 'cd ..'
      abbr -a ... 'cd ../..'
    '';
  };

  # starship prompt configuration
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };
}
EOF

# install home-manager and apply configuration
echo "Installing home-manager..."
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

echo "Installing home-manager package..."
nix-shell '<home-manager>' -A install

echo "Applying home-manager configuration..."
home-manager switch

# set fish as default shell
echo "Setting fish as default shell..."
FISH_PATH=$(which fish)
if [ -n "$FISH_PATH" ]; then
    echo "$FISH_PATH" | sudo tee -a /etc/shells
    sudo chsh -s "$FISH_PATH" vscode
    echo "Default shell set to fish: $FISH_PATH"
else
    echo "Warning: fish not found in PATH"
fi

# create SSH directory with proper permissions
echo "Setting up SSH configuration..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# configure workspace as safe directory for git
echo "Configuring git safe directories..."
git config --global --add safe.directory "/workspaces/*"

echo "Development container setup complete!"
echo "- Nix package manager: $(nix --version)"
echo "- Fish shell: $(fish --version)"
echo "- Git: $(git --version)"
echo "- Home-manager configuration applied"
echo ""
echo "To start using fish shell, run: exec fish"
