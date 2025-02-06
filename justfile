default:
  just --list

# update the lockfile of this configuration flake
update:
  nix flake update

# format the source files of this configuration flake
fmt:
  nix fmt

# check the source files of this configuration flake for error-free evaluation
check:
  nix flake check
  statix check

# apply this configuration flake to the current NixOS system
switch-system: fmt check
  nixos-rebuild switch --use-remote-sudo --flake .#wsl-nixos

# apply this configuration flake to your user
switch-home: fmt check
  home-manager switch --flake .#paz@wsl-nixos

# opens the sops secret file in the default console editor
edit-secrets:
  nix-shell -p sops --run "sops secrets/secrets.yaml"
