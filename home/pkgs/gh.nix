{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ gh gh-dash ];

  # ref:: https://github.com/petertriho/nix-config
  #xdg.configFile."gh/config.yml".source =
  #  config.lib.meta.mkDotfilesSymlink "gh/.config/gh/config.yml";
}
