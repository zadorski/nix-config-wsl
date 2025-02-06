{ inputs, config, pkgs, ... }:
let
  stable-packages = with pkgs; [
    tree
    unzip
    zip
    just
    statix
    wsl-open
  ];

  unstable-packages = with pkgs.unstable ; [
    devenv

    #jetbrains.idea-ultimate
    #jetbrains.rust-rover
    #jetbrains.pycharm-professional
    #jetbrains.webstorm
  ];

in
{
  imports = [
    inputs.vscode-server.nixosModules.home

    ../../modules/home-manager/sops
    ../../modules/home-manager/git
    ../../modules/home-manager/starship
  ];

  home = {
    username = "paz";
    homeDirectory = "/home/paz";

    sessionVariables.EDITOR = "nano";

    packages = stable-packages ++ unstable-packages;

    stateVersion = "23.11";
  };

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      experimental-features = nix-command flakes
      !include ${config.sops.secrets.nix_conf_include_access_tokens.path}
    '';
  };

  programs = {
    home-manager.enable = true;
    htop.enable = true;
    ssh.enable = true;

    readline.enable = true;
    readline.variables.completion-ignore-case = true;      

    bash.enable = true;

    direnv.enable = true;
    direnv.enableBashIntegration = true;
    direnv.nix-direnv.enable = true;
  };

  services.vscode-server.enable = true;

}