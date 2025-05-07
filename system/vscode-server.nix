{ config, pkgs, lib, vscode-server, ... }:

{
  imports = [
    vscode-server.nixosModules.default
  ];

  # see https://github.com/nix-community/NixOS-WSL/issues/294
  services.vscode-server.enable = true;
    
  environment.systemPackages = [
    pkgs.wget
  ];

  programs.nix-ld.enable = true;
    
  #TODO: add conditional to enable this only on WSL
  wsl = {
    extraBin = with pkgs; [
      { src = "${coreutils}/bin/cat"; }
      { src = "${coreutils}/bin/date"; }
      { src = "${coreutils}/bin/dirname"; }
      { src = "${coreutils}/bin/id"; }
      { src = "${coreutils}/bin/mkdir"; }
      { src = "${coreutils}/bin/mv"; }
      { src = "${coreutils}/bin/readlink"; }
      { src = "${coreutils}/bin/rm"; }
      { src = "${coreutils}/bin/sleep"; }
      { src = "${coreutils}/bin/uname"; }
      { src = "${coreutils}/bin/wc"; }
      { src = "${findutils}/bin/find"; }
      { src = "${gnutar}/bin/tar"; }
      { src = "${gzip}/bin/gzip"; }
    ];
  };

  #services.vscode-server.settings = {
  #  "terminal.integrated.shell.linux" = "${pkgs.zsh}/bin/zsh";
  #};
}