{
  description = "WSL minimal flake";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.nix-ld-rs.url = "github:nix-community/nix-ld-rs"; # this is forgivable for WSL
  inputs.nix-ld-rs.inputs.nixpkgs.follows = "nixpkgs";
  inputs.nixoswsl.url = "github:nix-community/NixOS-WSL";
  inputs.nixoswsl.inputs.nixpkgs.follows = "nixpkgs";
  inputs.home-manager.url = "github:nix-community/home-manager";
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";
  inputs.vscode-server.url = "github:nix-community/nixos-vscode-server";
  inputs.vscode-server.inputs.nixpkgs.follows = "nixpkgs";

  outputs = {
    nixpkgs,
    nixoswsl,
    home-manager,
    vscode-server,
    ...
  }: let
    username = "paz";
    systemname = "crodax";
  in {
    nixosConfigurations.${systemname} = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixoswsl.nixosModules.wsl
        vscode-server.nixosModules.default
        home-manager.nixosModules.home-manager
        # homemanager inline
        (
          {pkgs, ...}: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.${username} = {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              home.stateVersion = "24.05";
              home.packages = [
                pkgs.alejandra # nix formatter
                pkgs.nil # nix language server
              ];
              home.file = {
                vscode = {
                  target = ".vscode-server/server-env-setup";
                  text = ''
                    # make sure that basic commands are available
                    PATH=$PATH:/run/current-system/sw/bin/
                  '';
                };
              };
              programs.home-manager.enable = true;
            };
          }
        )
        # wsl inline
        (
          {pkgs, ...}: {
            wsl = {
              enable = true;
              defaultUser = username;
            };
          }
        )
        # nixos inline
        (
          {pkgs, ...}: {
            system = {
              stateVersion = "24.05";
            };
            environment.systemPackages = with pkgs; [
              btop
              htop
              wget
              jq
              yq-go
              dnsutils
            ];
            nix = {
              settings.experimental-features = ["nix-command" "flakes"];
              gc.automatic = true;
              gc.options = "--delete-older-than 14d";
            };
            networking.hostName = systemname;
          }
        )
        # vscode remoting inline
        (
          {pkgs, ...}: {
            programs.nix-ld.enable = true;
            services.vscode-server.enable = true;
          }
        )
      ];
    };
  };
}
