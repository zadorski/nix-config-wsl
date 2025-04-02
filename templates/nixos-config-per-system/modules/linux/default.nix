# import all linux modules :
{ lanzaboote, ... }:
{
  imports = [
    ./core.nix
    #./update
    #lanzaboote.nixosModules.lanzaboote # dependency
  ];
}