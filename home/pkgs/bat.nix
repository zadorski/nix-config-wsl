{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ bat ];

  # ref:: https://github.com/petertriho/nix-config
  #xdg.configFile."bat".source = config.lib.meta.mkDotfilesSymlink "bat/.config/bat";
}
