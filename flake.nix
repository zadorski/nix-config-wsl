{
  description = "WSL development environment";

  outputs = inputs: with inputs; with nixpkgs.lib;
  {
    # build with: nixos-rebuild switch --flake .#nixos
    nixosConfigurations.nixos = nixosSystem rec {
      modules = [ ./system ];  # load system configuration modules
      system = "x86_64-linux"; # WSL architecture

      # shared configuration values passed to all modules
      specialArgs = inputs // rec {
        userName = "nixos";  # change this to your preferred username
        gitEmail = "678169+${gitHandle}@users.noreply.github.com";
        gitHandle = "zadorski";  # change this to your GitHub username
      };
    };
  };

  inputs = {
    # safe to use unstable for latest features
    nixpkgs.url = "nixpkgs/nixos-unstable";

    # essential for WSL functionality
    nixos-wsl.url = "github:nix-community/NixOS-WSL";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager for user-level configuration
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # devenv for project-specific development environments
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";

    # vscode remote server support for WSL development
    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # catppuccin themes for dark mode compatibility
    catppuccin-starship.url = "github:catppuccin/starship";
    catppuccin-starship.flake = false;
    catppuccin-lazygit.url = "github:catppuccin/lazygit";
    catppuccin-lazygit.flake = false;
    catppuccin-bat.url = "github:catppuccin/bat";
    catppuccin-bat.flake = false;
    catppuccin-fzf.url = "github:catppuccin/fzf";
    catppuccin-fzf.flake = false;    
    catppuccin-btop.url = "github:catppuccin/btop";
    catppuccin-btop.flake = false;    
  };

  # the nix config here affects the flake itself only, not the system configuration
  nixConfig.experimental-features = ["nix-command" "flakes"];
}
