# Optimized single-stage Dockerfile for reliable devcontainer fallback
FROM ubuntu:24.04

# prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# install essential system packages for Nix and development
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    git \
    sudo \
    gnupg \
    xz-utils \
    build-essential \
    file \
    tree \
    jq \
    unzip \
    openssh-client \
    dnsutils \
    netcat-openbsd \
    telnet \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# create non-root user with sudo privileges (handle existing GID gracefully)
RUN if ! getent group 1000 >/dev/null 2>&1; then groupadd --gid 1000 vscode; else groupmod -n vscode $(getent group 1000 | cut -d: -f1); fi \
    && if ! getent passwd 1000 >/dev/null 2>&1; then useradd --uid 1000 --gid 1000 -m vscode; else usermod -l vscode -d /home/vscode -m $(getent passwd 1000 | cut -d: -f1); fi \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /home/vscode/.config \
    && chown -R vscode:vscode /home/vscode

# certificate handling - prepare directory structure
RUN mkdir -p /usr/local/share/ca-certificates/corporate/ \
    && echo "Certificate directory prepared for runtime installation"

USER vscode
ENV USER=vscode
WORKDIR /home/vscode

# install Nix package manager with comprehensive error handling
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon --yes || { \
        echo "Primary Nix installation failed, trying alternative..."; \
        curl -L https://install.determinate.systems/nix | sh -s -- install --no-confirm || { \
            echo "Alternative Nix installation also failed"; \
            exit 1; \
        }; \
    }

# configure Nix with flakes and experimental features
RUN mkdir -p /home/vscode/.config/nix \
    && echo "experimental-features = nix-command flakes" > /home/vscode/.config/nix/nix.conf \
    && echo "auto-optimise-store = true" >> /home/vscode/.config/nix/nix.conf \
    && echo "max-jobs = auto" >> /home/vscode/.config/nix/nix.conf

# set up Nix environment paths
ENV PATH="/home/vscode/.nix-profile/bin:/home/vscode/.nix-profile/sbin:$PATH"
ENV NIX_PATH="/home/vscode/.nix-defexpr/channels"

# create SSH directory with proper permissions
RUN mkdir -p /home/vscode/.ssh \
    && chmod 700 /home/vscode/.ssh

# copy setup and validation scripts
COPY --chown=vscode:vscode ./scripts/ /home/vscode/.devcontainer-scripts/
RUN chmod +x /home/vscode/.devcontainer-scripts/*.sh

WORKDIR /workspaces

# health check for container readiness
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /home/vscode/.devcontainer-scripts/health-check.sh || exit 1

# default command
CMD ["/bin/bash"]
