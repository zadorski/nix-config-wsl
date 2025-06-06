# WSL Configuration Cleanup Plan

This file tracks improvements for streamlining the repository into a minimal, easy to understand NixOS‑WSL setup. Follow these tasks to keep the configuration approachable for newcomers while enabling a solid VS Code remote environment with corporate certificates.

## Tasks

- [ ] **Restructure `flake.nix` to follow nix.dev conventions**
  - Move `inputs` above `outputs`.
  - Use `inputs@{ self, nixpkgs, ... }` in the `outputs` function.
  - Drop `with` statements and reference attributes explicitly.
  - Pass only required values via `specialArgs`.

- [ ] **Split optional system modules from the base configuration**
  - Keep only core modules (`wsl.nix`, `vscode-server.nix`, `nix.nix`, `users.nix`, `ssh.nix`, `certificates.nix`) in `system/default.nix`.
  - Create `system/optional/*` modules for extras like fonts, Python, Docker, etc.
  - Trim base `environment.systemPackages` to essentials (e.g. `wget`, `curl`, `git`).
  - Allow optional modules to be enabled via a list in the flake or an overlay variable.

- [ ] **Parameterise the certificate import path**
  - Add an option `windowsCertsDir` in `system/certificates.nix`.
  - Use this option to build the path instead of the hard-coded directory.
  - Pass `windowsCertsDir` via `specialArgs` so each developer can override it.
  - Document how to run `get-all-certs.ps1` to populate the directory.

- [ ] **Create a minimal `home` profile with optional extras**
  - Move essentials (`git`, `ssh`, `fzf`, `zoxide`, `starship`) into `home/minimal.nix`.
  - Place programs like `zellij`, `btop`, `bat`, custom scripts, and `ffmpeg` under `home/optional/*`.
  - Import the minimal profile by default and allow extras via `specialArgs`.

- [ ] **Pin Nix version in `system/nix.nix`**
  - Set `nix.package = pkgs.nixVersions.nix_2_20` (or whichever version is desired).
  - Note in comments that this ensures consistent features such as flakes.

- [ ] **Guard the VS Code server with a WSL check**
  - Wrap the module in `lib.mkIf config.wsl.enable` so it activates only inside WSL.
  - Avoid running the server on non‑WSL machines.

## Guiding Principles

- Aim for a minimal, declarative configuration suitable for company onboarding.
- Prefer explicit references and avoid `with` to keep code easy to follow.
- Keep optional tools separate so the base setup stays lean.
- Document how to add corporate certificates and extras clearly.
