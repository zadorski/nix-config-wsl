{ pkgs, ... }:

{
  # make shells available system-wide (adds them to /etc/shells)
  environment.shells = with pkgs; [
    bash  # POSIX-compliant shell, stable and reliable for scripts
    fish  # user-friendly interactive shell with good defaults
  ];

  # enable fish system-wide to ensure proper PATH and nix integration
  programs.fish.enable = true;

  # set bash as the default login shell (recommended for WSL compatibility, for scripts and fallback)
  # fish is configured as interactive shell in home-manager for better UX  
  # individual users can have fish as their login shell
  users.defaultUserShell = pkgs.bash;
}
