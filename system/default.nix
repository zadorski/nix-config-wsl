{ pkgs, ... }:

{
  imports = [
    ./wsl.nix
    ./vscode-server.nix
    ./nix.nix
    ./users.nix
    ./ssh.nix
    ./shells.nix
    ./certificates.nix
  ];

  system = {
    stateVersion = "24.05";
  };

  #networking.hostName = "${specialArgs.hostName}";
  
  environment.systemPackages = with pkgs; [ # $ nix search wget
    git
    curl
    wget
  ];

  programs = {
  };
}