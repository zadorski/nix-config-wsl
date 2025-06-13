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

# source nix environment (if needed)
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    source ~/.nix-profile/etc/profile.d/nix.sh
    echo "Nix environment ready"
fi

# install development tools via Nix
#echo "Installing development tools..."
#nix-env -iA nixpkgs.git nixpkgs.vim nixpkgs.fish

echo "Development container setup complete!"




# install .NET (if needed for project) or use dotnet base image for docker
#echo "Installing .NET..."
#wget -q https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
#sudo dpkg -i packages-microsoft-prod.deb
#rm packages-microsoft-prod.deb
#sudo apt-get update -qq
#sudo apt-get install -y -qq dotnet-sdk-8.0



# https://stackoverflow.com/a/66815106/289515
#export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# https://github.com/devkimchi/devcontainers-dotnet/blob/main/.devcontainer/on-create.sh

## install additional apt packages
#sudo apt-get update && \
#    sudo apt upgrade -y && \
#    sudo apt-get install -y apt-utils dos2unix libsecret-1-0 xdg-utils && \
#    sudo apt clean -y && \
#    sudo rm -rf /var/lib/apt/lists/*

## configure git
#git config --global pull.rebase false
#git config --global core.autocrlf input

## enable local HTTPS for .NET
#dotnet dev-certs https --trust

## CaskaydiaCove Nerd Font
#mkdir "$HOME/.local"
#mkdir "$HOME/.local/share"
#mkdir "$HOME/.local/share/fonts"
#wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaCode.zip
#unzip CascadiaCode.zip -d "$HOME/.local/share/fonts"
#rm CascadiaCode.zip

## AzureCLI extensions
# extensions=$(az extension list-available --query "[].name" | jq -c -r '.[]')
#extensions=(account alias deploy-to-azure functionapp subscription webapp resource-graph portal)
# https://www.shellcheck.net/wiki/SC2128
#for extension in $extensions;
#for extension in "${extensions[@]}";
#do
#    az extension add --name "$extension" || echo "Failed to add extension $extension"
#done

# trust the repo
# fixes:
# - fatal: detected dubious ownership in repository at '/workspaces/repo'.
git config --global --add safe.directory "$PWD"

# config local GPG for signing
# fixes:
# - error: cannot run C:\Program Files (x86)\Gpg4win..\GnuPG\bin\gpg.exe: No such file or directory.
#git config --global gpg.program gpg

# install NPM packages
#echo ""
#echo "Installing packages..."
#npm install --no-audit --no-fund

# copy example.env to .env
#if [ ! -f .env ]; then
#    echo ""
#    echo "Copying .example.env to .env..."
#    cp .example.env .env
#fi

# colors
#NC='\033[0m' # no color
#BLUE='\033[1;34m'
#YELLOW='\033[1;33m'

# echo start instructions
#echo ""
#echo ""
#echo "${BLUE}To start your bot-zero instance, please enter: ${YELLOW}npm run dev${NC}"
#echo ""