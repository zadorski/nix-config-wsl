<<<<<<< HEAD
{
  outputs = {
    self,
    nixpkgs,
    nixos-wsl,
    home-manager,
    ...
  } @ inputs: {
    nixosConfigurations = {
      crodax = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {inherit inputs;};
        modules = [
          nixos-wsl.nixosModules.default
          {
            wsl.defaultUser = "paz"; # be sure to update username
            nix.settings.experimental-features = ["nix-command" "flakes"];
            system.stateVersion = "24.05"; # important: keep the value set upon installation
            wsl.enable = true;
          }
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true; # it allows the home-manager setup to activate properly inside a `nixos-rebuild build-vm` (helping to avoid `nix-env` like the plague, per https://discourse.nixos.org/t/need-configuration-feedback-and-tips-and-question-about-managing-shell-scripts/17232/3)
            home-manager.users.paz = import ./home.nix; # be sure to update username
            #home-manager.extraSpecialArgs = inputs;            # why?
          }
        ];
      };
    };
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # prefer rolling release
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager"; #url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nixos-wsl.url = "github:nix-community/nixos-wsl/main";
  };
}
||||||| empty tree
=======
{
  description = "Tiny NixOS config: WSL2 dev + cloud VPS + Sops-nix secrets";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.home-manager.url = "github:nix-community/home-manager/release-23.11";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nur.url = "github:nix-community/NUR";

  inputs.nixos-wsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-index-database.url = "github:Mic92/nix-index-database";
  inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  inputs.disko.url = "github:nix-community/disko";
  inputs.disko.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs:
    with inputs; let
      secrets = builtins.fromJSON (builtins.readFile "${self}/secrets.json");

      nixpkgsWithOverlays = with inputs; rec {
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [];     # add any insecure packages you absolutely need here
        };
        overlays = [
          nur.overlay
          (_final: prev: {
            # this allows us to reference pkgs.unstable
            unstable = import nixpkgs-unstable {
              inherit (prev) system;
              inherit config;
            };
          })
        ];
      };

      configurationDefaults = args: {
        nixpkgs = nixpkgsWithOverlays;
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-backup";
        home-manager.extraSpecialArgs = args;
      };

      argDefaults = {
        inherit secrets inputs self nix-index-database;
        channels = {
          inherit nixpkgs nixpkgs-unstable;
        };
      };

      mkNixosConfiguration = {
        system ? "x86_64-linux",
        hostname,
        username,
        args ? {},
        modules,
      }: let
        specialArgs = argDefaults // {inherit hostname username;} // args;
      in
        nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules =
            [
              (configurationDefaults specialArgs)
              home-manager.nixosModules.home-manager
            ]
            ++ modules;
        };
    in {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.alejandra;
      
      nixosConfigurations.dev-laptop-wsl = mkNixosConfiguration {
        hostname = "dev-laptop-wsl";    # development
        username = "paz";
        modules = [
          nixos-wsl.nixosModules.wsl
          ./nixos/base.nix
          ./nixos/wsl-specific.nix
          ./nixos/dev-specific.nix
        ];
      };

      nixosConfigurations.gate-cloud-vps = mkNixosConfiguration {
        hostname = "gate-cloud-vps";    # services
        username = "paz";
        modules = [
          disko.nixosModules.disko
          ./nixos/base.nix
          ./nixos/vps-specific.nix
          ./nixos/dev-specific.nix
        ];
      };

      nixosConfigurations.media-desktop-vm = mkNixosConfiguration {
        hostname = "media-desktop-vm";    # proxmox
        username = "paz";
        modules = [
          ./nixos/base.nix
        ];
      };
    };
}
>>>>>>> 7e15d5ddcdd7006eb29875697ae1dd2f0a2065ce
