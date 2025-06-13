FROM ubuntu:22.04

# debconf isn't happy upon onCreateCommand stage otherwise
ENV DEBIAN_FRONTEND=noninteractive

USER root
# copy your custom root certificate
COPY ./zscaler-root-ca.crt /usr/local/share/ca-certificates/zscaler-root-ca.crt
# manually place it in the system certs directory
RUN mkdir -p /etc/ssl/certs && \
    cp /usr/local/share/ca-certificates/zscaler-root-ca.crt /etc/ssl/certs/zscaler-root-ca.pem

ENV SSL_CERT_FILE=/etc/ssl/certs/zscaler-root-ca.pem \
    CURL_CA_BUNDLE=/etc/ssl/certs/zscaler-root-ca.pem \
    REQUESTS_CA_BUNDLE=/etc/ssl/certs/zscaler-root-ca.pem \
    NODE_EXTRA_CA_CERTS=/etc/ssl/certs/zscaler-root-ca.pem \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/zscaler-root-ca.pem

# now apt-get should work with HTTPS
RUN apt-get update && apt-get install -y ca-certificates apt-utils dialog 
# now you can run update-ca-certificates safely
RUN update-ca-certificates

#COPY ./zscaler-root-ca.crt /usr/local/share/ca-certificates/
#RUN chmod 644 /usr/local/share/ca-certificates/zscaler-root-ca.crt
#RUN update-ca-certificates

# don't stay in root if you don't have to
#USER root
# assess this line against the line `containerEnv` in .devcontainer
#ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
#ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
#ENV NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
#ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# https://stackoverflow.com/a/66815106/289515
# https://blog.jhnr.ch/2018/05/16/working-with-azure-cli-behind-ssl-intercepting-proxy-server/
#ENV REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

# uncomment temporary for bundle helpful when migrating to other environment (without docker installed yet)
#COPY --from=build /etc/ssl/certs/ca-certificates.crt ./ca-bundle-incl-zscaler-root-ca.crt

# Install basic packages
RUN apt-get update && apt-get install -y \
  curl \
  git \
  sudo \
  gnupg \
  xz-utils && \
  curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
  apt-get install -y nodejs

# Create non-root user
RUN useradd -m -s /bin/bash vscode && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER vscode
ENV USER=vscode
WORKDIR /home/vscode

# Install Nix in daemon-less mode
RUN curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
ENV PATH="/home/vscode/.nix-profile/bin:/home/vscode/.nix-profile/sbin:$PATH"

RUN mkdir -p /home/vscode/.config/nix && \
    echo "experimental-features = nix-command flakes" >> /home/vscode/.config/nix/nix.conf

WORKDIR /workspaces
