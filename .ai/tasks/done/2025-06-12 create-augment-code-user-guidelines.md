# Task: Create Comprehensive Augment Code User Guidelines

## Objective
Create a definitive reference document that combines repository-specific patterns, Augment Code best practices, and NixOS/WSL development guidelines to improve AI assistance quality and consistency for this workspace.

## Target/Scope
- Create `.ai/knowledge-base/augment-code-user-guidelines.md`
- Analyze entire nix-config-wsl repository for patterns and conventions
- Research and integrate Augment Code methodology best practices
- Synthesize comprehensive guidelines for AI agent interactions

## Context & Approach
1. **Repository Analysis**: Conduct thorough scan of existing patterns, conventions, and architectural decisions
2. **Best Practices Integration**: Research Augment Code methodology and incorporate proven practices
3. **Guidelines Synthesis**: Combine findings into actionable, categorized guidelines with examples

## Repository-Specific Findings
- **Established AI Infrastructure**: Well-structured `.ai/` directory with manifest, rules, knowledge base, and task management
- **Modular NixOS Architecture**: Clear system/home separation with flake-based configuration
- **WSL-Specific Focus**: Optimized for Windows Subsystem for Linux development environments
- **Existing Documentation Standards**: Comprehensive coding standards, architecture documentation, and task protocols
- **Development Workflow**: VS Code Remote Server, devcontainers, and standardized testing procedures

## Technical Specifications
- **Configuration Management**: Flake-based NixOS with home-manager integration
- **Module Organization**: System-level (`./system/`) and user-level (`./home/`) separation
- **Quality Assurance**: Required `nix fmt` and `nix flake check` for all changes
- **Documentation Protocol**: Task documentation in `.ai/tasks/doing/` with structured templates
- **Memory System**: Established memory protocol for preserving context across sessions

## Progress Notes
- [x] Analyzed existing `.ai/` directory structure and documentation
- [x] Reviewed repository architecture and coding standards
- [x] Researched Augment Code methodology and best practices
- [x] Created comprehensive user guidelines document (`.ai/knowledge-base/augment-code-user-guidelines.md`)
- [x] Updated `.ai/manifest.yaml` to reference new guidelines
- [x] Updated `.ai/README.md` to include guidelines reference
- [x] Validated guidelines against repository patterns and existing documentation
- [x] Ensured reusability for similar NixOS/development projects

## Key Deliverables Completed
1. **Comprehensive Guidelines Document**: Created `.ai/knowledge-base/augment-code-user-guidelines.md` with 10 major sections covering all aspects of AI agent interaction
2. **Repository Integration**: Updated manifest and README to properly reference the new guidelines
3. **Pattern Documentation**: Documented existing repository patterns and best practices
4. **Augment Code Integration**: Incorporated Augment Code methodology including context-first approach, documentation-driven development, and adaptive learning
5. **NixOS/WSL Specifics**: Included detailed considerations for WSL environment constraints and NixOS configuration patterns

## Guidelines Structure Summary
- Repository Context & Architecture
- Augment Code Integration Principles
- AI Agent Interaction Guidelines
- Code Quality & Review Standards
- Documentation & Memory Management
- Testing & Validation Protocols
- NixOS/WSL Specific Considerations
- Common Patterns & Examples
- Troubleshooting & Recovery
- Future Evolution Guidelines
- Quick Reference Section
