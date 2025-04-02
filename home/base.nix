{ pkgs, ... }:

{  
  imports = [
    ./git
    ./gpg
    ./bash
    ./btop
    ./yazi
    ./nvim
    ./nushell
    ./starship
  ];

  home.packages = with pkgs; [    
    home-manager # manage itself

    docker-compose
    git-lfs
    clang
    tree
    file
    unzip
    curl

    sops
    age
  ];
}
