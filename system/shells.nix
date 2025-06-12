{ pkgs, ... }:

{
  # make shells available system-wide (adds them to /etc/shells)
  environment.shells = with pkgs; [
    bash  # POSIX-compliant shell, stable and reliable
    fish  # user-friendly interactive shell with good defaults
  ];

  # set bash as the default login shell (recommended for WSL compatibility)
  # fish is configured as interactive shell in home-manager for better UX
  users.defaultUserShell = pkgs.bash;
}
