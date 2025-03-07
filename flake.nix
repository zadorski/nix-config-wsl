{
  description = "Declarative Dimension of WSL";

  outputs =
    inputs@{ self, nixpkgs, ... }: # inputs are external dependencies, whereas outputs become public API

    let
      globals = # common values for flake modules
        let
          handle = "zadorski";
        in
        rec {
          user = "paz";
          host = "crodax";
          fullName = handle;
          gitName = fullName;
          gitEmail = "678169+${handle}@users.noreply.github.com";

          homePath = "/home/${user}";
          dotsPath = "${homePath}/.config/system"; # non-NixOS usage included
          dotsRepo = "https://github.com/${handle}/nix-config-wsl";
        };

      overlays = [
        # common overlays for flake inputs
        #inputs.nur.overlays.default
      ];

      withSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" ]; # generate attrset for all supported platforms

      #withPkgs = withSystem (system: import inputs.nixpkgs { inherit system; });
      #let pkgs = nixpkgsFor.${system}; in
      #runtimeInputs = with pkgs; [ git ];

      withPkgs = # forAllSystems (system: let pkgs = import nixpkgs { inherit system overlays; }; in ...);
        callback: # ref:: https://github.com/LarsGKodehode/nix.system
        withSystem (
          system:
          callback (
            import nixpkgs {
              inherit system overlays; # added overlays here ref:: https://github.com/nmasur/dotfiles (compare w/https://github.com/librephoenix/nixos-config)
              config.allowUnfree = true;
            }
          )
        );

    in
    rec {
      # ref:: https://github.com/guilherme-romanholo/nixdots/blob/main/flake.nix
      #inherit (self) outputs;
      #lib = nixpkgs.lib // home-manager.lib; # define lib to use in flake

      nixosConfigurations = {
        ${globals.host} = import ./hosts/${globals.host} { inherit inputs globals overlays; }; # nixos-rebuild switch --flake .#crodax
      };

      homeConfigurations = {
        ${globals.user} =
          nixosConfigurations.${globals.host}.config.home-manager.users.${globals.user}.home; # home-manager switch --flake .#paz
      };

      packages = { }; # package specific config as standalone

      #diskoConfigurations = { root = import ./disks/root.nix; }; # disk formatting, only used once

      devShells = withPkgs (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            git
            nixfmt-rfc-style
            shfmt # formats shell scripts
            shellcheck # static analysis for shell scripts
          ]; # see the repo description about buildInputs
        }; # for working on this repo
      }); # dev environments via "nix develop"

      formatter = withPkgs (pkgs: pkgs.nixfmt-rfc-style); # for formatting the repo via "nix fmt"
    };

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable"; # manage linux systems

  inputs.wsl.url = "github:nix-community/NixOS-WSL"; # manage wsl systems
  inputs.wsl.inputs.nixpkgs.follows = "nixpkgs";

  inputs.home-manager.url = "github:nix-community/home-manager/master"; # manage home dirs
  inputs.home-manager.inputs.nixpkgs.follows = "nixpkgs";

  inputs.nix-ld.url = "github:Mic92/nix-ld"; # manage apps requiring dynamically linked libraries
  inputs.nix-ld.inputs.nixpkgs.follows = "nixpkgs"; # (e.g. vscode server in wsl)

  inputs.stylix.url = "github:danth/stylix";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";

  inputs.gh-collaborators.url = "github:katiem0/gh-collaborators"; # gh CLI extension to list and manage repository (outside) collaborators
  inputs.gh-collaborators.flake = false;

  inputs.osc.url = "github:theimpostor/osc/v0.4.6"; # clipboard over SSH
  inputs.osc.flake = false;
}
