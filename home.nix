{ config, pkgs, ... }: 

{
  home.username = "paz";
  #home.homeDirectory = lib.mkForce "/home/paz/";
  
  home.packages = with pkgs;[
    wget
    git
    vim
    eza
  ];

  programs.git = {
    enable = true;
    userName = "";  # FIXME
    userEmail = ""; # FIXME
  };

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}