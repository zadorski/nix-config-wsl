# WSL Improvement Plan

This plan outlines tasks to streamline the `nix-config-wsl` repository for a minimal development setup on Windows 11 using WSL.

## Goals

1. reduce modules and packages to only what is needed for development
2. rely on declarative configuration with flakes and home manager
3. support VS Code Remote Server for editing
4. integrate company root certificates such as ZScaler
5. provide Docker or Podman for container workflows
6. document the minimal configuration for onboarding

## Tasks

1. [x] **create improvement plan** for minimal wsl flake (2025-06-07)
2. [x] **simplify flake inputs** (2025-06-07)
   - keep `nixpkgs`, `nixos-wsl`, `home-manager`, and `vscode-server`
   - drop optional themes and scripts unless required
3. [x] **trim system modules** (2025-06-07)
   - keep `wsl.nix`, `vscode-server.nix`, `nix.nix`, `users.nix`, and `shells.nix`
   - move optional services (fonts, python, docker) to separate examples
4. [x] **define base packages** (2025-06-07)
   - include tools such as `git`, `curl`, `wget`, and a basic editor
   - add `nix` package manager with `experimental-features` enabled
5. [x] **enable containers** (2025-06-07)
   - choose between Docker and Podman; configure rootless mode when possible
6. [x] **configure certificates** (2025-06-07)
   - use `security.pki.certificateFiles` to import ZScaler root certificate from the Windows filesystem
7. [x] **set up home manager defaults** (2025-06-07)
   - provide minimal shell configuration with `bash` or `nushell`
   - enable `git` and `ssh` settings for the user
8. [x] **document onboarding** (2025-06-07)
   - create a short guide describing how to build the system and log in through VS Code
   - explain where to place certificates and any company-specific secrets
9. [x] **restore ssh module** (2025-06-08)
10. [x] **refer to certificate from repo** (2025-06-08)
11. [x] **start fish for interactive shell** while keeping bash default (2025-06-08)

Following these steps will yield a clean NixOS-WSL base that new developers can extend without dealing with extra complexity.