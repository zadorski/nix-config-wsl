{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {

    # nice list of options:
    # https://mynixos.com/nix-darwin/options
    services.nix-daemon.enable = true;

    environment.shells = [ pkgs.fish ];

    security.pam.enableSudoTouchIdAuth = true;

    system = {

      stateVersion = 5;

      defaults = {
        dock = {
          # automatically show and hide the dock
          autohide = true;

          # add translucency in dock for hidden applications
          showhidden = true;

          # enable spring loading on all dock items
          enable-spring-load-actions-on-all-items = true;

          # highlight hover effect in dock stack grid view
          mouse-over-hilite-stack = true;

          mineffect = "genie";
          orientation = "left";
          show-recents = false;
          tilesize = 44;

          persistent-apps = [
            "/Applications/1Password.app"
            "${pkgs.alacritty}/Applications/Alacritty.app"
          ];
        };
      };
    };

    # fix 'Error: HOME is set to "/var/root" but we expect "/var/empty"'
    home-manager.users.root.home.homeDirectory = lib.mkForce "/var/root";
  };
}
