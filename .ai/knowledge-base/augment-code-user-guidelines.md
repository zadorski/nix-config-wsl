# Augment Code User Guidelines for NixOS-WSL Configuration

## Overview

This document provides comprehensive guidelines for effective AI agent interactions within the nix-config-wsl repository. It combines repository-specific patterns, Augment Code methodology, and NixOS/WSL development best practices to ensure consistent, high-quality AI assistance.

## Repository Context & Architecture

### Core Characteristics
- **Purpose**: Modular NixOS-WSL flake configuration for Windows development environments
- **Architecture**: Flake-based with clear system/home separation using home-manager
- **Target Users**: Windows developers using WSL2 with NixOS for development workflows
- **Key Features**: VS Code Remote Server, container support, certificate management, devenv integration

### Established Infrastructure
- **AI Directory**: Well-structured `.ai/` with manifest, rules, knowledge base, and task management
- **Documentation Standards**: Comprehensive coding standards and architecture documentation
- **Quality Assurance**: Required `nix fmt` and `nix flake check` for all changes
- **Task Management**: Structured task documentation protocol in `.ai/tasks/`

## Augment Code Integration Principles

### 1. Context-First Approach
**Always start with comprehensive context gathering:**
- Read `AI_ROOT_GUIDE.md` for essential repository overview
- Consult `.ai/knowledge-base/architecture.md` for deep architectural understanding
- Review `.ai/rules/coding-standards.md` for code quality requirements
- Check `.ai/tasks/doing/` for current work context

**Before making any changes:**
- Use `codebase-retrieval` tool to understand existing patterns
- Ask for ALL symbols, classes, methods, and dependencies involved in the change
- Understand the full scope of impact across system and home configurations

### 2. Documentation-Driven Development
**Follow the established documentation protocol:**
- Create task documentation in `.ai/tasks/doing/` using the structured template
- Update documentation alongside code changes
- Maintain comprehensive comments explaining WHY, not just WHAT
- Reference existing documentation and cross-link related components

### 3. Memory and Learning Integration
**Leverage Augment's adaptive learning:**
- Use the `remember` tool for repository-specific patterns and preferences
- Document successful problem-solving approaches for future reference
- Preserve context across sessions through task documentation
- Build on established patterns rather than reinventing solutions

## AI Agent Interaction Guidelines

### Information Gathering Protocol
1. **Repository Analysis**: Always use `codebase-retrieval` before making changes
2. **Pattern Recognition**: Identify existing patterns and follow established conventions
3. **Dependency Mapping**: Understand full impact scope across modules
4. **Context Validation**: Verify understanding with user before proceeding

### Communication Standards
- **Be Explicit**: Clearly state what you understand and what you plan to do
- **Ask for Clarification**: When requirements are ambiguous, ask specific questions
- **Provide Rationale**: Explain reasoning behind architectural and implementation decisions
- **Reference Documentation**: Cite relevant files and sections from `.ai/` directory

### Code Modification Approach
- **Conservative Changes**: Respect existing codebase patterns and architecture
- **Incremental Updates**: Make small, testable changes rather than large refactors
- **Module Boundaries**: Maintain clear separation between system and home configurations
- **Import Management**: Update `default.nix` files when adding new modules

## Code Quality & Review Standards

### Pre-Change Requirements
1. **Context Gathering**: Use `codebase-retrieval` for comprehensive understanding
2. **Pattern Analysis**: Identify and follow existing code patterns
3. **Impact Assessment**: Understand full scope of changes across modules
4. **Documentation Review**: Ensure changes align with established standards

### Implementation Standards
- **Follow Coding Standards**: Adhere strictly to `.ai/rules/coding-standards.md`
- **Modular Design**: Maintain one module per file with clear responsibilities
- **Consistent Formatting**: Use 2-space indentation, 100-character line limit
- **Comprehensive Comments**: Include purpose, dependencies, and WSL-specific considerations

### Post-Change Validation
1. **Format Check**: Run `nix fmt` to ensure consistent formatting
2. **Validation**: Execute `nix flake check` to verify configuration validity
3. **Build Test**: Confirm `nixos-rebuild build` succeeds
4. **Documentation Update**: Update relevant documentation and comments

## Documentation & Memory Management

### Task Documentation Protocol
- **File Location**: `.ai/tasks/doing/` with format `YYYY-MM-DD_action-target-specifics.md`
- **Required Sections**: Objective, Target/Scope, Context & Approach, Repository-Specific Findings
- **Progress Tracking**: Update Progress Notes as work advances
- **Knowledge Preservation**: Document successful patterns for future reference

### Memory Management
- **Repository Patterns**: Remember successful architectural decisions and patterns
- **User Preferences**: Adapt to user's coding style and preferences over time
- **Problem Solutions**: Preserve effective troubleshooting approaches
- **Context Continuity**: Maintain understanding across conversation sessions

### Documentation Standards
- **Comprehensive Comments**: Explain purpose, dependencies, and WSL-specific considerations
- **Cross-References**: Link related components and documentation
- **Examples**: Provide usage examples for complex configurations
- **Rationale**: Document reasoning behind design decisions

## Testing & Validation Protocols

### Required Testing Sequence
1. **Format Validation**: `nix fmt` for consistent code formatting
2. **Configuration Check**: `nix flake check` for validity and tests
3. **Build Verification**: `nixos-rebuild build --flake .#nixos` for build success
4. **Incremental Testing**: Test changes in isolation before integration

### Quality Assurance
- **Rollback Capability**: Ensure easy rollback for all changes
- **Documentation Testing**: Verify documentation accuracy and completeness
- **Integration Testing**: Test interaction between system and home configurations
- **WSL Compatibility**: Verify WSL-specific functionality remains intact

