{ pkgs, ... }:

{
  imports = [
    ./wsl.nix
    ./vscode-server.nix
    ./nix.nix
    ./users.nix
    ./shells.nix
    ./ssh.nix
  ];

  system = {
    stateVersion = "24.05";
  };

  #networking.hostName = "${specialArgs.hostName}";
  
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
  ];

  programs = {};
}