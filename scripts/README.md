# Scripts Directory

This directory contains utility scripts for managing and validating the nix-config-wsl development environment.

## Available Scripts

### `validate-nix-workflow-optimizations.sh`

**Purpose**: Comprehensive validation of Nix workflow optimizations to ensure elimination of redundant warnings and confirmation prompts.

**Usage**:
```bash
./scripts/validate-nix-workflow-optimizations.sh
```

**What it tests**:
1. **Experimental features configuration** - Verifies nix-command and flakes are enabled
2. **Flake operations without prompts** - Tests that flake commands don't hang on confirmations
3. **Git dirty tree warning suppression** - Checks that development warnings are suppressed
4. **Flake nixConfig settings** - Validates optimization settings in flake.nix
5. **System Nix configuration** - Verifies system-wide optimizations
6. **Devcontainer configuration** - Checks container environment settings
7. **Devenv scripts optimization** - Validates development scripts use optimized flags
8. **Performance settings** - Confirms performance optimizations are active
9. **User permissions** - Checks wheel group membership for trusted-users
10. **Command functionality** - Tests that Nix commands work without prompts

**Expected Output**:
```
🔍 Validating Nix workflow optimizations...

🧪 Testing: Experimental features configuration
✅ PASS: Experimental features (nix-command flakes) are enabled

🧪 Testing: Flake operations without confirmation prompts
✅ PASS: Flake check completed without hanging on prompts

...

🏁 Validation Summary:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Total tests: 10
Passed: 10
Failed: 0

🎉 All optimizations are working correctly!

✅ Experimental features confirmation loops eliminated
✅ Git dirty tree warnings suppressed
✅ Trust configuration properly set up
✅ Performance optimizations enabled

Your Nix workflow should now be much more efficient!
```

**Troubleshooting**:
If tests fail, the script provides specific guidance:
- Rebuild NixOS configuration if system settings are missing
- Restart shell session for environment changes
- Rebuild container for devcontainer-specific issues

## Script Development Guidelines

### Adding New Scripts

1. **Make scripts executable**: `chmod +x scripts/your-script.sh`
2. **Use proper shebang**: `#!/usr/bin/env bash`
3. **Include error handling**: `set -e` for strict error handling
4. **Add documentation**: Include purpose, usage, and examples
5. **Follow naming convention**: Use kebab-case for script names

### Script Structure Template

```bash
#!/usr/bin/env bash
# brief description of what the script does

set -e  # exit on any error

# colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # no color

echo "🚀 Starting script..."

# your script logic here

echo "✅ Script completed successfully!"
```

### Best Practices

1. **Use colors for output** - Makes scripts more readable
2. **Provide clear feedback** - Show progress and results
3. **Handle errors gracefully** - Provide helpful error messages
4. **Test thoroughly** - Validate scripts in different environments
5. **Document dependencies** - List required tools and packages

## Integration with Development Workflow

### Automated Validation

Scripts in this directory are designed to integrate with:
- **CI/CD pipelines** - Automated testing of configuration changes
- **Development workflows** - Pre-commit validation
- **Container environments** - Post-setup validation
- **System maintenance** - Regular health checks

### Usage in Different Environments

#### Native WSL Environment
```bash
# Run validation after system changes
sudo nixos-rebuild switch --flake .#nixos
./scripts/validate-nix-workflow-optimizations.sh
```

#### Devcontainer Environment
```bash
# Validation runs automatically via lifecycle commands
# Manual validation if needed:
./scripts/validate-nix-workflow-optimizations.sh
```

#### CI/CD Integration
```yaml
# Example GitHub Actions step
- name: Validate Nix Workflow Optimizations
  run: ./scripts/validate-nix-workflow-optimizations.sh
```

## Maintenance

### Regular Tasks

1. **Update validation criteria** - Keep tests current with Nix best practices
2. **Add new validations** - Test new optimizations and configurations
3. **Performance monitoring** - Track script execution times
4. **Cross-platform testing** - Ensure scripts work in all environments

### Contributing

When adding new scripts:
1. Follow the established patterns and conventions
2. Include comprehensive error handling
3. Add appropriate documentation
4. Test in multiple environments
5. Update this README with new script information

## Related Documentation

- **System Configuration**: `system/README.md` - System-level Nix configuration
- **Development Environment**: `home/README.md` - User-level configuration
- **Container Setup**: `.devcontainer/README.md` - Container environment setup
- **Task Documentation**: `.ai/tasks/` - Detailed implementation documentation

The scripts in this directory are essential tools for maintaining and validating the optimized Nix development environment, ensuring consistent performance and eliminating workflow friction.
