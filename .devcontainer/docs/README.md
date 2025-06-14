# Devcontainer Documentation

This directory contains comprehensive documentation for the minimalistic devcontainer configuration designed as a fallback solution for the nix-config-wsl repository.

## Document Overview

### Core Documentation
- **[windows-wsl-integration.md](./windows-wsl-integration.md)** - Integration with repository's Windows-WSL management system
- **[devenv-vs-devcontainer-updated.md](./devenv-vs-devcontainer-updated.md)** - Updated comparison and decision matrix

### Quick Reference
- **[../README.md](../README.md)** - Main devcontainer configuration documentation
- **[../../docs/devenv-vs-devcontainer.md](../../docs/devenv-vs-devcontainer.md)** - Original comparison document

## Purpose and Context

This devcontainer configuration serves as a **reliable fallback** when the preferred devenv approach encounters issues, particularly:

- SSH agent forwarding problems in corporate environments
- Certificate validation issues with Zscaler or other corporate proxies
- Need for guaranteed environment consistency across team members
- CI/CD integration requirements

## Key Design Principles

### 1. Reliability First
- Multi-stage Dockerfile with comprehensive error handling
- Multiple fallback approaches for common failure points
- Extensive validation and troubleshooting tools

### 2. Corporate Environment Support
- Multi-source certificate detection and installation
- Zscaler-specific certificate handling
- Windows-WSL integration patterns
- Proxy-friendly configuration

### 3. Repository Pattern Consistency
- Mirrors `devenv.nix` tool selection
- Uses `system/certificates.nix` patterns
- Integrates with `home/windows/` modules
- Maintains fish shell and starship prompt configuration

### 4. Comprehensive Testing
- Nix-based application testing
- Environment validation scripts
- Health monitoring and diagnostics
- Automated troubleshooting tools

## Architecture Overview

```
Devcontainer Architecture
├── Base: Ubuntu 24.04 LTS
├── Nix: Single-user with flakes
├── Certificates: Multi-source detection
├── SSH: VS Code native + fallbacks
├── Shell: Fish + Starship
├── Tools: Matching devenv.nix
└── Validation: Comprehensive testing
```

## Integration Points

### Windows-WSL Manager Integration
- Environment variable promotion from Windows to WSL to container
- Certificate detection from Windows certificate store
- SSH key sharing between Windows, WSL, and container
- VS Code settings synchronization

### Repository Configuration Alignment
- Development tools match `devenv.nix` package selection
- Certificate handling mirrors `system/certificates.nix` patterns
- Shell configuration consistent with repository standards
- Git configuration aligned with repository practices

## Usage Scenarios

### When to Use Devcontainer

✅ **Use devcontainer when:**
- SSH agent forwarding is unreliable or blocked
- Corporate certificates cause validation issues
- Team needs identical development environments
- CI/CD integration requires container consistency
- Troubleshooting complex environment issues

### When to Use Devenv

✅ **Use devenv when:**
- Standard WSL environment works reliably
- Performance is critical (native vs container)
- Quick environment activation is needed (seconds vs minutes)
- Host integration is preferred over isolation

## Performance Characteristics

| Metric | Devenv | Devcontainer | Impact |
|--------|--------|--------------|---------|
| Startup Time | 5-15s | 2-5min | 16x slower |
| Memory Usage | ~50MB | ~500MB | 10x more |
| File I/O | Native | 90% native | 10% slower |
| Network | Direct | Container layer | Minimal |

## Troubleshooting Resources

### Diagnostic Scripts
- `scripts/validate-environment.sh` - Comprehensive environment testing
- `scripts/troubleshoot.sh` - Diagnostic information and automated fixes
- `scripts/test-nix-applications.sh` - Nix package functionality testing
- `scripts/check-environment.sh` - Quick startup validation

### Common Issues and Solutions

#### SSH Agent Forwarding
```bash
# Check SSH agent status
echo $SSH_AUTH_SOCK
ssh-add -l

# Test SSH connectivity
ssh -T git@github.com

# Run troubleshooting
~/.devcontainer-scripts/troubleshoot.sh
```

#### Certificate Issues
```bash
# Check certificate installation
ls -la /usr/local/share/ca-certificates/

# Test HTTPS connectivity
curl -v https://github.com

# Reinstall certificates
~/.devcontainer-scripts/install-certificates.sh
```

#### Environment Setup Issues
```bash
# Re-run full setup
~/.devcontainer-scripts/setup-environment.sh

# Validate environment
~/.devcontainer-scripts/validate-environment.sh

# Test Nix applications
~/.devcontainer-scripts/test-nix-applications.sh
```

## Migration Guidance

### From Devenv to Devcontainer
1. Identify the specific issue with devenv
2. Open project in VS Code
3. Choose "Reopen in Container" when prompted
4. Wait for automatic setup to complete
5. Run validation script to confirm functionality

### From Devcontainer to Devenv
1. Ensure host environment is properly configured
2. Test SSH agent forwarding and certificates
3. Close container and reopen in WSL
4. Allow direnv to activate devenv environment
5. Verify functionality with devenv tools

## Maintenance and Updates

### Regular Maintenance Tasks
- Update base Ubuntu image for security patches
- Refresh Nix package versions
- Update corporate certificates as needed
- Test both devenv and devcontainer approaches regularly

### Configuration Updates
- Keep devcontainer tools aligned with `devenv.nix`
- Update certificate detection patterns as needed
- Maintain consistency with repository patterns
- Document any configuration changes

## Contributing

When contributing to the devcontainer configuration:

1. **Test Both Approaches**: Ensure changes don't break devenv compatibility
2. **Maintain Patterns**: Follow repository configuration patterns
3. **Document Changes**: Update relevant documentation
4. **Validate Thoroughly**: Run all validation scripts
5. **Consider Corporate Environments**: Test with proxy/certificate scenarios

## Support and Resources

### Internal Resources
- Repository documentation in `docs/` directory
- Windows-WSL integration in `home/windows/` modules
- System configuration in `system/` directory
- Development environment in `devenv.nix`

### External Resources
- [VS Code Dev Containers](https://code.visualstudio.com/docs/remote/containers)
- [Nix Package Manager](https://nixos.org/manual/nix/stable/)
- [Home Manager](https://github.com/nix-community/home-manager)
- [NixOS WSL](https://github.com/nix-community/NixOS-WSL)

## Future Enhancements

### Planned Improvements
- Dynamic certificate monitoring and updates
- Enhanced Windows certificate store integration
- Performance optimization for container startup
- Automated testing in CI/CD pipelines
- Integration with repository's task documentation system

### Potential Features
- Multi-architecture support (ARM64)
- Alternative base images (NixOS container)
- Enhanced debugging and profiling tools
- Integration with repository's development workflow scripts
