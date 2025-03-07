{
  config,
  pkgs,
  lib,
  ...
}:

{
  # homebrew: mac-specific packages that aren't in Nix
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # requires Homebrew to be installed
    system.activationScripts.preUserActivation.text = ''
      if ! xcode-select --version 2>/dev/null; then
        $DRY_RUN_CMD xcode-select --install
      fi
      if ! /opt/homebrew/bin/brew --version 2>/dev/null; then
        $DRY_RUN_CMD /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
    '';

    # add homebrew paths to CLI path
    home-manager.users.${config.user}.home.sessionPath = [ "/opt/homebrew/bin/" ];

    homebrew = {
      enable = true;
      onActivation = {
        autoUpdate = false; # don't update during rebuild
        cleanup = "zap"; # uninstall all programs not declared
        upgrade = true;
      };

      global = {
        brewfile = true; # run brew bundle from anywhere
        lockfiles = false; # don't save lockfile (since running from anywhere)
      };

      brews = [
        "trash" # delete files and folders to trash instead of rm
      ];

      casks = [
        "1password" # 1Password will not launch from Nix on macOS
        "orbstack" # container runtime for MacOS
      ];
    };
  };
}
