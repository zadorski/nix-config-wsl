{
  config,
  pkgs,
  lib,
  ...
}:
{
  home-manager.users.${config.user} = {
    # create nix-index if doesn't exist
    home.activation.createNixIndex =
      let
        cacheDir = "${config.homePath}/.cache/nix-index";
      in
      lib.mkIf config.home-manager.users.${config.user}.programs.nix-index.enable (
        config.home-manager.users.${config.user}.lib.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d ${cacheDir} ]; then
            $DRY_RUN_CMD ${pkgs.nix-index}/bin/nix-index -f ${pkgs.path}
          fi
        ''
      );

    # set automatic generation cleanup for home-manager
    nix.gc = {
      automatic = config.nix.gc.automatic;
      options = config.nix.gc.options;
    };
  };

  nix = {
    # set channel to flake packages, used for nix-shell commands
    nixPath = [ "nixpkgs=${pkgs.path}" ];

    # set registry to this flake's packages, used for nix X commands
    registry.nixpkgs.to = {
      type = "path";
      path = builtins.toString pkgs.path;
    };

    # for security, only allow specific users
    settings.allowed-users = [
      "@wheel"
      config.user
    ];

    # enable features in Nix commands
    extraOptions = ''
      experimental-features = nix-command flakes
      warn-dirty = false
    '';

    gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };

    settings = {
      # add community Cachix to binary cache
      # don't use with macOS because blocked by corporate firewall
      builders-use-substitutes = true;
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };
}
