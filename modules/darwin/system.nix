{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {

    # Nice list of options:
    # https://mynixos.com/nix-darwin/options
    services.nix-daemon.enable = true;

    environment.shells = [ pkgs.fish ];

    security.pam.enableSudoTouchIdAuth = true;

    system = {

      stateVersion = 5;

      defaults = {
        dock = {
          # Automatically show and hide the dock
          autohide = true;

          # Add translucency in dock for hidden applications
          showhidden = true;

          # Enable spring loading on all dock items
          enable-spring-load-actions-on-all-items = true;

          # Highlight hover effect in dock stack grid view
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

    # Fix for: 'Error: HOME is set to "/var/root" but we expect "/var/empty"'
    home-manager.users.root.home.homeDirectory = lib.mkForce "/var/root";
  };
}
