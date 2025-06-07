# Markdown Files Inventory

This document provides a comprehensive inventory of all markdown (.md) files in the repository, categorized by their purpose and relevance for AI agents and development workflows.

## Summary

Total markdown files found: **11**
- High relevance for AI agents: **6**
- Medium relevance for AI agents: **3** 
- Low relevance for AI agents: **2**

## Detailed Inventory

| File Path | File Name | Primary Purpose/Category | Brief Description | Relevance Score |
|-----------|-----------|-------------------------|-------------------|-----------------|
| `.ai/README.md` | README.md | AI Agent Documentation | Comprehensive overview of the `.ai` directory structure, explaining how AI agents should interact with the repository's AI-specific resources and configuration files. | High |
| `AGENTS.md` | AGENTS.md | AI Agent Rules | Primary instruction file for automated agents, containing high-level goals, interaction principles, development environment setup, and testing requirements for code changes. | High |
| `.ai/tasks/doing/2025-06-06 add-repo-issue-agents-plan.md` | 2025-06-06 add-repo-issue-agents-plan.md | Task Management | Active task tracking the addition of AGENTS instructions and devcontainer configuration, including specific deliverables and scope definition. | High |
| `.ai/tasks/backlog/2025-06-06 revise-wsl-flake-minimal.md` | 2025-06-06 revise-wsl-flake-minimal.md | Task Management | Detailed improvement plan for streamlining the WSL configuration, including goals for minimal development setup and specific implementation tasks. | High |
| `README.md` | README.md | Project Documentation | Main project documentation explaining the NixOS-WSL flake configuration, inspiration sources, learning path, and follow-up recommendations for development setup. | High |
| `docs/docker.md` | docker.md | Technical Documentation | Comprehensive guide for Docker integration with NixOS and WSL2, including rootless Docker solutions, development environment setup, and various implementation approaches. | High |
| `docs/podman.md` | podman.md | Technical Documentation | Documentation for Podman container runtime integration, focusing on rootless containers, systemd units, and VSCode dev container compatibility with WSL. | Medium |
| `docs/vps.md` | vps.md | Technical Documentation | Brief documentation about installing NixOS over existing OS in cloud environments, specifically referencing nixos-infect for DigitalOcean droplets. | Medium |
| `docs/vpn.md` | vpn.md | Technical Documentation | Configuration examples for creating Docker networks in NixOS, including activation scripts and systemd oneshot approaches for VPN network setup. | Medium |
| `docs/2025-03-23 output with zscaler off.md` | 2025-03-23 output with zscaler off.md | Debug/Log Documentation | VS Code WSL extension log output showing server installation and connection process, useful for troubleshooting WSL development environment issues. | Low |
| `templates/nixos-config-per-host/home/nvim/snippets/markdown.json` | markdown.json | Configuration File | JSON configuration for markdown snippets in Neovim, containing HTML tags, GitHub alerts, and various markdown formatting shortcuts for development productivity. | Low |

## Categories Breakdown

### AI Agent Documentation (2 files)
- `.ai/README.md` - Central guide for AI agent interaction
- `AGENTS.md` - Primary instruction file for automated contributors

### Task Management (2 files)  
- `.ai/tasks/doing/2025-06-06 add-repo-issue-agents-plan.md` - Active development tasks
- `.ai/tasks/backlog/2025-06-06 revise-wsl-flake-minimal.md` - Planned improvements

### Project Documentation (1 file)
- `README.md` - Main project overview and setup guide

### Technical Documentation (4 files)
- `docs/docker.md` - Docker integration and setup
- `docs/podman.md` - Podman container runtime
- `docs/vps.md` - Cloud deployment guidance  
- `docs/vpn.md` - Network configuration examples

### Debug/Configuration Files (2 files)
- `docs/2025-03-23 output with zscaler off.md` - Debug logs
- `templates/nixos-config-per-host/home/nvim/snippets/markdown.json` - Editor configuration

## Recommendations for AI Agents

### High Priority Files
AI agents should prioritize reading and understanding these files:
1. `AGENTS.md` - Contains primary instructions and development workflow requirements
2. `.ai/README.md` - Explains the AI directory structure and interaction patterns
3. Active task files in `.ai/tasks/doing/` - Current work items and objectives

### Context Files
These files provide important context for development work:
1. `README.md` - Project background and setup information
2. `docs/docker.md` - Container integration approaches
3. Backlog task files - Future improvement plans

### Reference Files
Lower priority files that may be useful for specific scenarios:
1. Technical documentation in `docs/` - For specific integration questions
2. Debug logs - For troubleshooting similar issues
3. Configuration files - For understanding editor setup

## Usage Notes

- Files marked as "High" relevance should be consulted for most AI agent interactions
- Task management files should be updated as work progresses
- Technical documentation files contain valuable context for container and development environment setup
- Debug and configuration files are primarily for reference and troubleshooting

---

*Generated on: 2025-01-27*  
*Last updated: 2025-01-27*
