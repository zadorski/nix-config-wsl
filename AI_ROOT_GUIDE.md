# AI Agent Root Guide

## Repository Overview

This repository provides a **modular NixOS-WSL flake configuration** for Windows Subsystem for Linux development environments. It implements a clean, maintainable approach to NixOS configuration using flakes and home-manager.

### Purpose
- **Primary**: Declarative WSL development environment using NixOS
- **Architecture**: Modular flake-based configuration with system/home separation
- **Target**: Windows developers using WSL2 with NixOS

### Key Features
- Flake-based NixOS configuration with reproducible builds
- Modular system configuration in `./system/` directory
- Home-manager integration for user-space configuration
- VS Code Remote Server support for seamless development
- Container support (Docker/Podman) for development workflows
- Certificate management for corporate environments (ZScaler)

## Quick Start for AI Agents

### 1. Repository Structure
```
├── flake.nix              # Main flake configuration
├── system/                # NixOS system modules
│   ├── default.nix        # System module imports
│   ├── wsl.nix           # WSL-specific configuration
│   ├── users.nix         # User management
│   └── *.nix             # Other system modules
├── home/                  # Home-manager configuration
│   ├── default.nix       # Home module imports
│   └── */                # User application configs
├── .ai/                  # AI agent resources (see below)
└── docs/                 # Technical documentation
```

### 2. AI Resources Navigation
- **Start here**: This file (AI_ROOT_GUIDE.md)
- **AI Directory**: `.ai/` - All AI-specific resources
- **Coding Standards**: `.ai/rules/coding_standards.md`
- **Architecture Details**: `.ai/knowledge_base/architecture.md`
- **Current Tasks**: `.ai/tasks/doing/`
- **Agent Instructions**: `AGENTS.md`

### 3. Development Workflow
1. **Build System**: `nixos-rebuild switch --flake .#nixos`
2. **Format Code**: `nix fmt`
3. **Run Tests**: `nix flake check`
4. **Development**: Use VS Code Remote Server in WSL

## NixOS-WSL Architecture

### Flake Structure
- **Inputs**: nixpkgs, nixos-wsl, home-manager, vscode-server, themes
- **Outputs**: Single nixosConfiguration named "nixos"
- **Special Args**: userName, gitEmail, gitHandle, pkgs-stable

### Module Organization
- **System Level**: Hardware, services, system packages
- **User Level**: Applications, dotfiles, user packages
- **Separation**: Clear boundary between system and home-manager

### Key Dependencies
- `nixos-wsl`: WSL2 integration and compatibility
- `home-manager`: User environment management
- `vscode-server`: VS Code Remote Server support

## Essential Commands

### For AI Agents
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

### Development Environment
```bash
# Enter development shell
nix develop

# Build specific output
nix build .#nixosConfigurations.nixos.config.system.build.toplevel
```

## AI Agent Guidelines

### Code Quality Requirements
1. **Follow** `.ai/rules/coding_standards.md` for all Nix code
2. **Test** changes with `nix fmt` and `nix flake check`
3. **Document** significant changes in commit messages
4. **Maintain** modular structure - avoid monolithic configurations

### Security Considerations
1. **Certificates**: Use `security.pki.certificateFiles` for corporate certs
2. **Secrets**: Never commit secrets - use SOPS or external management
3. **Permissions**: Follow principle of least privilege
4. **WSL**: Be aware of Windows/Linux boundary security implications

### Common Tasks
- **Add Package**: Modify `system/default.nix` or `home/default.nix`
- **New Module**: Create in appropriate `system/` or `home/` subdirectory
- **Configuration**: Update relevant module, maintain imports in `default.nix`
- **Dependencies**: Add to `flake.nix` inputs, update flake.lock

## Next Steps

1. **Read**: `AGENTS.md` for detailed agent instructions
2. **Study**: `.ai/knowledge_base/architecture.md` for deep architecture understanding
3. **Follow**: `.ai/rules/coding_standards.md` for code quality
4. **Check**: `.ai/tasks/doing/` for current work items

## Support Resources

- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **Home Manager**: https://nix-community.github.io/home-manager/
- **NixOS-WSL**: https://github.com/nix-community/NixOS-WSL
- **Nix Language**: https://nixos.org/manual/nix/stable/language/

---
*This guide provides the essential context for AI agents working with this NixOS-WSL configuration repository.*
