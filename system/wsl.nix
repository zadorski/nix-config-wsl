{ nixos-wsl, ... }:

{
  # import the NixOS-WSL module for Windows Subsystem for Linux integration
  imports = [ nixos-wsl.nixosModules.wsl ];

  # this handles WSL integration, Windows path mounting, and other WSL features
  wsl.enable = true;
}