{
  config,
  pkgs,
  lib,
  ...
}:
{
  options = {
    _1password = {
      enable = lib.mkEnableOption {
        description = "Enable 1Password CLI";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config._1password.enable) {
    home-manager.users.${config.user} = {
      programs._1password.enable = true;
    };
  };
}
