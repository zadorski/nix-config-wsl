{ inputs, config, lib, ... }:

{
  imports = [
    ../base # FIXME: common
    inputs.home-manager.nixosModules.home-manager
  ];

  nix.gc.dates = "weekly";
  nix.settings.auto-optimise-store = true;

  users.users.${config.user} = {
    isNormalUser = true;
    extraGroups = [
      "docker"
      "wheel"
    ];
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = false;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  time.timeZone = "Europe/Berlin";

  system.stateVersion = lib.mkDefault "24.05";
}
