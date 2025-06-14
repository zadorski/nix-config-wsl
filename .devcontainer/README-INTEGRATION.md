# Devcontainer Integration with nix-config-wsl Repository

This document explains how the new devcontainer configuration integrates with and complements the existing nix-config-wsl repository structure.

## Repository Integration Overview

The devcontainer configuration is designed to work seamlessly with the repository's existing patterns and configurations, providing a fallback solution that maintains consistency with the preferred devenv approach.

### Integration Points

#### 1. Certificate Management Integration
```nix
# system/certificates.nix patterns mirrored in container
security.pki.certificateFiles = lib.optionals isValidCert [ certPath ];
environment.variables = {
  SSL_CERT_FILE = systemCertBundle;
  NIX_SSL_CERT_FILE = systemCertBundle;
  # ... additional certificate variables
};
```

**Devcontainer Implementation:**
- Multi-source certificate detection from repository, WSL host, and Windows
- Same environment variable setup as system/certificates.nix
- Certificate validation using same patterns as repository

#### 2. Development Tools Alignment
```nix
# devenv.nix package selection mirrored in container
packages = with pkgs; [
  nil nixfmt-classic nix-tree nix-diff  # Nix development tools
  git gh just pre-commit                # Development utilities
  fish starship                         # Shell and prompt
  fd ripgrep jq yq tree                 # File and text processing
  curl wget                             # Network tools
];
```

**Devcontainer Implementation:**
- Home-manager configuration matches devenv.nix package selection
- Same development tool versions and configurations
- Consistent shell setup with fish and starship

#### 3. Windows-WSL Manager Integration
```nix
# home/windows/ module patterns leveraged in container
programs.windows-wsl-manager = {
  enable = true;
  applications = {
    vscode = true;    # VS Code settings synchronization
    ssh = true;       # SSH key sharing
    git = true;       # Git configuration synchronization
  };
};
```

**Devcontainer Implementation:**
- Environment variable promotion using windows-wsl-manager patterns
- Certificate detection from Windows certificate store
- SSH key sharing between Windows, WSL, and container
- VS Code settings coordination

#### 4. Shell Configuration Consistency
```nix
# Repository fish shell configuration mirrored
programs.fish = {
  enable = true;
  shellInit = ''
    # Git aliases matching devenv.nix
    abbr -a g git
    abbr -a ga 'git add'
    # ... additional aliases
  '';
};
```

**Devcontainer Implementation:**
- Same fish shell aliases and abbreviations
- Consistent starship prompt configuration
- Matching environment variable setup

## Configuration File Relationships

### Primary Configuration Alignment
| Repository File | Devcontainer Equivalent | Purpose |
|----------------|------------------------|---------|
| `devenv.nix` | `scripts/setup-environment.sh` | Development environment setup |
| `system/certificates.nix` | `scripts/install-certificates.sh` | Certificate management |
| `home/windows/` | Container environment variables | Windows-WSL integration |
| `flake.nix` | Nix configuration in container | Nix package management |

### Validation and Testing
| Repository Pattern | Devcontainer Implementation | Purpose |
|-------------------|---------------------------|---------|
| `nix flake check` | `scripts/validate-environment.sh` | Environment validation |
| System health checks | `scripts/health-check.sh` | Container health monitoring |
| Development workflow | `scripts/test-nix-applications.sh` | Application functionality testing |

## Environment Variable Promotion

### From Repository System Configuration
```bash
# system/certificates.nix environment variables
SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
CURL_CA_BUNDLE="/etc/ssl/certs/ca-certificates.crt"
# ... additional certificate variables
```

### To Container Environment
```json
{
  "containerEnv": {
    "SSL_CERT_FILE": "/etc/ssl/certs/ca-certificates.crt",
    "NIX_SSL_CERT_FILE": "/etc/ssl/certs/ca-certificates.crt",
    "CURL_CA_BUNDLE": "/etc/ssl/certs/ca-certificates.crt",
    "GIT_USER_NAME": "${localEnv:GIT_USER_NAME:zadorski}",
    "GIT_USER_EMAIL": "${localEnv:GIT_USER_EMAIL:678169+zadorski@users.noreply.github.com}"
  }
}
```

## SSH Integration Patterns

### Repository SSH Configuration
```nix
# home/windows/ssh.nix patterns
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
  };
};
```

