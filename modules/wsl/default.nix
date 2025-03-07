{ config, pkgs, lib, ... }:

{
  # already defined in common
  #options = {
  #  nixConfigPath = lib.mkOption {
  #    description = "Path to NixOS configuration"; # see host file merging globals with per-host value
  #  };
  #};

  config = lib.mkIf (pkgs.stdenv.isLinux && config.wsl.enable) {

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