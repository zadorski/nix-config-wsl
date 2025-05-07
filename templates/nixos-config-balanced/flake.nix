{
  description = "WSL NixOS Flake";

  outputs = inputs @ { 
    self,
    nixpkgs,
    nixpkgs-stable,
    nixos-wsl,
    home-manager,
    vscode-server,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";      
      specialArgs = inputs // rec {
        #hostName = "nixos";
        userName = "nixos";
        gitEmail = "678169+${gitHandle}@users.noreply.github.com";
        gitHandle = "zadorski";
        
        pkgs-stable = import nixpkgs-stable {
          system = system;
          config.allowUnfree = true;
        };
      };

      modules = [
        nixos-wsl.nixosModules.wsl {
          wsl.defaultUser = "${specialArgs.userName}";
        }

        ./system

        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = specialArgs;
            users."${specialArgs.userName}" = import ./home;
          };
        }

        vscode-server.nixosModules.default
        ({ pkgs, ... }: {
          system = {
            stateVersion = "24.05";
          };

          # see https://github.com/nix-community/NixOS-WSL/issues/294
          programs.nix-ld.enable = true;
          services.vscode-server.enable = true;
          environment.systemPackages = [
            pkgs.wget
          ];

          #networking.hostName = "${specialArgs.hostName}";

          wsl = {
            enable = true;
            defaultUser = "${specialArgs.userName}";
            extraBin = with pkgs; [
              { src = "${coreutils}/bin/cat"; }
              { src = "${coreutils}/bin/date"; }
              { src = "${coreutils}/bin/dirname"; }
              { src = "${findutils}/bin/find"; }
              { src = "${coreutils}/bin/id"; }
              { src = "${coreutils}/bin/mkdir"; }
              { src = "${coreutils}/bin/mv"; }
              { src = "${coreutils}/bin/readlink"; }
              { src = "${coreutils}/bin/rm"; }
              { src = "${coreutils}/bin/sleep"; }
              { src = "${coreutils}/bin/uname"; }
              { src = "${coreutils}/bin/wc"; }
              { src = "${gnutar}/bin/tar"; }
              { src = "${gzip}/bin/gzip"; }
            ];
          };
        })
      ];
    };
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.11";
    
    # follows https://github.com/nix-community/NixOS-WSL/issues/294
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs"; 
    };
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    
    # useful nushell scripts, such as auto_completion
    nushell-scripts = {
      url = "github:nushell/nu_scripts";
      flake = false;
    };

    # color scheme
    catppuccin-btop = {
      url = "github:catppuccin/btop";
      flake = false;
    };
    catppuccin-bat = {
      url = "github:catppuccin/bat";
      flake = false;
    };
    catppuccin-starship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
  };

  # the nix config here affects the flake itself only, not the system configuration
  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
  };
}
