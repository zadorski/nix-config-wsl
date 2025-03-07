{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.toolchain.diffoscope.enable = lib.mkEnableOption "Miscellaneous tools for development";

  config = lib.mkIf config.toolchain.diffoscope.enable {
    home-manager.users.${config.user}.home.packages = [
      # advanced tool for diffing files and directories
      # has quite a load of dependencies, > 250 direct
      pkgs.diffoscope # fails to compile on aarch64-darwin
      pkgs.diffoscopeMinimal
    ];
  };
}
