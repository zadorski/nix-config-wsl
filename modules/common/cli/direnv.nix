{ config, ... }:

{
  # enables quickly entering Nix shells when changing directories
  home-manager.users.${config.user}.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      whitelist = {
        prefix = [ config.dotsPath ];
      };
      # disable environment variable diff dump
      # nix environment variables are just too noisy
      hide_env_diff = true;
    };
  };

  # prevent garbage collection
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
}
