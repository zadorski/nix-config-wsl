{ self, nixpkgs, nixos-wsl, nixos-hardware, home-manager, ... }:
let
  hostRoles = list: map (x: self + "/modules/${x}") list; # load option respective to host profile
  
  mkNixosSystem =
    hostModules: # pass nixpkgs-stable for server: { hostModules, nixpkgs ? nixpkgs, system ? "x86_64-linux", }: 
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; #inherit system;
      specialArgs = { inherit hostRoles nixpkgs nixos-wsl nixos-hardware home-manager; };
      modules = [
        #../modules/wsl # WSL as nixos option
        hostModules
        (self + /users)
        /*
        (_: {
          # to enable it for all users
          home-manager.sharedModules = [
            #sops.homeManagerModules.default
          ];
        })
        */
      ];
    };
in
{
  wsl = mkNixosSystem ./wsl.nix;
}