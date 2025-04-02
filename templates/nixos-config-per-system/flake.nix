# credits:: https://github.com/MadMcCrow/nixos-configuration/blob/main/flake.nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, ... }: 
  let 
    lib = nixpkgs.lib;

    systems = import ./systems inputs;

    withSystem = lib.genAttrs [ "x86_64-linux" ];
    
    withPkgs = callback:
      withSystem (system:
        callback nixpkgs.legacyPackages.${system}
      );    
  in 
  {    
    inherit (systems) nixosConfigurations;
    packages = withPkgs (pkgs: pkgs.callPackages ./packages { });    
  };
}
