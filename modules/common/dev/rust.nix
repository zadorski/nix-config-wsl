{
  config,
  pkgs,
  lib,
  ...
}:

{
  options.toolchain.rust.enable = lib.mkEnableOption "Rust dev language toolchain";

  config = lib.mkIf config.toolchain.rust.enable {
    home-manager.users.${config.user} = {

      programs.fish.shellAbbrs = {
        ca = "cargo";
      };

      home.packages = with pkgs; [
        cargo
        rustc
        clippy
        gcc
      ];
    };
  };
}
