# AGENT INSTRUCTIONS

This file provides guidelines for automated agents contributing to this repository.

## Scope

These instructions apply to the entire repository.

## High-Level Goals for AI Assistance
- Assist with code generation for new features and bug fixes.
- Help in writing and maintaining documentation.
- Identify potential improvements in code quality and performance.
- Automate repetitive tasks where possible.

## Key Resources in the `.ai` Directory
All detailed instructions, knowledge bases, and task lists are located within the `.ai/` directory. Please refer to its `README.md` and `manifest.yaml` for a full map.
- **Goals:** See `.ai/goals/` for current objectives
- **Instructions:** Adhere to guidelines in `.ai/rules/` (e.g., `coding_standards.md`)
- **Knowledge Base:** Consult `.ai/knowledge_base/` for project-specific context
- **Tasks:** Current work items are in `.ai/tasks/`

## General Interaction Principles
- Prioritize clarity and maintainability in all generated code.
- Ask for clarification if instructions are ambiguous.
- When modifying existing code, try to follow the established patterns and style.
- Reference specific files from the `.ai` directory when relevant to your current task.

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

## Pull request messages

Describe the reasoning behind the change and include references to relevant files or command output. Follow the repository's standard commit and PR practices.