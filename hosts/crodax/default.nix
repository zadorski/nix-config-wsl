{ inputs, globals, overlays, ... }:

with inputs;

nixpkgs.lib.nixosSystem rec { # ref:: https://github.com/nmasur/dotfiles

  system = "x86_64-linux"; # keys are mutually visible in definitions within this record (thanks to rec)

  modules = [
    ../../modules/common
    ../../modules/wsl # FIXME: move wsl-specific code into module?
    
    globals
    # overrule gitname and gitemail for work
    #(
    #  globals
    #  // rec {
    #    homePath = "/home/${globals.user}";
    #  }
    #)
    
    nixos-wsl.nixosModules.wsl
    nix-ld.nixosModules.nix-ld
    home-manager.nixosModules.home-manager
    
    {
      networking.hostName = "crodax"; # FIXME: pull dir name

      theme = {
        colors = (import ../../modules/common/ricing/colorscheme/gruvbox-dark).dark;
        dark = true;
      };

      #modules.wsl = {
      #  enable = true;
      #  defaultUser = globals.user;        
      #};

      wsl = {
        enable = true;
        defaultUser = globals.user;
        startMenuLaunchers = true;
        usbip.enable = true;
        #docker-desktop.enable = true; # integration with docker desktop (needs to be installed)
        wslConf.automount.root = "/mnt";
        wslConf.network.generateHosts = false;
        wslConf.network.generateResolveConf = true; # disable because it breaks tailscale ref:: https://github.com/kgadberry/dotfiles/blob/main/hosts/cerberus/default.nix
        interop.includePath = false; # including windows PATH will slow down other systems, filesystem cross talk ref:: https://github.com/nmasur/dotfiles/blob/master/hosts/hydra/default.nix                        
      };

      programs.nix-ld.dev.enable = true; # for vscode server remote to work

      # programs
      alacritty.enable = false;

      # dev toolchain
      toolchain.nix.enable = true;
      toolchain.diffoscope.enable = false;
      toolchain.kubernetes.enable = false;
      toolchain.infrastructure-as-code.enable = false;
      toolchain.rust.enable = false;
      toolchain.dotnet.enable = false;

      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      system.stateVersion = "24.05"; # pin state version
    }
  ];
}
