{ pkgs, config, ... }:
{
  home.packages = with pkgs; [ starship ];

  # ref:: https://github.com/petertriho/nix-config
  #xdg.configFile."starship.toml".source = config.lib.meta.mkDotfilesSymlink "starship/starship.toml";
}
