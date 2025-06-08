{ nixos-wsl, ... }:

{
  #<nixpkgs/nixos/modules/virtualisation/wsl.nix>     
  imports = [ nixos-wsl.nixosModules.wsl ]; 

  wsl.enable = true;

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  security.pki.certificateFiles = [
    ../certs/zscaler.pem
  ];
}