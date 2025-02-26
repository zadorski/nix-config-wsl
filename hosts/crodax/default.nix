{
  inputs,
  globals,
  overlays,
}:

let
  system = "x86_64-linux";
in
inputs.nixpkgs.lib.nixosSystem {
  inherit system;

  modules = [
    ../../modules/common
    (
      globals
      // rec {
        homePath = "/home/${globals.user}";
      }
    )
    inputs.wsl.nixosModules.wsl
    inputs.nix-ld.nixosModules.nix-ld
    inputs.home-manager.nixosModules.home-manager
    {
      # FIXME: why?
      # replace config with our directory, as it's sourced on every launch
      system.activationScripts.configDir.text = ''
        rm -rf /etc/nixos
        ln --symbolic --no-dereference --force /home/zab/system /etc/nixos
      '';

      networking.hostName = "crodax"; # FIXME: pull dir name

      theme = {
        colors = (import ../../modules/common/ricing/colorscheme/gruvbox-dark).dark;
        dark = true;
      };

      # wsl specific
      wsl = {
        enable = true;
        defaultUser = globals.user;
        docker-desktop.enable = true;
        wslConf.network.generateResolveConf = true; # turn off if it breaks vpn
        interop.includePath = false; # including windows PATH will slow down other systems, filesystem cross talk
      };
      
      programs.nix-ld.dev.enable = true; # for vscode server remote to work

      # programs
      alacritty.enable = false;

      # dev toolchain
      toolchain.nix.enable = true;
      toolchain.misc-tooling.enable = false;
      toolchain.kubernetes.enable = false;
      toolchain.infrastructure-as-code.enable = false;
      toolchain.rust.enable = false;
      toolchain.dotnet.enable = false;

      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      system.stateVersion = "24.05"; # pin state version #FIXME: move
    }
  ];
}
