{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = {
    home-manager.users.${config.user} = {

      programs.bash = {
        enable = true;
        shellAliases = config.home-manager.users.${config.user}.programs.fish.shellAliases;
        initExtra = "";
        profileExtra = "";
      };

      programs.starship.enableBashIntegration = false;
    };
  };
}
