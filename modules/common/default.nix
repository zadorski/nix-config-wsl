{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./cli
    ./dev
    ./gui
    ./nix
  ];

  options = {
    user = lib.mkOption {
      type = lib.types.str;
      description = "Primary user of the system";
    };

    theme = {
      colors = lib.mkOption {
        type = lib.types.attrs;
        description = "Base16 color scheme";
      };
      dark = lib.mkOption {
        type = lib.types.bool;
        description = "Enable dark mode";
      };
    };

    gui = {
      enable = lib.mkEnableOption {
        description = "Enable graphics";
        default = false;
      };
    };

    homePath = lib.mkOption {
      type = lib.types.path;
      description = "Path of user's home directory";
    };

    dotfilesPath = lib.mkOption {
      type = lib.types.path;
      description = "Path of dotfiles repository";
      default = config.homePath + "/.config/system";
    };

    unfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of unfree packages to allow";
      default = [ ];
    };
  };

  config =
    let
      stateVersion = "24.05";
    in
    {
      # basic common system packages for all devices
      environment.systemPackages = with pkgs; [
        git
        vim
        wget
        curl
      ];

      # use the system-level nixpkgs instead of Home Manager's
      home-manager.useGlobalPkgs = true;

      # install packages to /etc/profiles instead of ~/.nix-profile, useful when
      # using multiple profiles for one user
      home-manager.useUserPackages = true;

      # allow specified unfree packages (identified elsewhere)
      # Retrieves package object based on string name
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfreePackages;

      # pin a state version to prevent warnings
      home-manager.users.${config.user}.home.stateVersion = stateVersion;
      home-manager.users.root.home.stateVersion = stateVersion;
    };
}
