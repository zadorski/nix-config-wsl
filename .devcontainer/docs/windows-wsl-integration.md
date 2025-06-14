# Windows-WSL Integration for Devcontainer

This document explains how the devcontainer configuration integrates with the repository's sophisticated Windows-WSL management system.

## Overview

The repository includes comprehensive Windows-WSL integration through the `home/windows/` modules. This devcontainer configuration leverages these patterns to provide seamless integration between:

- Windows VS Code client
- WSL host environment  
- Development container

## Integration Architecture

```
Windows VS Code Client
         ↓
    WSL Host (NixOS)
    ├── windows-wsl-manager
    ├── Certificate Management
    ├── SSH Key Sharing
    └── Environment Variables
         ↓
    Development Container
    ├── Certificate Import
    ├── SSH Agent Forwarding
    ├── Environment Promotion
    └── Development Tools
```

## Windows-WSL-Manager Integration

### Environment Variable Promotion

The devcontainer automatically inherits environment variables from the WSL host:

```bash
# Variables promoted from Windows to WSL to Container
WIN_USERNAME          # Windows username detection
WIN_USERPROFILE       # Windows user profile path
WIN_APPDATA          # Windows application data
WIN_LOCALAPPDATA     # Windows local application data
```

### Certificate Handling Integration

The devcontainer certificate installation script (`install-certificates.sh`) integrates with the repository's certificate management:

1. **System Integration**: Uses patterns from `system/certificates.nix`
2. **Windows Certificate Store**: Accesses Windows certificates via WSL mounts
3. **Multiple Sources**: Checks repository, WSL host, and Windows locations
4. **Validation**: Uses same validation logic as system configuration

### SSH Key Sharing

Leverages the `home/windows/ssh.nix` patterns:

1. **VS Code Native Forwarding**: Primary approach using VS Code's SSH agent forwarding
2. **Key Synchronization**: Fallback using repository's SSH key sharing scripts
3. **Permission Management**: Applies same permission fixes as repository scripts

## Certificate Management Deep Dive

### Certificate Sources (Priority Order)

1. **Container Direct**: `/usr/local/share/ca-certificates/corporate/`
2. **Repository**: `/workspaces/nix-config-wsl/certs/zscaler.pem`
3. **Windows User Profile**: `/mnt/c/Users/*/AppData/Local/Zscaler/`
4. **Windows System**: `/mnt/c/ProgramData/Zscaler/cert/`

### Environment Variable Configuration

Mirrors `system/certificates.nix` patterns:

```bash
SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
PIP_CERT=/etc/ssl/certs/ca-certificates.crt
CARGO_HTTP_CAINFO=/etc/ssl/certs/ca-certificates.crt
GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
```

## VS Code Integration Optimizations

### Settings Synchronization

The devcontainer includes VS Code settings that complement the `home/windows/vscode.nix` configuration:

```json
{
  "remote.WSL.useShellEnvironment": true,
  "remote.WSL.fileWatcher.polling": false,
  "terminal.integrated.defaultProfile.linux": "fish",
  "files.watcherExclude": {
    "**/nix/store/**": true,
    "**/.devenv/**": true
  }
}
```

### Extension Management

Coordinates with repository's VS Code extension management:

- **Workspace Extensions**: Nix IDE, language servers
- **Remote Extensions**: Installed in container context
- **Host Extensions**: Managed by `home/windows/vscode.nix`

## SSH Agent Forwarding Deep Dive

### Primary Approach: VS Code Native

```json
{
  "mounts": [
    "type=bind,source=${env:SSH_AUTH_SOCK},target=/ssh-agent,consistency=cached"
  ],
  "containerEnv": {
    "SSH_AUTH_SOCK": "/ssh-agent"
  }
}
```

### Fallback Approach: Key Mounting

If SSH agent forwarding fails, the container can fall back to direct key mounting using repository patterns from `home/windows/ssh.nix`.

### Troubleshooting Integration

The troubleshooting script includes checks that align with repository SSH debugging:

1. **Agent Socket Validation**: Checks VS Code forwarding
2. **Key Availability**: Lists available keys
3. **Connection Testing**: Tests GitHub/Azure DevOps access
4. **Permission Verification**: Ensures proper SSH permissions

## Environment Variable Promotion

### Automatic Detection

Uses repository patterns from `home/windows/env-vars.nix`:

```bash
# Windows environment detection
if command -v wslvar >/dev/null 2>&1; then
  WIN_USERNAME=$(wslvar USERNAME 2>/dev/null || echo "")
  # Additional Windows environment variables
fi
```

### Certificate Environment Promotion

Promotes certificate-related environment variables from WSL host to container:

```bash
# Inherited from WSL host system configuration
export SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
export NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
# ... additional certificate variables
```

## Performance Optimizations

### File System Performance

- **Bind Mounts**: Optimized for WSL2 file system performance
- **Watcher Exclusions**: Excludes Nix store and cache directories
- **Consistency Settings**: Uses `cached` consistency for better performance

### Network Performance

- **Certificate Caching**: Caches certificate validation results
- **Connection Pooling**: Uses SSH connection multiplexing
- **DNS Optimization**: Leverages WSL DNS resolution

## Troubleshooting Integration

### Diagnostic Alignment

The container troubleshooting scripts align with repository patterns:

1. **Windows Environment Detection**: Uses same detection logic
2. **Certificate Validation**: Uses same validation patterns
3. **SSH Debugging**: Uses same SSH testing approaches
4. **Network Connectivity**: Tests same endpoints

### Automated Fixes

Applies same fixes as repository scripts:

1. **SSH Permissions**: Uses `fix-ssh-permissions` patterns
2. **Certificate Installation**: Uses `install-certificates` patterns
3. **Environment Setup**: Uses home-manager patterns

## Migration Considerations

### From Devenv to Devcontainer

When migrating from devenv to devcontainer:

1. **Environment Variables**: Automatically promoted from WSL host
2. **Certificates**: Automatically detected and installed
3. **SSH Keys**: Automatically forwarded or synchronized
4. **Development Tools**: Matched to devenv.nix configuration

### From Devcontainer to Devenv

When migrating back to devenv:

1. **Configuration Consistency**: Same tools and settings
2. **Certificate Handling**: Uses same system configuration
3. **SSH Integration**: Uses same WSL SSH agent
4. **Performance Improvement**: Native performance without container overhead

## Best Practices

### Certificate Management

1. **Keep Repository Certificate Updated**: Ensure `certs/zscaler.pem` is current
2. **Test Multiple Sources**: Verify certificate detection from all sources
3. **Monitor Expiration**: Set up certificate expiration monitoring

### SSH Integration

1. **Prefer Agent Forwarding**: Use VS Code native SSH forwarding when possible
2. **Test Connectivity**: Regularly test SSH access to Git repositories
3. **Monitor Key Rotation**: Ensure SSH keys are rotated according to policy

### Environment Consistency

1. **Sync Configurations**: Keep devcontainer and devenv configurations aligned
2. **Test Both Approaches**: Regularly test both devcontainer and devenv setups
3. **Document Differences**: Maintain clear documentation of approach differences

## Future Enhancements

### Planned Improvements

1. **Dynamic Certificate Detection**: Real-time certificate store monitoring
2. **Enhanced Windows Integration**: Deeper integration with Windows certificate store
3. **Performance Monitoring**: Container performance metrics and optimization
4. **Automated Testing**: Continuous integration testing of both approaches
