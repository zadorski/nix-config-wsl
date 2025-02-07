{ outputs, lib, user, homePath, ... }:
{
  imports = [
    outputs.homeManagerModules.helpers
    ./pkgs/bat.nix
    ./pkgs/devenv.nix
    ./pkgs/devops.nix
    ./pkgs/direnv.nix
    ./pkgs/fish.nix
    ./pkgs/gh.nix
    ./pkgs/git.nix
    ./pkgs/ripgrep.nix
    ./pkgs/starship.nix
    ./pkgs/tools.nix
    ./pkgs/yazi.nix
    #./pkgs/k8s.nix
    #./pkgs/neovim.nix
    #./pkgs/scripts.nix
    #./pkgs/tmux.nix
    #./pkgs/vivid.nix
  ];

  home = {
    username = user;
    homeDirectory = homePath;
    stateVersion = lib.mkDefault "24.05";
  };

  programs.home-manager.enable = true;
}
