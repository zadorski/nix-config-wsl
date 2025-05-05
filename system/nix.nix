{ config, lib, pkgs, ... }:

{
  # allow unfree packages.
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  # garbage collection.
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 1w";
  };

  nix.settings = {
    # manual optimise storage: nix-store --optimise
    # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
    auto-optimise-store = true;
    experimental-features = [ "nix-command" "flakes" ];
  };

  # set your time zone.
  time.timeZone = "Europe/Berlin";
}