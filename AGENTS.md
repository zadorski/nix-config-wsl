# AGENT INSTRUCTIONS

This file provides guidelines for automated agents contributing to this repository.

## Scope

These instructions apply to the entire repository.

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
