#!/usr/bin/env bash
set -e

echo "Setting up development container..."

# suppress apt warnings and install essentials
echo "Installing system packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update -qq
sudo apt-get install -y -qq apt-utils # install it first to avoid debconf warning (delaying package configuration)
sudo apt-get install -y -qq \
    curl \
    git \
    wget \
    unzip \
    ca-certificates \
    gnupg \
    fontconfig \
    lsb-release

# create directories safely
echo "Setting up user directories..."
mkdir -p ~/.local/share/fonts
mkdir -p ~/.config

# install Cascadia Code font
echo "Installing Cascadia Code font..."
cd /tmp
wget -q https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip -O CascadiaCode.zip
if [ -f CascadiaCode.zip ]; then
    unzip -q CascadiaCode.zip -d CascadiaCode
    cp CascadiaCode/ttf/*.ttf ~/.local/share/fonts/ 2>/dev/null || true
    rm -rf CascadiaCode CascadiaCode.zip
fi

# update font cache
fc-cache -fv

# set up Nix environment (if not already done in Dockerfile)
echo "Setting up Nix environment..."
if [ ! -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
fi

# source Nix environment for current session
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    source ~/.nix-profile/etc/profile.d/nix.sh
fi

# install fish shell via Nix
echo "Installing fish shell..."
nix profile install nixpkgs#fish

# configure fish as default shell for vscode user
echo "Configuring fish as default shell..."
if command -v fish >/dev/null 2>&1; then
    FISH_PATH=$(which fish)
    echo "Fish found at: $FISH_PATH"

    # add fish to /etc/shells if not already present
    if ! grep -q "$FISH_PATH" /etc/shells; then
        echo "$FISH_PATH" | sudo tee -a /etc/shells
    fi

    # change default shell for vscode user
    sudo chsh -s "$FISH_PATH" vscode
    echo "Default shell changed to fish"
else
    echo "Warning: fish installation failed"
fi

# configure SSH and Git integration
echo "Configuring SSH and Git..."

# create SSH directory with proper permissions
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# configure SSH agent forwarding (preferred approach for security)
if [ -n "$SSH_AUTH_SOCK" ]; then
    echo "SSH agent forwarding detected"
    # create SSH config for agent forwarding
    cat > ~/.ssh/config << 'EOF'
# SSH configuration for devcontainer
# Uses SSH agent forwarding for security

Host *
    AddKeysToAgent yes
    UseKeychain no
    IdentitiesOnly yes
    ServerAliveInterval 60
    ServerAliveCountMax 3
    ForwardAgent yes

    # security settings
    HashKnownHosts yes

    # performance settings
    Compression yes
    ControlMaster auto
    ControlPath ~/.ssh/control-%r@%h:%p
    ControlPersist 10m

# GitHub configuration
Host github.com
    HostName github.com
    User git
    Port 22
    PreferredAuthentications publickey
    PubkeyAuthentication yes

# Azure DevOps configuration
Host ssh.dev.azure.com
    HostName ssh.dev.azure.com
    User git
    Port 22
    PreferredAuthentications publickey
    PubkeyAuthentication yes
EOF
    chmod 600 ~/.ssh/config
    echo "SSH config created for agent forwarding"
else
    echo "No SSH agent forwarding detected - SSH keys will need to be configured manually"
fi

# configure Git with environment variables or defaults
echo "Configuring Git..."
GIT_USER_NAME="${GIT_USER_NAME:-vscode}"
GIT_USER_EMAIL="${GIT_USER_EMAIL:-vscode@localhost}"

git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.autocrlf input

echo "Git configured with user: $GIT_USER_NAME <$GIT_USER_EMAIL>"

# configure fish shell environment
echo "Configuring fish shell..."
mkdir -p ~/.config/fish

# create basic fish configuration
cat > ~/.config/fish/config.fish << 'EOF'
# Fish configuration for devcontainer
# Basic setup for development environment

# disable fish greeting
set -g fish_greeting

# set up development environment variables
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less

# nix environment setup
if test -f ~/.nix-profile/etc/profile.d/nix.sh
    # source nix environment for fish
    bass source ~/.nix-profile/etc/profile.d/nix.sh
end

# add nix profile to PATH if not already present
if test -d ~/.nix-profile/bin
    fish_add_path ~/.nix-profile/bin
end

# git aliases for productivity
abbr -a g git
abbr -a ga 'git add'
abbr -a gc 'git commit'
abbr -a gco 'git checkout'
abbr -a gp 'git push'
abbr -a gl 'git pull'
abbr -a gs 'git status'
abbr -a gd 'git diff'

# development aliases
abbr -a ll 'ls -la'
abbr -a la 'ls -la'
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'

# nix aliases
abbr -a nf 'nix flake'
abbr -a nfc 'nix flake check'
abbr -a nfs 'nix flake show'

echo "Fish shell configured for development"
EOF

# install bass for bash script compatibility (needed for nix environment)
if command -v fish >/dev/null 2>&1; then
    echo "Installing bass for fish..."
    nix profile install nixpkgs#fishPlugins.bass
fi

echo "Development container setup complete!"
echo "Fish shell is now the default shell"
echo "SSH agent forwarding is configured (if available)"
echo "Git is configured with user: $GIT_USER_NAME <$GIT_USER_EMAIL>"