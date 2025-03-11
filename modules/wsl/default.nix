{ config, pkgs, lib, ... }:

#let
#  cfg = config.modules.wsl;
#in
{
  #imports = [
  #  inputs.nixos-wsl.nixosModules.wsl
  #];

  options.modules.wsl = {
    enable = lib.mkEnableOption "Enable WSL support";

    defaultUser = lib.mkOption {
      description = "WSL default user";
      type = lib.types.str;
      default = "nixos";
    };
  };

  # already defined in common
  #options = {
  #  nixConfigPath = lib.mkOption {
  #    description = "Path to NixOS configuration"; # see host file merging globals with per-host value
  #  };
  #};

  config = lib.mkIf config.wsl.enable { #lib.mkIf cfg.enable {
    #wsl = {
    #  enable = true;
    #  defaultUser = cfg.defaultUser; # globals.user
    #  startMenuLaunchers = true;
    #  usbip.enable = true;
    #  #docker-desktop.enable = true; # integration with docker desktop (needs to be installed)
    #  wslConf.automount.root = "/mnt";
    #  wslConf.network.generateHosts = false;
    #  wslConf.network.generateResolveConf = true; # disable because it breaks tailscale ref:: https://github.com/kgadberry/dotfiles/blob/main/hosts/cerberus/default.nix
    #  interop.includePath = false; # including windows PATH will slow down other systems, filesystem cross talk ref:: https://github.com/nmasur/dotfiles/blob/master/hosts/hydra/default.nix                        
    #};

    # systemd doesn't work in wsl so these must be disabled
    #services.geoclue2.enable = lib.mkForce false;
    #location = {
    #  provider = lib.mkForce "manual";
    #};
    #services.localtimed.enable = lib.mkForce false;

    # used by neovim for clipboard sharing with windows
    # home-manager.users.${config.user}.home.sessionPath =
    #   [ "/mnt/c/Program Files/win32yank/" ];

    #system.copySystemConfiguration = false; # ref:: https://github.com/SlavaKuntsov/nixos/blob/main/system/hosts/jano/default.nix

    # replace config directory with our repo, since it sources from config on every launch ref:: 
    system.activationScripts.configDir.text = ''
      rm -rf /etc/nixos
      ln --symbolic --no-dereference --force ${config.dotsPath} /etc/nixos
    '';
  };
}