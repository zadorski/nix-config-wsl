# Devcontainer Feature Restoration Plan

## Current Status

✅ **Container Build**: Successful (5.4 seconds)
❌ **Container Runtime**: Failing due to SSH mount issue
🔄 **Minimal Config**: Implemented and ready for testing

## Progressive Restoration Strategy

### Phase 1: Establish Baseline ⏳ IN PROGRESS

**Objective**: Get basic devcontainer working without advanced features

**Current Configuration** (`devcontainer.json`):
```json
{
  "name": "nix-wsl-dev-fallback",
  "build": { "dockerfile": "Dockerfile", "context": "." },
  "runArgs": ["--memory=4g", "--cpus=2", "--init", "--security-opt=seccomp=unconfined"],
  "workspaceFolder": "/workspaces/${localWorkspaceFolderBasename}",
  "containerEnv": {
    "GIT_USER_NAME": "${localEnv:GIT_USER_NAME:zadorski}",
    "GIT_USER_EMAIL": "${localEnv:GIT_USER_EMAIL:678169+zadorski@users.noreply.github.com}"
  },
  "features": { "ghcr.io/devcontainers/features/common-utils:2": {...} },
  "remoteUser": "vscode"
}
```

**Test Criteria**:
- [ ] Container starts successfully
- [ ] VS Code connects to container
- [ ] Basic terminal access works
- [ ] User permissions are correct

**If Phase 1 Fails**: Switch to host networking approach

### Phase 2: Network Configuration Testing

**Option A: Test Current Minimal Config**
```bash
# Test with current configuration
# Check if SSH_AUTH_SOCK issue is resolved by removing mount
```

**Option B: Test Host Networking**
```bash
# Copy devcontainer-host-network.json to devcontainer.json
# Test container startup with host networking
# Validate SSH agent access
```

**Decision Matrix**:
| Test Result | Next Action |
|-------------|-------------|
| Minimal config works | Proceed to Phase 3 |
| Minimal config fails | Switch to host networking |
| Host networking works | Use as baseline for Phase 3 |
| Both fail | Investigate deeper container issues |

### Phase 3: Certificate Environment Variables

**Objective**: Add certificate handling for corporate environments

**Configuration Addition**:
```json
"containerEnv": {
  // existing variables...
  "SSL_CERT_FILE": "/etc/ssl/certs/ca-certificates.crt",
  "NIX_SSL_CERT_FILE": "/etc/ssl/certs/ca-certificates.crt",
  "CURL_CA_BUNDLE": "/etc/ssl/certs/ca-certificates.crt",
  "REQUESTS_CA_BUNDLE": "/etc/ssl/certs/ca-certificates.crt",
  "NODE_EXTRA_CA_CERTS": "/etc/ssl/certs/ca-certificates.crt",
  "PIP_CERT": "/etc/ssl/certs/ca-certificates.crt",
  "CARGO_HTTP_CAINFO": "/etc/ssl/certs/ca-certificates.crt",
  "GIT_SSL_CAINFO": "/etc/ssl/certs/ca-certificates.crt",
  "NIXPKGS_ALLOW_UNFREE": "1",
  "NIX_CONFIG": "experimental-features = nix-command flakes"
}
```

