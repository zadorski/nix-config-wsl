#!/usr/bin/env bash
# Container health check script
# Used by Docker HEALTHCHECK to verify container readiness

set -euo pipefail

# basic system health checks
check_system() {
    # check if basic commands are available
    command -v bash >/dev/null 2>&1 || return 1
    command -v curl >/dev/null 2>&1 || return 1
    
    # check if user home directory is accessible
    [ -d /home/vscode ] || return 1
    [ -w /home/vscode ] || return 1
    
    return 0
}

# check Nix installation
check_nix() {
    # check if Nix is installed
    [ -f /home/vscode/.nix-profile/etc/profile.d/nix.sh ] || return 1

    # source Nix environment and test
    . /home/vscode/.nix-profile/etc/profile.d/nix.sh 2>/dev/null || return 1
    command -v nix >/dev/null 2>&1 || return 1

    return 0
}

# check certificate store
check_certificates() {
    # check if system certificate store exists
    [ -f /etc/ssl/certs/ca-certificates.crt ] || return 1
    
    # basic connectivity test
    curl -s --max-time 5 https://github.com >/dev/null 2>&1 || return 1
    
    return 0
}

# main health check
main() {
    echo "Performing container health check..."
    
    if ! check_system; then
        echo "UNHEALTHY: System check failed"
        exit 1
    fi
    
    if ! check_nix; then
        echo "UNHEALTHY: Nix check failed"
        exit 1
    fi
    
    if ! check_certificates; then
        echo "UNHEALTHY: Certificate/connectivity check failed"
        exit 1
    fi
    
    echo "HEALTHY: All checks passed"
    exit 0
}

main "$@"
