{
  description = "WSL flake + vscode remote + fish";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

  inputs.home-manager.url = "github:nix-community/home-manager/release-24.11";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nixos-wsl.url = "github:nix-community/nixos-wsl";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

  inputs.sops-nix.url = "github:mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";

  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  inputs.catppuccin.url = "github:catppuccin/nix";

  #inputs.nix-ld-rs.url = "github:nix-community/nix-ld-rs"; 
  #inputs.nix-ld-rs.inputs.nixpkgs.follows = "nixpkgs";

  #inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  #inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  #inputs.nur.url = "github:nix-community/nur";

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixos-wsl,
    home-manager,
    ...
  } @inputs: let
    inherit (self) outputs;
    username = "paz";
    system = "x86_64-linux";
    systemname = "crodax";
    
    # ref:: https://github.com/kylejamesross/flake
    #unstable = import nixpkgs-unstable {
    #  inherit system;
    #  config.allowUnfree = true;
    #};
    #specialArgs = { inherit nixpkgs inputs username unstable; };
    
    specialArgs = { inherit inputs outputs username systemname; };

    # ref:: https://github.com/Berberer/wsl-nixos-config
    nixpkgsConfig = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true;
      };
      overlays = [
        (_final: prev: {
          unstable = import nixpkgs-unstable {
            inherit (prev) system;
            inherit (prev) config;
          };
        })
      ];
    };
  in {
    formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;

    #homeConfigurations.${username}@${systemname} = home-manager.lib.homeManagerConfiguration {           # switch user configs without root (standalone home-manager)
    #  pkgs = nixpkgsConfig;
    #  extraSpecialArgs = { inherit inputs outputs; };
    #  modules = [
    #    ./users/admin
    #  ];
    #};

    nixosConfigurations.${systemname} = nixpkgs.lib.nixosSystem {
      pkgs = nixpkgsConfig;
      #specialArgs = { inherit inputs outputs; };
      inherit specialArgs;
      modules = [
        nixos-wsl.nixosModules.wsl
        ./hosts/wsl
        home-manager.nixosModules.home-manager                                                            # use home-manager as system module (entire config via single switch)
        { 
          home-manager.extraSpecialArgs = specialArgs; 
          #home-manager.sharedModules = [
          #  inputs.sops-nix.homeManagerModules.sops
          #];
        }
        ./users/admin
      ];
    };

  };
}
