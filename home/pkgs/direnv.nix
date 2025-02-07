{ config, ... }:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  home.sessionVariables.DIRENV_LOG_FORMAT = "";

  # ref:: https://github.com/petertriho/nix-config
  #xdg.configFile."direnv/direnvrc".source = config.lib.meta.mkDotfilesSymlink "direnv/.config/direnv/direnvrc";  
}
