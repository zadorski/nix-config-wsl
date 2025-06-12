{ pkgs, ... }:

{
  # import all system configuration modules
  imports = [
    ./wsl.nix           # enable WSL container
    ./nix.nix           # general nix package manager settings
    ./users.nix         # set user accounts and home-manager
    ./shells.nix        # system-wide shell config
    ./ssh.nix           # ssh daemon and git integration
    ./certificates.nix  # corporate certificate management
    ./docker.nix        # docker containerization support
    ./vscode-server.nix # support vscode remote server         
  ];

  system = {
    stateVersion = "24.05"; # system initial release, no need to update (for backwards compatibility)
  };

  # system essentials available to all users
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
    micro # simple text editor
  ];

  # system-wide program configurations
  programs = {};
}