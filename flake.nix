{
  description = "NixOS-WSL flake with sane modular configuration";

  # supported systems
  
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
  
  inputs.nixos-wsl.url = "github:nix-community/nixos-wsl";
  inputs.nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  
  # services and programs
  
  inputs.sops-nix.url = "github:mic92/sops-nix";
  inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  #inputs.neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

  inputs.catppuccin.url = "github:catppuccin/nix";

  #inputs.nix-ld-rs.url = "github:nix-community/nix-ld-rs"; 
  #inputs.nix-ld-rs.inputs.nixpkgs.follows = "nixpkgs";

  #inputs.nix-index-database.url = "github:nix-community/nix-index-database";
  #inputs.nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

  #inputs.nur.url = "github:nix-community/nur";

  # ref:: https://github.com/petertriho/nix-config
  #inputs.nix-darwin.url = "github:LnL7/nix-darwin";
  #inputs.nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

  outputs = inputs@{ self, nixpkgs, nixpkgs-stable, nixos-wsl, nix-darwin, home-manager, ... }: 

  let
    inherit (self) outputs;
    system = "x86_64-linux";
    
    # ref:: https://github.com/petertriho/nix-config
    mkHostConfig = system: {
      inherit system;
      specialArgs = { inherit inputs outputs; };
    };        
  in 
  
  {
    overlays = import ./overlays { inherit inputs; };
    systemModules = import ./modules/system;
    homeManagerModules = import ./modules/home-manager;

    options = {
      user = "paz";    
    };

    nixosConfigurations = {
      crodax = nixpkgs.lib.nixosSystem (
        mkHostConfig "x86_64-linux"
        // {
          modules = [ ./systems/nixos/wsl.nix ];
        }
      );
    };

    #formatter.${system} = nixpkgs.legacyPackages.${system}.nixpkgs-fmt;    
  };
}
