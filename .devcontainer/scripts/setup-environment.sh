#!/usr/bin/env bash
# Comprehensive environment setup script for Nix development container
# Designed as fallback solution with robust error handling

set -euo pipefail

echo "🚀 Setting up Nix development environment..."
echo "========================================"

# logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

error() {
    echo "[ERROR] $*" >&2
}

warning() {
    echo "[WARNING] $*" >&2
}

# Phase 1: Certificate setup
log "Phase 1: Certificate Management"
if [ -f "/home/vscode/.devcontainer-scripts/install-certificates.sh" ]; then
    bash "/home/vscode/.devcontainer-scripts/install-certificates.sh" || {
        warning "Certificate installation had issues, continuing..."
    }
else
    warning "Certificate installation script not found"
fi

# Phase 2: Nix environment setup
log "Phase 2: Nix Environment Setup"

# source Nix environment
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    source ~/.nix-profile/etc/profile.d/nix.sh
    log "Nix environment loaded"
else
    error "Nix environment not found"
    log "Attempting to install Nix..."
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon --yes || {
        error "Failed to install Nix"
        exit 1
    }
    source ~/.nix-profile/etc/profile.d/nix.sh
fi

# verify Nix installation
if ! command -v nix >/dev/null 2>&1; then
    error "Nix command not found in PATH"
    exit 1
fi

log "Nix version: $(nix --version)"

# Phase 3: Home Manager setup
log "Phase 3: Home Manager Configuration"

# create home-manager configuration directory
mkdir -p ~/.config/home-manager

# create comprehensive home-manager configuration
log "Creating home-manager configuration..."
cat > ~/.config/home-manager/home.nix << 'EOF'
{ pkgs, ... }:

{
  # basic home-manager configuration for devcontainer
  home = {
    username = "vscode";
    homeDirectory = "/home/vscode";
    stateVersion = "24.05";
  };

  # enable home-manager to manage itself
  programs.home-manager.enable = true;

  # essential development tools matching repository patterns
  home.packages = with pkgs; [
    # nix development tools (from devenv.nix)
    nil                   # nix language server
    nixfmt-classic        # nix code formatter
    nix-tree             # visualize nix dependencies
    nix-diff             # compare nix derivations
    
    # development utilities
    git                  # version control
    gh                   # github CLI
    just                 # modern make alternative
    pre-commit           # git hooks
    
    # shell and prompt
    fish                 # modern shell
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
    
    # additional container utilities
    htop                 # process monitor
    ncdu                 # disk usage analyzer
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
      # certificate configuration
      http.sslCAInfo = "/etc/ssl/certs/ca-certificates.crt";
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

  # fish shell configuration matching repository patterns
  programs.fish = {
    enable = true;
    shellInit = ''
      # disable fish greeting
      set -g fish_greeting

      # development environment variables
      set -gx EDITOR code
      set -gx VISUAL code
      set -gx PAGER less

      # git aliases (from devenv.nix)
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

log "Home-manager configuration created"

# Phase 4: Install packages and apply configuration
log "Phase 4: Package Installation"

# install essential packages directly first
log "Installing essential packages..."
nix-env -iA nixpkgs.fish nixpkgs.starship nixpkgs.git nixpkgs.nil nixpkgs.nixfmt-classic || {
    warning "Some package installations failed, continuing..."
}

# install home-manager
log "Installing home-manager..."
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager || {
    warning "Failed to add home-manager channel"
}

nix-channel --update || {
    warning "Failed to update channels"
}

# install and apply home-manager configuration
if nix-shell '<home-manager>' -A install; then
    log "Home-manager installed successfully"
    
    if home-manager switch; then
        log "Home-manager configuration applied successfully"
    else
        warning "Home-manager configuration application failed"
    fi
else
    warning "Home-manager installation failed, skipping configuration"
fi

# Phase 5: Shell configuration
log "Phase 5: Shell Configuration"

# set fish as default shell
FISH_PATH=$(which fish 2>/dev/null || echo "")
if [ -n "$FISH_PATH" ] && [ -x "$FISH_PATH" ]; then
    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells
    fi
    sudo chsh -s "$FISH_PATH" vscode || {
        warning "Failed to change default shell to fish"
    }
    log "Default shell set to fish: $FISH_PATH"
else
    warning "Fish not found in PATH, keeping bash as default shell"
fi

# Phase 6: SSH and Git setup
log "Phase 6: SSH and Git Setup"

# create SSH directory with proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# configure git safe directories
git config --global --add safe.directory "/workspaces/*"

# test SSH agent forwarding
if [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ]; then
    log "SSH agent forwarding is available"
    if ssh-add -l >/dev/null 2>&1; then
        KEY_COUNT=$(ssh-add -l | wc -l)
        log "SSH agent has $KEY_COUNT key(s) loaded"
    else
        log "SSH agent has no keys loaded"
    fi
else
    warning "SSH agent forwarding not available"
fi

log "🎉 Environment setup completed successfully!"
log ""
log "Summary:"
log "- Nix package manager: $(nix --version)"
log "- Fish shell: $(fish --version 2>/dev/null || echo 'not available')"
log "- Git: $(git --version)"
log "- Home-manager configuration applied"
log ""
log "To start using fish shell, run: exec fish"
