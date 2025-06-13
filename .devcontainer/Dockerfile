FROM ubuntu:22.04

# prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

USER root

# install essential system packages for Nix and development
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    git \
    sudo \
    gnupg \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# copy and install Zscaler certificate for corporate environments
COPY ./zscaler-root-ca.crt /usr/local/share/ca-certificates/zscaler-root-ca.crt
RUN chmod 644 /usr/local/share/ca-certificates/zscaler-root-ca.crt && \
    update-ca-certificates

# create non-root user with sudo privileges
RUN useradd -m -s /bin/bash vscode && \
    echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER vscode
ENV USER=vscode
WORKDIR /home/vscode

# install Nix package manager in single-user mode
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon

# configure Nix with flakes support
RUN mkdir -p /home/vscode/.config/nix && \
    echo "experimental-features = nix-command flakes" >> /home/vscode/.config/nix/nix.conf

# set up Nix environment
ENV PATH="/home/vscode/.nix-profile/bin:/home/vscode/.nix-profile/sbin:$PATH"

WORKDIR /workspaces
