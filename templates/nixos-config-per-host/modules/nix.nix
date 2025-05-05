{ system, username, ... }:

{
  nixpkgs.hostPlatform = system; # the platform the configuration will be used on
  nix.settings.experimental-features = [ "nix-command" "flakes" ]; # enable experimental features
  
  environment.variables = { # set system-wide environment variables (need system reboot to take effect)
    EDITOR = "nvim";
    ZK_SHELL = "bash";
    SHELL = "/etc/profiles/per-user/${username}/bin/nu";
  };

  nix.optimise.automatic = true; # optimize storage
}