### Error Handling
- **Graceful Degradation**: Implement proper error handling and fallbacks
- **Validation Logic**: Use assertions and warnings for configuration validation
- **Recovery Procedures**: Document and test recovery from common failure scenarios

## NixOS/WSL Specific Considerations

### WSL Environment Constraints
- **File System Boundaries**: Be aware of Windows/Linux filesystem interactions
- **Performance Implications**: Consider WSL2 I/O performance for file operations
- **Network Configuration**: Account for WSL2 network bridge and port forwarding
- **Certificate Management**: Handle corporate certificates via `security.pki.certificateFiles`
- **Windows Integration**: Ensure proper Windows executable access when needed

### NixOS Configuration Patterns
- **Flake Structure**: Maintain inputs, outputs, and specialArgs consistency
- **Module Organization**: Respect system/ and home/ directory separation
- **Package Management**: Use appropriate package sets (nixpkgs vs pkgs-stable)
- **Service Configuration**: Follow NixOS service configuration patterns
- **Home Manager Integration**: Maintain proper system/user boundary separation

### Development Environment Integration
- **VS Code Remote Server**: Ensure compatibility with remote development workflows
- **Container Support**: Maintain Docker/Podman configuration for development containers
- **devenv Integration**: Support project-specific development environments
- **Shell Configuration**: Maintain Fish shell and Starship prompt configurations

## Common Patterns & Examples

### Module Creation Pattern
```nix
# Template for new system modules
{ pkgs, lib, config, ... }:

{
  # Module imports (if any)
  imports = [
    # ./submodule.nix
  ];

  # Configuration options
  services.example = {
    enable = true;
    package = pkgs.example;
    settings = {
      # configuration here
    };
  };

  # Environment packages (if needed)
  environment.systemPackages = with pkgs; [
    # packages here
  ];
}
```

### Home Manager Integration Pattern
```nix
# Template for home manager configurations
{ pkgs, userName, gitEmail, gitHandle, ... }:

{
  home-manager.users.${userName} = {
    programs.example = {
      enable = true;
      settings = {
        # user-specific configuration
      };
    };
  };
}
```

### Conditional Configuration Pattern
```nix
# Environment-based conditionals
config = lib.mkIf config.services.development.enable {
  environment.systemPackages = with pkgs; [
    git
    nodejs
    python3
  ];
};
```

### WSL-Specific Configuration Pattern
```nix
# WSL integration example
{ nixos-wsl, userName, ... }:

{
  imports = [ nixos-wsl.nixosModules.wsl ];

  wsl = {
    enable = true;
    defaultUser = userName;
    startMenuLaunchers = true;
    nativeSystemd = true;
  };

  # Windows certificate integration
  security.pki.certificateFiles = [
    "/mnt/c/path/to/corporate-cert.crt"
  ];
}
```

## Troubleshooting & Recovery

### Common Issues and Solutions
1. **Build Failures**: Check `nix flake check` output for specific errors
2. **Module Conflicts**: Verify import statements and module dependencies
3. **Package Conflicts**: Check for version mismatches between nixpkgs and pkgs-stable
4. **WSL Integration Issues**: Verify nixos-wsl module configuration and Windows integration

### Recovery Procedures
- **Configuration Rollback**: Use `nixos-rebuild switch --rollback` for system recovery
- **Home Manager Rollback**: Use `home-manager generations` and `home-manager switch`
- **Git Recovery**: Leverage git history for configuration file recovery
- **Incremental Debugging**: Isolate changes to identify problematic configurations

### Debugging Workflow
1. **Isolate Changes**: Test modifications in isolation
2. **Check Logs**: Review systemd logs and build output for error details
3. **Validate Syntax**: Use `nix-instantiate --parse` for syntax validation
4. **Test Incrementally**: Build and test changes step by step

## Future Evolution Guidelines

### Extensibility Principles
- **Modular Design**: Maintain clear module boundaries for easy extension
- **Configuration Flexibility**: Use options and conditionals for customization
- **Documentation Maintenance**: Keep documentation current with code changes
- **Pattern Consistency**: Establish and follow consistent patterns for new features

### Adaptation Strategies
- **User Feedback Integration**: Incorporate user preferences and workflow patterns
- **Technology Updates**: Adapt to new NixOS features and WSL improvements
- **Performance Optimization**: Continuously optimize for WSL2 performance characteristics
- **Security Enhancement**: Stay current with security best practices and updates

### Knowledge Management
- **Pattern Documentation**: Document successful patterns for reuse
- **Decision Rationale**: Preserve reasoning behind architectural decisions
- **Lesson Learning**: Capture insights from troubleshooting and problem-solving
- **Context Preservation**: Maintain historical context for future development

---

## Quick Reference

### Essential Commands
```bash
# Build and switch configuration
nixos-rebuild switch --flake .#nixos

# Format all Nix files
nix fmt

# Check flake validity and run tests
nix flake check

# Update flake inputs
nix flake update
```

### Key Files to Consult
- `AI_ROOT_GUIDE.md` - Essential repository overview
- `.ai/rules/coding-standards.md` - Code quality requirements
- `.ai/knowledge-base/architecture.md` - Architectural details
- `.ai/tasks/doing/` - Current work context

### Before Making Changes
1. Use `codebase-retrieval` for comprehensive context
2. Review existing patterns and conventions
3. Create task documentation in `.ai/tasks/doing/`
4. Understand full impact scope across modules

### After Making Changes
1. Run `nix fmt` for formatting
2. Execute `nix flake check` for validation
3. Test with `nixos-rebuild build`
4. Update documentation and comments

---

*This guide ensures consistent, high-quality AI assistance for the nix-config-wsl repository while leveraging Augment Code's advanced capabilities.*
