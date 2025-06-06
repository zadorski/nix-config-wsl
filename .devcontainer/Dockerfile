FROM ubuntu:22.04

# Install basic packages
RUN apt-get update && apt-get install -y curl git sudo

# Create non-root user
RUN useradd -m -s /bin/bash vscode && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER vscode
ENV USER vscode
WORKDIR /home/vscode

# Install Nix in daemon-less mode
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
ENV PATH="/home/vscode/.nix-profile/bin:/home/vscode/.nix-profile/sbin:$PATH"

WORKDIR /workspace
