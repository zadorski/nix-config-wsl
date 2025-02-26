{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.toolchain.nix.enable = lib.mkEnableOption "Nix Language toolchain";

  config = lib.mkIf config.toolchain.nix.enable {
    home-manager.users.${config.user} = {

      home.packages = with pkgs; [
        nil # Nix Language Server
      ];

      home.sessionVariables = { };
    };
  };
}
