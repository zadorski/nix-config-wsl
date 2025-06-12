{ config, lib, pkgs, ... }:

{
  # allow installation of proprietary software (nvidia drivers, etc.)
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # automatic garbage collection to keep disk usage manageable
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";  # run weekly cleanup
    options = lib.mkDefault "--delete-older-than 1w";  # remove generations older than 1 week
  };

  nix.settings = {
    # automatically optimize nix store to save disk space
    # manually run: nix-store --optimise
    auto-optimise-store = true;

    # enable modern Nix features (required for flakes)
    experimental-features = [ "nix-command" "flakes" ];

    # configure SSL certificate handling for Nix operations
    # ensures that Nix can download packages through corporate proxies
    ssl-cert-file = lib.mkDefault "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
  };

  # set your time zone - change this to your local timezone
  time.timeZone = "Europe/Berlin";
}