# multi-stage Dockerfile for optimized Nix development environment
# designed as fallback solution for corporate environments with certificate challenges

# Stage 1: Base system setup with certificates
FROM ubuntu:24.04 AS base

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
    # additional utilities for corporate environments
    dnsutils \
    netcat-openbsd \
    telnet \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Stage 2: Certificate handling with multiple fallback approaches
FROM base AS certificates

# create certificate directory structure
RUN mkdir -p /usr/local/share/ca-certificates/corporate \
    && mkdir -p /tmp/certificates

# copy certificates from multiple potential sources
# approach 1: direct certificate file (primary)
COPY --from=base /usr/local/share/ca-certificates/ /usr/local/share/ca-certificates/
# copy optional corporate certificate with proper directory destination
COPY ./zscaler-root-ca.crt /usr/local/share/ca-certificates/corporate/
# handle missing certificate file gracefully
RUN if [ ! -f /usr/local/share/ca-certificates/corporate/zscaler-root-ca.crt ]; then \
    echo "Corporate certificate not found in build context, will try alternative sources"; \
    fi

# approach 2: copy from WSL host if available (fallback)
# this will be handled by setup scripts at runtime

# approach 3: certificate detection and installation script
COPY ./scripts/install-certificates.sh /usr/local/bin/install-certificates.sh
RUN chmod +x /usr/local/bin/install-certificates.sh

# update certificate store with error handling
RUN set -e; \
    echo "Installing certificates..."; \
    if [ -f /usr/local/share/ca-certificates/corporate/zscaler-root-ca.crt ]; then \
        chmod 644 /usr/local/share/ca-certificates/corporate/zscaler-root-ca.crt; \
        echo "Found Zscaler certificate, updating certificate store..."; \
        update-ca-certificates || echo "Warning: Certificate update failed, continuing..."; \
    else \
        echo "No corporate certificates found, using system defaults"; \
    fi

# Stage 3: User setup and Nix installation
FROM certificates AS nix-setup

# create non-root user with sudo privileges
RUN useradd -m -s /bin/bash vscode \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
    && mkdir -p /home/vscode/.config \
    && chown -R vscode:vscode /home/vscode

USER vscode
ENV USER=vscode
WORKDIR /home/vscode

# install Nix package manager with comprehensive error handling
RUN set -e; \
    echo "Installing Nix package manager..."; \
    curl -L https://nixos.org/nix/install | sh -s -- --no-daemon --yes || { \
        echo "Primary Nix installation failed, trying alternative approach..."; \
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

# Stage 4: Development environment setup
FROM nix-setup AS development

# source Nix environment and install essential packages
RUN . /home/vscode/.nix-profile/etc/profile.d/nix.sh \
    && nix-env -iA nixpkgs.fish nixpkgs.starship nixpkgs.git nixpkgs.curl nixpkgs.wget \
    || echo "Warning: Some package installations failed, continuing..."

# create SSH directory with proper permissions
RUN mkdir -p /home/vscode/.ssh \
    && chmod 700 /home/vscode/.ssh

# create development directories
RUN mkdir -p /home/vscode/.config/fish \
    && mkdir -p /home/vscode/.local/share

WORKDIR /workspaces

# final stage: runtime configuration
FROM development AS runtime

# copy setup and validation scripts
COPY ./scripts/ /home/vscode/.devcontainer-scripts/
RUN sudo chown -R vscode:vscode /home/vscode/.devcontainer-scripts \
    && chmod +x /home/vscode/.devcontainer-scripts/*.sh

# set default shell to bash (fish will be configured by setup scripts)
SHELL ["/bin/bash", "-c"]

# health check for container readiness
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /home/vscode/.devcontainer-scripts/health-check.sh || exit 1

# default command
CMD ["/bin/bash"]
