{ nixpkgs, nixpkgs-stable, home-manager, nixos-wsl, system, hostname, ... }@inputs:

let
  username = "paz";
  
  specialArgs = inputs // {
    pkgs-stable = import nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
    nixpkgs.config.allowUnfree = true; # allow unfree software to be installed
    inherit username; # inherit variables defined above
  };

  configuration =
    { pkgs, config, ... }: # inline module
    {
      environment.systemPackages = with pkgs; [ 
        git
        neovim        
        xdg-utils # wsl-specific
        wslu # wsl-specific
      ];
    };
in

nixpkgs.lib.nixosSystem {
  inherit specialArgs;
  
  modules = [
    configuration # install packages in operating system

    ../modules/nix.nix
    ../modules/users.nix
    ../modules/docker.nix
    ../modules/security/sops

    nixos-wsl.nixosModules.default # windows subsystem for linux
    {
      wsl.enable = true;
      wsl.defaultUser = username;
      system.stateVersion = "24.05";
      networking.hostName = hostname;
    }

    home-manager.nixosModules.home-manager # home manager as module
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users.${username} = import ../home;
      home-manager.extraSpecialArgs = specialArgs;
    }
  ];
}
