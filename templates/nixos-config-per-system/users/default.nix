{ config, home-manager, hostSpec, ... }:

{
  imports = [ 
    home-manager.nixosModules.home-manager 
  ];

  home-manager.enable = true; # let HM manage itself

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.extraSpecialArgs = { inherit hostSpec; };
  home-manager.users.${hostSpec.user} = ./home.nix;      
}