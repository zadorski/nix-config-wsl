{ config, pkgs, ... }:
{
  home.packages = with pkgs; [ vivid ];

  # ref:: https://github.com/petertriho/nix-config
  #xdg.configFile."vivid".source = config.lib.meta.mkDotfilesSymlink "vivid/.config/vivid";
}
