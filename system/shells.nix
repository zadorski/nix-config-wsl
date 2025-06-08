{ pkgs, ... }:

{
  # add user's shell into /etc/shells
  environment.shells = with pkgs; [
    bash
    fish
  ];

  # set user's default shell system-wide
  users.defaultUserShell = pkgs.bash; # wsl recommends bash or dash for login shell
}