### Container SSH Implementation
```bash
# Primary: VS Code native SSH agent forwarding
"mounts": ["type=bind,source=${env:SSH_AUTH_SOCK},target=/ssh-agent"]
"containerEnv": {"SSH_AUTH_SOCK": "/ssh-agent"}

# Fallback: SSH key synchronization using repository patterns
sync-ssh-keys  # Script based on home/windows/ssh.nix patterns
```

## Certificate Handling Deep Integration

### Repository Certificate Validation
```nix
# system/certificates.nix validation logic
isValidCert = certExists &&
  (lib.hasInfix "BEGIN CERTIFICATE" certContent ||
   lib.hasInfix "BEGIN TRUSTED CERTIFICATE" certContent) &&
  !(lib.hasInfix "placeholder" certContent);
```

### Container Certificate Validation
```bash
# scripts/install-certificates.sh uses same validation
validate_certificate() {
  if grep -q "BEGIN CERTIFICATE\|BEGIN TRUSTED CERTIFICATE" "$cert_file"; then
    if ! grep -qi "placeholder\|example\|template" "$cert_file"; then
      return 0  # Valid certificate
    fi
  fi
  return 1  # Invalid certificate
}
```

## Development Workflow Integration

### Repository Development Commands
```nix
# devenv.nix scripts
scripts = {
  rebuild.exec = "sudo nixos-rebuild switch --flake .#nixos";
  check.exec = "nix flake check";
  format.exec = "find . -name '*.nix' -exec nixfmt {} \\;";
};
```

### Container Development Commands
```bash
# Available in container environment
nix flake check          # Same flake validation
nixfmt *.nix            # Same formatting tool
git operations          # Same Git configuration
```

## VS Code Integration Coordination

### Repository VS Code Settings
```nix
# home/windows/vscode.nix settings
"remote.WSL.useShellEnvironment" = true;
"remote.WSL.fileWatcher.polling" = false;
"terminal.integrated.defaultProfile.linux" = "fish";
```

### Container VS Code Settings
```json
{
  "customizations": {
    "vscode": {
      "settings": {
        "remote.WSL.useShellEnvironment": true,
        "terminal.integrated.defaultProfile.linux": "fish",
        "nix.enableLanguageServer": true,
        "nix.serverPath": "nil"
      }
    }
  }
}
```

## Migration Compatibility

### Seamless Transition Patterns
1. **Configuration Consistency**: Same tools and settings in both approaches
2. **Environment Variables**: Automatic promotion from repository patterns
3. **Certificate Handling**: Uses same validation and installation logic
4. **SSH Integration**: Leverages same SSH configuration patterns
5. **Development Tools**: Identical package selection and versions

### Validation Alignment
```bash
# Repository validation patterns
nix flake check                    # Flake validation
nixos-rebuild dry-build           # Configuration testing

# Container validation patterns
~/.devcontainer-scripts/validate-environment.sh  # Comprehensive testing
~/.devcontainer-scripts/test-nix-applications.sh # Application testing
```

## Maintenance Synchronization

### Keeping Configurations Aligned
1. **Package Updates**: Update container packages when devenv.nix changes
2. **Certificate Updates**: Sync certificate handling with system/certificates.nix
3. **Tool Versions**: Maintain same tool versions across approaches
4. **Configuration Patterns**: Keep shell and environment setup consistent

### Testing Both Approaches
```bash
# Test devenv approach
cd /path/to/repository
direnv allow
devenv shell
# Validate functionality

# Test devcontainer approach
code .  # Open in VS Code
# Choose "Reopen in Container"
~/.devcontainer-scripts/validate-environment.sh
```

## Benefits of Integration

### Consistency Benefits
✅ **Same Development Experience**: Identical tools and configurations
✅ **Seamless Migration**: Easy switching between approaches
✅ **Shared Patterns**: Leverages existing repository patterns
✅ **Unified Documentation**: Consistent documentation approach

### Reliability Benefits
✅ **Fallback Reliability**: Container works when devenv has issues
✅ **Corporate Support**: Enhanced certificate and proxy handling
✅ **Team Consistency**: Identical environments across team members
✅ **CI/CD Integration**: Container-based development workflows

This integration ensures that the devcontainer serves as a true fallback solution that maintains the same development experience while providing enhanced reliability for challenging environments.
