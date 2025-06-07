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

1. [ ] **simplify flake inputs**
   - keep `nixpkgs`, `nixos-wsl`, `home-manager`, and `vscode-server`
   - drop optional themes and scripts unless required
2. [ ] **trim system modules**
   - keep `wsl.nix`, `vscode-server.nix`, `nix.nix`, `users.nix`, and `shells.nix`
   - move optional services (fonts, python, docker) to separate examples
3. [ ] **define base packages**
   - include tools such as `git`, `curl`, `wget`, and a basic editor
   - add `nix` package manager with `experimental-features` enabled
4. [ ] **enable containers**
   - choose between Docker and Podman; configure rootless mode when possible
5. [ ] **configure certificates**
   - use `security.pki.certificateFiles` to import ZScaler root certificate from the Windows filesystem
6. [ ] **home manager defaults**
   - provide minimal shell configuration with `bash` or `nushell`
   - enable `git` and `ssh` settings for the user
7. [ ] **document onboarding**
   - create a short guide describing how to build the system and log in through VS Code
   - explain where to place certificates and any company-specific secrets

Following these steps will yield a clean NixOS-WSL base that new developers can extend without dealing with extra complexity.
