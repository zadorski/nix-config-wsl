{ username, ... }:

{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";
  home.enableNixpkgsReleaseCheck = false;

  imports = [ 
    ./base.nix
    ./dev.nix 
  ];
}
