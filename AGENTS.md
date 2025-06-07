# AGENT INSTRUCTIONS

This file provides guidelines for automated agents contributing to this repository.

**Quick Start**: New AI agents should first read `AI_ROOT_GUIDE.md` in the repository root for essential context and navigation guidance.

## Scope

These instructions apply to the entire repository and complement the information in `AI_ROOT_GUIDE.md`.

## High-Level Goals for AI Assistance
- Assist with NixOS configuration and Nix code generation for new features and bug fixes
- Help in writing and maintaining documentation for NixOS-WSL environments
- Identify potential improvements in code quality, performance, and NixOS best practices
- Automate repetitive tasks while maintaining declarative configuration principles
- Ensure WSL-specific considerations are properly addressed in all changes

## Key Resources in the `.ai` Directory
All detailed instructions, knowledge bases, and task lists are located within the `.ai/` directory. Please refer to its `README.md` and `manifest.yaml` for a full map.
- **Goals:** See `.ai/goals/` for current objectives
- **Instructions:** Adhere to guidelines in `.ai/rules/` (e.g., `coding_standards.md`)
- **Knowledge Base:** Consult `.ai/knowledge_base/` for project-specific context
- **Tasks:** Current work items are in `.ai/tasks/`

## General Interaction Principles
- Prioritize clarity and maintainability in all generated Nix code
- Ask for clarification if instructions are ambiguous
- When modifying existing code, follow established NixOS module patterns and style
- Reference specific files from the `.ai` directory when relevant to your current task
- Maintain the modular architecture with clear system/home-manager separation
- Ensure all changes are compatible with WSL2 environment constraints

## Development environment

A VS Code devcontainer is provided under `.devcontainer`. Use this container to reproduce builds locally.

## Testing and linting

- **Required for code changes**: When modifying any files that are not purely documentation or comment updates, run the following commands before committing:
  1. `nix fmt` – format the Nix code.
  2. `nix flake check` – evaluate the flake and run any defined tests.
- Document the outcome of these commands in the pull request description using terminal output citations.
- If the commands fail because Nix is unavailable, note the failure in the PR testing section.

## Documentation-only changes

If a change only touches Markdown files or code comments, running `nix fmt` and `nix flake check` is not required.

## NixOS-Specific Guidelines

### Nix Language and Module Standards
- **Follow** `.ai/rules/coding_standards.md` for all Nix code formatting and style
- **Use** proper Nix language constructs (attribute sets, functions, imports)
- **Maintain** modular structure - avoid monolithic configurations
- **Validate** all Nix expressions with `nix flake check` before submission

### WSL Environment Considerations
- **Windows Integration**: Be aware of Windows/Linux filesystem boundaries
- **Performance**: Consider WSL2 I/O performance implications for file operations
- **Certificates**: Handle corporate certificates using `security.pki.certificateFiles`
- **Networking**: Account for WSL2 network bridge configuration
- **Interoperability**: Ensure Windows executable access when needed

### Module Organization
- **System Configuration**: Place system-level configs in `./system/` directory
- **User Configuration**: Place user-level configs in `./home/` directory
- **Imports**: Update `default.nix` files when adding new modules
- **Dependencies**: Add new flake inputs to `flake.nix` when required

### Security Protocols
- **No Secrets**: Never commit secrets, passwords, or private keys to the repository
- **Certificate Management**: Use proper paths for corporate certificate integration
- **Permissions**: Follow principle of least privilege for user and service permissions
- **WSL Security**: Be aware of Windows/Linux security boundary implications

### Configuration Testing
- **Incremental Testing**: Test configuration changes incrementally
- **Build Verification**: Ensure `nixos-rebuild build` succeeds before switching
- **Rollback Capability**: Verify rollback procedures work for critical changes
- **Documentation**: Document any special testing procedures or requirements

## Pull request messages

Describe the reasoning behind the change and include references to relevant files or command output. Follow the repository's standard commit and PR practices.

### Required Information
- **Purpose**: Clear description of what the change accomplishes
- **Testing**: Results of `nix fmt` and `nix flake check` commands
- **WSL Impact**: Any WSL-specific considerations or testing performed
- **Rollback**: Confirmation that rollback procedures remain functional