**Test Criteria**:
- [ ] Container starts with certificate variables
- [ ] HTTPS connectivity works (curl https://github.com)
- [ ] Certificate environment variables are set correctly

### Phase 4: SSH Integration (Conditional)

**Objective**: Add SSH agent forwarding with fallback handling

**Approach A: Conditional Mount** (if using default networking)
```json
"mounts": [
  "type=bind,source=${env:SSH_AUTH_SOCK:-/tmp/ssh-fallback},target=/ssh-agent,consistency=cached"
],
"containerEnv": {
  "SSH_AUTH_SOCK": "${env:SSH_AUTH_SOCK:+/ssh-agent}"
}
```

**Approach B: Host Networking** (if using host networking)
```json
// No mount needed - direct access to host SSH agent
"containerEnv": {
  "SSH_AUTH_SOCK": "${env:SSH_AUTH_SOCK}"
}
```

**Test Criteria**:
- [ ] SSH agent is accessible in container
- [ ] SSH keys are available (ssh-add -l)
- [ ] Git SSH operations work (ssh -T git@github.com)

### Phase 5: Lifecycle Commands

**Objective**: Add automated setup and validation

**Progressive Addition**:

**Step 5.1**: Add onCreateCommand only
```json
"onCreateCommand": {
  "setupEnvironment": "bash -c 'echo \"🚀 Setting up Nix development environment...\" && ./.devcontainer/scripts/setup-environment.sh'"
}
```

**Step 5.2**: Add postCreateCommand
```json
"postCreateCommand": {
  "validateEnvironment": "bash -c 'echo \"✅ Running post-setup validation...\" && ./.devcontainer/scripts/validate-environment.sh'"
}
```

**Step 5.3**: Add postStartCommand
```json
"postStartCommand": {
  "checkEnvironment": "bash -c 'echo \"🔄 Container started, checking environment...\" && ./.devcontainer/scripts/check-environment.sh'"
}
```

**Test Criteria for Each Step**:
- [ ] Command executes without errors
- [ ] Expected output is produced
- [ ] Container remains functional after command execution

### Phase 6: VS Code Customizations

**Objective**: Add VS Code settings and extensions

**Progressive Addition**:

**Step 6.1**: Basic Settings
```json
"customizations": {
  "vscode": {
    "settings": {
      "terminal.integrated.defaultProfile.linux": "bash",
      "remote.WSL.useShellEnvironment": true
    }
  }
}
```

**Step 6.2**: File Watcher Exclusions
```json
"settings": {
  // previous settings...
  "files.watcherExclude": {
    "**/node_modules/**": true,
    "**/.git/objects/**": true,
    "**/nix/store/**": true,
    "**/.devenv/**": true,
    "**/.direnv/**": true
  }
}
```

**Step 6.3**: Extensions
```json
"extensions": [
  "jnoortheen.nix-ide",
  "ms-vscode.vscode-json",
  "redhat.vscode-yaml"
]
```

**Test Criteria**:
- [ ] VS Code settings are applied correctly
- [ ] Extensions install without errors
- [ ] File watching performance is acceptable

### Phase 7: Advanced Features

**Objective**: Add sophisticated features like Fish shell and Starship

**Configuration**:
```json
"customizations": {
  "vscode": {
    "settings": {
      "terminal.integrated.defaultProfile.linux": "fish",
      "terminal.integrated.profiles.linux": {
        "fish": {
          "path": "/home/vscode/.nix-profile/bin/fish",
          "args": ["-l"]
        }
      }
    }
  }
}
```

**Dependencies**: Requires successful Nix setup and package installation

## Testing Protocol

### For Each Phase:

1. **Backup Current Config**:
   ```bash
   cp .devcontainer/devcontainer.json .devcontainer/devcontainer.json.backup
   ```

2. **Apply Changes**:
   ```bash
   # Edit devcontainer.json with phase-specific changes
   ```

3. **Test Container**:
   ```bash
   # In VS Code: Command Palette > "Dev Containers: Rebuild Container"
   # Or: Docker Desktop > Remove container > VS Code > Reopen in Container
   ```

4. **Validate Functionality**:
   ```bash
   # Run phase-specific test criteria
   # Document any issues or failures
   ```

5. **Decision Point**:
   - ✅ **Success**: Proceed to next phase
   - ❌ **Failure**: Rollback and investigate
   - ⚠️ **Partial**: Document issues and decide whether to proceed

## Rollback Strategy

### Quick Rollback
```bash
# Restore previous working configuration
cp .devcontainer/devcontainer.json.backup .devcontainer/devcontainer.json
```

### Configuration Variants
- `devcontainer.json` - Current test configuration
- `devcontainer.json.backup` - Previous working state
- `devcontainer-host-network.json` - Host networking variant
- `devcontainer-minimal.json` - Absolute minimal configuration

## Success Metrics

### Phase Completion Criteria
- [ ] **Phase 1**: Basic container functionality
- [ ] **Phase 2**: Network configuration working
- [ ] **Phase 3**: Certificate handling functional
- [ ] **Phase 4**: SSH integration working
- [ ] **Phase 5**: Automated setup successful
- [ ] **Phase 6**: VS Code integration complete
- [ ] **Phase 7**: Advanced features operational

### Final Success Criteria
- [ ] Container builds and starts reliably
- [ ] SSH agent forwarding works for Git operations
- [ ] Certificate handling supports corporate environments
- [ ] Nix package manager is functional
- [ ] Development tools are available and working
- [ ] VS Code integration provides good developer experience

## Documentation Updates

After each successful phase:
1. Update TROUBLESHOOTING-ANALYSIS.md with findings
2. Document any configuration changes in README.md
3. Update NETWORK-ANALYSIS.md with network configuration results
4. Create or update troubleshooting guides for identified issues

This systematic approach ensures we can identify the exact failure point and build a robust, working devcontainer configuration step by step.
