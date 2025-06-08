{ nixos-wsl, ... }:

{
  #<nixpkgs/nixos/modules/virtualisation/wsl.nix>     
  imports = [ nixos-wsl.nixosModules.wsl ]; 

  wsl.enable = true;
}