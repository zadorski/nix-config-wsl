{
  description = "Declarative Dimension of WSL";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";             # manage linux systems
    
  #inputs.darwin.url = "github:lnl7/nix-darwin/master";                   # manage macOS systems
  #inputs.darwin.inputs.nixpkgs.follows = "nixpkgs";

  inputs.wsl.url = "github:nix-community/NixOS-WSL";                      # manage wsl systems
  inputs.wsl.inputs.nixpkgs.follows = "nixpkgs";
  
  inputs.home-manager.url = "github:nix-community/home-manager/master";   # manage home dirs
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
  inputs.nix-ld.url = "github:Mic92/nix-ld";                              # manage apps requiring dynamically linked libraries 
  inputs.nix-ld.inputs.nixpkgs.follows = "nixpkgs";                       # (e.g. vscode server in wsl)

  outputs = inputs@ { self, nixpkgs, ... }:

  let
    # common values sourced by other files
    globals =
      let
        handle = "zadorski";
      in
      rec {
        user = "paz";
        gitName = handle;
        gitEmail = "678169+${handle}@users.noreply.github.com";
      };

    # modifications to the declared inputs
    overlays = [ ];

    # helpers for generating attribute sets across systems
    withSystem = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      #"x86_64-darwin"
      #"aarch64-linux"
      #"aarch64-darwin"
    ];

    withPkgs =
      callback:
      withSystem (
        system:
        callback (
          import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          }
        )
      );
  in
  {
    # full NixOS builds
    nixosConfigurations = {
      crodax = import ./hosts/crodax { inherit inputs globals overlays; }; # wsl
    };

    # full macOS builds
    #darwinConfigurations = {
    #  lupus = import ./hosts/lupus { inherit inputs globals overlays; };
    #  minmus = import ./hosts/minmus { inherit inputs globals overlays; };
    #};

    # standalone applications
    packages = { };

    # dev environments via "nix develop"
    devShells = withPkgs (pkgs: {
      # for working on this repo
      default = pkgs.mkShell {
        packages = [
          pkgs.git
          pkgs.vim
        ];
      };
    });

    # for formatting the repo via "nix fmt"
    formatter = withPkgs (pkgs: pkgs.nixfmt-rfc-style);
  };
   
}

/*
{
  description = "Nix-based config";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable-small";
  inputs.nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11-small";
  inputs.nixos-hardware.url = "github:nixos/nixos-hardware"; 

  inputs.nixgl.url = "github:nix-community/nixGL";
  inputs.nixos-wsl.url = "github:nix-community/nixos-wsl";
  
  # home-manager has its own pkgs, so let it follow flake's nixpkgs
  # NB: no need to do the same for all inputs, as it might slowdown build due to lack of cache
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs"; 
  
  inputs.ragenix.url = "github:yaxitech/ragenix";
  inputs.ragenix.inputs.nixpkgs.follows = "nixpkgs";
  
  #inputs.sops-nix.url = "github:mic92/sops-nix";
  #inputs.sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  #inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

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

  outputs = inputs@{ self, nixpkgs, ... }: let
    # credits:: https://github.dev/BestPlagueDoctor/dotfiles
    config = {
      allowUnfree = true;
      contentAddressedByDefault = false;
    };
    
    overlays = []; # inputs.emacs-overlay.overlays.default

    forAllSystems = f: nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] 
      ( system: f system ( import nixpkgs { inherit system config overlays; } ));

    root = ./.;
    user = {
      login = "paz";
      name = "zadorski";
      email = "";
    };

    baseModules = [
      { _module.args = {inherit inputs root user; }; }
      { nixpkgs = { inherit config overlays; }; }
    ];

    homeManagerModules = baseModules;

    modules = homeManagerModules ++ [
      inputs.home-manager.nixosModules.home-manager
      inputs.ragenix.nixosModules.default
      #inputs.lanzaboote.nixosModules.lanzaboote
      #inputs.disko.nixosModules.disko
      ./modules
    ];

  in {
    nixosConfigurations = {
      crodax = nixpkgs.lib.nixosSystem {
        modules = modules ++ [
          inputs.nixos-wsl.nixosModules.default
          ./hosts/crodax
        ];
      };
    };

    homeConfigurations = forAllSystems (system: pkgs: with pkgs; {
      default = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = homeManagerModules ++ [ 
	        { nixpkgs = { inherit config overlays; }; }
	        ./home 
          {
            home = {
              homeDirectory = "/home/${user.login}";
              username = "${user.login}";
            };
          }
	      ];
        extraSpecialArgs = {
          stateVersion = "24.05";
          host.headless = false;
          host.nixpkgs = pkgs;
        };
      };
    });

    devShells = forAllSystems (system: pkgs: with pkgs; {
      default = mkShell {
        packages = [
          #inputs.deploy-rs.packages.${system}.default
          nix-output-monitor
          nvd
          openssl
        ];

        shellHook = ''
          export PATH=$PWD/util:$PATH
        '';
      };
    });

    # ref:: https://github.com/nullishamy/derivation-station
    #devShell = let
    #  pkgs = inputs.nixpkgs.legacyPackages.${system};
    #  unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
    #in
    #  pkgs.mkShell {
    #    inherit (self.checks.${system}.pre-commit-check) shellHook;
    #    packages = with pkgs; [
    #      unstable.just
    #      sops
    #      nixpkgs-fmt
    #      nix-output-monitor
    #      nvd
    #      nixd
    #    ];
    #  };
    #});
  };
}
*/




/*
let
  inherit (self) outputs;

  systems = [
    "x86_64-linux"
  ];

  forAllSystems = nixpkgs.lib.genAttrs systems;

  # Extend the library with custom functions
  extendedLib = nixpkgs.lib.extend (
    self: super: {
      custom = import ./lib { inherit (nixpkgs) lib; };
    }
  );
in
{
  # Enables `nix fmt` at root of repo to format all nix files
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  nixosConfigurations = {
    legion = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
        lib = extendedLib; # Use the extended library
      };
      modules = [ ./hosts/nixos/legion ];
    };
    servox = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
        lib = extendedLib; # Use the extended library
      };
      modules = [ ./hosts/nixos/servox ];
    };
    think = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs;
        lib = extendedLib; # Use the extended library
      };
      modules = [ ./hosts/nixos/think ];
    };
  };
};
*/
