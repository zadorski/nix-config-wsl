{ inputs, config, lib, pkgs, ... }:

{
  imports = [
    ./base.nix # FIXME: common.nix
    inputs.nixos-wsl.nixosModules.wsl
  ];

  wsl = {
    enable = true;
    defaultUser = config.user;
  };
  
  networking.hostName = "crodax"; # FIXME: ${config.wsl.hostName};

  environment = {
    systemPackages = with pkgs; [
      wsl-open
      xdg-utils
    ];
    variables = {
      BROWSER = "wsl-open";
    };
  };
}
