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

    fullName = lib.mkOption {
      type = lib.types.str;
      description = "Human readable name of the user";
    };

    host = lib.mkOption {
      type = lib.types.str;
      description = "Networking hostname";
    };

    identityFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to existing private key file";
      default = "/etc/ssh/ssh_host_ed25519_key";
    };

    gui = {
      enable = lib.mkEnableOption {
        description = "Enable graphics";
        default = false;
      };
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

    homePath = lib.mkOption {
      type = lib.types.path;
      description = "Path of user's home directory";
      default = builtins.toPath (
        if pkgs.stdenv.isDarwin then "/Users/${config.user}" else "/home/${config.user}"
      );
    };

    dotsPath = lib.mkOption {
      type = lib.types.path;
      description = "Path of dotfiles repository";
      default = config.homePath + "/.config/system";
    };

    dotsRepo = lib.mkOption {
      type = lib.types.str;
      description = "Link to dotfiles repository HTTPS URL";
    };

    unfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of unfree packages to allow";
      default = [ ];
    };

    insecurePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of insecure packages to allow";
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
      # retrieves package object based on string name
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfreePackages;

      # pin a state version to prevent warnings
      home-manager.users.${config.user}.home.stateVersion = stateVersion;
      home-manager.users.root.home.stateVersion = stateVersion;
    };
}
