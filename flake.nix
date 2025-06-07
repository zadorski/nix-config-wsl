{
  description = "WSL NixOS Flake";

  outputs = inputs: with inputs; with nixpkgs.lib;  # check duration of `nix flake check` without both `with` statements
  {
    nixosConfigurations.nixos = nixosSystem rec {   # evaluate via `nixos-rebuild switch .#nixos`
      modules = [ ./system ];                       # imports `nixos-wsl.nixosModules.wsl` and single host config
      system = "x86_64-linux";
        
      specialArgs = inputs // rec {                 # pass named inputs to modules + shared const values 
        #hostName = "nixos";
        userName = "nixos";
        gitEmail = "678169+${gitHandle}@users.noreply.github.com";
        gitHandle = "zadorski";

        pkgs-stable = import nixpkgs-stable {
          inherit system;
          config.allowUnfree = true;
        };
      };
    };
  };

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-24.11";    
    # follows https://github.com/nix-community/NixOS-WSL/issues/294
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";     
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    vscode-server.url = "github:nix-community/nixos-vscode-server";    
    # useful nushell scripts, such as auto_completion
    nushell-scripts.url = "github:nushell/nu_scripts";
    nushell-scripts.flake = false;
    # color scheme
    catppuccin-btop.url = "github:catppuccin/btop";
    catppuccin-btop.flake = false;
    catppuccin-bat.url = "github:catppuccin/bat";
    catppuccin-bat.flake = false;
    catppuccin-starship.url = "github:catppuccin/starship";
    catppuccin-starship.flake = false;
  };

  # the nix config here affects the flake itself only, not the system configuration
  nixConfig.experimental-features = ["nix-command" "flakes"];
}
