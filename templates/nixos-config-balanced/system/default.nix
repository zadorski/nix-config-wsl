{ pkgs, pkgs-stable, ... }:

{
  imports = [
    ./nix.nix
    ./users.nix
    ./ssh.nix
    ./shells.nix
    ./fonts.nix
    #./python.nix
    ./docker.nix
  ];
  
  environment.systemPackages = with pkgs; [ # $ nix search wget
    # helix # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    git
    git-lfs
    psmisc  # killall/pstree/prtstat/fuser/...
    tldr # simple man pages
    dig # DNS lookup tool

    # archive
    ouch
    zip
    xz
    unzip
    p7zip
    zstd
    gnutar

    # dev
    # nodejs
    nodePackages.nodejs
    nodePackages.npm
    typescript
    yarn
    # c
    cmake
    # python
    conda
    
    # used by pyppeteer
    pkgs-stable.chromium
  ];

  programs = {
    adb.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };
  };
}