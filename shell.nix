# ref:: https://github.com/Misterio77/nix-config/blob/main/shell.nix
#{ pkgs ? import <nixpkgs> {}, ... }: 

# ref:: https://github.com/jiaqiwang969/nix-config/blob/dev/shell.nix
{ 
  pkgs ? # if pkgs is not defined, instantiate nixpkgs from locked commit
  let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
  import nixpkgs { overlays = [ ]; }, 
  ... 
}:

{
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";
    nativeBuildInputs = with pkgs; [
      nix
      home-manager
      git

      just
      pre-commit

      sops
      ssh-to-age      
      age
      gnupg
    ];
  };
}