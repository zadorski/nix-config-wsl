{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.toolchain.misc-tooling.enable = lib.mkEnableOption "Miscellaneous tools for development";

  config = lib.mkIf config.toolchain.misc-tooling.enable {
    home-manager.users.${config.user}.home.packages = [
      # advanced tool for diffing files and directories
      # has quite a load of dependencies, > 250 direct
      # pkgs.diffoscope # Fails to compile on aarch64-darwin
      pkgs.diffoscopeMinimal
    ];
  };
}
