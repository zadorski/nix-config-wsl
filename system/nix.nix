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

    # eliminate redundant warnings and prompts for development efficiency
    warn-dirty = false;  # suppress git dirty tree warnings during development
    accept-flake-config = true;  # automatically accept flake configuration without prompting

    # configure SSL certificate handling for Nix operations
    # ensures that Nix can download packages through corporate proxies
    ssl-cert-file = lib.mkDefault "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

    # performance optimizations for development workflow
    max-jobs = "auto";  # use all available CPU cores for builds
    cores = 0;  # use all available CPU cores per job

    # development-friendly settings
    keep-outputs = true;  # keep build outputs for debugging
    keep-derivations = true;  # keep derivations for development

    # allow all users in wheel group to use Nix without confirmation prompts
    trusted-users = [ "root" "@wheel" ];
  };

  # set your time zone - change this to your local timezone
  time.timeZone = "Europe/Berlin";
}
