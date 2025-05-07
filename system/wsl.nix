{ nixos-wsl, userName, ... }: 

{
  #<nixpkgs/nixos/modules/virtualisation/wsl.nix>     
  imports = [ nixos-wsl.nixosModules.wsl ]; 

  wsl.enable = true;
  #wsl.defaultUser = userName; # moved to users.nix  
}