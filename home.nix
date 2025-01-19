{ config, pkgs, ... }: 

{
  home.username = "paz";                                        # be sure to update username
  #home.homeDirectory = lib.mkForce "/home/paz/";
  
  home.packages = with pkgs;[
    wget
    git
    vim
    eza
  ];

  programs.git = {
    enable = true;
    userName = "";                                              # FIXME: git name
    userEmail = "";                                             # FIXME: git email
  };

  home.stateVersion = "24.05";                                  # important: keep the value set upon installation

  programs.home-manager.enable = true;
}